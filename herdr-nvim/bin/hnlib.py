"""Shared helpers for herdr-nvim scripts (stdlib only, Python 3.8+)."""
import base64
import json
import os
import socket
import struct
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


def preview_state_path(tab_id):
    """Per-tab state of the nvim/browser right-pane toggle (see bin/hn-preview)."""
    return sock_path(tab_id)[: -len(".sock")] + ".preview.json"


def panes():
    """{pane_id: tab_id} for every pane herdr knows."""
    return {p["pane_id"]: p["tab_id"] for p in herdr("pane", "list")["result"]["panes"]}


def browsers():
    """Running terminal-browser instances (`terminal-browser ls --all --json`)."""
    out = subprocess.run(
        ["terminal-browser", "ls", "--all", "--json"], capture_output=True, text=True
    ).stdout
    return json.loads(out).get("browsers", []) if out.strip() else []


def cdp(port, target, method, params=None):
    """Send one DevTools command over a minimal WebSocket (stdlib only).

    The bundled agent-browser needs a newer glibc than some hosts have, so
    navigation goes straight to the browser's CDP port.
    """
    s = socket.create_connection(("127.0.0.1", port), timeout=3)
    try:
        key = base64.b64encode(os.urandom(16)).decode()
        s.sendall(
            (
                "GET /devtools/page/%s HTTP/1.1\r\nHost: 127.0.0.1:%d\r\n"
                "Upgrade: websocket\r\nConnection: Upgrade\r\n"
                "Sec-WebSocket-Key: %s\r\nSec-WebSocket-Version: 13\r\n\r\n" % (target, port, key)
            ).encode()
        )
        if b" 101 " not in s.recv(4096).split(b"\r\n")[0]:
            raise RuntimeError("CDP websocket handshake failed")
        body = json.dumps({"id": 1, "method": method, "params": params or {}}).encode()
        mask = os.urandom(4)
        n = len(body)
        head = bytes([0x81]) + (bytes([0x80 | n]) if n < 126 else bytes([0x80 | 126]) + struct.pack(">H", n))
        s.sendall(head + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(body)))
        s.recv(65536)
    finally:
        s.close()
