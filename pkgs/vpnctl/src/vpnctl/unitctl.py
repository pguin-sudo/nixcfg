"""Thin wrapper around `systemctl` for the two unit families vpnctl drives.

Every call here is a plain non-privileged `systemctl` invocation. Starting/
stopping `awg-quick@*.service` and `sing-box@*.service` as a non-root user
works because of the polkit rule installed by the `common.services.vpn`
NixOS module -- no sudo prompt.
"""

from __future__ import annotations

import subprocess


class UnitError(RuntimeError):
    pass


def is_active(unit: str) -> str:
    """systemd's ActiveState: active/inactive/failed/activating/deactivating/unknown."""
    result = subprocess.run(
        ["systemctl", "is-active", unit],
        capture_output=True,
        text=True,
    )
    return result.stdout.strip() or "unknown"


def start(unit: str) -> None:
    result = subprocess.run(["systemctl", "start", unit], capture_output=True, text=True)
    if result.returncode != 0:
        raise UnitError(f"failed to start {unit}: {result.stderr.strip()}")


def stop_and_wait(unit: str, timeout: float = 10.0) -> None:
    """Stop a unit, enforcing a hard deadline.

    `systemctl stop` already blocks until the stop job finishes (awg-quick's
    ExecStop / ExecStopPost, sing-box's shutdown), so the subprocess timeout
    below is the actual deadline enforcement the caller asked for: if a unit
    won't go down in time, this raises instead of silently proceeding to
    start a second VPN on top of it.
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
    fwmark policy table (see `ip rule`/`ip route show table 51820`), not a
    main-table default route -- so that query reports false negatives for a
    perfectly working AmneziaWG connection. `ip route get` resolves through
    every rule/table the kernel would actually use, so it reflects reality
    regardless of which routing mechanism (fwmark table, plain default
    route, tun auto_route) put the tunnel there.
    """
    result = subprocess.run(
        ["ip", "-o", "route", "get", "1.1.1.1"],
        capture_output=True,
        text=True,
    )
    return result.returncode == 0 and f"dev {interface} " in result.stdout
