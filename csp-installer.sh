#!/bin/bash

# Custom CSP installer for CachyOS/Arch
# Based on minsiam/csp-linux — updated by xion
# Uses: system wine-staging (no GE-Proton, no Steam Runtime needed)
#
# Installer versions (latest patch for each perpetual license tier):
#   v1 → CSP_1132w (v1.13.2) — last v1.x release
#   v2 → CSP_206w  (v2.0.6)  — perpetual v2 covers v2.0.x only
#   v3 → CSP_308w  (v3.0.8)  — perpetual v3 covers v3.0.x only
#   v4 → CSP_403w  (v4.0.3)  — perpetual v4 covers v4.0.x only
#   v5 → CSP_504w  (v5.0.4)  — perpetual v5 covers v5.0.x only (latest)

# ─── CONFIG ────────────────────────────────────────────────────────────────────
export CSP_PATH="$HOME/.local/share/csp-linux"
export WINEPREFIX="$CSP_PATH/csp-pfx"
export WINEARCH=win64
# ───────────────────────────────────────────────────────────────────────────────

usage() {
    cat << EOF
usage: $0 OPTION

OPTIONS:
    [1|2|3|4|5]   Install CSP major version
                    1 → v1.13.2  (perpetual v1)
                    2 → v2.0.6   (perpetual v2, latest v2.0.x)
                    3 → v3.0.8   (perpetual v3, latest v3.0.x)
                    4 → v4.0.3   (perpetual v4, latest v4.0.x)
                    5 → v5.0.4   (perpetual v5, latest v5.0.x)
    help          Show this message
    uninstall     Uninstall CSP
EOF
}

if [[ "$OSTYPE" != "linux-gnu" ]]; then
    echo "This script is only supported on Linux" 1>&2
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
    echo "Removing CSP..."
    if [ -d "$CSP_PATH" ]; then
        rm -rf "$CSP_PATH" || { echo "Failed to remove $CSP_PATH" 1>&2; exit 1; }
    fi
    if [ -f "$HOME/.config/csprc" ]; then
        rm "$HOME/.config/csprc" || { echo "Failed to remove ~/.config/csprc" 1>&2; exit 1; }
    fi
    echo "Successfully removed CSP"
    exit 0

else
    CSP_VERSION=
    case $1 in
        1) CSP_VERSION=1 ;;
        2) CSP_VERSION=2 ;;
        3) CSP_VERSION=3 ;;
        4) CSP_VERSION=4 ;;
        5) CSP_VERSION=5 ;;
        *)
            echo "Unknown command or CSP version" 1>&2
            usage
            exit 1
            ;;
    esac

    # ── Dependency checks ──────────────────────────────────────────────────────
    for dep in wget pv wine; do
        if ! command -v "$dep" &>/dev/null; then
            echo "Please install '$dep' before running this script" 1>&2
            if [ "$dep" = "wine" ]; then
                echo "  On CachyOS/Arch: sudo pacman -S wine-staging"
            fi
            exit 1
        fi
    done

    # Warn if not wine-staging
    if ! wine --version 2>/dev/null | grep -qi "staging"; then
        echo "Warning: wine-staging is recommended for best CSP compatibility."
        echo "  On CachyOS/Arch: sudo pacman -S wine-staging"
        echo "  Continuing with installed Wine..."
    fi

    mkdir -p "$CSP_PATH"
    mkdir -p "$HOME/.config"
    cd "$CSP_PATH" || exit 1

    if [ -d "$WINEPREFIX/drive_c/Program Files/CELSYS/CLIP STUDIO 1.5" ]; then
        echo "CSP is already installed. Run csp-linux to start."
        exit 0
    fi

    # ── CSP installer selection ────────────────────────────────────────────────
    CSP_SETUP=
    case $CSP_VERSION in
        1)
            [ ! -f CSP_1132w_setup.exe ] && {
                echo "Downloading CSP v1.13.2 installer..."
                wget -q --show-progress "https://vd.clipstudio.net/clipcontent/paint/app/1132/CSP_1132w_setup.exe"
            }
            CSP_SETUP="CSP_1132w_setup.exe"
            ;;
        2)
            [ ! -f CSP_206w_setup.exe ] && {
                echo "Downloading CSP v2.0.6 installer (latest perpetual v2)..."
                wget -q --show-progress "https://vd.clipstudio.net/clipcontent/paint/app/206/CSP_206w_setup.exe"
            }
            CSP_SETUP="CSP_206w_setup.exe"
            ;;
        3)
            [ ! -f CSP_308w_setup.exe ] && {
                echo "Downloading CSP v3.0.8 installer (latest perpetual v3)..."
                wget -q --show-progress "https://vd.clipstudio.net/clipcontent/paint/app/308/CSP_308w_setup.exe"
            }
            CSP_SETUP="CSP_308w_setup.exe"
            ;;
        4)
            [ ! -f CSP_403w_setup.exe ] && {
                echo "Downloading CSP v4.0.3 installer (latest perpetual v4)..."
                wget -q --show-progress "https://vd.clipstudio.net/clipcontent/paint/app/403/CSP_403w_setup.exe"
            }
            CSP_SETUP="CSP_403w_setup.exe"
            ;;
        5)
            [ ! -f CSP_504w_setup.exe ] && {
                echo "Downloading CSP v5.0.4 installer (latest perpetual v5)..."
                wget -q --show-progress "https://vd.clipstudio.net/clipcontent/paint/app/504/CSP_504w_setup.exe"
            }
            CSP_SETUP="CSP_504w_setup.exe"
            ;;
        *)
            echo "Impossible error: failed to set CSP_VERSION" 1>&2
            exit 1
            ;;
    esac

    # ── Create Wine prefix ─────────────────────────────────────────────────────
    echo ""
    echo "Initialising Wine prefix at $WINEPREFIX..."
    wineboot --init
    if [ $? -ne 0 ]; then
        echo "Failed to initialise Wine prefix" 1>&2
        exit 1
    fi

    echo "Setting Windows version to win81..."
    winecfg -v win81
    if [ $? -ne 0 ]; then
        echo "Failed to set Windows version to win81" 1>&2
        exit 1
    fi

    # ── Run installer ──────────────────────────────────────────────────────────
    echo ""
    echo "Installing CSP v${CSP_VERSION} using Wine Staging..."
    echo "Complete the installer as normal, then press [Enter] here when done."
    wine "$CSP_PATH/$CSP_SETUP"

    while true; do
        read -r -n 1 key
        if [[ -z $key ]]; then
            break
        fi
    done

    # ── Write csprc ────────────────────────────────────────────────────────────
    [ -f "$HOME/.config/csprc" ] && rm "$HOME/.config/csprc"

    cat >> "$HOME/.config/csprc" << EOF
[Wine]
WINEPREFIX=${WINEPREFIX}
WINEARCH=win64
EOF

    echo ""
    echo "CSP is now installed!"
    echo "Run csp-linux to start CSP."

    rm -f "$CSP_PATH/$CSP_SETUP"
fi
