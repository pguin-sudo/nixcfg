"""Cross-process mutual exclusion for connect/disconnect.

Guards against two vpnctl invocations racing each other (e.g. a manual
`vpnctl connect` from a terminal overlapping with a click in the Noctalia
panel) and stepping on each other's stop/start sequence.
"""

from __future__ import annotations

import contextlib
import fcntl
import os
from pathlib import Path


def _lock_path() -> Path:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
    return Path(runtime_dir) / "vpnctl.lock"


@contextlib.contextmanager
def exclusive():
    path = _lock_path()
    path.touch(exist_ok=True)
    with path.open("w") as f:
        try:
            fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise RuntimeError(
                "another vpnctl connect/disconnect is already in progress"
            ) from None
        yield
