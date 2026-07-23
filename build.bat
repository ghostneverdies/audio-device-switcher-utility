@echo off
setlocal enabledelayedexpansion

echo ============================================
echo  Audio Device Switcher - Nuitka Build
echo ============================================
echo.

where python >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Python was not found on PATH.
    echo Install Python 3.10+ from https://python.org and re-run this script.
    pause
    exit /b 1
)

where gcc >nul 2>nul
if errorlevel 1 (
    echo [ERROR] MinGW-w64 (gcc) was not found on PATH.
    echo Install it via: scoop install mingw
    echo Or add it manually from https://www.mingw-w64.org and ensure gcc.exe is on PATH.
    pause
    exit /b 1
)

echo [1/5] Installing build dependencies ...
python -m pip install --upgrade pip >nul2>&1
python -m pip install "nuitka[onefile]" ordered-set -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies. See output above.
    pause
    exit /b 1
)

echo.
echo [2/5] Cleaning previous build artifacts ...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist

echo.
echo [3/5] Checking for icon.ico ...
if not exist "icon.ico" (
    echo [WARN] icon.ico not found next to build.bat — building without a custom icon.
    set "ICON_ARGS="
    set "DATA_ARGS="
) else (
    set "ICON_ARGS=--windows-icon-from-ico=icon.ico"
    set "DATA_ARGS=--include-data-file=icon.ico=icon.ico"
)

echo.
echo [4/5] Compiling with Nuitka via MinGW-w64 (this may take a few minutes) ...
python -m nuitka ^
    --onefile ^
    --mingw64 ^
    --enable-plugin=pyqt6 ^
    --windows-console-mode=disable ^
    --output-dir=dist ^
    --output-filename="Audio Device Switcher.exe" ^
    !ICON_ARGS! !DATA_ARGS! ^
    --assume-yes-for-downloads ^
    main.py
if errorlevel 1 (
    echo [ERROR] Nuitka build failed. See output above.
    pause
    exit /b 1
)

echo.
echo [5/5] Finalizing output ...
if not exist "dist\Audio Device Switcher.exe" (
    echo [ERROR] Expected output "dist\Audio Device Switcher.exe" was not found.
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Build complete: dist\Audio Device Switcher.exe
echo ============================================
echo.

start "" "%~dp0dist"

endlocal
