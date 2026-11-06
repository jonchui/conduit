#!/bin/bash
# Rebuild Conduit and install it on Jon's iPhone 17 Pro over the LAN (run on JMBP16).
# Codegen runs in the root and in each package, matching .github/workflows/ci.yml.
set -euo pipefail
cd "$(dirname "$0")/.."
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
DERIVED="$HOME/Library/Developer/lan-install/conduit"

git submodule update --init --depth 1 third_party/mermaid third_party/katex
flutter pub get
dart run build_runner build --delete-conflicting-outputs
for dir in packages/*; do
  if grep -q '^  build_runner:' "$dir/pubspec.yaml"; then
    (cd "$dir" && dart run build_runner build --delete-conflicting-outputs)
  fi
done
flutter build ios --config-only --release
(cd ios && pod install)
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination generic/platform=iOS -derivedDataPath "$DERIVED" \
  -allowProvisioningUpdates -allowProvisioningDeviceRegistration build -quiet
lan-install "${1:-JonsiPhonePro17}" "$DERIVED/Build/Products/Release-iphoneos/Runner.app"
