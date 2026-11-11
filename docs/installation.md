# Installation — Ashita v4

1. Download `vanaradio/vanaradio.lua` from this repository.
2. In your Ashita installation, create an addon directory named `vanaradio` under `addons` if it does not exist.
3. Place the file at `addons/vanaradio/vanaradio.lua`.
4. In game, load it using `/addon load vanaradio` (or your Ashita configuration's addon-loading method).
5. Type `/vr` to toggle the interface. Type `/vr help` for commands.

On PhoenixXI, the Ashita installation may be under `C:\Games\PhoenixXI\`; confirm the location for your own installation.

**Compatibility:** Developed/tested on PhoenixXI with Ashita v4. Other client languages and servers have not been independently verified. This addon changes client-side music playback via packet interfaces; consult your server's rules before use.

**Troubleshooting:** If the UI fails to appear, check Ashita's console for Lua errors and confirm that `imgui` and `common` are available in your Ashita build. Track IDs depend on game audio assets.
