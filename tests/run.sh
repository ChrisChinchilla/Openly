#!/usr/bin/env bash
# Runs Vale over each fixtures/<name> directory and checks two things:
#   1. Files named pass*.md raise no alerts.
#   2. The full output matches fixtures/<name>/expected.txt. Other files, such as
#      fail*.md, are meant to raise alerts: Vale finding problems there shows the
#      rules work, so the alerts are recorded rather than treated as failures.
# It also checks that every rule in Openly/ raises at least one alert in some
# fixture, so a new rule needs a failing example.
# Pass --update to regenerate the expected files after an intentional change.
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
status=0

for dir in "$root"/fixtures/*/; do
  name="$(basename "$dir")"
  # --no-exit because Vale exits non-zero when it reports errors, which is expected.
  actual="$(cd "$dir" && vale --output=line --sort --normalize --relative --no-exit . 2>&1)"

  if [[ "${1:-}" == "--update" ]]; then
    printf '%s\n' "$actual" > "$dir/expected.txt"
    echo "updated $name"
    continue
  fi

  if unexpected="$(grep '^pass' <<<"$actual")"; then
    echo "FAIL: $name has alerts in a pass file:" >&2
    echo "$unexpected" >&2
    status=1
  fi

  if ! diff -u "$dir/expected.txt" <(printf '%s\n' "$actual"); then
    echo "FAIL: $name output differs from expected.txt" >&2
    status=1
  elif [[ $status -eq 0 ]]; then
    echo "ok: $name"
  fi
done

if [[ "${1:-}" != "--update" ]]; then
  for rule in "$root"/Openly/*.yml; do
    rule="$(basename "$rule" .yml)"
    if ! grep -qs "Openly\.${rule}:" "$root"/fixtures/*/expected.txt; then
      echo "FAIL: no fixture triggers Openly.${rule}" >&2
      status=1
    fi
  done
fi

exit "$status"
