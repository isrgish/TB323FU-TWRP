#!/usr/bin/env bash
set -euo pipefail

CACHE="${1:-}"
TREE="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="$TREE/prebuilt-tools.tsv"

die() { echo "ERROR: $*" >&2; exit 1; }

[ -n "$CACHE" ] || die "Usage: $0 /path/to/private-tools-cache [tree-root]"
[ -d "$CACHE/files" ] || die "Tool cache missing: $CACHE/files"
[ -f "$MANIFEST" ] || die "Tool manifest missing: $MANIFEST"
command -v sha256sum >/dev/null 2>&1 || die "sha256sum is required"

count=0
while IFS=$'\t' read -r target expected size status; do
    [ "$target" != "target_path" ] || continue
    [ -n "$target" ] || continue

    src="$CACHE/files/$target"
    dst="$TREE/$target"

    [ -f "$src" ] || die "Required prebuilt tool missing: $target"
    actual="$(sha256sum "$src" | awk '{print $1}')"
    [ "$actual" = "$expected" ] || die "Hash mismatch: $target"

    mkdir -p "$(dirname "$dst")"
    cp -f "$src" "$dst"

    installed="$(sha256sum "$dst" | awk '{print $1}')"
    [ "$installed" = "$expected" ] || die "Installed verification failed: $target"
    count=$((count + 1))
done < "$MANIFEST"

[ "$count" -eq 6 ] || die "Expected to stage 6 prebuilt tools, staged $count"
echo "Staged and verified $count prebuilt shell tools."
