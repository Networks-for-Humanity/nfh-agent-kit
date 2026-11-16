#!/usr/bin/env bash
# Validate skills against the Agent Skills spec basics and check that every docs link resolves.
# Usage: scripts/check.sh [--offline]
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
for f in skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$f")")"
  name="$(awk '/^---/{n++; next} n==1 && /^name:/{sub(/^name: */,""); print; exit}' "$f")"
  desc="$(awk '/^---/{n++; next} n==1 && /^description:/{sub(/^description: */,""); print; exit}' "$f")"
  [[ "$name" == "$dir" ]] || { echo "FAIL $f: name '$name' must equal folder '$dir'"; fail=1; }
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && ${#name} -le 64 ]] || { echo "FAIL $f: bad name"; fail=1; }
  [[ -n "$desc" && ${#desc} -le 1024 ]] || { echo "FAIL $f: description missing or over 1024 chars"; fail=1; }
  lines=$(wc -l < "$f"); [[ $lines -le 500 ]] || { echo "FAIL $f: $lines lines (keep under 500)"; fail=1; }
  grep -q "^## " "$f" || { echo "FAIL $f: no sections"; fail=1; }
done
python3 -c "import json,sys; [json.load(open(p)) for p in sys.argv[1:]]" .claude-plugin/*.json examples/*.json || fail=1
if [[ "${1:-}" != "--offline" ]]; then
  grep -rhoE 'https://(docs\.nfh\.global|docs\.finternetlab\.io)[^ )"`]*\.md' skills AGENTS.md llms/llms.txt | sort -u | while read -r u; do
    code=$(curl -sL -o /dev/null -w '%{http_code}' "$u")
    [[ "$code" == 200 ]] || { echo "FAIL link $code $u"; echo x >> /tmp/nfh-check-links.$$; }
  done
  [[ -f /tmp/nfh-check-links.$$ ]] && { rm -f /tmp/nfh-check-links.$$; fail=1; }
fi
[[ $fail == 0 ]] && echo "OK: $(ls -d skills/*/ | wc -l | tr -d ' ') skills valid" || exit 1
