#!/usr/bin/env bash
# Build the NostrRide iOS shell. Run on a Mac with Xcode, CocoaPods and Node 22.23.4+.
#   bash setup.sh                 # main branch of trevthom/nostr-ride
#   NR_REF=v1.2.3 bash setup.sh   # a tag or commit
#   NR_REPO=<url> bash setup.sh   # a fork
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
APP_REPO="${NR_REPO:-https://github.com/trevthom/nostr-ride.git}"
APP_REF="${NR_REF:-main}"
APP="$HERE/app"

command -v node >/dev/null 2>&1 || { echo "Node 22.23.4 or newer is required: https://nodejs.org"; exit 1; }
command -v pod  >/dev/null 2>&1 || { echo "CocoaPods is required: sudo gem install cocoapods"; exit 1; }
command -v xcodebuild >/dev/null 2>&1 || { echo "Xcode is required: install it from the App Store, then run xcode-select --install"; exit 1; }

if [ ! -d "$APP/.git" ]; then
  echo "==> Cloning $APP_REPO ($APP_REF)"
  git clone --depth 1 --branch "$APP_REF" "$APP_REPO" "$APP"
else
  echo "==> Reusing $APP"
fi

echo "==> Building the web app"
( cd "$APP" && npm ci && npm run build )

echo "==> Installing the iOS shell"
mkdir -p "$APP/native"
cp -R "$HERE/native/." "$APP/native/"

echo "==> Capacitor and CocoaPods"
# sync, not copy: the update step regenerates the plugin podspecs a fresh clone does not have,
# and it runs pod install at the end.
( cd "$APP/native" && npm install && npx cap sync ios )

WS="$APP/native/ios/App/App.xcworkspace"
echo
echo "Done. Open the workspace (not the .xcodeproj):"
echo "  $WS"
open "$WS" 2>/dev/null || true
