# Publication status

## Project scope

This is an unofficial TWRP port for the **Lenovo TB323FU**. It is not an
official TeamWin release and no endorsement is implied.

The public repository is being prepared as a source-first release. Proprietary
Lenovo/Qualcomm payload files are intentionally excluded from Git and are
acquired separately through the hash-pinned workflow described in
[PROPRIETARY_FILES.md](PROPRIETARY_FILES.md).

## Known-good recovery

The validated runtime baseline is:

`TWRP-3.7.1-16-TB323FU-20260813-portrait-crypto-fix3b-tzdata-a16.img`

SHA-256:

`851ec167d32b8474228a3e2864663489907c69334e9fa3a592c245a332f5ac28`

Validated behavior includes:

- recovery boot;
- portrait touch/UI;
- screen blank/wake;
- external SD access;
- `/metadata` mount;
- Android 16 `/data` decryption and `/data/media`;
- backup/restore;
- ADB, MTP, and sideload;
- recovery state capture.

The known-good image was validated on TB323FU firmware:

`TB323FU_ROW_OPEN_USER_Q00020.0_A16_ZUI_18.0.12.104_ST_260711`

See [KNOWN_GOOD.md](KNOWN_GOOD.md) for the detailed source/runtime baseline.

## Publication validation completed

The publication-prep work has verified:

- target naming integrity: TB323FU remains the build/runtime target;
- proprietary payload separation from Git;
- 103-file proprietary acquisition source map;
- 25 exact current-TB323FU stock acquisition targets;
- 78 exact inherited public donor-history acquisition targets;
- exact size/SHA-256 verification of all 103 targets;
- atomic failure behavior during proprietary acquisition;
- third-party recovery shell-tool licensing/source inventory;
- corresponding-source bundle for retained shell tools;
- canonical build workflow with pinned recovery source revision;
- user-facing build/acquisition help and argument failures;
- `--preflight-only` path through proprietary acquisition, donor Git checkout,
  Android 16 compatibility patching, magiskboot 4K handling, device-tree
  staging, and tzdata staging.

## Deliberately not re-run solely for publication cleanup

A full TWRP compile and device flash were **not** repeated merely to validate
documentation, licensing cleanup, or repository packaging.

The existing fix3b recovery remains the proven runtime baseline. The public
build workflow has been structurally and preflight tested, but a future build
may differ byte-for-byte from the historical known-good image due to build
metadata, source/toolchain state, or environment differences.

If a source change alters runtime behavior—especially decryption, storage,
kernel/recovery packaging, or hardware-service integration—it should be
validated as a new recovery variant before being treated as release-ready.

## Recovery-slot safety

Do not casually overwrite both recovery slots. Preserve the stock recovery
slot and validate a new custom recovery on the intended slot first. For a new
recovery image, verify its hash/read-back and first boot it through bootloader
→ Recovery Mode.

The build workflow itself never flashes recovery.

## Proprietary-material note

Public availability or byte provenance does not itself grant redistribution
rights for proprietary Lenovo, Qualcomm, or other vendor material. This
repository therefore keeps those payload bytes outside Git and documents the
separate acquisition/verification path instead.

## Future development

After the source publication is complete, new TWRP work should proceed on
feature branches. The current planned order is:

1. ORS / TWRP command-line behavior;
2. keyboard repeat/caps behavior;
3. File Explorer directory creation;
4. Wi-Fi;
5. Bluetooth.
