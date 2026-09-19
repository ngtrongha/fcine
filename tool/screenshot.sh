#!/bin/bash
# F-Cine Screenshot Tool - Linux/macOS version

set -e

PLATFORM="${1:-all}"
DEVICE="${2:-auto}"

echo "🎬 F-Cine Screenshot Tool"
echo "Platform: $PLATFORM | Device: $DEVICE"

# Check integration test exists
if [ ! -f "integration_test/screenshot_test.dart" ]; then
    echo "❌ integration_test/screenshot_test.dart not found"
    exit 1
fi

# Create screenshots directory
mkdir -p docs/screenshots
echo "📁 Created docs/screenshots"

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Run tests based on platform
case "$PLATFORM" in
    mobile)
        echo "📱 Capturing MOBILE screenshots..."
        flutter test integration_test/screenshot_test.dart --name "Capture all screens"
        ;;
    desktop)
        echo "🖥️ Capturing DESKTOP screenshots..."
        if [ "$DEVICE" = "auto" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                DEVICE="macos"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                DEVICE="linux"
            else
                DEVICE="windows"
            fi
        fi
        flutter test integration_test/screenshot_test.dart --name "Capture desktop screens" -d "$DEVICE"
        ;;
    all|*)
        echo "📱 Capturing MOBILE screenshots..."
        flutter test integration_test/screenshot_test.dart --name "Capture all screens"
        
        # Desktop if on desktop OS
        if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
            echo "🖥️ Capturing DESKTOP screenshots..."
            if [[ "$OSTYPE" == "darwin"* ]]; then
                DEVICE="macos"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                DEVICE="linux"
            else
                DEVICE="windows"
            fi
            flutter test integration_test/screenshot_test.dart --name "Capture desktop screens" -d "$DEVICE"
        fi
        ;;
esac

echo ""
echo "✅ Done! Screenshots saved to docs/screenshots/"
ls -la docs/screenshots/