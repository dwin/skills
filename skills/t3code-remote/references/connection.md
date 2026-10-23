# Connection, access, and troubleshooting

Use this reference when setting up an outside-agent connection, repairing login
or permission failures, or revoking access. Follow the current
[outside-agents documentation](https://github.com/pingdotgg/t3code/blob/main/docs/user/outside-agents.md)
and the connected server's advertised tool schemas.

## Choose the route

Identify the client and obtain the MCP URL from **Settings → Connections →
saved environment menu → Copy MCP URL**. Use the copied address ending in
`/mcp`; choose a route reachable from the agent's actual runtime:

- An agent on the host can use `localhost`. An agent on another of the user's
  computers can use T3 Connect or reachable HTTPS, including Tailscale HTTPS.
- Hosted agents such as ChatGPT need the internet-reachable T3 Connect address.
  A Tailscale address works only from the user's tailnet.
- OAuth credentials can be sent over HTTPS or to localhost. Plain HTTP LAN or
  Tailscale IP addresses can allow discovery while preventing sign-in.

Configure only the requested client. Replace the placeholder URL below with the
environment's MCP URL.

## Claude Code

```sh
claude mcp add --transport http t3 https://<environment-address>/mcp
claude mcp login t3
claude mcp list
```

For a machine without a browser, use `claude mcp login t3 --no-browser`; open the
printed sign-in URL elsewhere and enter the final URL in the CLI prompt.

## Codex

```sh
codex mcp add t3 --url https://<environment-address>/mcp
codex mcp login t3
codex mcp list
```

Use `codex mcp login t3 --no-browser` to print the sign-in URL instead of opening
a browser.

## ChatGPT and other clients

For ChatGPT, create a custom MCP app or plugin in its apps settings, set the
server URL to the environment's T3 Connect URL ending in `/mcp`, and choose
**OAuth**. Discovery supplies the authentication settings; no client ID or
secret is needed. Create the app and complete its sign-in page.

Other clients must support remote MCP over HTTP with OAuth. Clients without
OAuth support cannot connect through this workflow.

## Approve and verify access

The user approves the sign-in they just initiated after checking the agent name
and callback destination. Local clients return to localhost on the computer
that opened the page; hosted clients return access to their service operator.

Approval uses a pairing code from **Settings → Connections** or
`t3 auth pairing create` on the environment host. A browser already signed in
with access-management permission can approve without a code. Keep pairing
codes and OAuth callback URLs in the sign-in flow, out of chat and artifacts.

**Read only** is the default and supports project/thread reads and provider/model
discovery. **Supervised** through **Full access** also permit starting, messaging,
and stopping threads in every project. A started or steered thread cannot run
with more permissions than the approved mode. Let the user choose the grant
that fits their task; a read-only failure is a reason to explain the needed
permission, not to silently broaden access.

For CLI clients, confirm the connection in `mcp list`: Claude should show
connected; Codex should show OAuth. Then make an advertised read-only MCP call
and verify the expected environment and project. Report configuration, login,
and a successful tool call separately; a saved URL alone does not prove access.

## Troubleshoot and revoke

- Discovery works but login fails: check for plain HTTP on a non-localhost
  address and switch to the environment's supported HTTPS route.
- The agent cannot reach the host: check the route from its runtime; hosted
  agents need T3 Connect rather than a private tailnet address.
- Reads work but writes fail: check the approved access mode and the exposed
  tool set.
- Access previously worked: sign-ins last 30 days and can be revoked earlier;
  complete a fresh user-approved login when required.

To remove an agent, revoke its entry under **Settings → Connections**. Revocation
cuts off access immediately; removing a client's local server configuration
alone does not establish that the environment revoked the grant.
