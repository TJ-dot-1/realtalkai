#!/bin/bash
echo "Building Flutter Web..."
if ! command -v flutter &> /dev/null
then
    echo "Flutter not found. Installing..."
    git clone https://github.com/flutter/flutter.git -b stable
    export PATH="$PATH:`pwd`/flutter/bin"
    flutter doctor
fi

flutter build web --release \
  --dart-define=OPENAI_API_KEY="$OPENAI_API_KEY" \
  --dart-define=API_PROVIDER="$API_PROVIDER" \
  --dart-define=AUDIO_API_KEY="$AUDIO_API_KEY"
