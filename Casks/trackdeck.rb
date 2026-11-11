cask "trackdeck" do
  version "1.3.3"

  # Apple Silicon and Intel builds need macOS 15; older Macs get the macOS 12
  # Intel build (on Apple Silicon it runs under Rosetta 2).
  on_sonoma :or_older do
    sha256 "d71283812d0e2d38d42c80c3d7e424f5e63c795d1d8acbde7b7d4810b146a0b5"

    url "https://github.com/khoshekh-dj/trackdeck/releases/download/trackdeck-v#{version}/TrackDeck-#{version}-macOS12-Intel.dmg",
        verified: "github.com/khoshekh-dj/trackdeck/"
  end
  on_sequoia :or_newer do
    on_arm do
      sha256 "2652b4479b34e0d67ce7b159c07b83ec30b3f51eada47461cf0e43c91575342c"

      url "https://github.com/khoshekh-dj/trackdeck/releases/download/trackdeck-v#{version}/TrackDeck-#{version}-macOS-AppleSilicon.dmg",
          verified: "github.com/khoshekh-dj/trackdeck/"
    end
    on_intel do
      sha256 "c648b6005fd32d4875aca206c5685f143c3f4adb92250cac40b1aa4dcb5424d7"

      url "https://github.com/khoshekh-dj/trackdeck/releases/download/trackdeck-v#{version}/TrackDeck-#{version}-macOS-Intel.dmg",
          verified: "github.com/khoshekh-dj/trackdeck/"
    end
  end

  name "TrackDeck"
  desc "Music player for DJs with an RGB waveform, spectrum visualiser and BPM detection"
  homepage "https://khoshekh-dj.github.io/trackdeck/"

  livecheck do
    url :url
    regex(/^trackdeck[._-]v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "TrackDeck.app"

  # TrackDeck isn't notarized: without this, macOS blocks the first launch
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/TrackDeck.app"],
        writable_paths: ["TrackDeck.app"],
        writable_base:  :appdir,
        must_succeed:   false
  end

  zap trash: "~/Library/Application Support/TrackDeck"
end
