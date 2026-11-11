# VanaRadio

**VanaRadio v0.19.1** is an in-game Final Fantasy XI music player for **Ashita v4**, developed and tested on PhoenixXI. It plays music through FFXI's own audio system; no separate MP3 files are distributed or required.

## Installation

1. Download [vanaradio.lua](vanaradio/vanaradio.lua).
2. Create a folder named `vanaradio` inside your Ashita `addons` directory.
3. Place the file at `addons/vanaradio/vanaradio.lua`.
4. Start FFXI through Ashita v4 and enter `/addon load vanaradio`.
5. Enter `/vr` to show or hide the VanaRadio window.

For additional installation notes, see [Installation](docs/installation.md).

## Using VanaRadio

### Find and play a song

1. Open the player with `/vr`.
2. Choose **By Activity** to browse categories such as Towns & Cities, Fields & Dungeons, or Battle Arenas & Combat; choose **By Expansion** to browse game releases.
3. Expand a category and select a track. You can also use **Search** to filter by track name or numeric music ID.
4. Press **PLAY** to request playback. Enable **Auto Play** if you want clicking a track in the catalog to play it immediately.

The player shows the selected track and the current requested track in the **FARPLANE / NOW PLAYING** display.

### Playback controls

| Control | What it does |
| --- | --- |
| **PREV / NEXT** | Move backward or forward through the manual playlist, if one is populated. Otherwise, move through the music catalog. |
| **PLAY** | Play the selected track, or start the queue if a queue exists but has not been started. |
| **STOP** | Turn off VanaRadio's persistent/zone override control. Normal FFXI music resumes on the game's next music event; this does **not** immediately mute audio. |
| **Favorite / Unfavorite** | Add or remove the selected track from the **Favorites** category. |
| **Auto Play: ON/OFF** | Automatically play a track when selected from the catalog. |
| **Wave: ON/OFF** | Show or hide the decorative animated waveform. |

**Note:** Favorites, the queue, and the other interface toggles are session-only in this version; the addon does not save them to disk.

### Build and use a playlist

1. Select a track in the catalog and press **Queue +**. Repeat for more tracks.
2. Press **Playlist (N)** to open the manual queue.
3. Click a queued song to play it immediately, or press **Play Queue** to begin with the first entry.
4. Use **^** and **v** to reorder songs, **X** to remove a song, and **Clear Queue** to empty the queue.
5. Use **PREV** and **NEXT** to navigate queued songs.

**Playlist advancement is manual:** VanaRadio does not detect when a track finishes and does not automatically start the next song.

### Persistent music and zoning

FFXI normally changes music when you enter a new zone or encounter certain game events. VanaRadio offers two override options:

- **Persistent: ON** — attempts to retain your requested music across zone transitions and music events.
- **Zone Override: ON** — enables the legacy music packet override.

These controls modify client-side incoming music packet data. To return to normal behavior, press **STOP**, or turn the override options off. The game resumes its normal soundtrack at a subsequent music event; immediate restoration is not guaranteed.

### Chat commands

| Command | Action |
| --- | --- |
| `/vr` or `/vanaradio` | Toggle the VanaRadio window. |
| `/vr play` | Play the selected song. |
| `/vr next` | Next queued song, or next catalog song when the queue is empty. |
| `/vr prev` | Previous queued song, or previous catalog song when the queue is empty. |
| `/vr persist` | Toggle persistent music mode. |
| `/vr on` | Enable zone override. |
| `/vr off` or `/vr stop` | Disable VanaRadio's override control. |
| `/vr help` | Print a command reference to chat/console. |

## Features and limitations

- Searchable music catalog with activity and expansion grouping.
- Manual playlists, favorites, and Farplane-themed ImGui interface.
- Animated waveform using ImGui `PlotLines`. **The waveform is simulated, not audio-reactive.**
- Music playback uses FFXI's own audio assets. Some IDs may not play if your client lacks the relevant audio.
- Tested with **Ashita v4 on PhoenixXI**. Japanese-client and other server compatibility have not yet been verified.
- This release contains the Lua addon only. The experimental native **FarplaneAudio** plugin is not included.
- Consult the rules of your server before using client-side packet modification addons.

## Project files

- [Addon source](vanaradio/vanaradio.lua)
- [Installation guide](docs/installation.md)
- [Changelog](docs/changelog.md)

FFXI and its soundtrack are the property of their respective rights holders. This repository does not distribute copyrighted game audio files.
