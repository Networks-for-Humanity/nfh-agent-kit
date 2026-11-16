# Example: buy now, pay later for an insurance premium

A worked use case that touches every part of NFH. Paste the prompt below into Claude with the `nfh` plugin installed.

## Who does what

| Party | NFH role | Skills |
|---|---|---|
| Insurer | Provider node: publishes health plans | `nfh-registry`, `nfh-catalog-discovery` |
| Lender (e.g. a BNPL app) | Consumer node: search, credit decision, pays the premium | `nfh-transact`, `nfh-units` |
| Customer | Holds a reusable KYC credential | `nfh-credentials` |

## Flow

1. Lender app → DISCOVR `discover` "health cover" → `on_discover` returns plans and offers.
2. Customer picks a plan. The lender verifies their KYC credential, so no new KYC is needed.
3. `select` / `init` with the insurer returns the quote and terms.
4. The lender mints a **premium-only voucher** in UNITS. A pre-hook means the payee must be a licensed insurer and the purpose must be a premium.
5. `confirm` with the payment reference. The insurer redeems the voucher and `on_confirm` issues the policy.
6. The customer repays monthly under a revocable UNITS **delegation**.

This design is illustrative. Vouch has no public API yet, so steps 4 and 6 use UNITS primitives directly.

## Prompt to try

```
Using the nfh skills, set up a local NFH sandbox and walk me through the BNPL
premium flow in examples/bnpl-premium. I am the lender. Start with the devkit,
then show me the discover request for "health cover", then the init payload.
Stop before anything that needs real credentials and tell me what I need.
```
