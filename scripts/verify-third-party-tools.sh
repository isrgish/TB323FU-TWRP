#!/usr/bin/env bash
set -euo pipefail
TREE="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
die(){ echo "ERROR: $*" >&2; exit 1; }
count=0
while IFS=$'\t' read -r target expected size status rest; do
  [ "$target" != "target_path" ] || continue; [ -n "$target" ] || continue
  [ -f "$TREE/$target" ] || die "Missing third-party tool: $target"
  [ "$(sha256sum "$TREE/$target" | awk '{print $1}')" = "$expected" ] || die "Hash mismatch: $target"
  [ "$(stat -c '%s' "$TREE/$target")" = "$size" ] || die "Size mismatch: $target"
  count=$((count+1))
done < "$TREE/prebuilt-tools.tsv"
[ "$count" -eq 6 ] || die "Expected 6 tools, found $count"
[ -f "$TREE/docs/THIRD_PARTY_TOOLS.md" ] || die "Missing third-party tools documentation"
[ -f "$TREE/THIRD_PARTY_SOURCE_BUNDLE.sha256" ] || die "Missing source-bundle checksum pointer"
echo "TB323FU third-party recovery tool verification: PASS"
echo "Tracked tool targets: $count"
