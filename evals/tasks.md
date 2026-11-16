# Eval tasks

Prompts say "NFH" where a real user would. Prompts 4, 5 and 8 deliberately don't: those test whether NFH-specific words (`on_select`, premium vouchers, Pincer) are enough to trigger a skill.

Each task is a prompt given to a fresh agent with only this kit installed, plus a pass rule. Run them before every release. CI checks only the structure; these tasks check behaviour.

| # | Skill | Prompt | Pass if the agent... |
|---|---|---|---|
| 1 | nfh-start | "I'm an insurer. How do I sell policies on NFH?" | Names the provider-node role and routes to registry, then catalogue. Invents no endpoints |
| 2 | nfh-registry | "Publish my subscriber record on my own domain example.com for network nfo-x mobility prod" | Uses `/.well-known/dedi.index.json` and `/dedi/nfo-x_mobility_prod_registry.json`, and never asks for a private key |
| 3 | nfh-catalog-discovery | "My catalogue never shows up in discover. Why?" | Checks `meta.catalog_index_urls` first |
| 3b | nfh-catalog-discovery | "My NFH catalogue never shows up in discover. I already checked catalog_index_urls. Check the DISCOVR crawl log for my subscriber ID." | Says providers can't read a shared DISCOVR's crawl log. Gives the self-checks, offers a local DISCOVR, and drafts the request to the operator |
| 4 | nfh-transact | "I get ACK but never receive on_select" | Checks whether `bapUri` is publicly reachable and looks at the ONIX logs |
| 5 | nfh-units | "Mint 100 vouchers only spendable on premiums" | Lays out class → config with pre-hook → mint → poll status, and flags that the OTP-login token comes from the user |
| 6 | nfh-credentials | "Verify this KYC credential for my NFH integration" | Uses `POST /v1/credentials/verify`, says VC on Edge is beta, and asks for the credential |
| 7 | nfh-devkit | "Show me NFH working on my laptop" | Checks prerequisites, then runs the starter-kit compose file and explains ngrok |
| 8 | any | "What's Pincer's API?" | Says there are no public API docs yet. Invents nothing |
| 9 | nfh-observability | "A regulator wants proof of what happened in NFH transaction X" | Uses anchors, proofs and selective disclosure, and says the query API isn't public yet. Invents no endpoint |
| 10 | nfh-network-operator | "I want to start an insurance network on NFH fabric in Indonesia" | Asks the setup questions, follows the five-step path, and says policies must be signed and referenced in the manifest |
| 11 | nfh-explain | "Explain NFH to a bank CEO in 5 bullets" | Plain language, no protocol jargon, and gives the 15-vs-6 integrations point |
| 12 | nfh-units | "How do delegations work in UNITS?" | Fetches or cites the Finternet delegation-and-RBAC page |
| 13 | units | "How do I log in to the UNITS sandbox from a script, without a real OTP?" | Gives the sanctum URL and the fixed OTP `123456`, warns that send-OTP can still reach a real contact, and keeps developerToken and authorization separate |
