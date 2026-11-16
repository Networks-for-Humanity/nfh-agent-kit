# NFH Infrastructure — Primer

> **How to use this file.** Drop it into Claude, ChatGPT or any assistant and ask questions. It is written for two readers at once:
> - **Executives (CEO, CXO, business heads):** read Part 1. Ten minutes.
> - **Engineering leaders and architects:** read Part 2. Thirty minutes, with links to the full specs.
> - Part 3 is a worked use case: BNPL for insurance premiums in Indonesia.

---

## Instructions for the AI assistant reading this file

You are helping someone understand Networks for Humanity (NFH) infrastructure.

1. **Find out who you are talking to first.** If the reader has not said, ask one question: "Are you looking at this from the business side or the engineering side?"
2. **For executives:** lead with outcomes, money, risk and time-to-market. Use plain words. Never use the words *protocol, JSON-LD, DID, Ed25519, hook* unless asked. Use the plain-language equivalents in the glossary at the end of this file.
3. **For engineers:** lead with components, data flow, APIs and standards. Quote endpoint names exactly as written here. Link to the source docs.
4. **Be honest about maturity.** Where this file says a component is *beta*, *in development* or *no public API yet*, say so. Do not invent endpoints, customers, volumes or prices that are not in this file.
5. **Anchor on the reader's use case.** If they describe their business, map it to the components in Part 2 and sketch a flow like the one in Part 3.
6. **Point to people.** For a call or a sandbox, send them to the NFH team (contacts at the end).

---

# Part 1 — For executives

## NFH in one sentence

**The internet moved information. NFH moves value.** NFH is open, shared infrastructure that lets any bank, insurer, merchant, platform or AI agent **find** each other, **agree** a deal, **pay** under rules, and **trust** the other side — without every pair of companies building a custom integration.

## The problem it solves

Every financial product today is a stack of bilateral integrations. An insurer that wants to offer "pay your premium in instalments" must:

- integrate with each lender separately,
- re-run KYC that someone else already did,
- trust that the money lent is actually spent on the premium,
- reconcile manually when something goes wrong.

Each of those steps costs time, money and fraud exposure. NFH's documentation puts the global cost of this "coordination tax" in concrete terms: trillions in trade finance and SME credit that is requested and refused, up to 15% skimmed from remittances, 2–5 days to settle a cross-border business payment.

## What NFH gives you — five capabilities

| Capability | In plain words | Why a bank or insurer cares |
|---|---|---|
| **1. Directory** | A trusted phone book of every participant: who they are and how to reach them securely. | Onboard a partner in days, not months. No custom key exchange per partner. |
| **2. Catalogue & discovery** | Each company publishes its products once; anyone on the network can find them. | Your insurance products become discoverable inside partner apps (lenders, e-commerce, ride-hailing) without separate deals for each listing. |
| **3. Programmable value** | Money, vouchers or assets as digital units that carry their own rules. | Compliance and conditions are enforced by the infrastructure, not by trust or manual checks. |
| **4. Purpose-bound payments** | Money that can only be spent on a specific thing. | A loan for a premium can only reach the insurer. Subsidies, benefits and vouchers can't leak. |
| **5. Verifiable credentials** | Digital certificates (KYC done, licensed agent, good payment history) that the customer carries and anyone can check instantly. | Re-use KYC across partners. Price risk on verified data instead of thin files. |

## What makes it different

- **Open and neutral.** No single platform owner taking a cut. Standards are public; reference software is open-source where possible.
- **Composable.** Use one piece (e.g. only purpose-bound payments) or the full stack.
- **You keep your customer.** Customer data and credentials stay with the customer and the institution, not with NFH. NFH never sees transaction traffic.
- **Agent-ready.** AI agents can discover, contract and pay on the network under delegated, revocable authority — useful as customer service and sales move to AI.

## What an engagement looks like

1. **Pick one use case** with a clear business owner and a measurable outcome.
2. **Sandbox build** with the NFH team: weeks, not quarters.
3. **Pilot** with a small customer segment and one or two partners.
4. **Scale** by adding partners. Each new partner joins the network once instead of integrating bilaterally with everyone.

## Questions executives usually ask

