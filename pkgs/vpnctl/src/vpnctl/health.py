"""Best-effort TCP reachability probe for `vpnctl list --check`.

Only singbox profiles are checked: their VLESS/Reality endpoint is TCP, so a
plain connect() is a meaningful signal. amnezia (WireGuard) is UDP -- a
connect() on a UDP socket never touches the network, so it would always
"succeed" and tell us nothing; ikev2 has no per-profile server to point a
socket at (connections live in a single, auth-gated swanctl config). Both are
left unmarked (None) rather than lie about a check that didn't really happen.
"""

from __future__ import annotations

import socket
from concurrent.futures import ThreadPoolExecutor

from . import display
from .models import Profile, ProfileType

TIMEOUT = 2.0


def _reachable(host: str, port: int) -> bool:
    try:
        with socket.create_connection((host, port), timeout=TIMEOUT):
            return True
    except OSError:
        return False


def check_all(profs: list[Profile]) -> dict[str, bool | None]:
    """Maps profile name -> reachable, None for profiles that can't be checked."""
    targets: dict[str, tuple[str, int]] = {}
    for p in profs:
        if p.type is not ProfileType.SINGBOX:
            continue
        summary = display.server_summary(p)
        if summary is None:
            continue
        host, _, port_str = summary.rpartition(":")
        if not host or not port_str.isdigit():
            continue
        targets[p.name] = (host, int(port_str))

    results: dict[str, bool | None] = {p.name: None for p in profs}
    if not targets:
        return results

    with ThreadPoolExecutor(max_workers=len(targets)) as pool:
        futures = {
            name: pool.submit(_reachable, host, port)
            for name, (host, port) in targets.items()
        }
        for name, fut in futures.items():
            results[name] = fut.result()
    return results
