"""Click entry point: argument parsing, rich console output, and exit codes.

All actual VPN/profile logic lives in the other modules (profiles, sources,
remnawave, singbox, amnezia, unitctl, display) -- commands here just call
into them and translate results/exceptions into user-facing output.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

import click
from rich.console import Console
from rich.table import Table

from . import amnezia, display, lock, profiles, remnawave, singbox, sources, unitctl
from .models import Profile, ProfileType

console = Console()
err_console = Console(stderr=True)


@click.group()
@click.option(
    "--profiles-file",
    type=click.Path(path_type=Path),
    default=None,
    help="Override the profiles.toml path (default: ~/.config/vpnctl/profiles.toml).",
)
@click.pass_context
def main(ctx: click.Context, profiles_file: Path | None) -> None:
    """vpnctl -- unified control for AmneziaWG and sing-box VPN profiles."""
    ctx.ensure_object(dict)
    ctx.obj["profiles_file"] = profiles_file


def _load_profiles(ctx: click.Context) -> list[Profile]:
    try:
        return profiles.load(ctx.obj.get("profiles_file"))
    except profiles.ProfilesError as e:
        err_console.print(f"[red]error:[/red] {e}")
        sys.exit(1)


def _find_profile(profs: list[Profile], name: str) -> Profile:
    try:
        return profiles.find(profs, name)
    except profiles.ProfilesError as e:
        err_console.print(f"[red]error:[/red] {e}")
        sys.exit(1)


@main.command("list")
@click.option("--json", "as_json", is_flag=True, help="Machine-readable output.")
@click.pass_context
def list_cmd(ctx: click.Context, as_json: bool) -> None:
    """List all registered profiles with their current status."""
    profs = _load_profiles(ctx)
    rows = [display.profile_row(p) for p in profs]

    if as_json:
        click.echo(json.dumps(rows, indent=2))
        return

    table = Table(title="VPN profiles")
    table.add_column("Name")
    table.add_column("Type")
    table.add_column("Unit")
    table.add_column("Status")
    for r in rows:
        status = "[bold green]active[/bold green]" if r["active"] else r["state"]
        table.add_row(r["name"], r["type"], r["unit"], status)
    console.print(table)


@main.command()
@click.argument("name")
@click.option(
    "--stop-timeout",
    default=10.0,
    type=float,
    help="Seconds to wait for the previously active profile to stop.",
)
@click.pass_context
def connect(ctx: click.Context, name: str, stop_timeout: float) -> None:
    """Connect NAME, stopping any other active profile first."""
    profs = _load_profiles(ctx)
    target = _find_profile(profs, name)

    try:
        with lock.exclusive():
            for p in profs:
                if p.unit == target.unit:
                    continue
                if unitctl.is_active(p.unit) == "active":
                    console.print(f"stopping [yellow]{p.name}[/yellow] ({p.unit})...")
                    unitctl.stop_and_wait(p.unit, timeout=stop_timeout)

            console.print(f"starting [green]{target.name}[/green] ({target.unit})...")
            unitctl.start(target.unit)
    except (unitctl.UnitError, RuntimeError) as e:
        err_console.print(f"[red]error:[/red] {e}")
        sys.exit(1)

    console.print(f"[bold green]connected:[/bold green] {target.name}")


@main.command()
@click.argument("name", required=False)
@click.pass_context
def disconnect(ctx: click.Context, name: str | None) -> None:
    """Disconnect NAME, or whichever profile is currently active if omitted."""
    profs = _load_profiles(ctx)

    if name:
        targets = [_find_profile(profs, name)]
    else:
        targets = [p for p in profs if unitctl.is_active(p.unit) == "active"]
        if not targets:
            console.print("nothing is connected")
            return

    try:
        with lock.exclusive():
            for p in targets:
                if unitctl.is_active(p.unit) != "active":
                    continue
                console.print(f"stopping [yellow]{p.name}[/yellow] ({p.unit})...")
                unitctl.stop_and_wait(p.unit)
    except (unitctl.UnitError, RuntimeError) as e:
        err_console.print(f"[red]error:[/red] {e}")
        sys.exit(1)

    console.print("[bold]disconnected[/bold]")


@main.command()
@click.option("--json", "as_json", is_flag=True, help="Machine-readable output.")
@click.pass_context
def status(ctx: click.Context, as_json: bool) -> None:
    """Show the currently active profile. Fast -- safe to poll every few seconds."""
    profs = _load_profiles(ctx)
    active = next((p for p in profs if unitctl.is_active(p.unit) == "active"), None)

    result: dict[str, Any]
    if active is None:
        result = {"active": None}
    else:
        result = {
            "active": {
                "name": active.name,
                "type": active.type.value,
                "unit": active.unit,
                "interface": active.interface,
                "link_up": unitctl.link_up(active.interface),
                "has_default_route": unitctl.has_default_route(active.interface),
            }
        }

    if as_json:
        click.echo(json.dumps(result))
        return

    if active is None:
        console.print("disconnected")
    else:
        a = result["active"]
        link = "up" if a["link_up"] else "down"
        console.print(
            f"[bold green]{a['name']}[/bold green] ({a['type']}) "
            f"-- link {link}, default route: {a['has_default_route']}"
        )


@main.command("sync-singbox")
@click.argument("name")
@click.option(
    "--url",
    "url_override",
    default=None,
    help="Override the subscription URL for this sync.",
)
@click.pass_context
def sync_singbox_cmd(ctx: click.Context, name: str, url_override: str | None) -> None:
    """Fetch NAME's Remnawave subscription and (re)write its sing-box config."""
    profs = _load_profiles(ctx)
    target = _find_profile(profs, name)

    if target.type is not ProfileType.SINGBOX:
        err_console.print(f"[red]error:[/red] '{name}' is not a singbox profile")
        sys.exit(1)

    defaults = profiles.remnawave_defaults(ctx.obj.get("profiles_file"))
    url = url_override or target.subscription_url or defaults.get("url")
    hwid = defaults.get("hwid")
    if not url:
        err_console.print(
            "[red]error:[/red] no subscription URL configured "
            "(profile.subscription_url or [remnawave].url in profiles.toml)"
        )
        sys.exit(1)

    console.print(f"fetching subscription for [bold]{name}[/bold]...")
    try:
        sub = remnawave.fetch_and_parse(url, hwid=hwid)
    except Exception as e:
        err_console.print(f"[red]error:[/red] failed to fetch subscription: {e}")
        sys.exit(1)

    selector = target.subscription_selector
    match = remnawave.pick_endpoint(sub, selector)
    if match is None:
        hint = f" matching '{selector}'" if selector else ""
        err_console.print(
            f"[red]error:[/red] no usable subscription profile found{hint}{remnawave.no_endpoint_hint(sub)}"
        )
        sys.exit(1)
    chosen, endpoint = match

    path = Path(target.config_path)
    try:
        singbox.write_config(path, endpoint, interface_name=target.interface)
    except ValueError as e:
        err_console.print(f"[red]error:[/red] {e}")
        sys.exit(1)
    console.print(f"[bold green]wrote[/bold green] {path} (server: {chosen.name})")


