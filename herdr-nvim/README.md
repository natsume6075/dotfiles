# herdr-nvim

A [herdr](https://herdr.dev) plugin that pairs an agent pane with an nvim preview pane.

- **Dev tab**: one key opens a tab split into `[shell | nvim]`. Focus stays on the shell.
- **Auto reload**: buffers already open in that nvim reload when the agent changes them on disk
  (in-place writes and atomic replace). New files are never opened automatically.
- **Open from the agent** (`open` action, experimental): opens `path[:line[:col]]` in *that tab's* nvim.
  See [Limits](#limits) for what is and is not verified.

Your nvim config is not modified: the companion Lua is injected with `nvim -c` by `bin/hn-nvim`.

## Requirements

herdr >= 0.9, nvim >= 0.10 (uses `vim.uv`), Python 3.8+ (stdlib only).

## Install

```sh
herdr plugin install <owner>/herdr-nvim          # from GitHub
herdr plugin link /path/to/herdr-nvim            # local checkout
```

## Keys

Plugins cannot define keys, so add these to `~/.config/herdr/config.toml`:

```toml
[keys]
new_tab = "prefix+shift+c"        # keep a plain tab available

[[keys.command]]
key = "prefix+c"
type = "plugin_action"
command = "dev-tab"

[[keys.command]]
key = "prefix+f"
type = "plugin_action"
command = "open"                   # experimental, see Limits

[[keys.command]]
key = "prefix+t"
type = "plugin_action"
command = "preview-toggle"         # swap nvim and the browser preview
```

Then `herdr server reload-config`.

## HTML preview

Needs [terminal-browser](https://github.com/zenbu-labs/terminal-browser) and a terminal with kitty graphics
support (it cannot draw inside nvim's `:terminal`).

- In an html buffer of the dev-tab nvim, `<leader>t` shows the file in a resident browser that takes the nvim
  pane's place (`[shell | browser]`). `prefix+t` swaps back; press it again to swap again.
- Saving an html buffer reloads the browser without changing layout or focus.
- The hidden pane keeps running in a `preview` tab. State is per dev tab in
  `$XDG_RUNTIME_DIR/herdr-nvim/<tab_id>.preview.json`. herdr closes a tab when its last pane moves out, so
  the hidden pane always moves next to the one leaving.
- Navigation talks to the browser's CDP port directly (bundled agent-browser needs a newer glibc than some hosts).
  The port listens on 127.0.0.1 without auth, so on a shared host other users can drive your browser while it runs.
  Stop it with `terminal-browser shutdown`.

## How it finds the right nvim

`bin/hn-nvim` listens on `$XDG_RUNTIME_DIR/herdr-nvim/<tab_id>.sock`, one socket per herdr tab.
`bin/hn-open` talks to that socket; if no nvim is alive in the tab it splits the focused pane and starts one.

## Limits

- `open` is verified only when driven by a script with a context (`path:line:col`, `file://` URLs with
  `%20` and `#L30`, missing files). Triggered from a key binding it reported "nothing to open": herdr did
  not pass the selection to the action in testing.
- No `link_handlers` are registered. Whether the agent's file paths become clickable OSC 8 links in herdr
  was not verified.
- If you quit nvim in the preview pane, the next open creates a new split instead of reusing the shell pane.

## License

MIT
