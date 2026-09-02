# Tree provenance

This TB323FU device tree originated from community work based on an
`android_lenovo_TB323FU` source attachment and was subsequently corrected and
validated against a Lenovo TB323FU running Android 16.

Upstream/build sources used for the proven fix3b baseline:

- TWRP-Test `platform_manifest_twrp_aosp`, branch `twrp-16.0`
- `polygraphene/android_bootable_recovery`, branch `twrp-16.0-TB322FC`
- pinned recovery commit `ced4ad75f311fc8a3350e21de415c23d5f0aec74`
- Android Open Source Project components supplied by the selected manifest
- Lenovo/Qualcomm device-specific proprietary components supplied separately
  by the builder and not licensed by this project

The original source attachment recorded during development had SHA-256:

`9008973ca80d18ea3074401af60572575196e912a6397c45969d4ab5c875581c`

Major TB323FU-specific corrections validated during development include Android
16 API/VNDK alignment, F2FS metadata, wrapped-key/inlinecrypt FBE semantics,
SPU/KeyMint/Gatekeeper compatibility, KeyMint V4 StrongBox declaration,
targeted 4K `magiskboot` handling, timezone data staging, and normal portrait
screen blank/wake behavior.

The public repository is intentionally created with a fresh Git history rather
than publishing the private development history containing proprietary binary
objects and obsolete experimental build helpers.
