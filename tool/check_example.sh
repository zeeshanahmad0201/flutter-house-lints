#!/usr/bin/env bash
# Checks the plugin end to end on example/, with the flutter and dart on PATH:
# each of the nine rules warns exactly once, all on lib/page.dart, and no rule
# fires anywhere else (so lib/shared_app_bar.dart's ignore_for_file works).
# A plugin that silently fails to load reports nothing and fails here. Other
# analyzer diagnostics (an SDK deprecation, say) are printed but not judged;
# an error still fails the exit-code check.
set -euo pipefail

cd "$(dirname "$0")/../example"
flutter --version | head -n 1
flutter pub get > /dev/null

status=0
output=$(dart analyze --format=machine 2>&1) || status=$?
echo "$output"

# One "SEVERITY rule file" line per plugin diagnostic, from the machine format
# SEVERITY|TYPE|CODE|FILE|LINE|COL|LENGTH|MESSAGE.
actual=$(echo "$output" | awk -F'|' 'NF >= 8 && tolower($3) ~ /^no_raw_/ {
  n = split($4, parts, "/")
  print $1, tolower($3), parts[n - 1] "/" parts[n]
}' | sort)
expected=$(for rule in no_raw_app_bar no_raw_list_tile no_raw_dialog \
  no_raw_bottom_sheet no_raw_button no_raw_text_field no_raw_chip \
  no_raw_card no_raw_snack_bar; do
  echo "WARNING $rule lib/page.dart"
done | sort)

if [[ "$actual" != "$expected" ]]; then
  echo "FAIL: expected exactly these plugin diagnostics:" >&2
  echo "$expected" >&2
  echo "got:" >&2
  echo "${actual:-<none>}" >&2
  exit 1
fi
# Warnings at most (no errors): dart analyze exits 2.
if [[ "$status" != 2 ]]; then
  echo "FAIL: dart analyze exited $status, expected 2 (warnings)." >&2
  exit 1
fi
echo "OK: all nine rules fire on lib/page.dart; lib/shared_app_bar.dart is clean."