@main.command("sync-source")
@click.argument("url")
@click.pass_context
def sync_source_cmd(ctx: click.Context, url: str) -> None:
    """Refetch a Remnawave subscription once and refresh every profile sourced from it.

    Unlike sync-singbox (one profile, one fetch each), this hits URL a
    single time and updates every profile whose subscription_url matches --
    the right way to refresh a subscription that bundles several servers,
    instead of re-fetching it once per server.
    """
    profs = _load_profiles(ctx)
    targets = [p for p in profs if p.type is ProfileType.SINGBOX and p.subscription_url == url]
    if not targets:
        err_console.print("[red]error:[/red] no singbox profiles are sourced from that URL")
        sys.exit(1)

    hwid = profiles.remnawave_defaults(ctx.obj.get("profiles_file")).get("hwid")
    console.print(f"fetching subscription ({len(targets)} profile(s) to refresh)...")
    try:
        sub = remnawave.fetch_and_parse(url, hwid=hwid)
    except Exception as e:
        err_console.print(f"[red]error:[/red] failed to fetch subscription: {e}")
        sys.exit(1)

    matches = remnawave.pick_endpoints(sub, selector=None)
    if not matches:
        err_console.print(f"[red]error:[/red] subscription has no usable endpoints{remnawave.no_endpoint_hint(sub)}")
        sys.exit(1)

    failed = False
    for target in targets:
        idx = target.subscription_index
        if idx is None:
            err_console.print(
                f"[yellow]warning:[/yellow] skipping '{target.name}': added before per-server "
                "sync was supported -- remove and re-add it to enable refresh"
            )
            failed = True
            continue
        if idx >= len(matches):
            err_console.print(
                f"[red]error:[/red] '{target.name}': its server "
                f"('{target.subscription_selector}') is no longer in this subscription"
            )
            failed = True
            continue

        chosen, endpoint = matches[idx]
        path = Path(target.config_path)
        try:
            singbox.write_config(path, endpoint, interface_name=target.interface)
        except ValueError as e:
            err_console.print(f"[red]error:[/red] '{target.name}': {e}")
            failed = True
            continue
        console.print(f"[bold green]wrote[/bold green] {path} (server: {chosen.name})")

    if failed:
        sys.exit(1)


