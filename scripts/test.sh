#!/bin/bash
set -eu

PROJECT_DIR="$(git rev-parse --show-toplevel)"
XCODE_PROJECT_PATH="${PROJECT_DIR}/KaraokeApp.xcodeproj"
DESTINATION="platform=iOS Simulator,name=iPhone 17,OS=26.3.1"

xcrun xcodebuild clean \
  -project "$XCODE_PROJECT_PATH" \
  -scheme "KaraokeApp" \
  -derivedDataPath "${PROJECT_DIR}/build/XcodeDerivedData" \
  -destination "$DESTINATION"

xcrun xcodebuild test \
  -project "$XCODE_PROJECT_PATH" \
  -scheme "KaraokeAppUITests" \
  -derivedDataPath "${PROJECT_DIR}/build/XcodeDerivedData" \
  -destination "$DESTINATION"