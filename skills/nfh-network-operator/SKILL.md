---
name: nfh-network-operator
description: 'Operator playbook for creating and running a network on NFH fabric as a Network Facilitator Organisation (NFO) — registering the network, onboarding participants, network manifest, signed Rego policies distributed to ONIX, catalog discovery for the network, migrations from Beckn v1 and the central catalog service. Use when the user wants to start or govern a sector network (insurance, mobility, energy, commerce) rather than join one.'
---

# Run a network on NFH fabric (NFO playbook)

Start here: https://docs.nfh.global/build/creating-a-network.md

## The path (do the steps in order)

| Step | Guide |
|---|---|
| 1. Set up the network environment and register the network | https://docs.nfh.global/build/creating-a-network/environment.md |
| 2. Onboard network participants (NPs) | https://docs.nfh.global/build/creating-a-network/onboarding-participants.md. The registry mechanics are in the `nfh-registry` skill |
| 3. Publish and discover catalogues | https://docs.nfh.global/build/creating-a-network/catalog-publishing-and-discovery.md, or the `nfh-catalog-discovery` skill |
| 4. Configure network policies | https://docs.nfh.global/build/creating-a-network/network-policies.md |
| 5. Build the nodes that transact | The `nfh-transact` skill |

## Network manifest

The manifest is the network's rulebook. The registry points to it, and every participant's ONIX reads it. It holds the top-level fields, the policies, the observability settings and the governance section.

Guide: https://docs.nfh.global/build/creating-a-network/network-policies/network-manifest.md. Copy the field names from that guide, not from memory.

## Policies (Rego / OPA)

1. Write Rego rules and a decision rule. Examples: allowed actions per role, value caps, human approval above a threshold.
2. Organise the rules in a policy repository.
3. Build and **sign** the OPA bundle or Rego file with an OpenSSL key pair. See https://docs.nfh.global/build/creating-a-network/network-policies/signing-files.md
4. Test the policies before publishing.
5. Publish, then reference the published policy in the manifest. Participants add `checkPolicy` to their ONIX handler steps.

Guide: https://docs.nfh.global/build/creating-a-network/network-policies/rego-policies.md

## Migrations

- Moving from Beckn v1 to v2: https://docs.nfh.global/build/migration-guides/beckn-v1-to-v2.md
- Moving from the central catalog service to self-hosted catalogues: https://docs.nfh.global/build/migration-guides/catalog-service-to-decentralized-catalog.md

## Good questions to settle with the user first

1. Which sector and region is the network for, and who are the first 3 to 5 participants?
2. Hosted (dedi.global) or file-based registry for the NFO?
3. Which policies are mandatory on day one: KYC credential required, value limits, or human approval?
4. Will the network run its own DISCOVR, or use a shared one?
