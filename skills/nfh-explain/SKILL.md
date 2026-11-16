---
name: nfh-explain
description: 'Explain NFH fabric and Networks for Humanity to anyone (bank or insurer CEOs, CXOs, regulators, partners, engineers) in plain language: what it is, why open rails matter, principles, capabilities, personas, sector use cases (insurance BNPL, energy, cross-border commerce, health supply, arbitration, creator economy, agent data marketplaces), FAQs and glossary. Use for pitches, briefings, one-pagers, bullet summaries, FAQs, or "explain NFH" / "why should my bank care".'
---

# Explain NFH

## Pick the audience first

| Audience | Lead with | Avoid |
|---|---|---|
| CEO / CXO | The problem: one custom integration for every partner. Then what they gain: new distribution, lower fraud, faster partnerships | Protocol names |
| Regulator | Compliance built into the rails, audit trails anyone can verify, participants keep their own data | Crypto framing. UNITS is **not** a blockchain |
| Head of engineering | The five layers and the open standards behind them (Beckn v2, DeDi, W3C VCs, OpenTelemetry) | Marketing language |
| Partner or startup | "Connect once, reach every participant", plus the 10-minute devkit | Long roadmaps |

## Must-haves for a CEO or CXO answer

1. Include the integration math: 6 companies means 15 custom integrations today, or 6 connections with NFH (with 20 partners, 190 versus 20).
2. Name zero protocols or products: no UNITS, Finternet, DID, Beckn, ONIX or "token runtime". Say "a trusted directory", "money that carries its own rules", "proofs that travel".
3. Tie every point to a business outcome: new distribution, lower fraud, faster partnerships, compliance built in.
4. No hype lines such as "the most inclusive market in history". Stay factual.

## Core message

- **One line:** "The internet moved information. NFH moves value."
- **The problem:** with 6 companies, every pair builds its own integration, which is 15 integrations. With NFH, each company connects once, which is 6 connections. With 20 partners it's 20 instead of 190.
- **The five capabilities:** a trusted directory (REGISTR), publish once and be found everywhere (DISCOVR), contracting through one protocol (Beckn via ONIX), money with rules (UNITS), and proofs that travel (VC on Edge). Under all of them sits verifiable audit.

## Sources (fetch and quote these, don't paraphrase from memory)

- Offerings: https://docs.nfh.global/about-nfh-offerings/readme.md
- Why open rails: https://docs.nfh.global/nfh-fabric/open-rails.md
- Principles: https://docs.nfh.global/nfh-fabric/principles.md
- Capabilities: https://docs.nfh.global/nfh-fabric/capabilities.md
- Personas: https://docs.nfh.global/use-cases/personas.md
- Agents as participants: https://docs.nfh.global/nfh-fabric/agents.md
- Use cases (overview, with each sector page linked): https://docs.nfh.global/use-cases/use-cases.md
- Long-form primer with an exec part, a tech part, the BNPL example, a glossary and an FAQ: `llms/NFH-primer.md` in this kit
- Full page list: `llms/docs-index-nfh.md`

## Sector one-liners (expand from the use-case pages)

| Sector | Pitch |
|---|---|
| Insurance + lending | Pay premiums in instalments. The loan can only ever reach the insurer |
| Energy | Peer-to-peer rooftop solar, and procurement at data-centre scale |
| Commerce | Small sellers own the customer relationship; trade across borders without card-network chains |
| Health | Prequalified medicines sourced across borders, with end-to-end traceability |
| Justice | Arbitration and court-grade digital evidence as an open network |
| Agents | Agents hold an identity, act under delegated authority, buy data and are accountable |

## Honesty rules

- Say which pieces are in production and which are beta or have no public API yet (the status table is in AGENTS.md).
- Present any BNPL or sector flow as illustrative unless the docs describe it as live.
- Don't quote market-size numbers unless they come from an NFH page, and cite the page.
