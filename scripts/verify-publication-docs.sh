#!/usr/bin/env bash
set -euo pipefail

TREE="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

die(){ echo "ERROR: $*" >&2; exit 1; }

for p in \
  README.md \
  NOTICE \
  docs/INDEX.md \
  docs/PUBLICATION_STATUS.md \
  docs/KNOWN_GOOD.md \
  docs/BUILDING.md \
  docs/PROPRIETARY_FILES.md \
  docs/THIRD_PARTY_TOOLS.md \
  docs/DECRYPTION_TROUBLESHOOTING.md \
  TREE_PROVENANCE.md \
  docs/LICENSING.md
do
  [ -e "$TREE/$p" ] || die "Required publication document missing: $p"
done

grep -q 'TB323FU_PUBLICATION_DOCS_BEGIN' "$TREE/README.md" ||
  die "README publication documentation section missing"

# Do not allow accidental target regression to the donor device.
if git -C "$TREE" grep -n -I -E \
  'PRODUCT_(DEVICE|MODEL)[[:space:]]*:=[[:space:]]*TB322FC|twrp_TB322FC' \
  -- ':!docs/**' ':!NOTICE' ':!scripts/verify-publication-docs.sh' \
  >/tmp/tb323fu-doc-target.$$ 2>/dev/null; then
  cat /tmp/tb323fu-doc-target.$$ >&2
  rm -f /tmp/tb323fu-doc-target.$$
  die "TB322FC appears as a build/runtime target"
fi
rm -f /tmp/tb323fu-doc-target.$$ 2>/dev/null || true

# Prevent known private workstation/device paths from leaking into tracked
# publication text. These are unnecessary for public users.
if git -C "$TREE" grep -n -I -E \
  '/data/data/com\.termux/files/home|/storage/[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}|TB323FU-maintenance/twrp/private-blobs' \
  -- '*.md' '*.txt' '*.tsv' '*.sh' ':!scripts/verify-publication-docs.sh' \
  >/tmp/tb323fu-doc-private.$$ 2>/dev/null; then
  cat /tmp/tb323fu-doc-private.$$ >&2
  rm -f /tmp/tb323fu-doc-private.$$
  die "Private/local path leaked into tracked publication text"
fi
rm -f /tmp/tb323fu-doc-private.$$ 2>/dev/null || true

python3 - "$TREE" <<'PY'
from pathlib import Path
import re, sys

tree = Path(sys.argv[1]).resolve()
md_files = [p for p in tree.rglob("*.md") if ".git" not in p.parts]
link_re = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
bad = []

for md in md_files:
    text = md.read_text(errors="replace")
    for target in link_re.findall(text):
        target = target.strip()
        if not target or target.startswith(("#", "http://", "https://", "mailto:")):
            continue
        target = target.split("#", 1)[0]
        if not target:
            continue
        dest = (md.parent / target).resolve()
        try:
            dest.relative_to(tree)
        except ValueError:
            bad.append((md.relative_to(tree), target, "outside repository"))
            continue
        if not dest.exists():
            bad.append((md.relative_to(tree), target, "missing"))

if bad:
    for src, target, why in bad:
        print(f"{src}: {target}: {why}", file=sys.stderr)
    raise SystemExit("Broken local Markdown links detected")

print(f"PASS local Markdown links: {len(md_files)} Markdown files checked")
PY

grep -q 'ORS / TWRP command-line behavior' "$TREE/docs/PUBLICATION_STATUS.md" ||
  die "Future ORS roadmap item missing from publication status"

echo "PASS publication documentation"
