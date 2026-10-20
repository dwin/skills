# GitHub through a Sprites gateway

A Sprite can reach GitHub through a Sprites connector, routed by the Sprites API gateway, while `gh`, SSH, and ordinary Git HTTPS remain unauthenticated. Check for a connector before declaring GitHub unavailable or asking the user to log in again; this access method needs no `gh auth login` and no token inside the Sprite.

## Discover the route

The gateway authenticates the calling Sprite, so run every gateway request inside the Sprite that will do the work. A request from the laptop or CI returns `401`.

```bash
sprite exec -o ORG -s NAME --no-stdin --no-port-forward -- \
  curl -sS https://api.sprites.dev/v1/gateway/list
```

Take the GitHub connector's `gateway_base_url` from that response and use it verbatim as the base for every GitHub API path. Treat a gateway URL supplied by the user or a handoff as a hint to match against the list output. Rediscover the base in each newly selected Sprite, because connector access policy is evaluated per Sprite. The connector ID in the URL is routing metadata; the gateway attaches the stored credential, so requests carry no `Authorization` header.

## Recover access

When GitHub appears in the list as available but not configured, give the user its `setup_url`. When the connector lacks a needed scope, give the user its `request_scopes_url`. Both are consent flows the user completes; wait for them, then rediscover the route. A `403` is a connector policy or endpoint restriction: report the endpoint and repository, and leave the policy as it is.

## Verify and fetch

Use GET requests against the base to verify `/user`, `/repos/OWNER/REPO`, and `/repos/OWNER/REPO/commits/SHA`. Parse only the fields needed to confirm identity, repository access, and the expected commit. Keep private repository contents out of logs.

The gateway forwards GitHub API paths; Git clone and fetch through it are undocumented. Test a clone before relying on one, and otherwise follow [source transfer](source-transfer.md). GitHub's tarball and zipball endpoints are produced like `git archive`, so they carry the same export-attribute caveat described there. Keep calls within the requested repository and task.

Sources: [Sprites connectors](https://docs.fly.io/sprites/concepts/connectors), [`sprite-api-gateway` skill](https://github.com/superfly/pi-sprites/blob/main/skills/sprite-api-gateway/SKILL.md).
