# Eval tasks

Each task is a prompt given to a fresh agent with only this kit installed, plus a pass rule. Run them before every release. CI checks only the structure; these tasks check behaviour.

| # | Skill | Prompt | Pass if the agent... |
|---|---|---|---|
| 1 | nfh-start | "I'm an insurer. How do I sell policies on NFH?" | Names the provider-node role and routes to registry, then catalogue. Invents no endpoints |
| 2 | nfh-registry | "Publish my subscriber record on my own domain example.com for network nfo-x mobility prod" | Uses `/.well-known/dedi.index.json` and `/dedi/nfo-x_mobility_prod_registry.json`, and never asks for a private key |
| 3 | nfh-catalog-discovery | "My catalogue never shows up in discover. Why?" | Checks `meta.catalog_index_urls` first |
| 3b | nfh-catalog-discovery | "My NFH catalogue never shows up in discover. I already checked catalog_index_urls. Check the DISCOVR crawl log for my subscriber ID." | Says providers can't read a shared DISCOVR's crawl log. Gives the self-checks, offers a local DISCOVR, and drafts the request to the operator |
| 4 | nfh-transact | "I get ACK but never receive on_select" | Checks whether `bapUri` is publicly reachable and looks at the ONIX logs |
| 5 | nfh-units | "Mint 100 vouchers only spendable on premiums" | Lays out class → config with pre-hook → mint → poll status, and flags that the OTP-login token comes from the user |
| 6 | nfh-credentials | "Verify this KYC credential" | Uses `POST /v1/credentials/verify` and says VC on Edge is beta |
| 7 | nfh-devkit | "Show me NFH working on my laptop" | Checks prerequisites, then runs the starter-kit compose file and explains ngrok |
| 8 | any | "What's Pincer's API?" | Says there are no public API docs yet. Invents nothing |
| 9 | nfh-observability | "A regulator wants proof of what happened in transaction X" | Uses anchors, proofs and selective disclosure, and says the query API isn't public yet. Invents no endpoint |
| 10 | nfh-network-operator | "I want to start an insurance network in Indonesia" | Asks the setup questions, follows the five-step path, and says policies must be signed and referenced in the manifest |
| 11 | nfh-explain | "Explain NFH to a bank CEO in 5 bullets" | Plain language, no protocol jargon, and gives the 15-vs-6 integrations point |
| 12 | nfh-units | "How do delegations work in UNITS?" | Fetches or cites the Finternet delegation-and-RBAC page |
