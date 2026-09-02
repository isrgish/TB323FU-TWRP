#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-}"
die() { echo "ERROR: $*" >&2; exit 1; }

[ -n "$ROOT" ] || die "Usage: $0 /path/to/external/magisk-prebuilt"
[ -d "$ROOT" ] || die "Directory not found: $ROOT"

mapfile -t BP_FILES < <(
    grep -RIl --include='Android.bp' \
      -E 'name[[:space:]]*:[[:space:]]*"magiskboot"' \
      "$ROOT" 2>/dev/null || true
)

[ "${#BP_FILES[@]}" -eq 1 ] ||
    die "Expected exactly one Android.bp defining magiskboot; found ${#BP_FILES[@]}"

BP="${BP_FILES[0]}"

python3 - "$BP" <<'PY'
from pathlib import Path
import re, sys

p = Path(sys.argv[1])
lines = p.read_text().splitlines(keepends=True)

name_re = re.compile(r'^\s*name\s*:\s*"magiskboot"\s*,?\s*$')
matches = [i for i, line in enumerate(lines) if name_re.match(line.rstrip("\n"))]
if len(matches) != 1:
    raise SystemExit(f"Expected one magiskboot name property, found {len(matches)}")

name_i = matches[0]

start = None
for i in range(name_i, -1, -1):
    if "{" in lines[i]:
        start = i
        break
if start is None:
    raise SystemExit("Could not locate magiskboot module opening brace")

depth = 0
end = None
for i in range(start, len(lines)):
    depth += lines[i].count("{")
    depth -= lines[i].count("}")
    if depth == 0:
        end = i
        break
if end is None or end < name_i:
    raise SystemExit("Could not locate magiskboot module closing brace")

module_text = "".join(lines[start:end+1])
if re.search(r'(?m)^\s*ignore_max_page_size\s*:', module_text):
    if not re.search(
        r'(?m)^\s*ignore_max_page_size\s*:\s*true\s*,?\s*$',
        module_text,
    ):
        raise SystemExit(
            "magiskboot already has ignore_max_page_size but it is not true"
        )
    print("magiskboot ignore_max_page_size=true already present")
else:
    indent = re.match(r'^(\s*)', lines[name_i]).group(1)
    lines.insert(name_i + 1, f"{indent}ignore_max_page_size: true,\n")
    p.write_text("".join(lines))
    print("Added magiskboot ignore_max_page_size=true")
PY

grep -n -B3 -A8 \
  -E 'name[[:space:]]*:[[:space:]]*"magiskboot"|ignore_max_page_size' "$BP"

grep -qE 'ignore_max_page_size[[:space:]]*:[[:space:]]*true' "$BP" ||
    die "magiskboot exception verification failed"
