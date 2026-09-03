#!/usr/bin/env bash
set -euo pipefail

TREE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOCK_ROOT=""
UPSTREAM_DIR=""
KEEP_TEMP=0

usage(){
  cat <<EOF
Usage:
  $0 --stock-root PATH [--tree PATH] [--upstream-dir PATH] [--keep-temp]

Examples:
  # On the matching TB323FU itself:
  $0 --stock-root /

  # Against an extracted stock-filesystem root on a build host:
  $0 --stock-root /path/to/TB323FU-stock-root

This stages 103 hash-pinned proprietary files into the ignored recovery paths:
25 from matching TB323FU stock and 78 exact inherited files from the pinned
public TB322FC donor-tree Git history.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE="$2"; shift 2 ;;
    --stock-root) STOCK_ROOT="$2"; shift 2 ;;
    --upstream-dir) UPSTREAM_DIR="$2"; shift 2 ;;
    --keep-temp) KEEP_TEMP=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

die(){ echo "ERROR: $*" >&2; exit 1; }
for c in git python3 sha256sum stat cp mkdir rm mktemp; do
  command -v "$c" >/dev/null 2>&1 || die "Required command missing: $c"
done

[ -n "$STOCK_ROOT" ] || die "--stock-root is required"
[ -d "$TREE/.git" ] || die "Not a Git device tree: $TREE"
[ -f "$TREE/proprietary-files.tsv" ] || die "Missing proprietary-files.tsv"
[ -f "$TREE/proprietary-sources.tsv" ] || die "Missing proprietary-sources.tsv"

"$TREE/scripts/verify-proprietary-sources.sh" "$TREE"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/tb323fu-proprietary.XXXXXX")"
cleanup(){
  if [ "$KEEP_TEMP" -eq 0 ]; then rm -rf "$TMP"; else echo "Kept temp: $TMP"; fi
}
trap cleanup EXIT

STAGE="$TMP/stage"
mkdir -p "$STAGE"

UPSTREAM_URL="https://github.com/polygraphene/android_device_lenovo_TB322FC.git"
UPSTREAM_PIN="c9c6a9f1287e5b416c3480c5fe06b23dc54c9ab8"

if [ -z "$UPSTREAM_DIR" ]; then
  UPSTREAM_DIR="$TMP/TB322FC-upstream"
  git clone -q "$UPSTREAM_URL" "$UPSTREAM_DIR"
fi

[ -d "$UPSTREAM_DIR/.git" ] || die "Invalid --upstream-dir: $UPSTREAM_DIR"
git -C "$UPSTREAM_DIR" cat-file -e "$UPSTREAM_PIN^{commit}" ||
  die "Pinned donor commit unavailable in upstream repo"

python3 - "$TREE/proprietary-sources.tsv" "$STOCK_ROOT" "$UPSTREAM_DIR" "$STAGE" <<'PY'
from pathlib import Path
import hashlib, os, subprocess, sys

source_map = Path(sys.argv[1])
stock_root = Path(sys.argv[2])
upstream = Path(sys.argv[3])
stage = Path(sys.argv[4])

lines = source_map.read_text().splitlines()
header = lines[0].split("\t")
rows = [dict(zip(header, ln.split("\t"))) for ln in lines[1:] if ln.strip()]

def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024*1024), b""):
            h.update(chunk)
    return h.hexdigest()

for i, r in enumerate(rows, 1):
    target = r["target_path"]
    expected = r["expected_sha256"]
    size = int(r["size"])
    out = stage / target
    out.parent.mkdir(parents=True, exist_ok=True)

    if r["acquisition"] == "tb323fu-stock":
        rel = r["source_path"].lstrip("/")
        src = stock_root / rel

        try:
            data = src.read_bytes()
        except (PermissionError, OSError):
            import shlex, shutil
            if str(stock_root) != "/" or shutil.which("su") is None:
                raise SystemExit(f"Cannot read TB323FU stock source: {src}")
            cmd = "cat -- " + shlex.quote(str(src))
            try:
                data = subprocess.check_output(["su", "-c", cmd])
            except subprocess.CalledProcessError:
                raise SystemExit(f"Root-assisted read failed for TB323FU stock source: {src}")

        if len(data) != size or hashlib.sha256(data).hexdigest() != expected:
            raise SystemExit(f"TB323FU stock source mismatch for {target}: {src}")
        out.write_bytes(data)

    elif r["acquisition"] == "public-tb322fc-git":
        oid = r["source_blob_oid"]
        data = subprocess.check_output(["git","-C",str(upstream),"cat-file","blob",oid])
        if len(data) != size or hashlib.sha256(data).hexdigest() != expected:
            raise SystemExit(f"Donor Git blob mismatch for {target}: {oid}")
        out.write_bytes(data)

    else:
        raise SystemExit(f"Unknown acquisition class for {target}")

    if out.stat().st_size != size or sha256(out) != expected:
        raise SystemExit(f"Staged output verification failed: {target}")

print(f"PASS staged and verified {len(rows)} proprietary files")
PY

# Only copy into the tree after every source has been staged and verified.
while IFS=$'\t' read -r target expected size acquisition source_path source_repo source_ref oid commit; do
  [ "$target" != "target_path" ] || continue
  [ -n "$target" ] || continue
  mkdir -p "$(dirname "$TREE/$target")"
  cp -f "$STAGE/$target" "$TREE/$target"
done < "$TREE/proprietary-sources.tsv"

"$TREE/scripts/verify-device-tree.sh" "$TREE"
echo "PASS acquired and verified all 103 TB323FU fix3b proprietary payload files."
