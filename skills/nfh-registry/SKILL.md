---
name: nfh-registry
description: 'Onboard an organisation onto NFH fabric''s registry (REGISTR, built on the DeDi protocol). Use when the user needs to join an NFH network, publish subscriber details (endpoint and public keys), create or verify a namespace on dedi.global, publish DeDi files on their own domain, set up a network as an NFO, add participants, or look up another participant''s record.'
---

# REGISTR: get an identity on NFH fabric

REGISTR is the shared directory every participant uses for identity and routing. It is built on **DeDi**, the Decentralized Directory Protocol (an LF Decentralized Trust lab project). Each participant owns its own record.

Before you start, read https://docs.nfh.global/build/onboarding.md and the worked example at https://docs.nfh.global/build/onboarding/worked-example.md.

## Step 1: Pick role and path

- **Role:** NFO (runs a network) or NP (joins one, or joins on its own and gets added to networks later).
- **Path:**
  - **Hosted:** register on https://dedi.global. Nothing to host, but the user still needs DNS access to add a TXT record that verifies their namespace.
  - **File-based:** publish DeDi files on a domain the user controls.
- An entity writes on **exactly one** path. Never mix both for the same entity.

## Step 2a: Hosted path (dedi.global)

Follow https://docs.nfh.global/build/onboarding/hosted.md:
1. Create and verify the namespace (DNS TXT record).
2. Add a registry.
3. Add subscriber records: endpoint, signing public key, encryption public key, network role.
4. An NFO also adds reference records pointing at its NPs.

## Step 2b: File-based path (own domain)

Follow https://docs.nfh.global/build/onboarding/file-based.md:
- The index file goes at `https://<domain>/.well-known/dedi.index.json`.
- An NP's network key registry goes at `https://<domain>/dedi/<nfo>_<network>_<env>_registry.json`. Use the Beckn Subscriber schema: https://raw.githubusercontent.com/LF-Decentralized-Trust-labs/decentralized-directory-protocol/refs/heads/main/schemas/beckn_subscriber.json
- An NFO's reference registry goes at `https://<domain>/dedi/<nfo>_<network>_<env>_ref_registry.json`. Use the Beckn Subscriber Reference schema in the same repo.
- Sign the files. See https://docs.nfh.global/build/creating-a-network/network-policies/signing-files.md
- An NFO starts at the onboarding portal: https://fabric.nfh.global/#onboarding

Registry names are conventions. The hard rules are that record names are unique within a registry and that the published URLs are correct. A record's name can be reused as the key ID in the ONIX config.

To generate and sign the DeDi index and registry files, use the bundled `dedi-onboarding-builder` skill.

## Step 3: Verify with a lookup

```bash
curl -s https://api.dedi.global/dedi/lookup/<domain>/<registry-name> | jq .
```

## Provider nodes: don't forget this field

To be discoverable, a PN's subscriber record needs `meta.catalog_index_urls` (a list of `{ "url": ... }`). It is not part of the base schema, and **nothing errors if it's missing**: the catalogue just never appears in search. Continue with `nfh-catalog-discovery`.

## Keys

Generate Ed25519 keys locally. Publish only the public keys, and keep the private keys in ONIX's key manager (a file or Vault). Never print private keys into chat.
