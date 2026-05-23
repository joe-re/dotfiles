---
name: port-inspector
description: Find which process is bound to a TCP/UDP port, walk up to its parent, and propose how to free the port. Trigger when the user says a port is already in use, "address already in use", "EADDRINUSE", a dev server fails to start, or asks "who's using port N".
---

# Inspecting and freeing a port

The job is: figure out *what* is bound, *why* it's still alive (often a leftover dev server or a different app entirely), and offer a graceful way to free it. Don't reach for `kill -9` first — a polite SIGTERM almost always works and avoids losing in-flight state.

## 1. Find the listener

Try the commands in this order. The first one that prints a PID wins. Both `lsof` and `ss` cover macOS and Linux respectively; `lsof` works on both but is slower.

```bash
# macOS + Linux. -nP avoids DNS/service-name lookups (much faster).
lsof -nP -iTCP:<PORT> -sTCP:LISTEN 2>/dev/null
lsof -nP -iUDP:<PORT> 2>/dev/null

# Linux only, faster than lsof. -t = TCP, -u = UDP, -l = listening, -n = numeric, -p = show PID.
ss -tulnp 2>/dev/null | grep -E ":<PORT>\b"

# Fallback when lsof/ss aren't available (busybox, minimal containers).
netstat -anv 2>/dev/null | grep -E "[.:]<PORT>\b"
```

If nothing comes back:
- Check both TCP and UDP — people often assume TCP.
- Check IPv6 separately: `lsof -nP -i6TCP:<PORT> -sTCP:LISTEN`. A process bound to `::` (IPv6 any) can block IPv4 binds depending on `IPV6_V6ONLY`.
- Confirm the port is actually in use by trying to bind it (`nc -l <PORT>` — if it returns immediately the port may be free, or held by a privileged process you can't see without sudo).
- Re-run with `sudo` — without it, you only see *your* processes and miss system daemons.

## 2. Identify the process — and its parent

Don't stop at "node is using port 3000". The PID the user cares about is often the *parent* (the supervisor, the IDE, the shell that spawned it).

```bash
# Given PID from step 1:
ps -p <PID> -o pid,ppid,user,etime,command
ps -p <PPID> -o pid,ppid,user,etime,command
```

Common patterns:
- **Parent is your shell** — you started it manually and forgot. Foreground it (`fg`) if it's still attached, or kill it.
- **Parent is `launchd` (macOS) / `systemd` (Linux)** — it's a managed service that will *respawn* if you just kill it. You need to stop the unit, not the process.
- **Parent is `node` / `npm` / `pnpm` / `yarn`** — a dev server's child worker. Kill the parent to take down the whole tree, not the leaf.
- **Parent is an editor process (Code Helper, JetBrains)** — the IDE's integrated terminal or run config still owns it. Stop it from the IDE, or kill the editor's child process group.
- **Same port, multiple PIDs** — usually a parent + forked workers (e.g. `nginx` master + workers, `node --cluster`). Kill the master.

## 3. Decide if killing is even the right move

Before killing, ask whether the user actually wants to:
- **Just use a different port** — for ad-hoc dev, the cheapest fix. Suggest `PORT=3001 npm start` or equivalent.
- **Reconnect to the running server** — if it's *their* server still running from a prior session, attaching (open the URL, `tmux attach`, etc.) may be all they want.
- **Kill it** — only if it's a stale process or the wrong app.

Killing a system daemon (postgres, redis, docker-proxy) is rarely what the user wants — flag this before acting.

## 4. Free the port — gracefully first

Always show the PIDs and what they are *before* killing, and wait for confirmation. Killing is destructive.

```bash
# Step A: polite ask. Most servers handle SIGTERM and shut down cleanly.
kill <PID>

# Wait ~2 seconds, then verify the port is free:
lsof -nP -iTCP:<PORT> -sTCP:LISTEN

# Step B: only if SIGTERM was ignored. SIGKILL drops in-flight requests and skips cleanup.
kill -9 <PID>
```

For process *trees* (parent + workers), kill the parent — children usually exit on their own. If they don't:

```bash
# macOS + Linux: kill the entire process group of <PID>.
kill -- -<PGID>          # PGID is shown in `ps -o pgid -p <PID>`
# or:
pkill -TERM -P <PARENT_PID>   # kills children of <PARENT_PID>
```

Avoid `pkill <name>` (no PID) until the blast radius is clear — it matches by name across the whole system.

## 5. If it's a managed service, stop it properly

A service that respawns means the unit, not the process, is the source of truth.

```bash
# macOS launchd (user agents)
launchctl list | grep -i <name>
launchctl unload ~/Library/LaunchAgents/<plist>          # stop + disable for this session
# Or, modern syntax:
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/<plist>

# macOS Homebrew services
brew services list
brew services stop <name>

# Linux systemd
systemctl --user status <unit>     # user services
sudo systemctl status <unit>       # system services
sudo systemctl stop <unit>
```

For Docker-published ports, the listener you see is `com.docker.backend` / `docker-proxy`. Stop the *container*, not the proxy:

```bash
docker ps --filter "publish=<PORT>"
docker stop <container>
```

## 6. Stale sockets without a process

Occasionally a port shows as in use but no PID is reported even with sudo. Causes:

- **TIME_WAIT after a previous connection** — a listening socket in `TIME_WAIT` can block rebinds for up to ~2 minutes. Set `SO_REUSEADDR` in the app, or wait it out. Check with: `ss -tan state time-wait '( sport = :<PORT> )'` (Linux) / `netstat -an | grep TIME_WAIT | grep <PORT>` (macOS).
- **Kernel-held socket** — rare; reboot or `sudo` the lookup.
- **Firewall / pf / iptables rule** rejecting the bind — `sudo pfctl -sr` (mac), `sudo iptables -L -n` (linux).

## How to report back to the user

- Show the PID, parent, command line, and how long it's been running *before* proposing a kill.
- Distinguish "stale" (you started this earlier and forgot) from "wrong app" from "managed service" — the right action differs.
- Always offer the graceful fix first (different port, SIGTERM, `brew services stop`) before SIGKILL.
- After killing, verify the port is actually free and report back — don't assume.
