#!/bin/bash

PROJECT_DIR="$(git rev-parse --show-toplevel)"
XCODE_PROJECT_PATH="${PROJECT_DIR}/KaraokeApp.xcodeproj"
SCHEME_NAME="KaraokeApp"
DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=17.0"

xcodebuild test \
  -project "$XCODE_PROJECT_PATH" \
  -scheme "$SCHEME_NAME" \
  -destination "$DESTINATION"