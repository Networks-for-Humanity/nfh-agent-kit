---
name: nfh-start
description: 'Entry point for anyone building on NFH fabric (Networks for Humanity). Use when the user mentions NFH, NFH fabric, Networks for Humanity, Beckn v2 networks, DeDi, REGISTR, DISCOVR, ONIX, UNITS, Finternet, OpenCred, Vouch or Pincer, or asks "how do I build X on NFH". Works out the user''s role and use case, routes to the right NFH skill, and says honestly what is live, beta or not yet public.'
---

# Start building on NFH fabric

## 1. Find the user's role (ask one question if it's unclear)

| If the user is... | They are a... | Go to |
|---|---|---|
| Selling or offering something (an insurer, a lender's product, a merchant, a data provider) | **Provider node (PN)** | `nfh-registry`, then `nfh-catalog-discovery` |
| Building the app where customers search and buy (a super-app, a lender app, an agent) | **Consumer node (CN)** | `nfh-registry`, then `nfh-transact` |
| Moving money or value with rules attached | **Tokenisation user** | `nfh-units` |
| Issuing or checking proofs (KYC, licences, delegation) | **Issuer or verifier** | `nfh-credentials` |
| Running a network for a sector, with rules for everyone | **NFO operator** | `nfh-network-operator` |
| Proving to a regulator or auditor what happened | **Auditor or operator** | `nfh-observability` |
| Explaining NFH, not building | **Briefing someone** | `nfh-explain` |
| "Just show me it working" | Anyone | `nfh-devkit` |

Many real use cases combine roles. For example, insurance BNPL needs an insurer PN, a lender CN, UNITS vouchers and a KYC credential. See `examples/bnpl-premium/` in the nfh-agent-kit repo.

## 2. Confirm the plan before building

State back, in three lines or fewer:
1. The user's role or roles.
2. The NFH pieces involved, and each one's status (production, beta, or not yet public). The status table is in AGENTS.md.
3. The first runnable step, which is almost always the sandbox (`nfh-devkit`).

## 3. Look things up, don't guess

- Docs index: https://docs.nfh.global/llms.txt. Append `.md` to any docs URL to get Markdown.
- Ask the docs: `GET https://docs.nfh.global/index.md?ask=<question>&goal=<goal>`
- Tokenisation docs: https://docs.finternetlab.io/llms.txt
- Human help: https://support.nfh.global/ or https://github.com/Networks-for-Humanity/fabric-support

## Products without public APIs

If asked for the API of **Vouch** (purpose-bound value, vouch.finance) or **Pincer** (underwriter-backed guarantees and arbitration, pincer.network), say plainly that neither has public API docs yet, and invent nothing. For Vouch-style behaviour, use UNITS vouchers and pre-hooks (`nfh-units`). For Pincer, point the user to https://support.nfh.global/.

## Explaining NFH to a non-technical person

Use the one-liner "The internet moved information. NFH moves value." Then add: "Instead of building a custom integration with every partner, each company connects once to shared, open rails for identity, discovery, contracting and payment." For a full briefing, load `llms/NFH-primer.md` from the nfh-agent-kit repo.
