"""Decoding AmneziaVPN `vpn://` share links into AmneziaWG `.conf` text.

Format reverse-engineered from amnezia-vpn/amnezia-client's export/import
controllers (client/core/controllers/selfhosted/{export,import}Controller.cpp):
strip the "vpn://" prefix, base64url-decode, then undo Qt's `qCompress`
framing (a 4-byte big-endian uncompressed-length prefix in front of an
ordinary zlib stream) to get a JSON document shaped like:

    {
      "containers": [{"container": "amnezia-awg", "awg": {"last_config": "<json string>"}}, ...],
      "defaultContainer": "amnezia-awg",
      "hostName": "1.2.3.4",
      ...
    }

Only per-client share links (an embedded "last_config" with client keys) are
supported. A "full access" server export has no client keys -- turning one
into a usable config needs AmneziaVPN's SSH provisioning step against the
server, which vpnctl doesn't do.
"""

from __future__ import annotations

import base64
import json
import zlib
from dataclasses import dataclass

_CONTAINER_PROTOCOL = {
    "amnezia-awg": "awg",
    # AmneziaWG protocol v2 -- a distinct container type, but
    # containerTypeToProtocolString() still keys its config under "awg"
    # (client/core/utils/containers/containerUtils.cpp in amnezia-client).
    "amnezia-awg2": "awg",
    "amnezia-awg3": "awg",
    "amnezia-wireguard": "wireguard",
}

# (.conf key, last_config JSON key) for the AmneziaWG obfuscation params --
# see client/server_scripts/awg/template.conf in amnezia-client. Absent/empty
# values are skipped, which is how plain WireGuard configs and older
# AmneziaWG protocol versions (missing S3/S4/I1-I5) fall out naturally.
_INTERFACE_FIELDS = [
    ("PrivateKey", "client_priv_key"),
    ("Jc", "Jc"),
    ("Jmin", "Jmin"),
    ("Jmax", "Jmax"),
    ("S1", "S1"),
    ("S2", "S2"),
    ("S3", "S3"),
    ("S4", "S4"),
    ("H1", "H1"),
    ("H2", "H2"),
    ("H3", "H3"),
    ("H4", "H4"),
    ("I1", "I1"),
    ("I2", "I2"),
    ("I3", "I3"),
    ("I4", "I4"),
    ("I5", "I5"),
    ("HeaderProtectionKey", "HeaderProtectionKey"),
    ("ContentPaddingAddition", "ContentPaddingAddition"),
    ("RekeyAfterTime", "RekeyAfterTime"),
    ("RekeyTimeout", "RekeyTimeout"),
    ("RejectAfterTime", "RejectAfterTime"),
    ("KeepaliveTimeout", "KeepaliveTimeout"),
    ("MaxHandshakeAttempts", "MaxHandshakeAttempts"),
    ("RandomTrailers", "RandomTrailers"),
    ("DisableCookies", "DisableCookies"),
]


class AmneziaLinkError(RuntimeError):
    pass


@dataclass
class AmneziaConfig:
    host: str
    conf_text: str


def decode_link(link: str) -> AmneziaConfig:
    """Parse an untrusted `vpn://` link. Never raises anything but
    AmneziaLinkError -- any unexpected shape in the decoded payload is a
    malformed/unsupported link, not a bug to crash the caller over."""
    if not link.startswith("vpn://"):
        raise AmneziaLinkError("not an amnezia vpn:// link")

    try:
        return _decode_link(link)
    except AmneziaLinkError:
        raise
    except Exception as e:
        raise AmneziaLinkError(f"could not parse link: {e}") from e


def _decode_link(link: str) -> AmneziaConfig:
    payload = link[len("vpn://") :].strip()
    raw = _b64url_decode(payload)
    data = _q_uncompress(raw) or raw
    doc = json.loads(data)

    if not isinstance(doc, dict):
        raise AmneziaLinkError("not a valid amnezia config")

    containers = doc.get("containers")
    if not isinstance(containers, list) or not containers:
        raise AmneziaLinkError("amnezia config has no containers")
    if not all(isinstance(c, dict) for c in containers):
        raise AmneziaLinkError("amnezia config has a malformed container entry")

    default = doc.get("defaultContainer")
    container = next(
        (c for c in containers if c.get("container") == default), containers[0]
    )

    kind = container.get("container", "")
    protocol_key = _CONTAINER_PROTOCOL.get(kind)
    if protocol_key is None:
        raise AmneziaLinkError(
            f"unsupported container type '{kind}' (only AmneziaWG/WireGuard are supported)"
        )

    protocol_obj = container.get(protocol_key)
    if not isinstance(protocol_obj, dict):
        protocol_obj = {}
    last_config_str = protocol_obj.get("last_config")
    if not last_config_str:
        raise AmneziaLinkError(
            "this looks like a full-access AmneziaVPN server export with no embedded "
            "client keys -- vpnctl only supports per-client share links"
        )

    client = json.loads(last_config_str)
    if not isinstance(client, dict):
        raise AmneziaLinkError("invalid embedded client config")

    host = client.get("hostName") or doc.get("hostName") or ""
    port = client.get("port") or 51820
    client_ip = client.get("client_ip") or ""
    server_pub_key = client.get("server_pub_key") or ""
    psk = client.get("psk_key")
    mtu = client.get("mtu")

    if not (host and client_ip and server_pub_key and client.get("client_priv_key")):
        raise AmneziaLinkError("embedded client config is missing required fields")

    lines = ["[Interface]", f"Address = {client_ip}"]
    if mtu:
        lines.append(f"MTU = {mtu}")
    for conf_key, json_key in _INTERFACE_FIELDS:
        value = client.get(json_key)
        if value not in (None, ""):
            lines.append(f"{conf_key} = {value}")

    lines += ["", "[Peer]", f"PublicKey = {server_pub_key}"]
    if psk:
        lines.append(f"PresharedKey = {psk}")
    lines.append("AllowedIPs = 0.0.0.0/0, ::/0")
    lines.append(f"Endpoint = {host}:{port}")
    lines.append("PersistentKeepalive = 25")

    return AmneziaConfig(host=host, conf_text="\n".join(lines) + "\n")


def _b64url_decode(s: str) -> bytes:
    s = s.strip()
    s += "=" * (-len(s) % 4)
    return base64.urlsafe_b64decode(s)


def _q_uncompress(data: bytes) -> bytes | None:
    """Undo Qt's `qCompress` framing: a 4-byte big-endian length prefix in
    front of a standard zlib stream. Returns None if `data` doesn't look
    qCompress'd, mirroring the upstream client's fall-back to raw bytes."""
    if len(data) < 5:
        return None
    try:
        return zlib.decompress(data[4:])
    except zlib.error:
        return None
