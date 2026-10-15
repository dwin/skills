# Optional SSHFS editing

SSHFS lets local tools edit a remote checkout while builds run inside Linux. Remote filesystem access can be slow for file watchers and dependency scans; keep dependency installation, indexing that scans dependencies, and compilation inside the Sprite.

## Check prerequisites

Check `command -v sshfs`, `sshfs --version`, and macFUSE availability. Homebrew package installation alone does not prove the macOS filesystem extension is approved or loaded. Report a required macOS approval or reboot instead of changing system security settings. Remote execution and file transfer work without a mount.

Sprites do not expose SSH directly. Inspect `sprite proxy --help`: newer clients provide `--ssh`, a managed SSH endpoint that can complete a handshake even when the Sprite has no sshd or listening port 22. Try this path first:

```bash
ssh -i /path/to/private-key -o IdentitiesOnly=yes \
  -o 'ProxyCommand=sprite proxy --ssh -o ORG -s NAME' \
  sprite@NAME true
```

An SSH handshake alone does not prove authentication or SFTP support. Verify login and an SFTP session before using the same ProxyCommand with SSHFS. Inspect the current managed endpoint's key-registration and host-key verification instructions; do not assume it reads the Sprite user's authorized_keys or uses OpenSSH host keys.

For an older CLI, or when the managed endpoint cannot provide the required SFTP access, use a tunneled OpenSSH server as described below.

## OpenSSH fallback

Inspect the Sprite for OpenSSH, `/run/sshd`, host keys, its existing service configuration, and `sprite-env services --help`. Reuse a working server. If setup is needed within the authorized task, install openssh-server, create the runtime directory, generate missing host keys, and configure the service using the installed CLI. Run sshd in the foreground (`/usr/sbin/sshd -D -e`) under its service supervisor with the privileges needed to bind port 22. Validate `sshd -t` before starting it.

Authorize one selected local public key for the remote `sprite` user. Preserve existing authorized keys, append idempotently, and set .ssh to 0700 and authorized_keys to 0600 with correct ownership. Keep private keys local. Inspect password and root-login settings before exposing SSH through a tunnel.

## Connect and mount

Use `sprite proxy --help` to verify `-W` stream forwarding. Test SSH first, explicitly targeting the organization. Replace placeholders and use an absolute path to the local sprite executable if the SSH environment lacks its PATH:

```bash
ssh -i /path/to/private-key -o IdentitiesOnly=yes \
  -o 'ProxyCommand=sprite proxy -o ORG -s NAME -W :22' \
  sprite@NAME true
```

Verify the remote host-key fingerprint through authenticated `sprite exec` before accepting it. Keep host-key checking enabled and use a distinct alias per org/Sprite; use a task-specific known_hosts file if names overlap. Do not bypass checking to suppress an error.

Mount only the needed checkout into an empty task-specific local directory:

```bash
sshfs -o IdentityFile=/path/to/private-key,IdentitiesOnly=yes \
  -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 \
  -o 'ProxyCommand=sprite proxy -o ORG -s NAME -W :22' \
  sprite@NAME:/home/sprite/workspaces/TASK /path/to/empty-mount
```

Check a known source file through the mount and perform a small write/read check when edits are intended. Run builds with `sprite exec --dir` against the remote path. Running cargo locally against the mounted tree still consumes local CPU and RAM.

A live mount or tunnel may keep the Sprite awake. When the task authorizes ending the mount, unmount with `umount /path/to/empty-mount` (or `diskutil unmount` on macOS) and verify it detached. Keep remote source, caches, and evidence. Stop only proxies and sessions owned by the task.
