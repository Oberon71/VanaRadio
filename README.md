# VanaRadio

An Ashita v4 addon for browsing and playing Final Fantasy XI's native music within the game. Developed and tested with PhoenixXI.

## Version

**v0.19.1** — first source baseline published from the tested addon.

## Features

- Searchable catalog of FFXI music IDs, organized by activity or expansion.
- Play, stop control, previous/next selection, and favorites.
- Manual session playlist with add, reorder, remove, and queue navigation.
- Persistent music and zone override options.
- Farplane-themed in-game ImGui controls and an animated simulated waveform.

**Important:** The waveform is decorative, not audio-reactive. Playlist tracks do not automatically advance when a song finishes. Music availability depends on installed FFXI audio assets and the client. Stop control does not immediately silence the game; normal game music resumes at the next game music event.

## Installation

See [docs/installation.md](docs/installation.md).

## Commands

`/vr` toggles the interface. `/vr play`, `/vr next`, `/vr prev`, `/vr persist`, `/vr on`, `/vr off`, and `/vr help` are available.

## Development

The optional native audio-reactive FarplaneAudio plugin is an experimental future project and is **not included** in this release. This repository currently contains only Lua addon source and documentation.

FFXI and related music are property of their respective owners. This repository does not distribute game audio assets.
