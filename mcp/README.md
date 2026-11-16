# NFH MCP server (v2, planned)

Skills tell an agent *how* to work with NFH. An MCP server lets it *act*: call the sandbox directly from Claude, Codex, ChatGPT or any other MCP client.

## Already available

- **Docs MCP:** docs.nfh.global is published with GitBook, which serves an MCP endpoint for asking questions about the docs. It is also available over plain HTTP at `GET https://docs.nfh.global/index.md?ask=<question>&goal=<goal>`.

## Planned tools (remote server, OAuth sign-in)

| Tool | Calls | Writes? |
|---|---|---|
| `registry_lookup` | `api.dedi.global/dedi/lookup/{domain}/{registry}` | No |
| `discover` | DISCOVR `POST /discover`, waiting for `on_discover` | No |
| `beckn_send` | The caller's sandbox ONIX `/beckn/{action}` | Sandbox only |
| `units_mint`, `units_transact`, `units_status` | UNITS `/v1/token/*` on a sandbox instance | Sandbox only |
| `vc_verify` | OpenCred `POST /v1/credentials/verify` | No |

Ship it with a `server.json` so it can be listed in the official MCP Registry (registry.modelcontextprotocol.io).

## Blocker to resolve first

UNITS config and mint need a token from an OTP login, and ONIX calls need a registered signing key. Before "anyone with Claude" can use this server end to end, NFH needs **self-serve sandbox credentials**: a test identity and test token issued through OAuth, without a person in the loop.
