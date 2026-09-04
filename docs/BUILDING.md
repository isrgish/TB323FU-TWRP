# Building TWRP for Lenovo TB323FU

The build target is **TB323FU**. `TB322FC` in the workflow refers only to the
public upstream donor recovery fork.

## Canonical build spine

- Manifest: `TWRP-Test/platform_manifest_twrp_aosp`, branch `twrp-16.0`
- Recovery fork: `polygraphene/android_bootable_recovery`, branch `twrp-16.0-TB322FC`
- Pinned recovery commit: `ced4ad75f311fc8a3350e21de415c23d5f0aec74`
- Lunch: `twrp_TB323FU bp2a eng`
- Build: `m -j1 recoveryimage`
- Portrait orientation
- Raw AOSP Android-16 tzdata staged into recovery
- Android-16 stale `copySqliteDb()` call removed
- Targeted `magiskboot ignore_max_page_size=true` exception for the 4 KiB kernel
- 103 proprietary files acquired and SHA-256 verified before build

## Preflight only

```bash
scripts/build-tb323fu-recovery.sh \
  --src /path/to/twrp-src \
  --stock-root /path/to/TB323FU-stock-root \
  --preflight-only
```

## Build / sync

```bash
scripts/build-tb323fu-recovery.sh \
  --src /path/to/twrp-src \
  --stock-root /path/to/TB323FU-stock-root \
  --sync
```

Historical source initialization used:

```bash
repo init --depth=1 \
  -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp \
  -b twrp-16.0

repo sync -c --force-sync --no-clone-bundle --no-tags \
  --optimized-fetch --prune --fail-fast --retry-fetches=3 -j2
```

The proven Codespace build used conservative Go memory settings, `m -j1`, and
approximately 8 GiB swap. A full checkout/build needs substantial disk and RAM.

The workflow never flashes recovery. For device validation, keep stock
`recovery_a`, test only the intended custom recovery slot, verify hashes/readback,
and first boot a new image via bootloader → Recovery Mode.

See `KNOWN_GOOD.md`, `PROPRIETARY_FILES.md`, and
`DECRYPTION_TROUBLESHOOTING.md`.
