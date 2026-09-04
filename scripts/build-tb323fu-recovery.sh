#!/usr/bin/env bash
set -eo pipefail
# Android envsetup scripts are not compatible with set -u.

TREE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC=""
STOCK_ROOT=""
OUT_DIR=""
ARTIFACTS=""
DO_SYNC=0
PREFLIGHT_ONLY=0
SUFFIX="public-build"

MANIFEST_URL="https://github.com/TWRP-Test/platform_manifest_twrp_aosp"
MANIFEST_BRANCH="twrp-16.0"
RECOVERY_URL="https://github.com/polygraphene/android_bootable_recovery"
RECOVERY_BRANCH="twrp-16.0-TB322FC"
RECOVERY_COMMIT="ced4ad75f311fc8a3350e21de415c23d5f0aec74"
DEVICE="TB323FU"
DEVICE_PATH="device/lenovo/TB323FU"
PARTITION_SIZE=104857600

usage(){
  cat <<'USAGE'
Usage:
  scripts/build-tb323fu-recovery.sh --src PATH --stock-root PATH [options]

Required:
  --src PATH          Android/TWRP source checkout.
  --stock-root PATH   Root containing the mapped TB323FU stock files.

Options:
  --sync              Initialize/sync TWRP-Test twrp-16.0 source if needed.
  --out-dir PATH      Build output directory.
  --artifacts PATH    Artifact directory.
  --suffix NAME       Artifact suffix (default: public-build).
  --preflight-only    Prepare/validate everything, but do not compile.
  -h, --help          Show this help.

This script never flashes recovery.
USAGE
}

die(){ echo "ERROR: $*" >&2; exit 1; }
need(){ command -v "$1" >/dev/null 2>&1 || die "Required command missing: $1"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --src) SRC="$2"; shift 2 ;;
    --stock-root) STOCK_ROOT="$2"; shift 2 ;;
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    --artifacts) ARTIFACTS="$2"; shift 2 ;;
    --suffix) SUFFIX="$2"; shift 2 ;;
    --sync) DO_SYNC=1; shift ;;
    --preflight-only) PREFLIGHT_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[ -n "$SRC" ] || die "--src is required"
[ -n "$STOCK_ROOT" ] || die "--stock-root is required"
[ -d "$TREE/.git" ] || die "Device tree is not a Git checkout: $TREE"
for c in git python3 rsync sha256sum grep sed awk find cmp stat tee; do need "$c"; done
[ "$DO_SYNC" -eq 0 ] || need repo

OUT_DIR="${OUT_DIR:-$TREE/.build-out}"
ARTIFACTS="${ARTIFACTS:-$TREE/build-artifacts}"
mkdir -p "$OUT_DIR" "$ARTIFACTS"
RUN_ID="$(date -u +%Y%m%d-%H%M%S)"
RUN_LOG="$ARTIFACTS/build-workflow-$RUN_ID.log"
BUILD_LOG="$ARTIFACTS/recovery-build-$RUN_ID.log"
exec > >(tee -a "$RUN_LOG") 2>&1

echo "=== TB323FU canonical TWRP build workflow ==="
echo "Target device: TB323FU"
echo "TB322FC: upstream donor recovery fork only"

echo "[1/10] Verify canonical metadata..."
"$TREE/scripts/verify-proprietary-sources.sh" "$TREE"
"$TREE/scripts/verify-device-tree.sh" "$TREE"

echo "[2/10] Acquire and verify 103 proprietary files..."
"$TREE/scripts/acquire-proprietary-files.sh" --tree "$TREE" --stock-root "$STOCK_ROOT"
"$TREE/scripts/verify-device-tree.sh" "$TREE"

