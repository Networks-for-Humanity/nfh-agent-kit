---
name: nfh-credentials
description: Issue, verify and revoke W3C Verifiable Credentials on NFH fabric with VC on Edge (OpenCred) — KYC reuse, licences, capability and delegation credentials for agents. Use when the user wants to prove something about a customer, business or agent, reuse a KYC done elsewhere, give an agent scoped authority, or run the OpenCred Docker image/API.
---

# VC on Edge (OpenCred): proofs that travel

**Status: beta.** Read the security model before production use: https://docs.nfh.global/product-documentation/products/vc-on-edge/security.md

Concepts (VCs, DIDs, trust chains, revocation): https://docs.nfh.global/product-documentation/products/vc-on-edge/concepts.md

## Run it headless

```bash
docker pull ghcr.io/nfh-trust-labs/opencred/opencred-server:1.2.0   # pin a version in production
```

Then follow https://docs.nfh.global/product-documentation/products/vc-on-edge/docker.md to mount a signing key and start the server. It listens on port 3100 by default.

| Endpoint | Does |
|---|---|
| `GET /v1/health` | Readiness and signing-key status |
| `GET /v1/schemas` | Available credential schemas |
| `POST /v1/credentials/issue` | Issue one credential |
| `POST /v1/credentials/batch` | Batch issuance |
| `POST /v1/credentials/verify` | Verify JSON-LD, vc-jwt, sd-jwt-vc, a PixelPass QR or a PDF |
| `POST /v1/credentials/revoke` | Revoke a credential |
| `POST /v1/credentials/revocation-status` | Check whether a credential is revoked |

There are four ways to verify, all using the same engine: https://docs.nfh.global/product-documentation/products/vc-on-edge/verifying.md

## Common uses on NFH

- **KYC reuse:** a bank issues a KYC credential once. A lender or insurer verifies it during Beckn `init` instead of redoing KYC.
- **Agent authority:** issue a time-bounded, scope-bounded credential from a person or organisation to an agent. Revoking it takes one call. See https://docs.nfh.global/build/agents.md
- **Gating value:** a UNITS pre-hook can require a valid credential before a transfer goes through (see `nfh-units`).

Never put real personal data into test credentials.
