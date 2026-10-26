"""systemctl/ip wrappers, and the cross-process connect/disconnect lock.

Every systemctl call here is non-privileged -- starting/stopping
`awg-quick@*.service` / `sing-box@*.service` / `ikev2-connection.service` as
a non-root user works because of the polkit rule the `vpn.nix` NixOS module
installs. No sudo prompt.
"""

from __future__ import annotations

import contextlib
import fcntl
import os
import subprocess
from pathlib import Path


class UnitError(RuntimeError):
    pass


def is_active_many(units: list[str], timeout: float = 10.0) -> dict[str, str]:
    """ActiveState (active/inactive/failed/...) for several units in one
    systemctl call, in the order given. `systemctl is-active` exits non-zero
    if any unit isn't active, but still prints a state line for every one --
    so the exit code is ignored and only stdout is parsed."""
    if not units:
        return {}
    try:
        result = subprocess.run(
            ["systemctl", "is-active", *units],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return dict.fromkeys(units, "unknown")
    states = result.stdout.splitlines()
    return {u: (states[i] if i < len(states) else "unknown") for i, u in enumerate(units)}


def is_active(unit: str, timeout: float = 10.0) -> str:
    return is_active_many([unit], timeout=timeout).get(unit, "unknown")


def start(unit: str, timeout: float = 60.0) -> None:
    """Start a unit, enforcing a hard deadline.

    Without an explicit timeout, `systemctl start` blocks for as long as the
    start job takes to resolve -- which, unlike awg-quick's near-instant
    config load, can genuinely hang: a polkit authorization that never gets
    an agent response, or (ikev2-connection.service) a strongSwan IKE
    handshake stalling against an unreachable/firewalled server.
    """
    try:
        result = subprocess.run(
            ["systemctl", "start", unit],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired as e:
        raise UnitError(f"{unit} did not start within {timeout:.0f}s") from e
    if result.returncode != 0:
        raise UnitError(f"failed to start {unit}: {result.stderr.strip()}")


def stop_and_wait(unit: str, timeout: float = 10.0) -> None:
    """Stop a unit, enforcing a hard deadline.

    `systemctl stop` already blocks until the stop job finishes, so the
    subprocess timeout below is the real deadline: if a unit won't go down
    in time this raises, instead of silently proceeding to start a second
    VPN on top of it.
    """
    try:
        result = subprocess.run(
            ["systemctl", "stop", unit],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired as e:
        raise UnitError(f"{unit} did not stop within {timeout:.0f}s") from e

    if result.returncode != 0:
        raise UnitError(f"failed to stop {unit}: {result.stderr.strip()}")

    state = is_active(unit)
    if state not in ("inactive", "failed"):
        raise UnitError(f"{unit} still reports '{state}' after stop")


def link_up(interface: str) -> bool:
    result = subprocess.run(
        ["ip", "-o", "link", "show", interface],
        capture_output=True,
        text=True,
    )
    return result.returncode == 0 and "UP" in result.stdout


def has_default_route(interface: str) -> bool:
    """Whether traffic to the public internet actually goes out `interface`.

    `ip route show default dev X` only looks at the main table, but
    awg-quick's default AllowedIPs=0.0.0.0/0 setup routes through a separate
    fwmark policy table, not a main-table default route -- so that query
    reports false negatives for a perfectly working AmneziaWG connection.
    `ip route get` resolves through every rule/table the kernel would
    actually use, regardless of which mechanism put the tunnel there.
    """
    result = subprocess.run(
        ["ip", "-o", "route", "get", "1.1.1.1"],
        capture_output=True,
        text=True,
    )
    return result.returncode == 0 and f"dev {interface} " in result.stdout


def _lock_path() -> Path:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
    return Path(runtime_dir) / "vpnctl.lock"


@contextlib.contextmanager
def exclusive():
    """Guards connect/disconnect's stop+start sequence against a second
    vpnctl invocation racing it (e.g. a manual `connect` overlapping with a
    click in the Noctalia panel)."""
    path = _lock_path()
    with path.open("a") as f:
        try:
            fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise RuntimeError(
                "another vpnctl connect/disconnect is already in progress"
            ) from None
        yield
