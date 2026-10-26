"""vpnctl -- unified control for AmneziaWG, sing-box and IKEv2 VPN profiles.

Argument parsing and output only. profiles.py owns storage, units.py owns
systemctl/ip and locking, remnawave.py owns subscription fetch + sing-box
config generation, amnezia.py decodes vpn:// links.
"""

from __future__ import annotations

import argparse
import json
import re
import socket
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from typing import NoReturn
from urllib.parse import urlparse

from . import amnezia, profiles, remnawave, units
from .profiles import Profile, ProfileType

AMNEZIA_CONFIG_DIR = Path("/etc/amnezia/amneziawg")
SINGBOX_CONFIG_DIR = Path("/etc/sing-box/configs")


def _error(msg: str) -> None:
    print(f"error: {msg}", file=sys.stderr)


def _die(msg: str) -> NoReturn:
    _error(msg)
    sys.exit(1)


def _load() -> list[Profile]:
    try:
        return profiles.load()
    except profiles.ProfilesError as e:
        _die(str(e))


def _find(profs: list[Profile], name: str) -> Profile:
    try:
        return profiles.find(profs, name)
    except profiles.ProfilesError as e:
        _die(str(e))


def _server_summary(p: Profile) -> str | None:
    """Best-effort "host:port" peeked from the profile's own config file --
    never raises, a bad/missing file just means no summary."""
    try:
        if p.type is ProfileType.SINGBOX:
            cfg = json.loads(Path(p.config_path).read_text(encoding="utf-8"))
            outbound = cfg["outbounds"][0]
            return f"{outbound['server']}:{outbound['server_port']}"
        if p.type is ProfileType.AMNEZIA:
            text = Path(p.config_path).read_text(encoding="utf-8")
            m = re.search(r"^\s*Endpoint\s*=\s*(\S+)", text, re.MULTILINE)
            return m.group(1) if m else None
    except (OSError, LookupError, ValueError):
        return None
    return None


def _profile_row(p: Profile, state: str) -> dict[str, object]:
    return {
        "name": p.name,
        "type": p.type.value,
        "unit": p.unit,
        "active": state == "active",
        "state": state,
        "dynamic": p.dynamic,
        # Raw server label from the subscription, for display -- p.name is a
        # filesystem/unit-safe slug, not meant to be shown to a human.
        "label": p.subscription_selector or p.name,
        "server": _server_summary(p),
        "group": p.subscription_url or p.name,
        "group_label": urlparse(p.subscription_url).netloc if p.subscription_url else p.name,
        "has_subscription": p.subscription_url is not None,
        # None = not probed / not checkable; only set by `list --check`.
        "reachable": None,
    }


def _probe(host: str, port: int) -> bool:
    try:
        with socket.create_connection((host, port), timeout=2.0):
            return True
    except OSError:
        return False


def _check_reachable(rows: list[dict[str, object]], profs: list[Profile]) -> None:
    """TCP-probes each singbox profile's server (reusing the host:port
    already read for `server` above) and fills in `reachable` in place.
    amnezia is UDP (a connect() would tell us nothing) and ikev2 has no
    per-profile server -- both are left as None rather than lying."""
    by_name = {r["name"]: r for r in rows}
    targets: dict[str, tuple[str, int]] = {}
    for p in profs:
        if p.type is not ProfileType.SINGBOX:
            continue
        server = by_name[p.name]["server"]
        if not isinstance(server, str):
            continue
        host, _, port = server.rpartition(":")
        if host and port.isdigit():
            targets[p.name] = (host, int(port))

    if not targets:
        return
    with ThreadPoolExecutor(max_workers=len(targets)) as pool:
        futures = {name: pool.submit(_probe, h, p) for name, (h, p) in targets.items()}
        for name, fut in futures.items():
            by_name[name]["reachable"] = fut.result()


def cmd_list(args: argparse.Namespace) -> None:
    profs = _load()
    states = units.is_active_many([p.unit for p in profs])
    rows = [_profile_row(p, states[p.unit]) for p in profs]

    if args.check:
        _check_reachable(rows, profs)

    if args.json:
        print(json.dumps(rows, indent=2))
        return

    print(f"{'NAME':<24}{'TYPE':<10}{'STATUS':<10}" + ("REACHABLE" if args.check else ""))
    for r in rows:
        status = "active" if r["active"] else r["state"]
        line = f"{r['name']:<24}{r['type']:<10}{status:<10}"
        if args.check:
            reach = r["reachable"]
            line += "yes" if reach is True else "no" if reach is False else "n/a"
        print(line)