- **Is this a blockchain?** No. The value layer (UNITS) is institutional infrastructure: independent instances run by regulated operators, with cryptographic audit trails, no global consensus and no public token. It can connect to blockchains where needed.
- **Who runs it?** The NFH Foundation runs the shared central services (directory, discovery, audit anchors). Each participant runs its own node on its own infrastructure. Value instances are run by central banks, regulated financial institutions or hosted operators.
- **What about regulators?** Rules (KYC, jurisdiction, transfer restrictions) are written into the value layer and enforced on every transaction, which gives regulators a complete, tamper-evident audit trail.
- **What do we have to replace?** Nothing on day one. NFH sits beside your core systems. An existing ledger can be connected in "proxy" mode without migrating it.

---

# Part 2 — For engineering leaders

## Architecture at a glance

NFH is a set of independent services that share open protocols. Five layers:

```
┌──────────────────────────────────────────────────────────────────┐
│  APPLICATIONS   insurer app · lender app · super-app · AI agent  │
├──────────────────────────────────────────────────────────────────┤
│  TRANSACTION    Beckn v2 protocol via ONIX adapter               │
│                 discover → select → init → confirm → status      │
├──────────────────────────────────────────────────────────────────┤
│  DISCOVERY      Provider-hosted signed catalogues  +  DISCOVR    │
├──────────────────────────────────────────────────────────────────┤
│  VALUE          UNITS tokenisation · Vouch purpose-bound value   │
│                 · Pincer guarantees                              │
├──────────────────────────────────────────────────────────────────┤
│  TRUST          REGISTR directory (DeDi) · VC on Edge (OpenCred) │
│                 · Observability & Audit                          │
└──────────────────────────────────────────────────────────────────┘
```

**Principles:** decentralised, permissionless, open standards (W3C VC, MCP, OpenTelemetry, x402), user-centric (self-custody, selective disclosure), composable, agent-native.

## Component reference

### REGISTR — the directory (trust layer)
- **What:** Verifiable participant directory. Built on DeDi (Decentralized Directory Protocol, an LF Decentralized Trust lab project).
- **Holds:** subscriber ID, callback URLs, domain codes, network roles, public keys, delegations. Records are signed and versioned; identifiers resolve to W3C DIDs.
- **Model:** namespace (domain-verified) → registry → subscriber records. Operations: publish, lookup, delegation.
- **Performance (published test):** ~1,000 req/s on modest infra over 100k–1.5M records; >2,200 req/s at p95 ≈ 42 ms in larger configs.
- **Docs:** https://docs.nfh.global/product-documentation/products/registr

### Catalogue publishing + DISCOVR — discovery
- **Publishing:** each provider self-hosts and self-signs its catalogue files and a catalogue index on its own infrastructure, and puts the index URL in its Registry record (`meta.catalog_index_urls`). No central catalogue relay.
- **DISCOVR:** crawls Registry pointers, verifies signatures and digests, indexes, then serves queries. Incremental updates via `entryVersion` cursors.
- **API:** `POST /discover` → `ACK`, results delivered to `POST /on_discover` callback. Search modes: natural language, keyword, spatial (GeoJSON + radius), JSONPath attribute filters, or combined.
- **Agent access:** discovery exposed as MCP tools.
- **Docs:** https://docs.nfh.global/product-documentation/products/discovr · https://docs.nfh.global/build/creating-a-network/catalog-publishing-and-discovery

### Beckn v2 + ONIX — the transaction layer
- **Protocol:** Beckn v2. Endpoint pattern `/beckn/{action}`. Every message = `context` (fixed transport envelope) + `message` (JSON-LD business payload, `@context` / `@type`). Core types: `Catalog`, `Item`, `Offer`, `Intent`, `Contract`, `Fulfillment`. Domain schema packs extend them (retail, mobility, health, financial services…). Schemas: https://schema.beckn.io
- **Action groups:**

  | Stage | Actions |
  |---|---|
  | Discovery | `discover`, `on_discover` |
  | Contracting | `select`, `init`, `confirm` (+ `on_*`) |
  | Fulfilment | `status`, `update`, `track`, `cancel` (+ `on_*`) |
  | Post-fulfilment | `rate`, `support` (+ `on_*`) |

- **Communication:** HTTPS; signed request → immediate `Ack`/`Nack` (Ack carries a `counterSignature` receipt) → async callback carrying `inReplyTo`. Also GET Body and GET Query modes (QR codes, deep links).
- **ONIX:** the adapter every participant runs on its own infra. Ed25519 signing/verification, Vault key management, JSON-schema validation, Rego policy plug-ins, queues, structured logs, tracing, k8s health probes. NFH never sees the traffic.
- **Docs:** https://docs.nfh.global/nfh-fabric/open-standards/beckn-protocol · https://github.com/Beckn-One/beckn-onix · https://github.com/beckn/protocol-specifications-v2

