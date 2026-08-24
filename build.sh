#!/bin/bash
set -e

echo "Installing Flutter 3.44.5..."

git clone --depth 1 --branch 3.44.5 https://github.com/flutter/flutter.git "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

echo "Flutter version:"
flutter --version

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter Web..."
flutter build web --release

echo "Build completed successfully."