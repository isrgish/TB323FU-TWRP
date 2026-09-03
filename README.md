# Unofficial TWRP for Lenovo TB323FU

Unofficial Android 16 TWRP device tree for the Lenovo Legion Y700 Gen 5
(TB323FU).

> **Warning**
>
> This project is provided **AS IS**, without warranty of any kind. Installing
> or using a custom recovery can cause data loss, an unbootable device, loss of
> access to encrypted data, security problems, or other unintended
> consequences. You are solely responsible for deciding whether to build,
> flash, modify, or use this project and for maintaining appropriate backups.
> The maintainer and contributors accept no responsibility or liability for
> damage, data loss, loss of functionality, or other consequences arising from
> its use.

This is not an official TeamWin release and is not affiliated with, sponsored
by, or endorsed by Lenovo, Qualcomm, Google, or TeamWin.

## Current baseline

The maintained baseline is the portrait Android 16 **fix3b** recovery:

`TWRP-3.7.1-16-TB323FU-20260813-portrait-crypto-fix3b-tzdata-a16.img`

SHA-256:

`851ec167d32b8474228a3e2864663489907c69334e9fa3a592c245a332f5ac28`

The tested image was installed on `recovery_b`; `recovery_a` was kept stock.

Runtime-validated functionality includes boot, portrait display/touch, normal
screen blank/wake, external microSD, `/metadata`, live `/data` decryption,
`/data/media`, TWRP backup and restore, ADB, MTP, sideload transport, and
recovery-side diagnostic capture.

## Proprietary files

This repository is being structured so Lenovo/Qualcomm proprietary binaries
are **not committed to Git**.

`proprietary-files.tsv` records the required target path and SHA-256 for each
external file. `scripts/stage-proprietary-files.sh` stages a locally supplied
cache and refuses to install files whose hashes do not match the manifest.

The private development cache is not part of this repository and must never be
published.

## Build status

The original fix3b image was successfully compiled and runtime tested. During
the public-repository cleanup, a new full TWRP compile is intentionally **not**
being performed solely to validate packaging changes.

The final public build wrapper and stock-file extraction instructions are still
being consolidated. Do not use old resume/retry scripts from earlier
development snapshots.

## Safety

- Target device: **Lenovo TB323FU only**.
- Keep an exact stock recovery backup before testing.
- Preserve a known-good recovery path.
- For first testing of a new image, flash only the intended recovery slot.
- Do not casually overwrite both recovery slots.
- Verify image hashes before flashing.

See `docs/KNOWN_GOOD.md` for the proven baseline and `TREE_PROVENANCE.md` for
source provenance.

## Licensing and third-party material

This is a mixed-origin project. See [`docs/LICENSING.md`](docs/LICENSING.md)
and [`NOTICE`](NOTICE). Proprietary Lenovo/Qualcomm files are intentionally excluded from Git history. The six validated recovery shell tools are intentionally included as third-party prebuilts; see [`docs/THIRD_PARTY_TOOLS.md`](docs/THIRD_PARTY_TOOLS.md).
