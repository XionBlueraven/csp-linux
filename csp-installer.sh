#!/bin/bash

set -euo pipefail

# Custom CSP installer for CachyOS/Arch
# Based on minsiam/csp-linux — updated by xion
# Uses: system wine-staging + CJK font support  (no GE-Proton, no Steam Runtime needed)

# Installer versions (latest patch for each perpetual license tier):
# v1 → CSP_1132w (v1.13.2) — last v1.x release
# v2 → CSP_206w (v2.0.6) — perpetual v2 covers v2.0.x only
# v3 → CSP_308w (v3.0.8) — perpetual v3 covers v3.0.x only
# v4 → CSP_403w (v4.0.10) — perpetual v4 covers v4.0.x only
# v5 → CSP_504w (v5.0.4) — perpetual v5 covers v5.0.x only (latest)

export CSP_PATH="$HOME/.local/share/clip-studio"
export WINEPREFIX="$CSP_PATH/prefix"
export WINEARCH=win64
DOWNLOADS_PATH="$CSP_PATH/downloads"
LOCAL_BIN_DIR="$HOME/.local/bin"
LAUNCHER_PATH="$CSP_PATH/clip-studio"
SYMLINK_PATH="$LOCAL_BIN_DIR/clip-studio"
CONFIG_PATH="$HOME/.config/clip-studio-rc"

usage() {
cat << EOF2
usage: $0 OPTION

OPTIONS:
[1|2|3|4|5] Install CSP major version
1 → v1.13.2 (perpetual v1)
2 → v2.0.6 (perpetual v2, latest v2.0.x)
3 → v3.0.8 (perpetual v3, latest v3.0.x)
4 → v4.0.10 (perpetual v4, latest v4.0.x)
5 → v5.0.4 (perpetual v5, latest v5.0.x)
help Show this message
uninstall Uninstall CSP
EOF2
}

write_config() {
    mkdir -p "$HOME/.config"
    cat > "$CONFIG_PATH" << EOF2
[Wine]
WINEPREFIX=$WINEPREFIX
WINEARCH=$WINEARCH
CSP_PATH=$CSP_PATH
DOWNLOADS_PATH=$DOWNLOADS_PATH
LAUNCHER_PATH=$LAUNCHER_PATH
EOF2
    echo "Wrote config: $CONFIG_PATH"
}

install_launcher() {
    mkdir -p "$LOCAL_BIN_DIR" "$CSP_PATH"
    cat > "$LAUNCHER_PATH" << EOF2
#!/bin/bash
set -euo pipefail
export CSP_PATH="$CSP_PATH"
export WINEPREFIX="$WINEPREFIX"
export WINEARCH="$WINEARCH"
TARGET_EXE="$WINEPREFIX/drive_c/Program Files/CELSYS/CLIP STUDIO 1.5/CLIP STUDIO PAINT/CLIPStudioPaint.exe"
if [ ! -f "\$TARGET_EXE" ]; then
    TARGET_EXE=\$(find "\$WINEPREFIX/drive_c" -type f -iname 'CLIPStudioPaint.exe' 2>/dev/null | head -n 1 || true)
fi
[ -n "\$TARGET_EXE" ] && [ -f "\$TARGET_EXE" ] || { echo "Clip Studio executable not found in \$WINEPREFIX" >&2; exit 1; }
exec wine "\$TARGET_EXE" "\$@"
EOF2
    chmod +x "$LAUNCHER_PATH"
    ln -snf "$LAUNCHER_PATH" "$SYMLINK_PATH"
    echo "Installed launcher: $LAUNCHER_PATH"
    echo "Linked command: $SYMLINK_PATH -> $(readlink "$SYMLINK_PATH")"

    case ":$PATH:" in
        *":$HOME/.local/bin:"*) echo "PATH already includes $HOME/.local/bin" ;;
        *)
            echo "Warning: $HOME/.local/bin is not currently in PATH." >&2
            echo "Add this to your shell profile:" >&2
            echo 'export PATH="$HOME/.local/bin:$PATH"' >&2
            ;;
    esac
}

if [[ "$OSTYPE" != "linux-gnu" ]]; then
    echo "This script is only supported on Linux" >&2
    exit 1
fi

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

if [ "$1" = "help" ]; then
    usage
    exit 0
elif [ "$1" = "uninstall" ]; then
    echo "Removing Clip Studio Paint..."
    rm -rf "$CSP_PATH"
    rm -f "$CONFIG_PATH"
    rm -f "$SYMLINK_PATH"
    echo "Successfully removed Clip Studio Paint"
    exit 0
fi

