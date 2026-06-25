# Clip Studio Paint on Linux (Wine Staging fork)

This project is based on `minsiam/csp-linux`, which originally installed Clip Studio Paint on Linux using GE-Proton and a Steam Runtime bundle. This modified version switches the setup to **system Wine Staging**, removes the Steam Runtime dependency, and uses a standard Wine prefix plus a direct launcher for `CLIPStudioPaint.exe`.

## Authors

- **Original code:** minsiam.
- **Modified Wine Staging version and standard layout updates:** xion.

## What changed

The original project used a Proton-style workflow with Steam compatibility paths and a bundled runtime. This updated version uses a regular `WINEPREFIX`, a dedicated app folder under `~/.local/share/clip-studio`, and a launcher named `clip-studio` that starts CSP through `wine` directly.

| Component | Original `minsiam/csp-linux` | Updated version |
|---|---|---|
| Runtime | GE-Proton  | Wine Staging  |
| Steam Runtime | Required  | Not required  |
| Prefix style | Proton-style Steam compat paths  | Standard `WINEPREFIX`  |
| App folder | `~/.local/share/csp-linux`  | `~/.local/share/clip-studio`  |
| Prefix folder | `csp-pfx`  | `prefix`  |
| Downloads folder | Not standardized  | `~/.local/share/clip-studio/downloads`  |
| Config file | `~/.config/csprc`  | `~/.config/clip-studio-rc`  |
| Launcher name | `csp-linux`  | `clip-studio`  |
| Launch method | Proton-based launcher flow  | `wine` launching `CLIPStudioPaint.exe` directly  |
| CJK Fonts | Not available  | Supported  |


## Why Wine Staging

This fork is designed for users who want a simpler Linux-native workflow than the older Proton-based setup. Instead of using Steam compatibility variables and a Proton wrapper, the launcher reads `WINEPREFIX` and `WINEARCH` from `~/.config/clip-studio-rc` and starts Clip Studio Paint directly with `wine`.

## Requirements

Install the required tools before running the installer:

```bash
wine-staging
winetricks
wget
pv
```

On Arch-based systems such as CachyOS, the typical command is:

```bash
sudo pacman -S wine-staging wget pv winetricks
```

The installer also includes distro detection and prints dependency guidance for common Arch-based and Debian/Ubuntu-based systems when required tools are missing.

## Installation

Clone the repository:

```bash
git clone https://github.com/XionBlueraven/csp-linux
cd csp-linux
```

Make the installer executable:

```bash
chmod +x csp-installer.sh
```

Run the installer with the CSP major version you want, you can pass it directly with the version number:

```bash
./csp-installer.sh 4
```

Supported version lines are:

- v1 -> 1.13.2
- v2 -> 2.0.6
- v3 -> 3.0.8
- v4 -> 4.0.10
- v5 -> 5.0.4

These follow the perpetual-license-safe `x.0.x` branch choices used by the installer.

## Installed layout

After installation, the standardized layout is:

```text
~/.local/share/clip-studio/
├── clip-studio
├── downloads/
└── prefix/

~/.config/clip-studio-rc
~/.local/bin/clip-studio
```

The launcher script is stored in the app folder, marked executable, and symlinked into `~/.local/bin` so the command can be run as `clip-studio` if `~/.local/bin` is in `PATH`.

## Running Clip Studio Paint

Start Clip Studio Paint with:

```bash
clip-studio
```

If `~/.local/bin` is not in your shell `PATH`, run it directly with:

```bash
~/.local/share/clip-studio/clip-studio
```

The launcher reads the config from `~/.config/clip-studio-rc`, checks that `WINEPREFIX` is set, and then launches `CLIPStudioPaint.exe` from the expected install path inside the prefix.

## Uninstall

To remove the app using the installer:

```bash
./csp-installer.sh uninstall
```

That removes the Clip Studio app folder, config file, and launcher symlink created by the installer.

## Notes

Newer CSP releases can still run into WebView-related issues in some parts of the Clip Studio ecosystem, especially around launcher, login, or store-related functions. Even when those components are unreliable, launching `CLIPStudioPaint.exe` directly is the practical workaround this project is built around.