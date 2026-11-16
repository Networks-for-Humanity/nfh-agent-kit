# AGENTS.md — building on NFH fabric

You are helping someone build on **NFH fabric**, the open network run by Networks for Humanity (NFH). Through it, banks, insurers, merchants, platforms and AI agents can find each other, agree a deal, pay under rules and trust the other side. They don't need a custom integration for every pair.

This file tells any coding agent (Claude, Codex, Copilot, Cursor, Gemini and others) how to work with NFH. The skills in `skills/` hold the step-by-step workflows.

## Ground rules

1. **The docs are the source of truth, not this file.** Every docs page is available as Markdown by adding `.md` to its URL. The full index is at https://docs.nfh.global/llms.txt.
2. **Ask the docs when unsure.** With the plugin installed, use the bundled `nfh-docs`, `finternet-docs` and `dedi-docs` MCP servers. Without them, send `GET https://docs.nfh.global/index.md?ask=<question>&goal=<user goal>`. It returns an answer with sources. Do this before guessing a field name, endpoint or schema.
3. **Never invent endpoints, schema fields or URLs.** If the docs don't have something, say so and point the user to https://support.nfh.global/.
4. **Keys stay with the participant.** Never ask the user to paste a private signing key into chat. Generate keys locally, and store them where ONIX expects them (a file or Vault).
5. **Start in the sandbox.** Use `fabric-devkit` or `beckn/starter-kit` before touching any production network.

## The map: what each piece does

| Need | NFH piece | Skill | Docs |
|---|---|---|---|
| Identity: who is on the network, their keys and endpoints | **REGISTR** (built on DeDi) | `nfh-registry` | https://docs.nfh.global/build/onboarding.md |
| Publish a catalogue once, be found everywhere | Self-hosted signed catalogues + **DISCOVR** | `nfh-catalog-discovery` | https://docs.nfh.global/build/creating-a-network/catalog-publishing-and-discovery.md |
| Transact: select, init, confirm, status | **Beckn Protocol v2** via the **ONIX** adapter | `nfh-transact` | https://docs.nfh.global/nfh-fabric/open-standards/beckn-protocol.md |
| Money and assets that carry rules | **UNITS** tokenisation (Finternet Lab) | `nfh-units` | https://docs.finternetlab.io/llms.txt |
| Prove things: KYC, licences, delegation | **VC on Edge** (OpenCred) | `nfh-credentials` | https://docs.nfh.global/product-documentation/products/vc-on-edge.md |
| Run a working network on a laptop | `fabric-devkit` / `beckn/starter-kit` | `nfh-devkit` | https://docs.nfh.global/build/getting-started-with-fabric.md |
| Trace transactions, prove what happened | **Observability & Audit** | `nfh-observability` | https://docs.nfh.global/product-documentation/products/observability-audit.md |
| Start and govern a whole network (NFO) | Manifest, Rego policies, migrations | `nfh-network-operator` | https://docs.nfh.global/build/creating-a-network.md |
| Explain NFH to executives, regulators, partners | Primer, use cases, personas | `nfh-explain` | https://docs.nfh.global/use-cases/use-cases.md |
| Beckn payloads, schemas, ONIX YAML, DeDi files | Beckn community skills | `beckn-agents` plugin | https://github.com/beckn/beckn-agents |

If you don't know which piece the user needs, use the `nfh-start` skill first. For offline lookups, every docs page is listed in `llms/docs-index-nfh.md`, `llms/docs-index-finternet.md` and `llms/docs-index-dedi.md`.

## Vocabulary

- **Consumer node (CN, also BAP):** the buyer-side app. It sends `discover`, `select`, `init`, `confirm`, `status`.
- **Provider node (PN, also BPP):** the seller-side app. It answers asynchronously with `on_discover`, `on_select`, `on_init`, `on_confirm`.
- **NFO:** Network Facilitator Organisation. It runs a network and keeps a reference registry of its participants.
- **NP:** Network Participant. It publishes its own subscriber record (endpoint and keys).
- **ONIX:** the adapter each participant runs on its own infrastructure. It signs (Ed25519), validates schemas, routes, and enforces Rego policies. NFH never sees the traffic.
- **Ack / Nack:** the immediate synchronous reply. The real answer always arrives later as a callback.

## How a transaction works (memorise this)

```
CN ──discover──▶ DISCOVR ──on_discover──▶ CN        (catalogue search)
CN ──select/init/confirm──▶ ONIX ──▶ PN            (signed, validated)
PN ──on_select/on_init/on_confirm──▶ CN            (async callbacks to bapUri)
```

Every request carries a `context`: `version` "2.0.0", `action`, `messageId`, `transactionId`, `timestamp`, `bapId`, `bapUri` and `networkId`. Callbacks go to `context.bapUri`. That URL must be reachable from the public internet; use ngrok when testing locally.

## Status of each piece (be honest with users about this)

| Piece | Status |
|---|---|
| REGISTR, DISCOVR, Beckn v2, ONIX | Production |
| VC on Edge / OpenCred | Beta |
| UNITS | Live instances. Writes need a token from an OTP login, so a human has to sign in first |
| Vouch (purpose-bound value), Pincer (guarantees) | No public API docs yet. Build the same behaviour on UNITS vouchers and pre-hooks |
| Observability & Audit | Service live; public query API not documented yet |

## When working in this repo

- Skills live in `skills/<name>/SKILL.md` and follow the Agent Skills standard (https://agentskills.io). Keep each SKILL.md under about 200 lines and put long material in `references/`.
- Run `scripts/check.sh` before committing. It validates every skill's frontmatter and links.
- Add an eval task to `evals/tasks.md` for every new skill.