CSP_VERSION=""
case "$1" in
    1) CSP_VERSION=1 ;;
    2) CSP_VERSION=2 ;;
    3) CSP_VERSION=3 ;;
    4) CSP_VERSION=4 ;;
    5) CSP_VERSION=5 ;;
    *)
        echo "Unknown command or CSP version" >&2
        usage
        exit 1
        ;;
esac

# Dependencies check
for dep in wget pv wine find chmod ln readlink winetricks; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Please install '$dep' before running this script" >&2
        if [ "$dep" = "wine" ]; then
            echo "On CachyOS/Arch: sudo pacman -S wine-staging"
        elif [ "$dep" = "winetricks" ]; then
            echo "On CachyOS/Arch: sudo pacman -S winetricks"
        fi
        exit 1
    fi
done

if ! wine --version 2>/dev/null | grep -qi "staging"; then
    echo "Warning: wine-staging is recommended for best CSP compatibility."
    echo "On CachyOS/Arch: sudo pacman -S wine-staging"
    echo "Continuing with installed Wine..."
fi

mkdir -p "$CSP_PATH" "$DOWNLOADS_PATH" "$HOME/.config"
cd "$DOWNLOADS_PATH" || exit 1

if [ -d "$WINEPREFIX/drive_c/Program Files/CELSYS/CLIP STUDIO 1.5" ]; then
    echo "CSP is already installed. Run clip-studio to start."
    write_config
    install_launcher
    exit 0
fi

CSP_SETUP=""
case "$CSP_VERSION" in
    1)
        CSP_SETUP="CSP_1132w_setup.exe"
        [ -f "$DOWNLOADS_PATH/$CSP_SETUP" ] || {
            echo "Downloading CSP v1.13.2 installer..."
            wget -q --show-progress -O "$DOWNLOADS_PATH/$CSP_SETUP" "https://vd.clipstudio.net/clipcontent/paint/app/1132/CSP_1132w_setup.exe"
        }
        ;;
    2)
        CSP_SETUP="CSP_206w_setup.exe"
        [ -f "$DOWNLOADS_PATH/$CSP_SETUP" ] || {
            echo "Downloading CSP v2.0.6 installer (latest perpetual v2)..."
            wget -q --show-progress -O "$DOWNLOADS_PATH/$CSP_SETUP" "https://vd.clipstudio.net/clipcontent/paint/app/206/CSP_206w_setup.exe"
        }
        ;;
    3)
        CSP_SETUP="CSP_308w_setup.exe"
        [ -f "$DOWNLOADS_PATH/$CSP_SETUP" ] || {
            echo "Downloading CSP v3.0.8 installer (latest perpetual v3)..."
            wget -q --show-progress -O "$DOWNLOADS_PATH/$CSP_SETUP" "https://vd.clipstudio.net/clipcontent/paint/app/308/CSP_308w_setup.exe"
        }
        ;;
    4)
        CSP_SETUP="CSP_4010w_setup.exe"
        [ -f "$DOWNLOADS_PATH/$CSP_SETUP" ] || {
            echo "Downloading CSP v4.0.10  installer (latest perpetual v4)..."
            wget -q --show-progress -O "$DOWNLOADS_PATH/$CSP_SETUP" "https://vd.clipstudio.net/clipcontent/paint/app/4010/CSP_4010w_setup.exe"
        }
        ;;
    5)
        CSP_SETUP="CSP_504w_setup.exe"
        [ -f "$DOWNLOADS_PATH/$CSP_SETUP" ] || {
            echo "Downloading CSP v5.0.4 installer (latest perpetual v5)..."
            wget -q --show-progress -O "$DOWNLOADS_PATH/$CSP_SETUP" "https://vd.clipstudio.net/clipcontent/paint/app/504/CSP_504w_setup.exe"
        }
        ;;
esac

echo ""
echo "Initialising Wine prefix at $WINEPREFIX..."
wineboot --init

echo "Setting Windows version to win81..."
winecfg -v win81

# --- AUTOMATED FONT INSTALLATION ---
echo ""
echo "Installing CJK fonts (Chinese, Japanese, Korean) to prevent text issues..."
# Use -q for quiet mode to avoid multiple pop-ups
WINEPREFIX="$WINEPREFIX" winetricks -q cjkfonts || echo "Warning: CJK font installation failed. You may see squares instead of text in some menus."

echo ""
echo "Installing CSP v${CSP_VERSION} using Wine Staging..."
echo "Complete the installer as normal, then press [Enter] here when done."
wine "$DOWNLOADS_PATH/$CSP_SETUP"

while true; do
    read -r -n 1 key
    if [[ -z "$key" ]]; then
        break
    fi
done

write_config
install_launcher

echo ""
echo "CSP is now installed with CJK fonts configured!"
echo "Run clip-studio to start CSP."