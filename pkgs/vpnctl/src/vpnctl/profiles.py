from __future__ import annotations

import re
import tomllib
from pathlib import Path
from typing import Any, cast

import tomli_w

from .models import Profile, ProfileType

DEFAULT_PATH = Path.home() / ".config" / "vpnctl" / "profiles.toml"

# Profiles added at runtime (Noctalia panel "add source", `vpnctl add-source`).
# DEFAULT_PATH is a home-manager-generated symlink into /nix/store and can't
# be written to -- this is the writable counterpart merged in alongside it.
EXTRA_PATH = Path.home() / ".local" / "state" / "vpnctl" / "profiles.toml"


class ProfilesError(RuntimeError):
    pass


def _default_interface(name: str, ptype: ProfileType) -> str:
    # awg-quick names the interface after the config file stem (must stay
    # <=15 chars, the Linux IFNAMSIZ limit -- that's on the profile author).
    # sing-box profiles are mutually exclusive by design, so one fixed tun
    # name for all of them is fine.
    if ptype is ProfileType.AMNEZIA:
        return name
    return "sing-tun0"


def _load_raw(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    with path.open("rb") as f:
        data = tomllib.load(f)
    return cast(list[dict[str, Any]], data.get("profile", []))


def load(path: Path | None = None) -> list[Profile]:
    path = path or DEFAULT_PATH
    if not path.exists():
        raise ProfilesError(f"profiles file not found: {path}")

    tagged = [(raw, False) for raw in _load_raw(path)] + [
        (raw, True) for raw in _load_raw(EXTRA_PATH)
    ]

    seen: set[str] = set()
    result: list[Profile] = []
    for raw, dynamic in tagged:
        try:
            name = raw["name"]
            ptype = ProfileType(raw["type"])
            unit = raw["unit"]
            config_path = raw["config_path"]
        except (KeyError, ValueError) as e:
            raise ProfilesError(f"invalid profile entry {raw!r}: {e}") from e

        if name in seen:
            raise ProfilesError(f"duplicate profile name: {name}")
        seen.add(name)

        result.append(
            Profile(
                name=name,
                type=ptype,
                unit=unit,
                config_path=config_path,
                interface=raw.get("interface") or _default_interface(name, ptype),
                subscription_source=raw.get("subscription_source"),
                subscription_selector=raw.get("subscription_selector"),
                subscription_url=raw.get("subscription_url"),
                subscription_index=raw.get("subscription_index"),
                dynamic=dynamic,
            )
        )
    return result


def find(profs: list[Profile], name: str) -> Profile:
    for p in profs:
        if p.name == name:
            return p
    raise ProfilesError(f"no such profile: {name}")


def remnawave_defaults(path: Path | None = None) -> dict[str, Any]:
    path = path or DEFAULT_PATH
    if not path.exists():
        return {}
    with path.open("rb") as f:
        data = tomllib.load(f)
    return cast(dict[str, Any], data.get("remnawave", {}))


def _profile_to_raw(p: Profile) -> dict[str, Any]:
    raw: dict[str, Any] = {
        "name": p.name,
        "type": p.type.value,
        "unit": p.unit,
        "config_path": p.config_path,
        "interface": p.interface,
    }
    if p.subscription_source is not None:
        raw["subscription_source"] = p.subscription_source
    if p.subscription_selector is not None:
        raw["subscription_selector"] = p.subscription_selector
    if p.subscription_url is not None:
        raw["subscription_url"] = p.subscription_url
    if p.subscription_index is not None:
        raw["subscription_index"] = p.subscription_index
    return raw


def add_profile(profile: Profile) -> None:
    """Append `profile` to the writable extra-profiles store (EXTRA_PATH)."""
    existing = _load_raw(EXTRA_PATH)
    if any(r.get("name") == profile.name for r in existing):
        raise ProfilesError(f"duplicate profile name: {profile.name}")

    existing.append(_profile_to_raw(profile))
    EXTRA_PATH.parent.mkdir(parents=True, exist_ok=True)
    EXTRA_PATH.write_text(tomli_w.dumps({"profile": existing}), encoding="utf-8")


def remove_profile(name: str) -> None:
    """Remove `name` from the writable extra-profiles store (EXTRA_PATH).

    Only ever touches EXTRA_PATH -- there is no such thing as removing a
    declarative (home-manager) profile at runtime.
    """
    existing = _load_raw(EXTRA_PATH)
    remaining = [r for r in existing if r.get("name") != name]
    if len(remaining) == len(existing):
        raise ProfilesError(f"no such dynamic profile: {name}")
    EXTRA_PATH.write_text(tomli_w.dumps({"profile": remaining}), encoding="utf-8")


def _slugify(text: str, max_len: int, fallback: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return (slug or fallback)[:max_len]


def unique_name(seed: str, existing: set[str], max_len: int = 32, fallback: str = "profile") -> str:
    """A filesystem/interface-safe name derived from `seed`, not in `existing`.

    `fallback` is used when `seed` has no ASCII alphanumerics to slugify --
    e.g. a Cyrillic-only subscription server name -- so unrelated sources
    don't all collapse into "profile", "profile-2", etc.
    """
    base = _slugify(seed, max_len, fallback)
    if base not in existing:
        return base
    for i in range(2, 1000):
        suffix = f"-{i}"
        candidate = base[: max_len - len(suffix)] + suffix
        if candidate not in existing:
            return candidate
    raise ProfilesError(f"could not generate a unique name from '{seed}'")
