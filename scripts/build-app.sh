#!/bin/zsh
# Regenerates the sprite sheets, builds a release binary and wraps it in OllieBoard.app.
set -euo pipefail
cd "$(dirname "$0")/.."
# The in-app updater compares this with the latest GitHub release tag (vX.Y).
VERSION=${VERSION:-1.1}

swift run -c release SpriteGen
swift build -c release --product OllieBoard

APP=build/OllieBoard.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$(swift build -c release --show-bin-path)/OllieBoard" "$APP/Contents/MacOS/"
cp -R Sources/OllieBoard/Resources/Sprites "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>com.ollieboard.app</string>
    <key>CFBundleName</key><string>OllieBoard</string>
    <key>CFBundleExecutable</key><string>OllieBoard</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>${VERSION}</string>
    <key>CFBundleVersion</key><string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>OllieBoard cần điều khiển Finder để các nhân vật đá và sắp xếp icon trên Desktop, và (nếu bạn bật) trình duyệt để nghịch trang web.</string>
</dict>
</plist>
PLIST

# Ad-hoc by default. Ad-hoc builds get a new identity each time, so macOS asks for Finder access again after
# every rebuild; set SIGN_IDENTITY (see `security find-identity -v -p codesigning`) to keep the permission.
codesign --force --sign "${SIGN_IDENTITY:--}" "$APP"
echo "Built $APP"
