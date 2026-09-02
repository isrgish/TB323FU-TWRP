#!/usr/bin/env bash
set -euo pipefail
CACHE="${1:-}"
TREE="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="$TREE/proprietary-files.tsv"
die() { echo "ERROR: $*" >&2; exit 1; }
[ -n "$CACHE" ] || die "Usage: $0 /path/to/private-cache [tree-root]"
[ -f "$MANIFEST" ] || die "Manifest missing: $MANIFEST"
[ -d "$CACHE/files" ] || die "Cache files directory missing: $CACHE/files"
command -v sha256sum >/dev/null 2>&1 || die "sha256sum is required"
count=0
while IFS=$'\t' read -r target expected size live_status live_source; do
    [ "$target" != "target_path" ] || continue
    [ -n "$target" ] || continue
    src="$CACHE/files/$target"
    dst="$TREE/$target"
    [ -f "$src" ] || die "Required proprietary file missing: $target"
    actual="$(sha256sum "$src" | awk '{print $1}')"
    [ "$actual" = "$expected" ] || die "Hash mismatch: $target"
    mkdir -p "$(dirname "$dst")"
    cp -f "$src" "$dst"
    installed="$(sha256sum "$dst" | awk '{print $1}')"
    [ "$installed" = "$expected" ] || die "Installed file verification failed: $target"
    count=$((count + 1))
done < "$MANIFEST"
[ "$count" -gt 0 ] || die "Manifest contained no proprietary files"
echo "Staged and verified $count proprietary files."
