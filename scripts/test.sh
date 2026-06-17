#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(git rev-parse --show-toplevel)"
XCODE_PROJECT_PATH="${PROJECT_DIR}/KaraokeApp.xcodeproj"
DERIVED_DATA="${PROJECT_DIR}/build/XcodeDerivedData"
DEVICE_NAME="iPhone 17"

# --- Simulator hygiene: start from clean, known-good state ---
# xcodebuild leaks "Clone N of ..." devices when it aborts; they accumulate on
# the long-lived node and drive CoreSimulator into the state that triggers the
# DVTiPhoneSimulator launchSession assertion. Clear them before every run.
echo "Cleaning simulator state..."
xcrun simctl shutdown all || true
xcrun simctl delete unavailable || true
# `|| true`: grep exits 1 when there are no clones, which would abort under pipefail.
clone_udids="$(xcrun simctl list devices | grep -E "Clone [0-9]+ of " | grep -oE '[0-9A-Fa-f-]{36}' || true)"
for udid in ${clone_udids}; do xcrun simctl delete "${udid}" || true; done

# Resolve a usable UDID for the target device (exact name match, not "... Pro").
# `|| true`: tolerate no-match (handled by the guard below) and head's SIGPIPE under pipefail.
UDID="$(xcrun simctl list devices available \
  | grep -E "^[[:space:]]+${DEVICE_NAME} \(" \
  | head -1 \
  | grep -oE '[0-9A-Fa-f-]{36}' || true)"
if [ -z "${UDID}" ]; then
  echo "Device '${DEVICE_NAME}' not found. Available:"; xcrun simctl list devices available
  exit 1
fi
echo "Using ${DEVICE_NAME} (${UDID})"

# Boot the pinned device and wait until fully booted before testing.
xcrun simctl erase "${UDID}" || true   # targeted erase; device is shut down above
xcrun simctl boot "${UDID}" || true
xcrun simctl bootstatus "${UDID}" -b || true

DESTINATION="platform=iOS Simulator,id=${UDID}"

xcrun xcodebuild clean \
  -project "${XCODE_PROJECT_PATH}" \
  -scheme "KaraokeApp" \
  -derivedDataPath "${DERIVED_DATA}" \
  -destination "${DESTINATION}"

xcrun xcodebuild test \
  -project "${XCODE_PROJECT_PATH}" \
  -scheme "KaraokeAppUITests" \
  -derivedDataPath "${DERIVED_DATA}" \
  -destination "${DESTINATION}" \
  -parallel-testing-enabled NO

# Leave the node clean for the next job.
xcrun simctl shutdown "${UDID}" || true
