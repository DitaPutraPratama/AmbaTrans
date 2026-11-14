#!/usr/bin/env bash
# Builds the per-ABI release APKs and publishes them as a GitHub release.
# Needs the gh CLI (logged in). Usage: scripts/release.sh ["release notes"]
set -euo pipefail
cd "$(dirname "$0")/.."

# Without key.properties Gradle falls back to the debug key: Play Protect flags debug-signed APKs and
# users cannot update across builds made on different machines. Refuse to publish those.
[[ -f android/key.properties ]] || { echo "android/key.properties missing: create a release keystore first" >&2; exit 1; }

version=$(sed -n 's/^version: *\([^+]*\).*/\1/p' pubspec.yaml)
out=build/app/outputs/flutter-apk

flutter build apk --release --split-per-abi
(cd "$out" && sha256sum app-*-release.apk > SHA256SUMS.txt)

gh release create "v$version" "$out"/app-*-release.apk "$out/SHA256SUMS.txt" \
  --title "AmbaTrans $version" --notes "${1:-AmbaTrans $version}"
