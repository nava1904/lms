#!/bin/sh
# Run the app from this directory so .env is bundled and SANITY_API_TOKEN is loaded.
# Usage: ./run_web.sh   or:   flutter run -d chrome --web-port=3000
cd "$(dirname "$0")"
flutter run -d chrome --web-port=3000 "$@"
