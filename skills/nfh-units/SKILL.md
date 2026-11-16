---
name: nfh-units
description: 'Programmable value on NFH fabric with UNITS (Finternet Lab tokenisation): token classes, token programs with pre/post hooks, minting, transfers, purpose-bound vouchers (e.g. vouchers only spendable on insurance premiums), delegations, RBAC, locks, escrow and federation. Use when the user wants money or assets that carry rules, premium or corporate vouchers, recurring or agent payments, or asks about Finternet, UNITS or Vouch.'
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

Every request has a `context` with `id`, `version`, `ts`, `msgId` and **two separate credentials**. Don't mix them up:

| Field | What it is | Where it comes from |
|---|---|---|
| `context.developerToken` | The calling app: base64 of `<clientId>:<clientSecret>` | `/v1/clients/register`. See https://docs.finternetlab.io/documentation/building/api-clients.md |
| `context.authorization` | The end user's session token (JWT) | An OTP login. An agent can't complete it, so the user signs in and supplies the token through an environment variable such as `UNITS_SESSION_TOKEN`. Never ask for it in chat |

- The API reference marks token-class registration as needing the session token too. In practice a developer token alone has been seen to register classes, but config and mint always need the session token. Follow the API reference.
- Writes can also carry a `signature` (`keyId` plus a JWS of the payload) from the user's registered key.
- The development server is `https://foundry.finternetlab.io`. Confirm the base URL for the user's instance before calling it.
- `/v1/tokenclass/{register,update,get,search}` is an undocumented alias of the canonical `/v1/registry/tokenclasses/*`. Prefer the canonical paths.

## Patterns

| Want | Build with |
|---|---|
| Value spendable only for one purpose, such as an insurance premium | Voucher program, plus a pre-hook that checks the payee category |
| Recurring repayment or an agent spending on someone's behalf | Delegation: scoped, expiring, revocable |
| Escrow or conditional release | Lock, then unlock on a condition |
| Delivery versus payment | Workflows / multi-sig |
| Refund that must return to the lender | Lock rules plus a post-hook |

## Program and hook names: never make them up

Program IDs (such as `purpose-bound-voucher`) and hook IDs must come from a Finternet docs page or from the instance's own program and hook registry. If no built-in hook does what the user needs (for example "payee must be an insurer"), say so. Explain that it needs a **custom hook**: a Rust implementation of the `Hook` trait, bound through the token class config. The guides are https://docs.finternetlab.io/documentation/token-manager-guide/custom-programs.md and https://docs.finternetlab.io/documentation/reference/token-program-interface.md. Write placeholder IDs as `<your-hook-id>`, never as names that look real.

## Finternet docs map (fetch before answering)

| Topic | Page |
|---|---|
| Quickstart | https://docs.finternetlab.io/documentation/building/quickstart.md |
| Accounts, identity (UUIDv7 address, `did:web`, MPC keys) | https://docs.finternetlab.io/documentation/concepts/accounts-and-identity.md |
| Delegation and RBAC | https://docs.finternetlab.io/documentation/concepts/delegation-and-rbac.md |
| Account integration in an app | https://docs.finternetlab.io/documentation/app-developer-guide/account-integration.md |
| Token operations from an app | https://docs.finternetlab.io/documentation/app-developer-guide/token-operations.md |
| Proxy tokens (an external ledger is authoritative) | https://docs.finternetlab.io/documentation/token-manager-guide/proxy-tokens.md |
| Custom token programs (Rust) | https://docs.finternetlab.io/documentation/token-manager-guide/custom-programs.md |
| Token program interface (Rust trait) | https://docs.finternetlab.io/documentation/reference/token-program-interface.md |
| Adapter integration | https://docs.finternetlab.io/documentation/token-manager-guide/adapter-integration.md |
| Corporate vouchers (worked use case) | https://docs.finternetlab.io/documentation/use-cases/corporate-vouchers.md |
| Federation across instances | https://docs.finternetlab.io/api-reference/registry/federation.md |

All 68 pages are listed in [references/finternet-pages.md](references/finternet-pages.md). When the plugin is installed, the `finternet-docs` MCP server can also answer questions directly.

Vouch (purpose-bound value) and Pincer (guarantees) have no public API docs yet, so build these patterns directly on UNITS.
