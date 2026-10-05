"""Shared helpers for herdr-nvim scripts (stdlib only, Python 3.8+)."""
import json
import os
import subprocess

HERDR = os.environ.get("HERDR_BIN_PATH", "herdr")
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HN_NVIM = os.path.join(ROOT, "bin", "hn-nvim")


def herdr(*args):
    """Run a herdr CLI command and return its parsed JSON (or {})."""
    out = subprocess.run(
        [HERDR, *args], check=True, capture_output=True, text=True
    ).stdout
    return json.loads(out) if out.strip() else {}


def notify(title, body):
    subprocess.run(
        [HERDR, "notification", "show", title, "--body", body], capture_output=True
    )


def context():
    return json.loads(os.environ.get("HERDR_PLUGIN_CONTEXT_JSON") or "{}")


def sock_path(tab_id):
    """One nvim server socket per herdr tab (tab IDs are never reused)."""
    base = os.path.join(os.environ.get("XDG_RUNTIME_DIR") or "/tmp", "herdr-nvim")
    return os.path.join(base, tab_id.replace(":", "_") + ".sock")


def nvim_alive(sock):
    if not os.path.exists(sock):
        return False
    try:
        r = subprocess.run(
            ["nvim", "--server", sock, "--remote-expr", "1"],
            capture_output=True,
            timeout=3,
        )
    except subprocess.TimeoutExpired:
        return False
    return r.returncode == 0
