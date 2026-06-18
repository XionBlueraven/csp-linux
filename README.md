# CSP Linux (Wine Staging fork)

This repository/script setup is based on [`minsiam/csp-linux`](https://github.com/minsiam/csp-linux), which originally installs Clip Studio Paint on Linux using GE-Proton and a Steam Runtime bundle. This fork changes that approach to use **plain Wine Staging** instead of Proton, and removes the Steam Runtime dependency entirely because plain Wine runs directly against the system Wine installation rather than `proton run` and Steam compatibility paths.

## What changed

The original `minsiam/csp-linux` script downloads a GE-Proton release and a Steam container runtime, sets `STEAM_COMPAT_*` variables, then launches the CSP installer through Proton. In this updated version, the installer uses `wine-staging`, a normal Wine prefix, and a simple launcher script, so no Proton tarball or Steam Runtime Sniper archive is required.

| Component | Original `minsiam/csp-linux` | Updated version |
|---|---|---|
| Runtime | GE-Proton  | Wine Staging  |
| Steam Runtime | Required  | Not required  |
| Prefix style | `STEAM_COMPAT_DATA_PATH` Proton prefix  | Standard `WINEPREFIX`  |
| Launch method | `proton run`  | `wine`  |
| Config file | Proton paths in `~/.config/csprc`  | Wine prefix settings in `~/.config/csprc` |

## Why Wine Staging

Current CSP Linux reports point toward plain Wine being a better fit than game-focused Proton builds. The Lutris page for Clip Studio Paint explicitly says to use only System Wine and notes that GE and Proton patches seem to break things, while Wine 10.7 was confirmed working there. WineHQ forum discussions also note that CSP can work with Wine when configured as Windows 8.1 and using Wine Gecko rather than trying to force Edge or Internet Explorer into the prefix.

## Requirements

Install the required packages first:

```bash
sudo pacman -S wine-staging wget pv
```

On CachyOS and other Arch-based systems, `wine-staging` is the intended package for this setup because the script expects the `wine` command to be present and uses a normal Wine prefix instead of a bundled runtime.

## Installation flow

Clone the repository.

```bash
git clone https://github.com/XionBlueraven/csp-linux
cd csp-linux
```

Make the `csp-installer.sh` file executable:

```bash
chmod +x csp-installer.sh
```

Run the installer and choose the CSP major version that matches the perpetual license tier: 1 for v1, 2 for v2, etc. If you want to install v4, type the line below in your terminal.

```bash
./csp-installer.sh 4
```

The updated installer uses perpetual-license-safe patch lines:

- v1 -> 1.13.2
- v2 -> 2.0.6
- v3 -> 3.0.8
- v4 -> 4.0.3
- v5 -> 5.0.4

Those version lines follow Clip Studio's current perpetual-license model where each perpetual license tier covers the `x.0.x` branch for that major version rather than later feature branches such as `x.1.x`.

## Launcher setup

After installation, copy or move the `csp-linux` launcher into the CSP data directory, then make it executable:

```bash
cp csp-linux ~/.local/share/csp-linux/
chmod +x ~/.local/share/csp-linux/csp-linux
```

If the launcher should no longer remain in the cloned repository folder, move it instead of copying it:

```bash
mv csp-linux ~/.local/share/csp-linux/
chmod +x ~/.local/share/csp-linux/csp-linux
```

This launcher reads the Wine prefix path from `~/.config/csprc` and starts `CLIPStudioPaint.exe` directly with `wine`, which avoids the old Proton-specific `STEAM_COMPAT_*` flow.

## Running CSP

Launch CSP with:

```bash
~/.local/share/csp-linux/csp-linux
```

If preferred, create a symlink so `csp-linux` is available in `~/.local/bin`:

```bash
mkdir -p ~/.local/bin
ln -sf ~/.local/share/csp-linux/csp-linux ~/.local/bin/csp-linux
```

Then run:

```bash
csp-linux
```

## Notes

Newer CSP versions, especially v3 and later, can still run into WebView-related issues for the Clip Studio launcher, login flow, or assets store because Wine does not fully replicate the modern embedded Microsoft web stack used by those parts of the app. Even when those pieces are unreliable, launching `CLIPStudioPaint.exe` directly is the most common Linux workaround and is exactly what this Wine Staging launcher is designed to do.
