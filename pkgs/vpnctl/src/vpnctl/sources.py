"""Registering and removing the VPN profiles vpnctl manages dynamically at
runtime (`add-source` / `remove-source` / `remove-group`), as opposed to
profiles.py, which only reads and writes the profiles.toml store those
profiles are recorded into.

Nothing here prints or calls sys.exit -- these functions raise on failure
(amnezia.AmneziaLinkError, unitctl.UnitError, profiles.ProfilesError, OSError,
ValueError) and take optional progress callbacks; the CLI layer decides how
to report both.
"""

from __future__ import annotations

from collections.abc import Callable
from pathlib import Path

from . import amnezia, lock, profiles, remnawave, singbox, unitctl
from .models import Profile, ProfileType

AMNEZIA_CONFIG_DIR = Path("/etc/amnezia/amneziawg")
SINGBOX_CONFIG_DIR = Path("/etc/sing-box/configs")


def register_amnezia(
    link: str, name_override: str | None, existing: set[str]
) -> Profile:
    """Decode an AmneziaVPN vpn:// link, write its .conf, and register it as
    a new Profile. Raises amnezia.AmneziaLinkError or OSError."""
    decoded = amnezia.decode_link(link)
    name = name_override or profiles.unique_name(
        decoded.host or "amnezia", existing, max_len=15, fallback="amnezia"
    )
    config_path = AMNEZIA_CONFIG_DIR / f"{name}.conf"
    config_path.parent.mkdir(parents=True, exist_ok=True)
    config_path.write_text(decoded.conf_text, encoding="utf-8")

    return Profile(
        name=name,
        type=ProfileType.AMNEZIA,
        unit=f"awg-quick@{name}.service",
        config_path=str(config_path),
        interface=name,
    )


def register_remnawave(
    link: str,
    name_override: str | None,
    existing: set[str],
    hwid: str | None,
    on_skip: Callable[[str, str], None] | None = None,
) -> list[Profile]:
    """Fetch a Remnawave subscription and register every usable server as its
    own profile. `on_skip(server_name, reason)` is called for each server
    build_config can't handle, without aborting the rest of the batch.

    Raises ValueError if --name is used against a multi-server subscription,
    or if no server produced a usable profile at all.
    """
    sub = remnawave.fetch_and_parse(link, hwid=hwid)
    matches = remnawave.pick_endpoints(sub, selector=None)
    if not matches:
        raise ValueError(
            f"subscription has no usable endpoints{remnawave.no_endpoint_hint(sub)}"
        )

    if name_override and len(matches) > 1:
        raise ValueError(
            f"--name doesn't apply here: this subscription has {len(matches)} usable "
            "servers, each needs its own name"
        )

    new_profiles: list[Profile] = []
    for index, (chosen, endpoint) in enumerate(matches):
        try:
            singbox.build_config(endpoint, interface_name="sing-tun0")
        except ValueError as e:
            if on_skip is not None:
                on_skip(chosen.name or "(unnamed)", str(e))
            continue

        name = name_override or profiles.unique_name(
            chosen.name or "remnawave", existing, max_len=32, fallback="remnawave"
        )
        existing.add(name)  # reserve so two servers in this subscription can't collide
        config_path = SINGBOX_CONFIG_DIR / f"{name}.json"
        singbox.write_config(config_path, endpoint, interface_name="sing-tun0")

        new_profiles.append(
            Profile(
                name=name,
                type=ProfileType.SINGBOX,
                unit=f"sing-box@{name}.service",
                config_path=str(config_path),
                interface="sing-tun0",
                subscription_source="remnawave",
                subscription_url=link,
                subscription_selector=chosen.name or None,
                subscription_index=index,
            )
        )

    if not new_profiles:
        raise ValueError("no server produced a usable config")
    return new_profiles


def remove_dynamic_profile(
    target: Profile,
    stop_timeout: float = 10.0,
    on_stop: Callable[[], None] | None = None,
) -> None:
    """Stop `target` if active, delete its config file, and deregister it.

    Raises unitctl.UnitError/RuntimeError or profiles.ProfilesError on
    failure -- callers decide whether that aborts immediately (a single
    remove-source) or just marks one item failed in a batch (remove-group).
    """
    if unitctl.is_active(target.unit) == "active":
        if on_stop is not None:
            on_stop()
        with lock.exclusive():
            unitctl.stop_and_wait(target.unit, timeout=stop_timeout)

    Path(target.config_path).unlink(missing_ok=True)
    profiles.remove_profile(target.name)
