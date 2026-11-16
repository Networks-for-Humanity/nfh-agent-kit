---
name: nfh-catalog-discovery
description: Publish a provider's catalogue on NFH fabric so it can be discovered, and search catalogues with DISCOVR. Use when the user wants products, policies, offers or services to be findable, needs to sign and host catalogue files, link a catalog index to their registry record, call POST /discover, handle on_discover callbacks, or debug a catalogue that never appears in results.
---

# Catalogues and DISCOVR

NFH has **no central catalogue service and no publish API**. Providers self-host signed catalogue files. DISCOVR crawls them, verifies them and indexes them, then answers `discover` queries.

Read first: https://docs.nfh.global/build/creating-a-network/catalog-publishing-and-discovery.md

## Provider side: publish

1. **Build the catalogue JSON** with Beckn v2 schemas. Items use JSON-LD contexts such as `https://schema.beckn.io/RetailResource/2.1/context.jsonld`, with offers and price specs alongside. The `beckn-payload-builder` skill from beckn-agents helps here if it's installed.
2. **Generate, sign and write the files with `catalog-publisher`**, the beckn-onix plugin. Don't hand-write baselines, change files, digests or the index. The plugin works out whether to write a fresh baseline or an incremental change file, then signs with the registered key. To try it on a running adapter, use `beckn/starter-kit` with the `catalog/publish` trigger on `onix-bpp`.
3. **Host the files** on storage the provider controls, reachable over public HTTPS.
4. **Link the index from the registry record.** This is the only "registration":
   ```json
   "meta": { "catalog_index_urls": [ { "url": "https://cdn.example.com/beckn/index/becknCatalogs.index.json" } ] }
   ```
5. **Verify.** There's no confirmation callback. Run a `discover` that should match, and check the DISCOVR crawl log for verification failures.

**If a catalogue never shows up:** check, in order, that `catalog_index_urls` is set, that the files are publicly reachable, that the signature key matches the registry, and that the index digests match the files.

## Consumer side: search

Read https://docs.nfh.global/product-documentation/products/discovr/getting-started.md, then the usage and examples pages next to it.

```bash
curl -X POST "$DISCOVR_BASE_URL/discover" \
  -H "Content-Type: application/json" \
  -H "Authorization: <Beckn HTTP Signature>" \
  -d '{
    "context": {
      "version": "2.0.0", "action": "discover",
      "messageId": "<uuid>", "transactionId": "<uuid>",
      "timestamp": "<ISO-8601>", "bapId": "<your subscriber id>",
      "bapUri": "<your public callback base>", "networkId": "<network>"
    },
    "message": { "intent": { "textSearch": "health insurance" } }
  }'
```

- DISCOVR replies `ACK` straight away. Results arrive later at `POST <bapUri>/on_discover`. That endpoint must be public (use ngrok locally) and must verify the signature.
- Search modes include text, structured attribute filters (JSONPath), and spatial queries (GeoJSON plus radius). Copy the exact request shapes from https://docs.nfh.global/product-documentation/products/discovr/examples.md. Don't invent them.
- In practice the request goes through the CN's own ONIX adapter, which signs it. Only call DISCOVR directly when testing signatures by hand.
