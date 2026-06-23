# AGENTS.md — setup & run instructions for AI coding agents

This file tells an AI coding agent (OpenAI Codex, Claude Code, Cursor, Windsurf, Devin, etc.)
how to set up and run this project for the user. Follow it top to bottom.

This is a **web app with a local Python backend** (FastAPI + uvicorn). Frontend is a single
static `index.html` served by the backend. No build step, no database.

## Goal

Get the server running at `http://localhost:8000` so the user can open it in a browser.
Three of the four practice modes (blind listening / listening / connected reading) work with
**zero credentials** — get those working first. Two optional features need user-supplied
secrets (see "Secrets the human must provide" below); set up the environment, then ask the user.

## Prerequisites (check, install if missing)

- **Python 3.10 or 3.11** (newer may work; some pinned deps were built against these).
- **ffmpeg** on PATH (needed for audio extraction & pronunciation assessment).
  - Windows: `winget install Gyan.FFmpeg`
  - macOS: `brew install ffmpeg`
  - Debian/Ubuntu: `sudo apt-get install -y ffmpeg`

## Setup

Run the helper script, or the equivalent manual steps.

- **Windows (PowerShell):** `./setup.ps1`
- **macOS / Linux:** `bash setup.sh`

Manual equivalent:

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate    macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
```

## Run

Always use the venv's Python, not the system/conda Python:

```bash
# Windows:
.venv\Scripts\python -m uvicorn app:app --port 8000
# macOS/Linux:
.venv/bin/python -m uvicorn app:app --port 8000
```

Then tell the user to open **http://localhost:8000** in a browser.
Use `localhost` (not a LAN IP) so the browser grants microphone access for the shadowing mode.

## Verify it works

- `GET http://localhost:8000/api/health` should return JSON like `{"ok":true,"azure":...}`.
- Open the page, paste any English paragraph, click "拆成句子，开始练" — sentences should appear
  and the four mode tabs should switch.

## Secrets the human must provide (do NOT commit these; not in the repo by design)

After the environment runs, prompt the user only if they want these features:

1. **Pronunciation scoring (shadowing mode)** — Azure Speech key.
   - Create an Azure Speech resource (Free F0, 5 hrs/month, no charge).
   - Easiest for the user: open the app → gear icon (top-right) → "发音评测设置" → paste the key,
     region `southeastasia` → Save. It writes `azure_key.txt` and takes effect immediately (no restart).
   - Or manually: `azure_key.txt` at the repo root (line 1 = key, line 2 = region), or env vars
     `AZURE_SPEECH_KEY` / `AZURE_SPEECH_REGION` (env wins and locks the in-app panel).
   - `GET /api/health` shows `"azure":true` once set. Without a key, shadowing still works via a
     local Whisper fallback (basic word-match) — only the phoneme-level precise scoring needs Azure.
2. **Bilibili videos** — a logged-in `cookies.txt`.
   - Bilibili returns HTTP 412 for logged-out requests. Use the browser extension
     "Get cookies.txt LOCALLY", log in to bilibili, export `cookies.txt` to the repo root
     (auto-detected, no restart needed). Other sites (YouTube/X) usually need no cookies.

Full step-by-step for both is in [docs/SETUP.md](docs/SETUP.md).

## Gotchas / pinned versions (do NOT "upgrade" these blindly)

Some versions in `requirements.txt` are pinned because newer ones crash on some CPUs
(observed on AMD Ryzen 6000-series):

- `ctranslate2==4.4.0` — newer segfaults when loading the Whisper model.
- `numpy==1.26.4` (<2) — otherwise "Failed to initialize NumPy".
- Optional background-music removal needs `torch==2.2.2` + `torchaudio==2.2.2` (CPU wheels);
  newer torch fails to import (c10.dll). Install only if the user wants Demucs vocal separation.

If a pinned version genuinely won't install on the target platform, tell the user before changing it.

## Notes for the agent

- Never commit `azure_key.txt`, `cookies.txt`, `*.key`, `.env`, or the `media/` folder — they are
  git-ignored and may contain secrets or large files. A pre-commit hook blocks obvious key leaks.
- The repo ships no credentials. Do not invent or hardcode any.
- If running in a sandbox without a browser/microphone, you can still install deps and start the
  server; the user opens `localhost` themselves to actually use it.
