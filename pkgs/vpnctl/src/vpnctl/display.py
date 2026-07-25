"""Turning a Profile (plus its live systemd/config-file state) into rows fit
for `vpnctl list`'s table and --json output. Presentation only -- nothing
here decides *which* profiles to show or mutates any state.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

from . import unitctl
from .models import Profile, ProfileType


def server_summary(p: Profile) -> str | None:
    """Best-effort "host:port" peeked from the profile's own config file, for
    display only -- never raises, since a bad/missing file just means no
    summary rather than a broken `list`."""
    try:
        if p.type is ProfileType.SINGBOX:
            cfg = json.loads(Path(p.config_path).read_text(encoding="utf-8"))
            outbound = cfg["outbounds"][0]
            return f"{outbound['server']}:{outbound['server_port']}"
        if p.type is ProfileType.AMNEZIA:
            text = Path(p.config_path).read_text(encoding="utf-8")
            m = re.search(r"^\s*Endpoint\s*=\s*(\S+)", text, re.MULTILINE)
            return m.group(1) if m else None
    except Exception:
        return None
    return None


def profile_row(p: Profile) -> dict[str, Any]:
    state = unitctl.is_active(p.unit)
    group = p.subscription_url or p.name
    group_label = urlparse(p.subscription_url).netloc if p.subscription_url else p.name
    return {
        "name": p.name,
        "type": p.type.value,
        "unit": p.unit,
        "active": state == "active",
        "state": state,
        "dynamic": p.dynamic,
        # Raw server label from the subscription (e.g. "🇩🇪 Германия"), for
        # display -- p.name is a filesystem/unit-safe slug, not meant to be
        # shown to a human.
        "label": p.subscription_selector or p.name,
        "server": server_summary(p),
        "group": group,
        "group_label": group_label,
        "has_subscription": p.subscription_url is not None,
    }
