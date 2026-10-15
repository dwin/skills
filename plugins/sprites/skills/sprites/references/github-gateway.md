# GitHub through a Sprites gateway

A Sprite can have GitHub access through a Sprites gateway while `gh`, SSH, and ordinary Git HTTPS remain unauthenticated. Check the user's configured access method before declaring GitHub unavailable or asking them to log in again.

The gateway base has the form `https://api.sprites.dev/v1/gateway/github/<gateway-id>`. Treat a user-supplied gateway URL as a private capability. Keep its actual identifier out of committed configuration, plugin instructions, logs, reports, and agent handoff text. Prefer an existing injected environment variable or private configuration reference. Keep shell tracing and verbose HTTP output disabled, and emit only parsed fields.

From the intended Sprite, use GET requests to verify the gateway's `/user`, `/repos/OWNER/REPO`, and `/repos/OWNER/REPO/commits/SHA` endpoints. Parse only the fields needed to confirm identity, private-repository access, and the expected commit.

Gateway API access does not establish Git clone or push support. For source retrieval, verify a gateway-supported contents or archive endpoint first; check the returned revision and content hashes before building. Keep calls within the requested repository and task. A permission failure should be reported for that endpoint and repository, rather than triggering credential copying or a different login method.

For local dirty work, the verified archive/patch transfer remains useful even when remote GitHub access works.
