"""Builds and persists sing-box client configs (VLESS+Reality outbound, tun inbound)."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .remnawave import Endpoint


def build_config(ep: Endpoint, interface_name: str = "sing-tun0") -> dict[str, Any]:
    if ep.protocol != "vless":
        raise ValueError(
            f"unsupported protocol '{ep.protocol}' (only vless is supported)"
        )
    if ep.security != "reality":
        raise ValueError(
            f"unsupported security '{ep.security}' (only reality is supported)"
        )

    outbound: dict[str, Any] = {
        "type": "vless",
        "tag": "proxy",
        "server": ep.address,
        "server_port": ep.port,
        "uuid": ep.uuid,
        "packet_encoding": "xudp",
        # sing-box's outbound dialer needs this explicitly since 1.12 dropped
        # the old global domain_strategy; only matters if `server` is a
        # hostname rather than a literal IP.
        "domain_resolver": "remote",
        "tls": {
            "enabled": True,
            "server_name": ep.sni or ep.address,
            "utls": {"enabled": True, "fingerprint": ep.fingerprint or "chrome"},
            "reality": {
                "enabled": True,
                "public_key": ep.public_key or "",
                "short_id": ep.short_id or "",
            },
        },
    }
    if ep.flow:
        outbound["flow"] = ep.flow

    return {
        "log": {"level": "warn"},
        # Full-tunnel: every DNS query (hijacked off the tun via the route
        # rule below) resolves through the remote server, which itself goes
        # out over the tun's default "proxy" route -- no split/local server
        # needed since nothing is meant to bypass the tunnel while connected.
        "dns": {
            "servers": [{"type": "tls", "tag": "remote", "server": "1.1.1.1"}],
            "final": "remote",
            "strategy": "prefer_ipv4",
        },
        "inbounds": [
            {
                "type": "tun",
                "tag": "tun-in",
                "interface_name": interface_name,
                "address": ["172.19.0.1/30"],
                "mtu": 9000,
                "auto_route": True,
                "strict_route": True,
                "stack": "system",
            }
        ],
        "outbounds": [
            outbound,
            {"type": "direct", "tag": "direct"},
        ],
        "route": {
            "auto_detect_interface": True,
            "final": "proxy",
            "rules": [{"protocol": "dns", "action": "hijack-dns"}],
        },
    }


def write_config(path: Path, ep: Endpoint, interface_name: str = "sing-tun0") -> None:
    """Build a client config for `ep` and persist it to `path`, creating parent
    directories as needed. Raises ValueError from build_config, or OSError on
    a write failure -- callers decide how to report either."""
    cfg = build_config(ep, interface_name=interface_name)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(cfg, indent=2), encoding="utf-8")
