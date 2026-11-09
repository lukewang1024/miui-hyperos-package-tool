# MIUI / HyperOS Package Tool

A small POSIX shell tool for reviewing and managing MIUI / HyperOS packages from Termux through Shizuku's `rish` shell client. It records each change so packages disabled or uninstalled by this tool can be restored for the current Android user.

This is an independent project. It is not affiliated with Canta or Shizuku.

## What it does

- Reads the device build and current Android user through `rish`.
- Evaluates a package manifest with `plan-list` before changes are made.
- Disables selected packages with `pm disable-user` or uninstalls selected system packages for the current Android user with `pm uninstall -k --user`.
- Saves the original enabled state in the local restore ledger.
- Restores disabled packages with their previous enabled state, or restores per-user uninstalls with `pm install-existing`.

Per-user uninstall leaves the preinstalled APK on the system image. It does not remove the APK from the system partition and does not require root. Restoration is available while Android still has that APK. This cannot guarantee that every app feature or vendor dependency behaves the same across builds.

## Requirements

- Android running MIUI or HyperOS.
- Termux and Shizuku.
- Shizuku's `rish` client installed and Termux authorized in Shizuku.
- `rish` available at `~/.local/bin/rish`, or set `RISH` to its path.

This repository does not bundle Shizuku, `rish`, or Shizuku's DEX helper. Get those from the [official Shizuku project](https://github.com/RikkaApps/Shizuku).

## Install

Clone the repository in Termux and run its installer:

```sh
git clone https://github.com/lukewang1024/miui-hyperos-package-tool.git
cd miui-hyperos-package-tool
./install.sh
```

The installer places the executable at `~/.local/bin/canta-pm`. It copies the bundled manifest to `~/.config/canta-pm/packages.tsv` only when that file does not already exist, so an existing personal list is preserved.

To update the script, pull the repository and run `./install.sh` again. To adopt manifest changes, compare `config/packages.tsv` with your local copy before replacing it; the installer intentionally does not overwrite an existing manifest.

## Review before applying

Start with the read-only plan:

```sh
canta-pm plan-list
```

The bundled list is the maintainer's personal default profile, not a universal recommendation. `canta-pm optimize` acts on every `apply` entry without prompting. Review each package and its note before running it, and adjust the manifest to match your own device and usage:

```sh
canta-pm optimize
```

Manifest fields are:

```text
status|action|package|deny_build_globs|purpose_reason_and_risk
```

- `apply`: eligible for `optimize`.
- `review`: shown in the plan, never changed automatically.
- `block`: explicitly excluded from changes.
- `disable`: disable for the current Android user.
- `uninstall`: per-user uninstall; accepted only for system packages.
- `deny_build_globs`: comma-separated shell-style patterns matched against `ro.build.version.incremental`; `-` means no exclusion.

Missing or not-installed packages are skipped. Package behavior and availability vary by model and software build. The list is a curated starting point, not a claim that every entry improves performance. Some package descriptions and risk notes were cross-checked against the [Universal Android Debloater community list](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/blob/main/resources/assets/uad_lists.json).

## Commands

```text
canta-pm list                         Show the local manifest
canta-pm plan-list                    Evaluate the manifest against this device
canta-pm plan PACKAGE...              Show current package state
canta-pm optimize                     Apply eligible manifest entries
canta-pm apply PACKAGE...             Disable selected packages
canta-pm uninstall-system PACKAGE...  Uninstall system packages for this user
canta-pm managed                      Show changes recorded by this tool
canta-pm restore [PACKAGE...]         Restore recorded changes
canta-pm list-disabled                List packages disabled for this user
canta-pm list-uninstalled             List packages uninstalled for this user
canta-pm restore-existing PACKAGE...  Reinstall a package for this user if its APK remains
```

`restore` only knows about changes recorded in this tool's ledger. It cannot infer or reverse changes made by another app or command. The ledger is stored at `${XDG_STATE_HOME:-~/.local/state}/canta-pm/changes.tsv`.

The manifest defaults to `~/.config/canta-pm/packages.tsv`. Set `CANTA_PM_MANIFEST` to use another manifest. `RISH` can similarly override the default `~/.local/bin/rish` path.

## Package information source

The manifest's notes are maintained for this project. Some entries were cross-checked against the UAD community package catalog; see its [license and repository](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation). Package presence and behavior are not guaranteed on every Xiaomi device.
