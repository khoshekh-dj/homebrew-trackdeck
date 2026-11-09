# Homebrew tap for TrackDeck

[TrackDeck](https://github.com/khoshekh-dj/trackdeck) is a music player for DJs, with an RGB waveform, a live spectrum visualiser and BPM detection.

```sh
brew install --cask khoshekh-dj/trackdeck/trackdeck
```

Homebrew asks you to trust this tap the first time; follow its prompt or run `brew trust khoshekh-dj/trackdeck`. Update with `brew upgrade --cask trackdeck`.

- Needs macOS 12 Monterey or newer. On macOS 15 and newer you get the Apple Silicon or Intel build; older Macs get the macOS 12 Intel build, which runs under Rosetta 2 on Apple Silicon.
- TrackDeck isn't notarized by Apple, so this cask isn't in Homebrew's main catalogue. After installing, the cask removes the quarantine flag so macOS opens it without asking.
- `brew uninstall --zap --cask trackdeck` also removes the settings and playlist in `~/Library/Application Support/TrackDeck`.

The cask is updated automatically when TrackDeck has a new release (`.github/workflows/update.yml`, using the checksums published with each release).