def cmd_connect(args: argparse.Namespace) -> None:
    profs = _load()
    target = _find(profs, args.name)

    try:
        with units.exclusive():
            for p in profs:
                if p.unit == target.unit:
                    continue
                if units.is_active(p.unit) == "active":
                    print(f"stopping {p.name} ({p.unit})...")
                    units.stop_and_wait(p.unit, timeout=args.stop_timeout)

            print(f"starting {target.name} ({target.unit})...")
            units.start(target.unit, timeout=args.start_timeout)
    except (units.UnitError, RuntimeError) as e:
        _die(str(e))

    print(f"connected: {target.name}")


def cmd_disconnect(args: argparse.Namespace) -> None:
    profs = _load()
    if args.name:
        targets = [_find(profs, args.name)]
    else:
        targets = [p for p in profs if units.is_active(p.unit) == "active"]
        if not targets:
            print("nothing is connected")
            return

    try:
        with units.exclusive():
            for p in targets:
                if units.is_active(p.unit) != "active":
                    continue
                print(f"stopping {p.name} ({p.unit})...")
                units.stop_and_wait(p.unit)
    except (units.UnitError, RuntimeError) as e:
        _die(str(e))

    print("disconnected")


def cmd_status(args: argparse.Namespace) -> None:
    profs = _load()
    active = next((p for p in profs if units.is_active(p.unit) == "active"), None)

    result: dict[str, object]
    if active is None:
        result = {"active": None}
    elif active.interface is None:
        # ikev2: no named interface to probe -- the unit's own active state
        # is the only signal we have.
        result = {
            "active": {
                "name": active.name,
                "type": active.type.value,
                "unit": active.unit,
                "interface": None,
                "link_up": None,
                "has_default_route": None,
            }
        }
    else:
        result = {
            "active": {
                "name": active.name,
                "type": active.type.value,
                "unit": active.unit,
                "interface": active.interface,
                "link_up": units.link_up(active.interface),
                "has_default_route": units.has_default_route(active.interface),
            }
        }

    if args.json:
        print(json.dumps(result))
        return

    if active is None:
        print("disconnected")
        return
    a = result["active"]
    assert isinstance(a, dict)
    if a["interface"] is None:
        print(f"{a['name']} ({a['type']})")
    else:
        link = "up" if a["link_up"] else "down"
        print(f"{a['name']} ({a['type']}) -- link {link}, default route: {a['has_default_route']}")


def cmd_add_source(args: argparse.Namespace) -> None:
    link = args.link.strip()
    existing = {p.name for p in _load()}
    new_profiles: list[Profile]

    if link.startswith("vpn://"):
        try:
            decoded = amnezia.decode_link(link)
        except (amnezia.AmneziaLinkError, OSError) as e:
            _die(str(e))
        name = args.name or profiles.unique_name(
            decoded.host or "amnezia", existing, max_len=15, fallback="amnezia"
        )
        config_path = AMNEZIA_CONFIG_DIR / f"{name}.conf"
        config_path.parent.mkdir(parents=True, exist_ok=True)
        config_path.write_text(decoded.conf_text, encoding="utf-8")
        new_profiles = [
            Profile(
                name=name,
                type=ProfileType.AMNEZIA,
                unit=f"awg-quick@{name}.service",
                config_path=str(config_path),
                interface=name,
            )
        ]

    elif link.startswith("http://") or link.startswith("https://"):
        print("fetching subscription...")
        try:
            subs = remnawave.fetch(link)
        except Exception as e:
            _die(f"failed to fetch subscription: {e}")

        matches = remnawave.pick_endpoints(subs)
        if not matches:
            _die(f"subscription has no usable endpoints{remnawave.no_endpoint_hint(subs)}")
        if args.name and len(matches) > 1:
            _die(
                f"--name doesn't apply here: this subscription has {len(matches)} usable "
                "servers, each needs its own name"
            )

        new_profiles = []
        for index, (chosen, endpoint) in enumerate(matches):
            try:
                remnawave.build_config(endpoint, interface_name="sing-tun0")
            except ValueError as e:
                print(f"warning: skipping '{chosen.name or '(unnamed)'}': {e}")
                continue

            name = args.name or profiles.unique_name(
                chosen.name or "remnawave", existing, max_len=32, fallback="remnawave"
            )
            existing.add(name)  # reserve so two servers in this subscription can't collide
            config_path = SINGBOX_CONFIG_DIR / f"{name}.json"
            remnawave.write_config(config_path, endpoint, interface_name="sing-tun0")

            new_profiles.append(
                Profile(
                    name=name,
                    type=ProfileType.SINGBOX,
                    unit=f"sing-box@{name}.service",
                    config_path=str(config_path),
                    interface="sing-tun0",
                    subscription_url=link,
                    subscription_selector=chosen.name or None,
                    subscription_index=index,
                )
            )
        if not new_profiles:
            _die("no server produced a usable config")
    else:
        _die(
            "link must start with 'vpn://' (AmneziaVPN) or 'http(s)://' (Remnawave subscription)"
        )

    for profile in new_profiles:
        try:
            profiles.add_profile(profile)
        except profiles.ProfilesError as e:
            _die(str(e))
        print(f"added {profile.name} ({profile.type.value})")


