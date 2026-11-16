# NFH agent kit

Build on **NFH fabric** (Networks for Humanity) with Claude, Codex, Cursor or any other AI agent. Install it once, then ask things like "set me up as an insurer on NFH" or "build the BNPL premium flow".

## Install

**Claude Code**
```
/plugin marketplace add Networks-for-Humanity/nfh-agent-kit
/plugin install nfh@nfh
```

**Codex, or any agent that reads Agent Skills**
```bash
git clone https://github.com/Networks-for-Humanity/nfh-agent-kit
nfh-agent-kit/scripts/install.sh codex     # or: claude | agents | <folder>
```

**Pi ([pi.dev](https://pi.dev))**
```bash
pi install git:github.com/Networks-for-Humanity/nfh-agent-kit
```

**Claude.ai, ChatGPT or any chat assistant:** upload [`llms/NFH-primer.md`](llms/NFH-primer.md) and ask your question.

## What's inside

| Path | What it is | Standard |
|---|---|---|
| [`AGENTS.md`](AGENTS.md) | How any coding agent should work with NFH | [AGENTS.md](https://agents.md) |
| [`skills/`](skills) | Ten step-by-step workflows, listed below | [Agent Skills](https://agentskills.io) |
| [`llms/`](llms) | `llms.txt` proposed for nfh.global, the one-file NFH primer, and offline page indexes for the NFH, Finternet and DeDi docs (`scripts/sync-docs.sh`) |
| [`.mcp.json`](.mcp.json) | Live docs servers for NFH, Finternet and DeDi | MCP | [llms.txt](https://llmstxt.org) |
| [`.claude-plugin/`](.claude-plugin) | One-command install for Claude Code | Claude Code plugins |
| [`mcp/`](mcp) | Plan for an MCP server that acts on the sandbox (v2) | [MCP](https://modelcontextprotocol.io) |
| [`examples/`](examples) | The BNPL insurance-premium walkthrough, and an A2A agent-card template | A2A |
| [`evals/`](evals) | 13 tasks an agent with this kit must pass, `run.sh` to run them, and the latest [results](evals/RESULTS.md) | — |
| [`hooks/`](hooks) | Session-start note that tells the agent NFH terms mean NFH fabric | Claude Code hooks |

### Skills

| Skill | Use it to |
|---|---|
| `nfh-start` | Work out your role and which NFH pieces you need |
| `nfh-registry` | Get an identity on REGISTR / DeDi, hosted or on your own domain |
| `nfh-catalog-discovery` | Publish signed catalogues and search with DISCOVR |
| `nfh-transact` | Run Beckn v2 select / init / confirm through ONIX |
| `nfh-units` | Move money and assets that carry rules (UNITS) |
| `nfh-credentials` | Issue and verify credentials (VC on Edge / OpenCred) |
| `nfh-devkit` | Run a full network on your laptop in about 10 minutes |
| `nfh-observability` | Trace transactions and get audit proofs |
| `nfh-network-operator` | Start and govern a network: manifest, Rego policies, migrations |
| `nfh-explain` | Explain NFH to executives, regulators and partners |

**Beckn community skills** (payloads, schemas, ONIX config, DeDi onboarding, devkits) live in [beckn/beckn-agents](https://github.com/beckn/beckn-agents), and the NFH skills defer to them. Until that repo publishes its own marketplace, load them next to this kit:
```bash
git clone https://github.com/beckn/beckn-agents ~/beckn-agents
claude --plugin-dir ~/beckn-agents/adapters/claude-code
```

Installing `nfh` also connects three documentation servers (MCP), for NFH, Finternet and DeDi, so the agent can ask the live docs questions.

## Contributing

1. Edit or add a skill in `skills/<name>/SKILL.md`. The folder name must match the `name:` field.
2. Add an eval task to [`evals/tasks.md`](evals/tasks.md).
3. Run `scripts/check.sh` (needs `pip install pyyaml`). It validates frontmatter and checks that every docs link resolves.

Docs are the source of truth. Skills link to https://docs.nfh.global pages, and don't copy them.

## Help

https://support.nfh.global/ · [fabric-support](https://github.com/Networks-for-Humanity/fabric-support)

## License

Apache-2.0. See [LICENSE](LICENSE).
