#!/usr/bin/env bash
set -euo pipefail

TREE="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="$TREE/proprietary-files.tsv"
SOURCES="$TREE/proprietary-sources.tsv"

die(){ echo "ERROR: $*" >&2; exit 1; }

[ -f "$MANIFEST" ] || die "Missing proprietary-files.tsv"
[ -f "$SOURCES" ] || die "Missing proprietary-sources.tsv"

python3 - "$MANIFEST" "$SOURCES" <<'PY'
from pathlib import Path
import sys

manifest = Path(sys.argv[1])
sources = Path(sys.argv[2])

def rows(path):
    lines = path.read_text().splitlines()
    header = lines[0].split("\t")
    return header, [dict(zip(header, ln.split("\t"))) for ln in lines[1:] if ln.strip()]

mh, mr = rows(manifest)
sh, sr = rows(sources)

if len(mr) != 103:
    raise SystemExit(f"Expected 103 proprietary manifest rows, found {len(mr)}")
if len(sr) != 103:
    raise SystemExit(f"Expected 103 proprietary source rows, found {len(sr)}")

m = {r["target_path"]: r for r in mr}
s = {r["target_path"]: r for r in sr}

if len(m) != 103 or len(s) != 103:
    raise SystemExit("Duplicate target_path detected")
if set(m) != set(s):
    missing = sorted(set(m)-set(s))
    extra = sorted(set(s)-set(m))
    raise SystemExit(f"Source-map target mismatch; missing={missing} extra={extra}")

stock = donor = 0
for target in sorted(m):
    a, b = m[target], s[target]
    if a["sha256"] != b["expected_sha256"]:
        raise SystemExit(f"SHA mismatch between manifests: {target}")
    if a["size_bytes"] != b["size"]:
        raise SystemExit(f"Size mismatch between manifests: {target}")
    kind = b["acquisition"]
    if kind == "tb323fu-stock":
        stock += 1
        if not b["source_path"].startswith(("/vendor/","/odm/","/system/","/system_ext/","/product/")):
            raise SystemExit(f"Invalid stock source_path: {target}")
    elif kind == "public-tb322fc-git":
        donor += 1
        if not b["source_blob_oid"] or len(b["source_blob_oid"]) != 40:
            raise SystemExit(f"Invalid donor blob OID: {target}")
        if not b["source_commit"] or len(b["source_commit"]) != 40:
            raise SystemExit(f"Invalid donor commit: {target}")
    else:
        raise SystemExit(f"Unknown acquisition class {kind!r}: {target}")

if stock != 25 or donor != 78:
    raise SystemExit(f"Expected 25 stock / 78 donor rows, found {stock} / {donor}")

if "liblenovokeymint_qti.so" in "\n".join(m):
    raise SystemExit("Retired liblenovokeymint_qti.so must not be required")

print("PASS proprietary source map: 103 targets = 25 TB323FU stock + 78 public donor-history")
PY
