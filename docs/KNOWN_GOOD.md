# Known-good TB323FU TWRP baseline

## Recovery

- Image: `TWRP-3.7.1-16-TB323FU-20260813-portrait-crypto-fix3b-tzdata-a16.img`
- SHA-256: `851ec167d32b8474228a3e2864663489907c69334e9fa3a592c245a332f5ac28`
- Size: 104,857,600 bytes
- Tested custom slot: `recovery_b`
- Safety policy during validation: preserve stock `recovery_a`

## Source baseline

- Manifest: `TWRP-Test/platform_manifest_twrp_aosp`
- Manifest branch: `twrp-16.0`
- Recovery fork: `polygraphene/android_bootable_recovery`
- Recovery branch: `twrp-16.0-TB322FC`
- Pinned recovery commit: `ced4ad75f311fc8a3350e21de415c23d5f0aec74`
- Lunch: `twrp_TB323FU bp2a eng`
- Physical kernel page size: 4 KiB

## Proven fix3b core

- `/metadata` is F2FS.
- Android 16 userdata FBE uses
  `aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0`.
- Metadata encryption uses `aes-256-xts:wrappedkey_v0`.
- Userdata mount uses `inlinecrypt`.
- dm-default-key options format is forced to version 2.
- TWRP legacy Keymaster compatibility fallback is `4.x`.
- StrongBox KeyMint VINTF declaration is V4.
- normal Power-button screen blank/wake is enabled.
- A/B partition list includes `dataext`.
- board shipping API is `202504`.
- product shipping API and target VNDK are `36`.
- the stale Android 16 `copySqliteDb()` call is removed.
- only `magiskboot` receives the targeted 4K page-size prebuilt exception.

## Runtime validation

Validated on the working fix3b image:

- boot
- portrait display
- touch
- normal screen blank/wake
- external microSD
- `/metadata`
- live `/data` decrypt/mount
- `/data/media`
- TWRP backup
- TWRP restore
- ADB
- MTP
- sideload transport
- recovery-side diagnostic capture

A new full compile is not required merely for publication cleanup; any future
functional source changes still require appropriate build/runtime validation.

## Decryption troubleshooting

For the fix3b SPU KeyMint/Gatekeeper history, including the retirement of the
stale inherited `liblenovokeymint_qti.so`, see
[`DECRYPTION_TROUBLESHOOTING.md`](DECRYPTION_TROUBLESHOOTING.md).