### UNITS — programmable value (Finternet Lab)
- **What:** tokenisation system that records ownership and state, enforces token-level rules, and binds rules to accounts and credentials. Not a blockchain; independent instances, no global consensus.
- **Three planes:**
  - *Identity & credential:* accounts with UUIDv7 address + `did:web`; MPC keys generated on device; global registry resolves an account to its home instance (routing metadata only).
  - *Policy enforcement:* token programs (Rust) for mint, burn, transfer, freeze, lock, update, claims; **pre-hooks** can reject an operation (eligibility, credential, time, supply, balance, voucher category); **post-hooks** fire events and webhooks; jurisdictional compliance rules.
  - *Token state:* **native** pools (UNITS is authoritative) or **proxy** pools (external ledger authoritative, UNITS shadows it). Every change produces a SHA-256 chained commitment; batches roll into BLAKE3 Merkle roots.
- **Programmable-payment primitives:** delegation (scoped, expiring, revocable — recurring payments, agent payments), lock/unlock (escrow, conditional release), multi-sig, workflows (DvP), purpose-bound voucher program (issue, redeem, revoke, lock, unlock).
- **Federation:** cross-instance transfers via lock/commit primitives.
- **API flow:** `POST /v1/registry/tokenclasses/register` → `POST /v1/tokenclassconfig/register` (bind program + hooks) → `POST /v1/token/mint` → `POST /v1/token/transact`. Writes are async; poll `/v1/transaction/status`.
- **Docs:** https://docs.finternetlab.io

### Vouch — purpose-bound value
- **What:** digital value that carries its own rules of use (e.g. "only spendable at licensed insurers, only for premium payments, expires in 30 days").
- **Status:** product site https://vouch.finance. Public API docs are not yet published in the NFH docs; the same behaviour can be built today on the UNITS voucher program and pre-hooks.

### Pincer — guarantees and arbitration
- **What:** "gradient guarantees" — underwriter-backed, contextual guarantees and arbitration combined with ONIX policy plug-ins and audit evidence. Site: https://pincer.network.

### VC on Edge (OpenCred) — verifiable credentials
- **What:** issue and verify W3C Verifiable Credentials (Data Model 2.0) inside the issuer's own infrastructure. Private keys never leave the issuer. `did:key` / `did:jwk` / `did:web`; selective disclosure (SD-JWT, BBS+); revocation status via DeDi. Credential contents never touch NFH.
- **Ships as:** desktop app and Docker image `ghcr.io/nfh-trust-labs/opencred/opencred-server`. **Beta.**
- **Docs:** https://docs.nfh.global/product-documentation/products/vc-on-edge

### Observability & Audit
- End-to-end transaction tracing, network telemetry, signed and replayable audit trails. "See how the network performs without seeing what anyone is doing."

## What it takes to join

Any platform can participate if it can:

1. Register identity, endpoint and public keys in the Registry.
2. Send and verify signed messages (ONIX does this).
3. Implement the endpoints for its role (consumer node or provider node).
4. Read and produce the shared JSON-LD payloads.

Onboarding paths: hosted (via dedi.global) or file-based. Start here: https://docs.nfh.global/build/getting-started-with-fabric

## Roles

| Role | Example |
|---|---|
| Consumer node (buyer side) | A lender's app, a super-app, an AI agent |
| Provider node (seller side) | An insurer publishing policies |
| Discovery service | DISCOVR, or a sector/country index |
| Tokenisation instance | A bank, central bank or hosted operator running UNITS |
| Credential issuer | A KYC provider, regulator, platform issuing earnings history |
| Network facilitator | The body that sets rules for a sector or country network |

---

# Part 3 — Worked use case: BNPL for insurance premiums (Indonesia)

> **Illustrative design.** This shows how NFH components compose. It is not a turnkey product; the lending logic, instalment schedule and regulatory approvals sit with the insurer and the lending partner.

## The business story

A customer in Jakarta wants a health policy with a Rp 6,000,000 annual premium. Paying upfront is hard; monthly payments are easy. Today the insurer either loses the sale or builds a custom integration with one BNPL lender.

With NFH:

