#!/usr/bin/env bash
# English Trainer — one-shot setup (macOS / Linux)
# Usage:  bash setup.sh
set -e

echo "==> Checking Python..."
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 not found. Install Python 3.10/3.11 first." >&2
  exit 1
fi
python3 --version

echo "==> Checking ffmpeg..."
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "WARNING: ffmpeg not on PATH. Install it (macOS: brew install ffmpeg | Debian/Ubuntu: sudo apt-get install -y ffmpeg)."
fi

if [ ! -d ".venv" ]; then
  echo "==> Creating virtual environment (.venv)..."
  python3 -m venv .venv
fi

echo "==> Installing dependencies (this can take a few minutes)..."
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt

echo ""
echo "Done. Start the server with:"
echo "    .venv/bin/python -m uvicorn app:app --port 8000"
echo "Then open http://localhost:8000 in your browser."
echo ""
echo "Optional features need your own keys (see docs/SETUP.md):"
echo "  - Pronunciation scoring: put an Azure Speech key in azure_key.txt"
echo "  - Bilibili videos: export a logged-in cookies.txt to this folder"
