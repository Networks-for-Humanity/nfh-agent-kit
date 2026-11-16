---
name: nfh-observability
description: 'NFH fabric Observability & Audit — end-to-end transaction tracing, commitment-chain anchors, verifiable audit trails, anchoring proofs and selective disclosure. Use when the user needs a tamper-evident record for regulators or auditors, wants to trace a transaction across adapters and instances, resolve a dispute without exposing private state, or configure observability in a network manifest.'
---

# Observability & Audit

Read: https://docs.nfh.global/product-documentation/products/observability-audit.md

## What it gives you

| Capability | What it means |
|---|---|
| Commitment-chain anchors | Each instance periodically publishes a hash of its state to NFH fabric |
| End-to-end traces | Spans that cover every hop: app → ONIX → counterparty ONIX → app |
| Verifiable audit trails | Signed, replayable, cryptographically grounded records |
| Anchoring proofs | BLAKE2 plus chain-anchored proofs for any single record |
| Selective disclosure | Share a slice of the audit trail without revealing the rest |

It is also the **signal-and-health surface**: network telemetry such as flows, instance health and supply summaries, for operators and participants.

**Who runs what:** NFH runs the anchor-acceptance and aggregation service. NFH defines the anchoring formats and audit-record schemas. Participants emit traces from their own ONIX.

## Standards

The service uses OpenTelemetry for traces and BLAKE2 hashing. Instrument apps with standard OpenTelemetry SDKs, and propagate `context.transactionId` and `messageId` as span attributes so one transaction can be followed across parties.

## Turning it on

- **Network level (NFO):** define observability in the network manifest. See section 8 of https://docs.nfh.global/build/creating-a-network/network-policies/network-manifest.md
- **Participant level:** enable ONIX structured logs and tracing in the adapter config. The bundled `beckn-onix-config` skill covers the YAML.
- **Value layer:** UNITS produces its own SHA-256 commitment chain and BLAKE3 Merkle roots. These are separate from fabric anchors, but they serve the same audit purpose (see `nfh-units`).

## Typical asks

1. "Prove to a regulator what happened in transaction X": get the anchored records and the proof, then disclose only that transaction's slice.
2. "Why did this order fail between us and the insurer?": follow the trace across both ONIX adapters, then check for NACK reasons and missing callbacks.

API details for querying anchors and proofs aren't in the public docs yet. Use `?ask=` on the docs page, or contact https://support.nfh.global/. Don't invent endpoints.
