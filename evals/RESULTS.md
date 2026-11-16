# Eval results

Run with `evals/run.sh`: a fresh Claude Code agent (2.1.63), only this kit loaded, an empty working directory, and tools limited to Skill, Read, Glob, Grep, WebFetch and the docs MCP servers.

## 2026-11-16 (v0.2.1)

| # | Skill | First run | Final | What changed |
|---|---|---|---|---|
| 1 | nfh-start | Pass | Pass | — |
| 2 | nfh-registry | Pass | Pass | — |
| 3 | nfh-catalog-discovery | Pass | Pass | — |
| 3b | nfh-catalog-discovery | Fail (told the user to read a crawl log they can't access) | Pass | Provider-runnable checks, plus what to send the DISCOVR operator |
| 4 | nfh-transact | Fail (no skill loaded) | Pass | Trigger words in the description, plus a SessionStart context hook |
| 5 | nfh-units | Fail (no skill loaded) | Pass | The hook, plus a credentials table (`developerToken` vs `authorization`), plus "never invent hook IDs" (one run made up `category-check`) |
| 6 | nfh-credentials | Fail (prompt had no NFH context) | Pass | Prompt now says NFH, as a real user would |
| 7 | nfh-devkit | Partial | Partial | The plan is right, but the eval harness doesn't allow Bash, so it stopped to ask for approval. Expected |
| 8 | nfh-start (Pincer) | Fail (answered about a Discord library) | Pass | SessionStart hook, plus a Vouch/Pincer section |
| 9 | nfh-observability | Fail (answered about blockchains) | Pass | Prompt says NFH |
| 10 | nfh-network-operator | Fail (answered about OJK licensing) | Pass | Prompt says NFH. Now opens with the setup question |
| 11 | nfh-explain | Partial (jargon, missed the integration math) | Pass | CEO must-haves: the 15-vs-6 math and no product names |
| 12 | nfh-units | Pass | Pass | — |

**Final: 12 pass, 1 partial (expected), 0 fail.**

Also found during these runs:
- **UNITS endpoints:** the Finternet guides use `/v1/tokenclass/register`, and the API reference uses `/v1/registry/tokenclasses/register` (canonical). Both work; the skill now says so.
- **Empty answer:** one run of task 10 ended on a tool call with no final text. The runner now flags empty answers.
