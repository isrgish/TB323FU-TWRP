#!/usr/bin/env bash
set -euo pipefail

TREE="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
die() { echo "ERROR: $*" >&2; exit 1; }

for f in \
  BoardConfig.mk device.mk recovery.fstab system.prop \
  recovery/root/system/etc/twrp.flags \
  recovery/root/system/etc/init/tb323fu-crypto-fix3.rc \
  proprietary-files.tsv \
  patches/0001-android16-remove-stale-copySqliteDb.patch \
  scripts/apply-magiskboot-4k-exception.sh \
  scripts/stage-proprietary-files.sh
do
    [ -f "$TREE/$f" ] || die "Required file missing: $f"
done

grep -q 'dataext' "$TREE/BoardConfig.mk" || die "dataext missing from A/B list"
! grep -qE '^[[:space:]]*TW_NO_SCREEN_BLANK[[:space:]]*:=' "$TREE/BoardConfig.mk" ||
    die "TW_NO_SCREEN_BLANK must not disable normal blank/wake"
grep -qE '^TW_FORCE_KEYMASTER_VER[[:space:]]*:=[[:space:]]*true' "$TREE/BoardConfig.mk" ||
    die "TW_FORCE_KEYMASTER_VER=true missing"

grep -qE 'BOARD_SHIPPING_API_LEVEL[[:space:]]*:=[[:space:]]*202504' "$TREE/device.mk" ||
    die "BOARD_SHIPPING_API_LEVEL incorrect"
grep -qE 'PRODUCT_SHIPPING_API_LEVEL[[:space:]]*:=[[:space:]]*36' "$TREE/device.mk" ||
    die "PRODUCT_SHIPPING_API_LEVEL incorrect"
grep -qE 'PRODUCT_TARGET_VNDK_VERSION[[:space:]]*:=[[:space:]]*36' "$TREE/device.mk" ||
    die "PRODUCT_TARGET_VNDK_VERSION incorrect"

grep -q 'fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0' \
  "$TREE/recovery.fstab" || die "Exact Android 16 userdata FBE policy missing"
grep -q 'metadata_encryption=aes-256-xts:wrappedkey_v0' \
  "$TREE/recovery.fstab" || die "Metadata encryption policy missing"
grep -q 'fsync_mode=nobarrier,inlinecrypt' "$TREE/recovery.fstab" ||
    die "inlinecrypt mount option missing"

grep -qE '^/metadata[[:space:]]+f2fs[[:space:]]+' \
  "$TREE/recovery/root/system/etc/twrp.flags" || die "/metadata must be F2FS"

grep -q '^keymaster_ver=4.x$' "$TREE/system.prop" || die "keymaster_ver=4.x missing"
grep -q '^ro.crypto.dm_default_key.options_format.version=2$' "$TREE/system.prop" ||
    die "dm-default-key options format v2 missing"

grep -q 'setprop keymaster_ver 4.x' \
  "$TREE/recovery/root/system/etc/init/tb323fu-crypto-fix3.rc" ||
    die "init keymaster fallback missing"
grep -q 'setprop ro.crypto.dm_default_key.options_format.version 2' \
  "$TREE/recovery/root/system/etc/init/tb323fu-crypto-fix3.rc" ||
    die "init dm-default-key v2 property missing"

COUNT="$(awk -F '\t' 'NR>1 && $1!=""{c++} END{print c+0}' "$TREE/proprietary-files.tsv")"
[ "$COUNT" -eq 104 ] || die "Expected 104 proprietary manifest targets, found $COUNT"

if grep -RInE \
  'git[[:space:]]+config[[:space:]]+--global[[:space:]]+user\.(name|email)' \
  "$TREE" --exclude-dir=.git >/dev/null 2>&1; then
    die "A script still modifies global Git identity"
fi

echo "TB323FU device-tree static verification: PASS"
echo "Proprietary manifest targets: $COUNT"
