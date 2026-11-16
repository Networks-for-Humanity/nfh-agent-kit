#!/usr/bin/env bash
# Refresh the Beckn community skills (skills/beckn-*, dedi-onboarding-builder, devkit-builder)
# from github.com/beckn/beckn-agents (adapters/claude-code/skills). Upstream is the source of
# truth: never edit these folders here; change upstream, then re-run this script.
# Usage: scripts/sync-beckn.sh [git-ref]
set -euo pipefail
cd "$(dirname "$0")/.."
ref="${1:-main}"; tmp="$(mktemp -d)"
git clone -q --depth 1 --branch "$ref" https://github.com/beckn/beckn-agents "$tmp"
sha="$(git -C "$tmp" rev-parse HEAD)"
for d in "$tmp"/adapters/claude-code/skills/*/; do
  name="$(basename "$d")"
  rm -rf "skills/$name"; cp -R "$d" "skills/$name"
  printf 'Vendored from https://github.com/beckn/beckn-agents/tree/%s/adapters/claude-code/skills/%s\nby scripts/sync-beckn.sh. Do not edit here; change upstream and re-sync.\nNot covered by this repository'"'"'s Apache-2.0 license: see NOTICE.\n' "$sha" "$name" > "skills/$name/UPSTREAM.md"
  echo "synced $name @ ${sha:0:7}"
done
rm -rf "$tmp"
