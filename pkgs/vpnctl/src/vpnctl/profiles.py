"""The Profile model and its two TOML stores.

DEFAULT_PATH is a home-manager-generated symlink into /nix/store (read-only,
possibly absent entirely on a host with no declared profiles). EXTRA_PATH is
the writable counterpart `add-source`/`remove-source` maintain at runtime.
"""

from __future__ import annotations

import os
import re
import tempfile
import tomllib
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any, cast

import tomli_w

DEFAULT_PATH = Path.home() / ".config" / "vpnctl" / "profiles.toml"
EXTRA_PATH = Path.home() / ".local" / "state" / "vpnctl" / "profiles.toml"


class ProfileType(str, Enum):
    AMNEZIA = "amnezia"
    SINGBOX = "singbox"
    IKEV2 = "ikev2"


@dataclass(frozen=True)
class Profile:
    name: str
    type: ProfileType
    unit: str
    config_path: str
    # None for ikev2 -- it has no named interface to probe (strongSwan routes
    # via XFRM policies over the existing default route, not a tun/wg device).
    interface: str | None
    # The server's own display name at add-source time, kept for display --
    # NOT used to re-match the same server later (a subscription can list
    # several servers under the identical name).
    subscription_selector: str | None = None
    subscription_url: str | None = None
    # Position in pick_endpoints()'s flat list at add-source time; sync-source
    # re-fetches the whole subscription and re-matches by this index, since
    # names alone aren't unique enough.
    subscription_index: int | None = None
    # True for profiles vpnctl itself registered (add-source), living in the
    # writable EXTRA_PATH. False for ones declared in Nix (DEFAULT_PATH) --
    # those can only be changed by editing home/*.nix and rebuilding.
    dynamic: bool = False


class ProfilesError(RuntimeError):
    pass


def _default_interface(name: str, ptype: ProfileType) -> str | None:
    # awg-quick names the interface after the config file stem (must stay
    # <=15 chars, the Linux IFNAMSIZ limit). sing-box profiles are mutually
    # exclusive by design, so one fixed tun name for all of them is fine.
    if ptype is ProfileType.AMNEZIA:
        return name
    if ptype is ProfileType.IKEV2:
        return None
    return "sing-tun0"


def _load_raw(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    with path.open("rb") as f:
        data = tomllib.load(f)
    return cast(list[dict[str, Any]], data.get("profile", []))


def load() -> list[Profile]:
    tagged = [(raw, False) for raw in _load_raw(DEFAULT_PATH)] + [
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


def _profile_to_raw(p: Profile) -> dict[str, Any]:
    raw: dict[str, Any] = {
        "name": p.name,
        "type": p.type.value,
        "unit": p.unit,
        "config_path": p.config_path,
    }
    # TOML has no null -- interface is only absent for ikev2.
    if p.interface is not None:
        raw["interface"] = p.interface
    if p.subscription_selector is not None:
        raw["subscription_selector"] = p.subscription_selector
    if p.subscription_url is not None:
        raw["subscription_url"] = p.subscription_url
    if p.subscription_index is not None:
        raw["subscription_index"] = p.subscription_index
    return raw


def _write_extra(raws: list[dict[str, Any]]) -> None:
    """tempfile + os.replace, so a crash mid-write or two concurrent
    add-source calls can't truncate or corrupt EXTRA_PATH."""
    EXTRA_PATH.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=EXTRA_PATH.parent, prefix=".profiles-")
    try:
        with os.fdopen(fd, "wb") as f:
            tomli_w.dump({"profile": raws}, f)
        os.replace(tmp_path, EXTRA_PATH)
    except BaseException:
        Path(tmp_path).unlink(missing_ok=True)
        raise


def add_profile(profile: Profile) -> None:
    existing = _load_raw(EXTRA_PATH)
    if any(r.get("name") == profile.name for r in existing):
        raise ProfilesError(f"duplicate profile name: {profile.name}")
    existing.append(_profile_to_raw(profile))
    _write_extra(existing)


def remove_profile(name: str) -> None:
    """Only ever touches EXTRA_PATH -- a declarative (Nix) profile can't be
    removed at runtime."""
    existing = _load_raw(EXTRA_PATH)
    remaining = [r for r in existing if r.get("name") != name]
    if len(remaining) == len(existing):
        raise ProfilesError(f"no such dynamic profile: {name}")
    _write_extra(remaining)


def _slugify(text: str, max_len: int, fallback: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return (slug or fallback)[:max_len]


def unique_name(
    seed: str, existing: set[str], max_len: int = 32, fallback: str = "profile"
) -> str:
    """A filesystem/interface-safe name derived from `seed`, not in `existing`.

    `fallback` covers a seed with no ASCII alphanumerics to slugify (e.g. a
    Cyrillic-only server name), so unrelated sources don't all collapse into
    "profile", "profile-2", etc.
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
