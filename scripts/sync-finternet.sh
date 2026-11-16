#!/usr/bin/env bash
# Refresh the Finternet UNITS skill (skills/units) from github.com/finternet-io/units-skills.
# Upstream is the source of truth: never edit skills/units here; change upstream, then re-run.
# Usage: scripts/sync-finternet.sh [git-ref]
set -euo pipefail
cd "$(dirname "$0")/.."
ref="${1:-main}"; tmp="$(mktemp -d)"
git clone -q --depth 1 --branch "$ref" https://github.com/finternet-io/units-skills "$tmp"
sha="$(git -C "$tmp" rev-parse HEAD)"
rm -rf skills/units; cp -R "$tmp/skills/units" skills/units
cp "$tmp/LICENSE" skills/units/LICENSE
printf 'Vendored from https://github.com/finternet-io/units-skills/tree/%s/skills/units\nby scripts/sync-finternet.sh. Do not edit here; change upstream and re-sync.\nMIT licensed (see LICENSE in this folder and NOTICE at the repo root).\n' "$sha" > skills/units/UPSTREAM.md
rm -rf "$tmp"; echo "synced units @ ${sha:0:7}"
