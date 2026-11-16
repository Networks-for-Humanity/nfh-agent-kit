---
name: nfh-devkit
description: 'Stand up a working NFH fabric / Beckn v2 network locally in about 10 minutes — consumer node, provider node, ONIX adapters, Redis and a router — using NFH''s fabric-devkit or beckn/starter-kit, then run discover → select → init → confirm. Use when the user wants to try NFH hands-on, test payloads, or reproduce an issue before touching a real network.'
---

# Run NFH fabric on your machine

Two kits. Use whichever matches the user's goal:

| Kit | Use for |
|---|---|
| https://github.com/beckn/starter-kit | The official 10-minute walkthrough, catalogue publishing, the full lifecycle |
| https://github.com/Networks-for-Humanity/fabric-devkit | NFH sample kits (for example DDM), and bringing your own payloads and Postman collection |

Walkthrough: https://docs.nfh.global/build/getting-started-with-fabric.md

## Prerequisites (check them before starting)

```bash
git --version && docker --version && docker compose version
```

You also need Postman (or curl) and, for callbacks and crawlable catalogues, **ngrok with a static domain** (a free account works).

## Quick start (starter-kit)

```bash
git clone https://github.com/beckn/starter-kit.git
cd starter-kit/generic-devkit/install
docker compose -f docker-compose-generic.yml up -d
docker compose -f docker-compose-generic.yml ps     # wait for running/healthy
```

| Container | Port | Role |
|---|---|---|
| beckn-router | 9000 | Caddy reverse proxy: `/bap/*`, `/bpp/*`, `/beckn/*` |
| onix-bap | 8081 | Consumer-side adapter |
| onix-bpp | 8082 | Provider-side adapter, plus `catalog/publish` |
| sandbox-bap / sandbox-bpp | 3001 / 3002 | Mock apps |
| redis | 6379 | Cache |

Watch messages being signed and routed:
```bash
docker compose -f docker-compose-generic.yml logs -f onix-bap onix-bpp
```

## Public callbacks

`on_discover` is sent to `context.bapUri`, so expose port 9000:
```bash
ngrok http --url=<your-static-domain>.ngrok-free.app 9000
```

## Then

1. Send `discover`, then `select`, `init` and `confirm` with the kit's Postman collection.
2. Swap in the user's own payloads (see `nfh-transact`).
3. Publish a catalogue (see `nfh-catalog-discovery`).
4. Shut down with `docker compose -f docker-compose-generic.yml down`.
