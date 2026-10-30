#!/usr/bin/env bash
# Runs Vale over each fixtures/<name> directory and compares the output with
# fixtures/<name>/expected.txt. Pass --update to regenerate the expected files.
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
status=0

for dir in "$root"/fixtures/*/; do
  name="$(basename "$dir")"
  # Vale exits non-zero when it reports errors, which is expected here.
  actual="$(cd "$dir" && vale --output=line --sort --normalize --relative --no-exit . 2>&1)"

  if [[ "${1:-}" == "--update" ]]; then
    printf '%s\n' "$actual" > "$dir/expected.txt"
    echo "updated $name"
  elif ! diff -u "$dir/expected.txt" <(printf '%s\n' "$actual"); then
    echo "FAIL: $name" >&2
    status=1
  else
    echo "ok: $name"
  fi
done

exit "$status"