@main.command("add-source")
@click.argument("link")
@click.option(
    "--name",
    "name_override",
    default=None,
    help="Profile name to register (auto-generated if omitted; only valid when the "
    "link resolves to a single server).",
)
@click.pass_context
def add_source_cmd(ctx: click.Context, link: str, name_override: str | None) -> None:
    """Register profile(s) from a Remnawave subscription URL or an AmneziaVPN vpn:// link.

    A Remnawave subscription commonly bundles several servers/nodes -- every
    usable one becomes its own profile.
    """
    link = link.strip()
    existing = {p.name for p in _load_profiles(ctx)}

    if link.startswith("vpn://"):
        try:
            new_profiles = [sources.register_amnezia(link, name_override, existing)]
        except (amnezia.AmneziaLinkError, OSError) as e:
            err_console.print(f"[red]error:[/red] {e}")
            sys.exit(1)
    elif link.startswith("http://") or link.startswith("https://"):
        hwid = profiles.remnawave_defaults(ctx.obj.get("profiles_file")).get("hwid")
        console.print("fetching subscription...")

        def _on_skip(server_name: str, reason: str) -> None:
            console.print(f"[yellow]warning:[/yellow] skipping '{server_name}': {reason}")

        try:
            new_profiles = sources.register_remnawave(
                link, name_override, existing, hwid, on_skip=_on_skip
            )
        except (ValueError, OSError) as e:
            err_console.print(f"[red]error:[/red] {e}")
            sys.exit(1)
        except Exception as e:
            err_console.print(f"[red]error:[/red] failed to fetch subscription: {e}")
            sys.exit(1)
    else:
        err_console.print(
            "[red]error:[/red] link must start with 'vpn://' (AmneziaVPN) or 'http(s)://' (Remnawave subscription)"
        )
        sys.exit(1)

    for profile in new_profiles:
        try:
            profiles.add_profile(profile)
        except profiles.ProfilesError as e:
            err_console.print(f"[red]error:[/red] {e}")
            sys.exit(1)
        console.print(f"[bold green]added[/bold green] {profile.name} ({profile.type.value})")


def _remove(target: Profile) -> None:
    def _on_stop() -> None:
        console.print(f"stopping [yellow]{target.name}[/yellow] ({target.unit})...")

    sources.remove_dynamic_profile(target, on_stop=_on_stop)
    console.print(f"[bold]removed:[/bold] {target.name}")


@main.command("remove-source")
@click.argument("name")
@click.pass_context
def remove_source_cmd(ctx: click.Context, name: str) -> None:
    """Remove a profile previously registered with add-source, stopping it first if active."""
    profs = _load_profiles(ctx)
    target = _find_profile(profs, name)

    if not target.dynamic:
        err_console.print(
            f"[red]error:[/red] '{name}' is declared in Nix (home-manager), not "
            "removable at runtime -- edit features.cli.vpnctl.profiles and rebuild instead"
        )
        sys.exit(1)

    try:
        _remove(target)
    except (unitctl.UnitError, RuntimeError, profiles.ProfilesError) as e:
        err_console.print(f"[red]error:[/red] {e}")
        sys.exit(1)


@main.command("remove-group")
@click.argument("url")
@click.pass_context
def remove_group_cmd(ctx: click.Context, url: str) -> None:
    """Remove every profile sourced from a given subscription URL."""
    profs = _load_profiles(ctx)
    targets = [p for p in profs if p.subscription_url == url]
    if not targets:
        err_console.print("[red]error:[/red] no profiles are sourced from that URL")
        sys.exit(1)

    non_dynamic = [p.name for p in targets if not p.dynamic]
    if non_dynamic:
        err_console.print(
            f"[red]error:[/red] {', '.join(non_dynamic)} declared in Nix, not removable at runtime"
        )
        sys.exit(1)

    failed = False
    for target in targets:
        try:
            _remove(target)
        except (unitctl.UnitError, RuntimeError, profiles.ProfilesError) as e:
            err_console.print(f"[red]error:[/red] '{target.name}': {e}")
            failed = True

    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
