# IP Monitor Plugin for Noctalia

A lightweight, configurable status bar widget for Noctalia Shell that displays your external IP address and geographical location (City, State/Region) with real-time polling and instant manual cache refresh.

---

## Features

- **Granular Display Toggles**: Independently show or hide IP address, City, and State.
- **Icon Visibility Control**: Toggle the status bar icon (`globe`) on or off dynamically without layout collapse.
- **Custom Delimiter**: Configure any custom separator string between location and IP text (default: ` | `).
- **Adjustable Polling Interval**: Configure poll rates from 1 to 3600 seconds via a graphical slider or configuration file.
- **Click-to-Refresh**: Clicking the widget immediately clears local caches and triggers a fresh network query.
- **Reliable Geo-Lookup**: Queries `ipwho.is` asynchronously to prevent UI freezing and ensure accurate ISP/regional attribution without requiring an API key.
- **Declarative UI**: Built using Noctalia v5's declarative `barWidget.render()` engine, automatically adapting between horizontal and vertical bar orientations.

---

## Directory Structure

To publish or install the plugin locally, organize the files as follows:

```text
~/.local/share/noctalia/plugins/local/ip-monitor/
├── plugin.toml
├── widget.luau
└── translations/
    └── en.json
```

---

## Enabling and Managing

After placing the files, load and enable the plugin via Noctalia's IPC interface:

```bash
noctalia msg plugins disable local/ip-monitor
noctalia msg plugins enable local/ip-monitor
```

To configure options visually, navigate to:
**Noctalia Settings** > **Panels** / **Widgets** > **IP Monitor**.

---

## Architecture & How It Works

1. **Initialization**: On startup, Noctalia invokes `update()`, setting the execution timer via `noctalia.setUpdateInterval(intervalSec * 1000)`.
2. **Declarative Rendering**:
   - `renderWidget()` inspects user configurations retrieved via `noctalia.getConfig()`.
   - Constructs a UI tree using `ui.row` (horizontal bar) or `ui.column` (vertical bar).
   - If `show_icon` is disabled, `ui.glyph` is excluded entirely from the node graph rather than rendered empty, preventing placeholder glyph errors.
3. **Asynchronous Polling**:
   - `noctalia.runAsync()` executes `curl -s https://ipwho.is/` off the main thread.
   - Luau pattern matching extracts the `"ip"`, `"city"`, and `"region"` attributes from the returned JSON payload.
   - Once data is parsed, state variables (`cachedIp`, `cachedCity`, `cachedRegion`) are updated and the widget re-renders.
4. **Cache Invalidation**:
   - Left-clicking the widget triggers `onClick()`.
   - In-memory variables are reset to `nil`, displaying an immediate `"Loading..."` state before firing an asynchronous network request.