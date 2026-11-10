#!/bin/bash
# update-cask.sh [version]: writes Casks/trackdeck.rb for a TrackDeck release
# (the latest one if no version is given), with checksums from the
# release's .sha256 files. Needs gh, logged in or with GH_TOKEN set.
set -euo pipefail
repo=khoshekh-dj/trackdeck
version=${1:-$(gh release view -R ${repo} --json tagName -q .tagName | sed 's/^trackdeck-v//')}
tag=trackdeck-v$version
# The latest release may lack a Mac build (1.3.2 and older had no macOS 12
# .dmg): leave the cask as it is then. A version given by hand must have all.
if [[ -z ${1:-} ]]; then
    assets=$(gh release view "$tag" -R ${repo} --json assets -q '.assets[].name')
    for f in macOS-AppleSilicon macOS-Intel macOS12-Intel; do
        if ! grep -qx "TrackDeck-$version-$f.dmg.sha256" <<<"$assets"; then
            echo "::notice::$tag has no $f .dmg yet: cask left as it is"
            exit 0
        fi
    done
fi
sum() {
    gh release download "$tag" -R ${repo} -p "TrackDeck-$version-$1.dmg.sha256" -O - | awk '{print $1}'
}
arm=$(sum macOS-AppleSilicon)
intel=$(sum macOS-Intel)
old=$(sum macOS12-Intel)
for s in "$arm" "$intel" "$old"; do
    [[ $s =~ ^[0-9a-f]{64}$ ]] || { echo "bad checksum in $tag: '$s'" >&2; exit 1; }
done
cd "$(dirname "$0")/.."
cat > Casks/trackdeck.rb <<CASK
cask "trackdeck" do
  version "${version}"

  # Apple Silicon and Intel builds need macOS 15; older Macs get the macOS 12
  # Intel build (on Apple Silicon it runs under Rosetta 2).
  on_sonoma :or_older do
    sha256 "$old"

    url "https://github.com/khoshekh-dj/trackdeck/releases/download/trackdeck-v#{version}/TrackDeck-#{version}-macOS12-Intel.dmg",
        verified: "github.com/khoshekh-dj/trackdeck/"
  end
  on_sequoia :or_newer do
    on_arm do
      sha256 "$arm"

      url "https://github.com/khoshekh-dj/trackdeck/releases/download/trackdeck-v#{version}/TrackDeck-#{version}-macOS-AppleSilicon.dmg",
          verified: "github.com/khoshekh-dj/trackdeck/"
    end
    on_intel do
      sha256 "$intel"

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
CASK
echo "Casks/trackdeck.rb: $version"
