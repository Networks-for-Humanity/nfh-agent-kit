#!/usr/bin/env bash
# Copy the NFH skills into an agent's skills folder.
# Usage: scripts/install.sh [claude|codex|agents|<custom dir>]
#   claude  -> ~/.claude/skills        (Claude Code, user-wide)
#   codex   -> ~/.codex/skills         (OpenAI Codex CLI, user-wide)
#   agents  -> ./.agents/skills        (project-level folder read by several tools)
# Claude Code users can instead run:
#   /plugin marketplace add Networks-for-Humanity/nfh-agent-kit
#   /plugin install nfh@nfh
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
case "${1:-claude}" in
  claude) dest="$HOME/.claude/skills" ;;
  codex)  dest="$HOME/.codex/skills" ;;
  agents) dest="$PWD/.agents/skills" ;;
  *)      dest="$1" ;;
esac
mkdir -p "$dest"
for s in "$here"/skills/*/; do
  name="$(basename "$s")"
  rm -rf "${dest:?}/$name"
  cp -R "$s" "$dest/$name"
  echo "installed $name -> $dest/$name"
done