echo "[3/10] Initialize/sync source if requested..."
if [ ! -d "$SRC/.repo" ]; then
  [ "$DO_SYNC" -eq 1 ] || die "Source checkout missing .repo; rerun with --sync"
  rm -rf "$SRC"
  mkdir -p "$SRC"
  ( cd "$SRC" && repo init --depth=1 -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH" )
fi
if [ "$DO_SYNC" -eq 1 ]; then
  ( cd "$SRC" && repo sync -c --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune --fail-fast --retry-fetches=3 -j2 )
fi
[ -f "$SRC/build/envsetup.sh" ] || die "build/envsetup.sh missing"

echo "[4/10] Pin proven recovery fork commit..."
RECOVERY_DIR="$SRC/bootable/recovery"
[ -d "$RECOVERY_DIR/.git" ] || die "bootable/recovery is not a Git checkout"
if git -C "$RECOVERY_DIR" remote get-url tb322fc-fork >/dev/null 2>&1; then
  git -C "$RECOVERY_DIR" remote set-url tb322fc-fork "$RECOVERY_URL"
else
  git -C "$RECOVERY_DIR" remote add tb322fc-fork "$RECOVERY_URL"
fi
git -C "$RECOVERY_DIR" fetch --no-tags tb322fc-fork "$RECOVERY_BRANCH"
if ! git -C "$RECOVERY_DIR" cat-file -e "$RECOVERY_COMMIT^{commit}" 2>/dev/null; then
  git -C "$RECOVERY_DIR" fetch --no-tags tb322fc-fork "$RECOVERY_COMMIT"
fi
git -C "$RECOVERY_DIR" checkout --detach "$RECOVERY_COMMIT"
[ "$(git -C "$RECOVERY_DIR" rev-parse HEAD)" = "$RECOVERY_COMMIT" ] || die "Recovery revision mismatch"

echo "[5/10] Install TB323FU device-tree contents..."
DEVICE_DIR="$SRC/$DEVICE_PATH"
rm -rf "$DEVICE_DIR"
mkdir -p "$DEVICE_DIR"
for f in Android.bp AndroidProducts.mk BoardConfig.mk device.mk recovery.fstab system.prop twrp_TB323FU.mk; do
  [ -f "$TREE/$f" ] || die "Required device-tree file missing: $f"
  cp -a "$TREE/$f" "$DEVICE_DIR/"
done
rsync -a "$TREE/recovery/" "$DEVICE_DIR/recovery/"
rsync -a "$TREE/prebuilts/" "$DEVICE_DIR/prebuilts/"

echo "[6/10] Stage raw AOSP Android-16 tzdata..."
TZDATA_SRC="$(find "$SRC/system/timezone" -type f -path '*/output_data/iana/tzdata' -print -quit 2>/dev/null)"
[ -n "$TZDATA_SRC" ] || die "Could not locate AOSP output_data/iana/tzdata"
[ -s "$TZDATA_SRC" ] || die "AOSP tzdata is empty"
TZDATA_DST="$DEVICE_DIR/recovery/root/system/usr/share/zoneinfo/tzdata"
mkdir -p "$(dirname "$TZDATA_DST")"
cp -f "$TZDATA_SRC" "$TZDATA_DST"
cmp -s "$TZDATA_SRC" "$TZDATA_DST" || die "Staged tzdata differs from AOSP source"

echo "[7/10] Apply Android-16 recovery + 4K compatibility fixes..."
COPY_PATCH="$TREE/patches/0001-android16-remove-stale-copySqliteDb.patch"
[ -f "$COPY_PATCH" ] || die "copySqliteDb patch missing"
if grep -qF 'android::keystore::copySqliteDb();' "$RECOVERY_DIR/twrp.cpp"; then
  git -C "$RECOVERY_DIR" apply --check "$COPY_PATCH" || die "copySqliteDb patch does not apply"
  git -C "$RECOVERY_DIR" apply "$COPY_PATCH"
fi
! grep -qF 'android::keystore::copySqliteDb();' "$RECOVERY_DIR/twrp.cpp" || die "Stale copySqliteDb remains"
grep -qF 'Decrypt_Page(skip_decryption, datamedia);' "$RECOVERY_DIR/twrp.cpp" || die "Decrypt_Page path missing"
MAGISK_DIR="$SRC/external/magisk-prebuilt"
[ -d "$MAGISK_DIR" ] || die "external/magisk-prebuilt missing"
"$TREE/scripts/apply-magiskboot-4k-exception.sh" "$MAGISK_DIR"

echo "[8/10] Static prebuild validation..."
grep -q 'twrp_TB323FU-bp2a-eng' "$DEVICE_DIR/AndroidProducts.mk" || die "bp2a lunch choice missing"
grep -qE '^PRODUCT_DEVICE[[:space:]]*:=[[:space:]]*TB323FU' "$DEVICE_DIR/twrp_TB323FU.mk" || die "PRODUCT_DEVICE is not TB323FU"
grep -qE '^PRODUCT_MODEL[[:space:]]*:=[[:space:]]*TB323FU' "$DEVICE_DIR/twrp_TB323FU.mk" || die "PRODUCT_MODEL is not TB323FU"
! grep -q 'TW_NO_SCREEN_BLANK' "$DEVICE_DIR/BoardConfig.mk" || die "Screen blanking unexpectedly disabled"
grep -Rqs --include='*.xml' 'IKeyMintDevice/strongbox' "$DEVICE_DIR/recovery/root" || die "StrongBox KeyMint declaration missing"
grep -Rqs --include='*.xml' '<version>[[:space:]]*4[[:space:]]*</version>' "$DEVICE_DIR/recovery/root" || die "KeyMint V4 declaration missing"
[ -s "$TZDATA_DST" ] || die "Recovery tzdata missing"

echo "Pinned recovery: $(git -C "$RECOVERY_DIR" rev-parse HEAD)"
echo "tzdata SHA256:  $(sha256sum "$TZDATA_DST" | awk '{print $1}')"

if [ "$PREFLIGHT_ONLY" -eq 1 ]; then
  echo "PREBUILD VALIDATION: PASS"
  echo "No compile invoked (--preflight-only)."
  exit 0
fi

echo "[9/10] Select TB323FU bp2a target..."
cd "$SRC"
export OUT_DIR ALLOW_MISSING_DEPENDENCIES=true USE_CCACHE=0
export GOMAXPROCS="${GOMAXPROCS:-1}" GOGC="${GOGC:-10}" GOMEMLIMIT="${GOMEMLIMIT:-6GiB}"
unset USE_LANDSCAPE
set +e
source build/envsetup.sh
rc=$?
set -e
[ "$rc" -eq 0 ] || die "envsetup failed with $rc"
set +e
lunch twrp_TB323FU bp2a eng
rc=$?
set -e
[ "$rc" -eq 0 ] || die "lunch failed with $rc"
[ "${TARGET_PRODUCT:-}" = "twrp_TB323FU" ] || die "Unexpected TARGET_PRODUCT=${TARGET_PRODUCT:-unset}"

echo "[10/10] Build recovery with conservative concurrency..."
set +e
m -j1 recoveryimage 2>&1 | tee "$BUILD_LOG"
BUILD_RC=${PIPESTATUS[0]}
set -e
[ "$BUILD_RC" -eq 0 ] || die "Recovery build failed with $BUILD_RC"
IMAGE="$OUT_DIR/target/product/$DEVICE/recovery.img"
[ -s "$IMAGE" ] || die "Build completed without recovery.img"
IMAGE_SIZE="$(stat -c '%s' "$IMAGE")"
[ "$IMAGE_SIZE" -le "$PARTITION_SIZE" ] || die "recovery.img exceeds 104857600-byte partition"
SAFE_SUFFIX="$(printf '%s' "$SUFFIX" | sed 's/[^A-Za-z0-9._-]/_/g')"
OUT_IMAGE="$ARTIFACTS/TWRP-3.7.1-16-TB323FU-$(date -u +%Y%m%d)-portrait-${SAFE_SUFFIX}.img"
cp -f "$IMAGE" "$OUT_IMAGE"
sha256sum "$OUT_IMAGE" > "$OUT_IMAGE.sha256"
echo "BUILD COMPLETE"
echo "Image: $OUT_IMAGE"
echo "SHA256: $(awk '{print $1}' "$OUT_IMAGE.sha256")"
echo "This workflow does not flash recovery."
