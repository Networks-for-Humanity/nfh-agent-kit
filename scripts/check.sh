#!/usr/bin/env bash
# Validate skills against the Agent Skills spec basics and check that every docs link resolves.
# Usage: scripts/check.sh [--offline]
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
python3 -c "import yaml" 2>/dev/null || { echo "check.sh needs PyYAML: pip install pyyaml"; exit 1; }
for f in skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$f")")"
  name="$(awk '/^---/{n++; next} n==1 && /^name:/{sub(/^name: */,""); print; exit}' "$f")"
  desc="$(python3 -c "import sys,yaml; print(yaml.safe_load(open(sys.argv[1]).read().split('---')[1])['description'])" "$f" 2>/dev/null)"
  [[ "$name" == "$dir" ]] || { echo "FAIL $f: name '$name' must equal folder '$dir'"; fail=1; }
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && ${#name} -le 64 ]] || { echo "FAIL $f: bad name"; fail=1; }
  [[ -n "$desc" && ${#desc} -le 1024 ]] || { echo "FAIL $f: description missing or over 1024 chars"; fail=1; }
  lines=$(wc -l < "$f"); [[ $lines -le 500 ]] || { echo "FAIL $f: $lines lines (keep under 500)"; fail=1; }
  grep -q "^## " "$f" || { echo "FAIL $f: no sections"; fail=1; }
done
python3 -c "import json,sys; [json.load(open(p)) for p in sys.argv[1:]]" .claude-plugin/*.json examples/*.json .mcp.json package.json || fail=1
# Parse each frontmatter as real YAML (a stray ': ' in an unquoted description silently breaks a skill)
python3 - skills/*/SKILL.md <<'PY2' || fail=1
import sys, yaml
bad = 0
for p in sys.argv[1:]:
    fm = open(p).read().split("---")[1]
    try:
        d = yaml.safe_load(fm); assert d["name"] and d["description"]
    except Exception as e:
        print(f"FAIL {p}: frontmatter is not valid YAML ({e})"); bad = 1
sys.exit(bad)
PY2
if [[ "${1:-}" != "--offline" ]]; then
  grep -rhoE 'https://(docs\.nfh\.global|docs\.finternetlab\.io)[^ )"`]*\.md' skills AGENTS.md llms/llms.txt | sort -u | while read -r u; do
    code=$(curl -sL -o /dev/null -w '%{http_code}' "$u")
    [[ "$code" == 200 ]] || { echo "FAIL link $code $u"; echo x >> /tmp/nfh-check-links.$$; }
  done
  [[ -f /tmp/nfh-check-links.$$ ]] && { rm -f /tmp/nfh-check-links.$$; fail=1; }
fi
[[ $fail == 0 ]] && echo "OK: $(ls -d skills/*/ | wc -l | tr -d ' ') skills valid" || exit 1
