#!/bin/bash
echo "Building Flutter Web..."
if ! command -v flutter &> /dev/null
then
    echo "Flutter not found. Installing..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$PATH:`pwd`/flutter/bin"
    flutter config --no-analytics
fi

# Create an empty .env file because it's listed in pubspec.yaml assets.
# Without this, `flutter build web` will crash complaining the asset is missing.
touch .env

flutter build web --release \
  --dart-define=OPENAI_API_KEY="$OPENAI_API_KEY" \
  --dart-define=API_PROVIDER="$API_PROVIDER" \
  --dart-define=AUDIO_API_KEY="$AUDIO_API_KEY"
