"""Fetching and parsing VLESS+Reality subscriptions from Remnawave-style panels.

Understands the three body formats these panels commonly return: a raw
Xray-JSON config array, a single sing-box-style JSON object with
"outbounds", or a base64/plain-text list of vless:// URIs. Only the fields
needed to build a sing-box client outbound are extracted -- this is not a
general subscription parser.
"""

from __future__ import annotations

import base64
import json
from dataclasses import dataclass, field
from typing import Any
from urllib.parse import parse_qs, unquote, urlparse

import requests

_PLACEHOLDER_UUID = "00000000-0000-0000-0000-000000000000"


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


@dataclass
class Subscription:
    profiles: list[SubProfile] = field(default_factory=list)


def fetch_and_parse(
    url: str, hwid: str | None = None, timeout: int = 15
) -> Subscription:
    headers = {
        "User-Agent": "Happ/1.0",
        "x-device-os": "Android",
        "x-ver-os": "14",
        "x-device-model": "VPNCTL",
        "x-hwid": hwid or "asdfghjkasdfghjkl",
    }

    r = requests.get(url, headers=headers, timeout=timeout)
    r.raise_for_status()
    return _parse_body(r.text, r.headers.get("content-type", ""))


_PROXY_PROTOCOLS = {"vless", "vmess", "trojan", "shadowsocks"}


def _parse_body(body: str, content_type: str) -> Subscription:
    text = body.strip()

    if text[:1] in "[{" or "json" in content_type.lower():
        try:
            obj = json.loads(text)
        except json.JSONDecodeError:
            obj = None
        if isinstance(obj, list):
            return Subscription(
                profiles=[_profile_from_xray(c) for c in obj if isinstance(c, dict)]
            )
        if isinstance(obj, dict) and "outbounds" in obj:
            return Subscription(profiles=[_profile_from_xray(obj)])

    try:
        decoded = _b64decode(text).decode("utf-8", "ignore")
        if "://" in decoded:
            return Subscription(profiles=_profiles_from_uris(decoded))
    except Exception:
        pass

    if "://" in text:
        return Subscription(profiles=_profiles_from_uris(text))

    return Subscription()


def pick_endpoints(
    sub: Subscription, selector: str | None
) -> list[tuple[SubProfile, Endpoint]]:
    """All (profile, endpoint) pairs with a security type build_config
    supports, scoped to profiles matching `selector` if given. A single
    Remnawave subscription commonly bundles several servers/nodes."""
    result: list[tuple[SubProfile, Endpoint]] = []
    for prof in sub.profiles:
        if selector is not None and selector.lower() not in prof.name.lower():
            continue
        for ep in prof.endpoints:
            if ep.security == "reality":
                result.append((prof, ep))
    return result


def pick_endpoint(
    sub: Subscription, selector: str | None
) -> tuple[SubProfile, Endpoint] | None:
    """First match from pick_endpoints, for callers that target a single
    already-registered profile (sync-singbox). None if there is no match."""
    matches = pick_endpoints(sub, selector)
    return matches[0] if matches else None


def _looks_like_placeholder(ep: Endpoint) -> bool:
    return (
        ep.address in ("", "0.0.0.0")
        or ep.port in (0, 1)
        or ep.uuid == _PLACEHOLDER_UUID
    )


def no_endpoint_hint(sub: Subscription) -> str:
    if any(
        _looks_like_placeholder(ep) for prof in sub.profiles for ep in prof.endpoints
    ):
        return (
            " (this subscription returned a placeholder link, not a real server -- "
            "usually means the device/HWID limit was reached or this client isn't "
            r"recognized; check the subscription's device limit, or set \[remnawave] "
            "hwid to the value your other client already uses)"
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
