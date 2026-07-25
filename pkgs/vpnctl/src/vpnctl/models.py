from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class ProfileType(str, Enum):
    AMNEZIA = "amnezia"
    SINGBOX = "singbox"


@dataclass(frozen=True)
class Profile:
    name: str
    type: ProfileType
    unit: str
    config_path: str
    interface: str
    subscription_source: str | None = None
    # The server's own display name at add-source time (e.g. "🇩🇪 Германия"),
    # kept for display -- NOT used to re-match the same server on sync-source,
    # since a subscription can list several servers under the identical name.
    subscription_selector: str | None = None
    subscription_url: str | None = None
    # Position in _pick_endpoints()'s flat list at add-source time. sync-source
    # re-fetches the whole subscription once and re-matches every profile
    # sourced from it by this index, since names alone aren't unique enough.
    subscription_index: int | None = None
    # True for profiles vpnctl itself registered (add-source), living in the
    # writable EXTRA_PATH store. False for profiles declared in the
    # home-manager-generated, read-only DEFAULT_PATH -- those can only be
    # changed by editing features.cli.vpnctl.profiles and rebuilding.
    dynamic: bool = False
