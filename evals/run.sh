#!/usr/bin/env bash
# Run every task in evals/tasks.md against a fresh Claude Code agent with only this kit loaded.
# Answers land in evals/results/<timestamp>/<task>.md; grade them against the "Pass if" column.
# Usage: evals/run.sh [task-number ...]     (run from a normal terminal, not inside Claude Code)
set -uo pipefail
kit="$(cd "$(dirname "$0")/.." && pwd)"
out="$kit/evals/results/$(date +%Y%m%d-%H%M)"; mkdir -p "$out"
work="$(mktemp -d)"   # empty working dir, so the agent relies on skills, not on reading this repo
python3 - "$kit/evals/tasks.md" "$@" > "$out/.tasks" <<'PY'
import sys,re
rows=[l for l in open(sys.argv[1]) if re.match(r"\|\s*\d",l)]
want=set(sys.argv[2:])
for r in rows:
    c=[x.strip() for x in r.strip().strip("|").split("|")]
    if want and c[0] not in want: continue
    print(c[0]+"\t"+c[2].strip('"'))
PY
run_one() {
  local id="$1" prompt="$2"
  # prompt goes on stdin: --allowedTools takes a list and would swallow a trailing prompt argument
  ( cd "$work" && printf '%s' "$prompt" | claude -p --plugin-dir "$kit" \
      --allowedTools "Skill,Read,Glob,Grep,WebFetch,mcp__plugin_nfh_nfh-docs,mcp__plugin_nfh_finternet-docs,mcp__plugin_nfh_dedi-docs" \
      ) > "$out/$id.md" 2>&1
  [[ $(wc -c < "$out/$id.md") -lt 5 ]] && echo "(empty answer: the agent ended on a tool call with no final text; rerun with: evals/run.sh $id)" >> "$out/$id.md"
  echo "done $id ($(wc -c < "$out/$id.md") bytes)"
}
export -f run_one; export kit work out
while IFS=$'\t' read -r id prompt; do printf '%s\0%s\0' "$id" "$prompt"; done < "$out/.tasks" \
  | xargs -0 -n2 -P 4 bash -c 'run_one "$0" "$1"'
echo "Results: $out"