def _remove(target: Profile) -> None:
    if units.is_active(target.unit) == "active":
        print(f"stopping {target.name} ({target.unit})...")
        with units.exclusive():
            units.stop_and_wait(target.unit)
    Path(target.config_path).unlink(missing_ok=True)
    profiles.remove_profile(target.name)
    print(f"removed: {target.name}")


def cmd_remove_source(args: argparse.Namespace) -> None:
    profs = _load()
    target = _find(profs, args.name)

    if not target.dynamic:
        _die(
            f"'{args.name}' is declared in Nix (home-manager), not removable at "
            "runtime -- edit home/*.nix and rebuild instead"
        )

    try:
        _remove(target)
    except (units.UnitError, RuntimeError, profiles.ProfilesError) as e:
        _die(str(e))


def cmd_remove_group(args: argparse.Namespace) -> None:
    profs = _load()
    targets = [p for p in profs if p.subscription_url == args.url]
    if not targets:
        _die("no profiles are sourced from that URL")

    non_dynamic = [p.name for p in targets if not p.dynamic]
    if non_dynamic:
        _die(f"{', '.join(non_dynamic)} declared in Nix, not removable at runtime")

    failed = False
    for target in targets:
        try:
            _remove(target)
        except (units.UnitError, RuntimeError, profiles.ProfilesError) as e:
            _error(f"'{target.name}': {e}")
            failed = True

    if failed:
        sys.exit(1)


def cmd_sync_source(args: argparse.Namespace) -> None:
    """Refetch `url` once and refresh every profile sourced from it -- the
    right way to refresh a subscription that bundles several servers,
    instead of re-fetching it once per server."""
    profs = _load()
    targets = [
        p for p in profs if p.type is ProfileType.SINGBOX and p.subscription_url == args.url
    ]
    if not targets:
        _die("no singbox profiles are sourced from that URL")

    print(f"fetching subscription ({len(targets)} profile(s) to refresh)...")
    try:
        subs = remnawave.fetch(args.url)
    except Exception as e:
        _die(f"failed to fetch subscription: {e}")

    matches = remnawave.pick_endpoints(subs)
    if not matches:
        _die(f"subscription has no usable endpoints{remnawave.no_endpoint_hint(subs)}")

    failed = False
    for target in targets:
        idx = target.subscription_index
        if idx is None:
            _error(
                f"skipping '{target.name}': added before per-server sync was supported "
                "-- remove and re-add it to enable refresh"
            )
            failed = True
            continue
        if idx >= len(matches):
            _error(f"'{target.name}': its server is no longer in this subscription")
            failed = True
            continue

        chosen, endpoint = matches[idx]
        try:
            remnawave.write_config(
                Path(target.config_path), endpoint, interface_name=target.interface or "sing-tun0"
            )
        except ValueError as e:
            _error(f"'{target.name}': {e}")
            failed = True
            continue
        print(f"wrote {target.config_path} (server: {chosen.name})")

    if failed:
        sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="vpnctl",
        description="unified control for AmneziaWG, sing-box and IKEv2 VPN profiles",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("list", help="list all registered profiles with their current status")
    p.add_argument("--json", action="store_true", help="machine-readable output")
    p.add_argument(
        "--check",
        action="store_true",
        help="TCP-probe each singbox profile's server; amnezia/ikev2 are left unmarked",
    )
    p.set_defaults(func=cmd_list)

    p = sub.add_parser("connect", help="connect NAME, stopping any other active profile first")
    p.add_argument("name")
    p.add_argument("--stop-timeout", type=float, default=10.0)
    p.add_argument("--start-timeout", type=float, default=60.0)
    p.set_defaults(func=cmd_connect)

    p = sub.add_parser("disconnect", help="disconnect NAME, or whichever profile is active")
    p.add_argument("name", nargs="?")
    p.set_defaults(func=cmd_disconnect)

    p = sub.add_parser("status", help="show the currently active profile")
    p.add_argument("--json", action="store_true")
    p.set_defaults(func=cmd_status)

    p = sub.add_parser(
        "add-source", help="register profile(s) from a subscription URL or an AmneziaVPN vpn:// link"
    )
    p.add_argument("link")
    p.add_argument("--name", help="profile name (auto-generated if omitted)")
    p.set_defaults(func=cmd_add_source)

    p = sub.add_parser("remove-source", help="remove a profile previously added with add-source")
    p.add_argument("name")
    p.set_defaults(func=cmd_remove_source)

    p = sub.add_parser("remove-group", help="remove every profile sourced from a subscription URL")
    p.add_argument("url")
    p.set_defaults(func=cmd_remove_group)

    p = sub.add_parser("sync-source", help="refetch a subscription and refresh every profile from it")
    p.add_argument("url")
    p.set_defaults(func=cmd_sync_source)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
