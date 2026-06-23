# English Trainer — one-shot setup (Windows PowerShell)
# Usage:  ./setup.ps1
$ErrorActionPreference = "Stop"

Write-Host "==> Checking Python..." -ForegroundColor Cyan
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { Write-Error "Python not found. Install Python 3.10/3.11 first."; exit 1 }
python --version

Write-Host "==> Checking ffmpeg..." -ForegroundColor Cyan
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
  Write-Warning "ffmpeg not on PATH. Install with: winget install Gyan.FFmpeg  (needed for video extraction & pronunciation scoring)"
}

if (-not (Test-Path ".venv")) {
  Write-Host "==> Creating virtual environment (.venv)..." -ForegroundColor Cyan
  python -m venv .venv
}

Write-Host "==> Installing dependencies (this can take a few minutes)..." -ForegroundColor Cyan
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r requirements.txt

Write-Host ""
Write-Host "Done. Start the server with:" -ForegroundColor Green
Write-Host "    .\.venv\Scripts\python.exe -m uvicorn app:app --port 8000"
Write-Host "Then open http://localhost:8000 in your browser."
Write-Host ""
Write-Host "Optional features need your own keys (see docs/SETUP.md):"
Write-Host "  - Pronunciation scoring: put an Azure Speech key in azure_key.txt"
Write-Host "  - Bilibili videos: export a logged-in cookies.txt to this folder"
