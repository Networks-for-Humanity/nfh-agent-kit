---
name: nfh-units
description: 'Programmable value on NFH fabric with UNITS (Finternet Lab tokenisation): token classes, token programs with pre/post hooks, minting, transfers, purpose-bound vouchers (e.g. vouchers only spendable on insurance premiums), delegations, RBAC, locks, escrow and federation. Use when the user wants money or assets that carry rules, premium or corporate vouchers, recurring or agent payments, or asks about Finternet, UNITS or Vouch.'
---

# UNITS: money and assets with rules

UNITS is a tokenisation system run as independent instances by regulated operators. It is not a blockchain: there is no global consensus and no public token. Docs: https://docs.finternetlab.io/llms.txt (append `.md` to any page URL).

**For field-level detail, load the bundled `units` skill.** It is Finternet's own skill, compiled from the UNITS source and tested against the sandbox. It covers exact payloads, scopes, error codes, worked examples, runnable clients (`examples/units-client.ts`, `units_client.py`, `quickstart.sh`), ready-made token-class JSON and program authoring. This skill gives the NFH context and the patterns. When the two differ on a detail, `units` wins.

The OpenAPI and JSON-LD schemas (including an `nfh-voucher` token-class schema) are at https://github.com/finternet-io/specs. They are licensed CC BY-NC-SA, so link to them; don't copy them.

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
| `context.developerToken` | The calling app (a service account): base64 of `<clientId>:<clientSecret>` | Self-serve in the web portal's **API Access** page. Calling `/v1/clients/register` directly returns 403, because it needs a superadmin |
| `context.authorization` | `Bearer <jwt>`: the end user's session (the HTTP `Authorization` header is **not** read) | OTP login (`/v1/account/login`). The access token lasts about 10 h, but the session idles out after 30 min without `/v1/account/refresh`, and refresh tokens are single-use |

| Environment | API | OTP |
|---|---|---|
| Sandbox ("sanctum") | `https://units.sanctum.finternetlab.io` (portal `sanctum.finternetlab.io`). Up about 08:00–21:00 IST on weekdays | The fixed OTP `123456` is accepted, but send-OTP may still email or text a real contact, so use test identities you control |
| Production | `https://units.finternetlab.io` (portal `my.finternetlab.io`) | Real OTP only. There is no non-OTP operator path yet |

### Login recipe (exact; don't invent other auth endpoints)

There is **no** `/v1/auth/*` path. Login is one endpoint, `POST /v1/account/login`, called twice. Both calls need the developer token (scope `accounts:manage`):

```json
{ "context": { "id": "api.account.login", "version": "1.0", "ts": "<ISO-8601>", "msgId": "<uuid>",
               "developerToken": "<base64 clientId:clientSecret>" },
  "payload": { "username": "<email or phone>" } }
```
Then send the same request again with `"payload": { "username": "<same>", "otp": "123456" }` (the fixed sandbox OTP). If the account exists, the response holds `accessToken`, `refreshToken`, `expiresIn: 36000` and `refreshExpiresIn: 1800`. If `isExisting` is false, the token is an OTP JWT that can only call `/v1/account/create`. Keep a session alive with `POST /v1/account/refresh` (`payload.refreshToken`) on a timer under 30 minutes, behind a single-flight lock: reusing a refresh token revokes the whole session. Full detail is in `units` → `references/auth-and-onboarding.md` §4 and §6. **Read that file before writing any auth code.**

- In production an agent can't complete the OTP login. The user signs in and supplies the session through an environment variable such as `UNITS_SESSION_TOKEN`. Never ask for it in chat.
- Writes can also carry a `signature` (`keyId` plus a JWS of the JCS-canonical payload) from a key registered with `/v1/account/keys/register`.
- `/v1/tokenclass/{register,update,get,search}` and `/v1/registry/tokenclasses/*` hit the same controller. Either works.

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