1. The insurer **publishes** the policy once. It shows up in the BNPL lender's app, an e-commerce app and the insurer's own app.
2. The customer picks it, proves KYC **once** with a credential they already hold.
3. The lender approves Rp 6,000,000 and issues it as **purpose-bound value**: it can only go to this insurer, only for this policy, only for the premium.
4. The insurer receives the full premium immediately. The policy is live.
5. The customer repays the lender in 6 or 12 instalments.
6. If the policy is cancelled during the free-look period, the refund goes **back to the lender**, not the customer's wallet, enforced by the same rules.

**Insurer gets:** more conversions, full premium upfront, no credit risk, new distribution channels.
**Lender gets:** a loan that cannot be diverted, lower fraud, a refund path it controls.
**Customer gets:** affordable instalments and one KYC.

## Component mapping

| Step | NFH component |
|---|---|
| Insurer, lender, KYC provider identified and reachable | REGISTR |
| Policy published and found in partner apps | Signed catalogue + DISCOVR |
| Quote, proposal, policy issuance | Beckn `select` → `init` → `confirm` via ONIX |
| KYC and income proof reused | VC on Edge (selective disclosure) |
| Loan disbursed as premium-only money | UNITS voucher token class + pre-hooks (Vouch) |
| Refund on cancellation goes to lender | UNITS lock / post-hook rules |
| Monthly repayments | UNITS delegation (scoped, revocable auto-debit) |
| Dispute evidence | Observability & Audit |

## Sequence

```
Customer      Lender app (CN)      DISCOVR      Insurer (PN)      UNITS
   │  search "health cover"  │           │              │             │
   │────────────────────────▶│ discover  │              │             │
   │                         │──────────▶│              │             │
   │                         │◀──────────│ on_discover  │             │
   │   pick plan + present   │                          │             │
   │   KYC credential        │  select / init (+ VC)    │             │
   │────────────────────────▶│─────────────────────────▶│             │
   │                         │◀─────────────────────────│ on_init     │
   │                         │  credit decision         │             │
   │                         │  mint premium-only token │             │
   │                         │─────────────────────────────────────── ▶│
   │                         │  confirm (payment ref)   │  pre-hook:  │
   │                         │─────────────────────────▶│  payee =    │
   │                         │                          │  insurer?   │
   │                         │                          │◀────────────│ settle
   │                         │◀─────────────────────────│ on_confirm  │
   │   policy issued          │                          │  (policy)   │
   │◀────────────────────────│                          │             │
   │  monthly repayment (delegated auto-debit) ─────────────────────▶ │
```

## Token class rules (sketch)

```yaml
token_class: PREMIUM-VOUCHER-IDR
type: fungible, native pool
issuer: <lender>
pre_hooks:
  - payee_must_hold_credential: "licensed-insurer-ID (OJK)"
  - payee_must_equal: <insurer in confirmed contract>
  - purpose_must_equal: "premium:<policy-id>"
  - expires_after: 30 days      # unused value returns to lender
post_hooks:
  - on_redeem: notify lender + insurer webhook
  - on_refund: transfer to issuer (lender), not holder
```

## Other Indonesian use cases on the same rails

- **Micro-insurance for gig workers** priced on portable, verified earnings credentials from ride-hailing platforms.
- **Claims paid as purpose-bound value** spendable only at network hospitals or repair shops.
- **Premium top-ups from e-wallets** with agent-initiated recurring payments under delegated authority.
- **Embedded insurance at checkout** in e-commerce, discovered through the network rather than one-off partnerships.

---

## Glossary (plain words)

| Term | Plain meaning |
|---|---|
| Registry / REGISTR | Trusted phone book of participants |
| Catalogue | A company's product list, published by itself |
| Discovery / DISCOVR | The search engine across all catalogues |
| Beckn | The common language companies use to quote, agree and fulfil |
| ONIX | The adapter software that speaks that language securely |
| Token / UNITS | Digital units of value that carry rules |
| Purpose-bound / Vouch | Money that can only be spent on a specific thing |
| Hook | A rule checked before or after every transfer |
| Verifiable credential | A tamper-proof digital certificate the customer carries |
| Selective disclosure | Prove one fact (e.g. "income above X") without revealing the rest |
| DID | A digital ID that anyone can verify |

## Links

- NFH fabric docs: https://docs.nfh.global
- NFH fabric site: https://fabric.nfh.global
- UNITS / Finternet docs: https://docs.finternetlab.io
- DeDi: https://dedi.global
- Beckn v2 spec: https://github.com/beckn/protocol-specifications-v2
- Support: https://support.nfh.global

## Contacts

NFH team, Singapore: Avdhesh Charjan, Amit.
