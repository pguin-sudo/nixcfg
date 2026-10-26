"""Fetching a Remnawave-style VLESS+Reality subscription and turning it into
a sing-box client config.

Understands the three body formats these panels commonly return: a raw
Xray-JSON config array, a single sing-box-style JSON object with
"outbounds", or a base64/plain-text list of vless:// URIs. Only the fields
needed to build a sing-box client outbound are extracted.
"""

from __future__ import annotations

import base64
import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any
from urllib.error import URLError
from urllib.parse import parse_qs, unquote, urlparse
from urllib.request import Request, urlopen

# Sent as the x-hwid header with every subscription request -- some panels
# gate by device/HWID limit. Not a secret, just an identifier other clients
# also use; override by editing this constant if a panel rejects it.
HWID = "asdfghjkasdfghjkl"

_PLACEHOLDER_UUID = "00000000-0000-0000-0000-000000000000"
_PROXY_PROTOCOLS = {"vless", "vmess", "trojan", "shadowsocks"}


@dataclass
class Endpoint:
    protocol: str
    address: str
    port: int
    uuid: str | None = None
    flow: str | None = None
    network: str = "tcp"
    security: str = "none"
    sni: str | None = None
    public_key: str | None = None
    short_id: str | None = None
    fingerprint: str | None = None


@dataclass
class SubProfile:
    name: str
    endpoints: list[Endpoint] = field(default_factory=list)


def fetch(url: str, timeout: int = 15) -> list[SubProfile]:
    headers = {
        "User-Agent": "Happ/1.0",
        "x-device-os": "Android",
        "x-ver-os": "14",
        "x-device-model": "VPNCTL",
        "x-hwid": HWID,
    }
    req = Request(url, headers=headers)
    try:
        with urlopen(req, timeout=timeout) as r:  # noqa: S310 -- panel URL is user-supplied by design
            content_type = r.headers.get("content-type", "")
            body = r.read().decode("utf-8", "ignore")
    except URLError as e:
        raise RuntimeError(f"{e}") from e
    return _parse_body(body, content_type)


def _parse_body(body: str, content_type: str) -> list[SubProfile]:
    text = body.strip()

    if text[:1] in "[{" or "json" in content_type.lower():
        try:
            obj = json.loads(text)
        except json.JSONDecodeError:
            obj = None
        if isinstance(obj, list):
            return [_profile_from_xray(c) for c in obj if isinstance(c, dict)]
        if isinstance(obj, dict) and "outbounds" in obj:
            return [_profile_from_xray(obj)]

    try:
        decoded = _b64decode(text).decode("utf-8", "ignore")
        if "://" in decoded:
            return _profiles_from_uris(decoded)
    except Exception:
        pass

    if "://" in text:
        return _profiles_from_uris(text)

    return []


def pick_endpoints(
    profiles: list[SubProfile], selector: str | None = None
) -> list[tuple[SubProfile, Endpoint]]:
    """All (profile, endpoint) pairs build_config can handle, scoped to
    profiles matching `selector` if given. A single Remnawave subscription
    commonly bundles several servers/nodes."""
    result: list[tuple[SubProfile, Endpoint]] = []
    for prof in profiles:
        if selector is not None and selector.lower() not in prof.name.lower():
            continue
        for ep in prof.endpoints:
            if ep.security == "reality":
                result.append((prof, ep))
    return result


def _looks_like_placeholder(ep: Endpoint) -> bool:
    return (
        ep.address in ("", "0.0.0.0")
        or ep.port in (0, 1)
        or ep.uuid == _PLACEHOLDER_UUID
    )


def no_endpoint_hint(profiles: list[SubProfile]) -> str:
    if any(
        _looks_like_placeholder(ep) for prof in profiles for ep in prof.endpoints
    ):
        return (
            " (this subscription returned a placeholder link, not a real server -- "
            "usually means the device/HWID limit was reached or this client isn't "
            "recognized; check the subscription's device limit, or edit "
            "remnawave.HWID to the value your other client already uses)"
        )
    return ""


def _profile_from_xray(cfg: dict[str, Any]) -> SubProfile:
    endpoints = []
    for ob in cfg.get("outbounds", []):
        ep = _endpoint_from_outbound(ob)
        if ep is not None:
            endpoints.append(ep)
    return SubProfile(name=cfg.get("remarks", "(unnamed)"), endpoints=endpoints)


def _endpoint_from_outbound(ob: dict[str, Any]) -> Endpoint | None:
    proto = ob.get("protocol")
    if proto not in _PROXY_PROTOCOLS:
        return None

    settings = ob.get("settings", {})
    ss = ob.get("streamSettings", {})
    ep = Endpoint(protocol=proto, address="", port=0)

    if proto in ("vless", "vmess"):
        vnext = (settings.get("vnext") or [{}])[0]
        ep.address = vnext.get("address", "")
        ep.port = vnext.get("port", 0)
        user = (vnext.get("users") or [{}])[0]
        ep.uuid = user.get("id")
        ep.flow = user.get("flow") or None

    ep.network = ss.get("network", "tcp")
    ep.security = ss.get("security", "none")

    if ep.security == "reality":
        r = ss.get("realitySettings", {})
        ep.sni = r.get("serverName")
        ep.public_key = r.get("publicKey")
        ep.short_id = r.get("shortId")
        ep.fingerprint = r.get("fingerprint")
    elif ep.security == "tls":
        t = ss.get("tlsSettings", {})
        ep.sni = t.get("serverName")
        ep.fingerprint = t.get("fingerprint")

    return ep


def _b64decode(s: str) -> bytes:
    s = s.strip().replace("-", "+").replace("_", "/")
    s += "=" * (-len(s) % 4)
    return base64.b64decode(s)


def _profiles_from_uris(text: str) -> list[SubProfile]:
    profiles = []
    for line in text.splitlines():
        line = line.strip()
        if not line or "://" not in line:
            continue
        ep, name = _endpoint_from_uri(line)
        if ep:
            profiles.append(SubProfile(name=name, endpoints=[ep]))
    return profiles


def _endpoint_from_uri(uri: str) -> tuple[Endpoint | None, str]:
    scheme = uri.split("://", 1)[0].lower()
    p = urlparse(uri)
    name = unquote(p.fragment) if p.fragment else ""
    q = {k: v[0] for k, v in parse_qs(p.query).items()}

    if scheme != "vless":
        return None, name

    ep = Endpoint(
        protocol="vless",
        address=p.hostname or "",
        port=p.port or 0,
        uuid=unquote(p.username or ""),
        flow=q.get("flow"),
        network=q.get("type", "tcp"),
        security=q.get("security", "none"),
        sni=q.get("sni"),
        public_key=q.get("pbk"),
        short_id=q.get("sid"),
        fingerprint=q.get("fp"),
    )
    return ep, name


# --- sing-box client config -------------------------------------------------


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
    """Build a client config for `ep` and persist it to `path`. Raises
    ValueError from build_config, or OSError on a write failure."""
    cfg = build_config(ep, interface_name=interface_name)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(cfg, indent=2), encoding="utf-8")
