---
name: nfh-transact
description: 'Run Beckn Protocol v2 transactions on NFH fabric through the ONIX adapter: select, init, confirm, status, cancel, update and their callbacks (on_select, on_init, on_confirm, on_status). Use when the user is wiring a BAP/consumer or BPP/provider app to ONIX, writing Beckn v2 payloads, configuring ONIX keys, routing, schema validation or Rego policies, or debugging NACKs, signature failures, a missing bapUri callback, or "ACK but no on_select".'
---

# Transact with Beckn v2 through ONIX

Read first:
- Protocol: https://docs.nfh.global/nfh-fabric/open-standards/beckn-protocol.md
- Adapter: https://docs.nfh.global/product-documentation/products/onix.md
- Code: https://github.com/beckn/beckn-onix, and specs at https://github.com/beckn/protocol-specifications-v2

## Companion skills

The Beckn community publishes skills for payloads, schemas and ONIX YAML at https://github.com/beckn/beckn-agents. If they aren't installed, point the user to that repo's README for install steps. They provide `beckn-payload-builder`, `beckn-schema-builder` and `beckn-onix-config`. Use them for payload and config details. This skill covers the NFH-specific flow.

## The lifecycle

```
CN app → ONIX(CN) ──signed──▶ ONIX(PN) → PN app
  select → on_select (quote)   init → on_init (terms, payment)
  confirm → on_confirm (order) status / update / cancel → on_*
```

1. Each call returns a synchronous `ACK` or `NACK`. An ACK carries a `counterSignature` receipt. The business answer **always** comes later as a callback, linked by `context.transactionId` and `inReplyTo`.
2. The app talks plain HTTP to its **own** ONIX. ONIX handles signing (Ed25519), verifying, schema validation, registry lookup for routing, and policy checks.
3. Endpoints follow the `/beckn/{action}` pattern on the adapter.

## Configuring ONIX

- Key ID = the record name in the participant's registry (see `nfh-registry`).
- Private keys go in a file or Vault, never in the repo.
- Network rules (allowed actions, value limits, human approval above a threshold) go in **Rego** policies: https://docs.nfh.global/build/creating-a-network/network-policies/rego-policies.md
- Network-wide settings go in the network manifest: https://docs.nfh.global/build/creating-a-network/network-policies/network-manifest.md

## Debugging checklist

1. **NACK on signature:** does the registry record's public key match the key ONIX signs with? Is the clock in sync?
2. **NACK on schema:** validate the payload against the v2 schema, and check the `@context` URLs.
3. **ACK but no callback:** is `bapUri` publicly reachable? Is the PN app running? Check the ONIX logs on both sides.
4. **Moving from v1:** follow https://docs.nfh.global/build/migration-guides/beckn-v1-to-v2.md
