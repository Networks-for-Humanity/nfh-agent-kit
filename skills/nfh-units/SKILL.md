---
name: nfh-units
description: Programmable value on NFH fabric with UNITS (Finternet Lab tokenisation) — register token classes, bind token programs and pre/post hooks, mint, transfer, and build purpose-bound vouchers, delegations, locks and escrow. Use when the user wants money or assets that carry rules (e.g. a loan that can only pay an insurance premium), recurring or agent payments, or asks about Finternet / UNITS APIs.
---

# UNITS: money and assets with rules

UNITS is a tokenisation system run as independent instances by regulated operators. It is not a blockchain: there is no global consensus and no public token. Docs: https://docs.finternetlab.io/llms.txt (append `.md` to any page URL).

## Concepts (read before writing code)

- Tokens and pools: https://docs.finternetlab.io/documentation/concepts/tokens-and-tokenpools.md. In **native** pools UNITS is the authoritative ledger. In **proxy** pools an external ledger is authoritative and UNITS shadows it.
- Token programs: https://docs.finternetlab.io/documentation/concepts/token-programs.md. Programs are written in Rust. **Pre-hooks** can reject an operation (eligibility, credential, time, supply, voucher category). **Post-hooks** fire events and webhooks.
- Every state change yields a SHA-256 chained commitment, and batches roll up into BLAKE3 Merkle roots.

## The API flow

1. `POST /v1/registry/tokenclasses/register` creates the token class.
2. `POST /v1/tokenclassconfig/register` binds a program and hooks to it.
3. `POST /v1/token/mint`
4. `POST /v1/token/transact` handles transfer, lock, unlock, redeem and similar operations.
5. Writes are **asynchronous**. Poll `/v1/transaction/status` until the transaction is final, and never assume success from the first response.

The step-by-step guides are under https://docs.finternetlab.io/documentation/token-manager-guide/token-manager-guide.md. Copy request bodies from there.

## Access (tell the user up front)

- A developer token can register token classes.
- **Config and mint need a JWT from an OTP login.** An agent can't complete that alone, so the user has to sign in and supply the token through an environment variable (for example `UNITS_TOKEN`). Never ask for it in chat.
- See https://docs.finternetlab.io/documentation/building/api-clients.md

## Patterns

| Want | Build with |
|---|---|
| Value spendable only for one purpose, such as an insurance premium | Voucher program, plus a pre-hook that checks the payee category |
| Recurring repayment or an agent spending on someone's behalf | Delegation: scoped, expiring, revocable |
| Escrow or conditional release | Lock, then unlock on a condition |
| Delivery versus payment | Workflows / multi-sig |
| Refund that must return to the lender | Lock rules plus a post-hook |

Vouch (purpose-bound value) and Pincer (guarantees) have no public API docs yet, so build these patterns directly on UNITS.
