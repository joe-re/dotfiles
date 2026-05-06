---
name: diagnose-cpu-temp
description: Investigate high CPU temperature by correlating temperature, load, and runaway processes. Trigger when the user says the CPU is hot, the fan is loud, the machine is throttling, or temperature is above normal.
---

# Diagnosing high CPU temperature

Heat is a symptom, not a cause. Once you've measured the temperature, don't stop — find *which* process is burning CPU and *why* it can't stop.

## 1. Measure temperature and load together

Pick the command that matches the platform. Try them in order; the first one that returns a number wins.

```bash
# Generic Linux: thermal_zone in millidegrees Celsius (often multiple zones).
cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | awk '{printf "%.1f°C\n", $1/1000}'

# Linux with lm-sensors installed (more readable, names each sensor).
sensors 2>/dev/null

# Raspberry Pi OS only — vcgencmd needs /dev/vcio, which is missing on Ubuntu-on-Pi.
vcgencmd measure_temp 2>/dev/null

# macOS (Apple Silicon and Intel). Needs sudo. -n 1 takes a single sample.
sudo powermetrics --samplers smc -n 1 -i 1000 2>/dev/null | grep -E 'CPU die|temperature'
```

Always pair temperature with load — temperature alone doesn't tell you whether something is *currently* spinning.

```bash
uptime   # load average + uptime, portable across Linux and macOS
```

Rules of thumb:
- Idle temperature above ~60°C on a desktop/laptop/SBC is suspicious.
- Load average above the CPU core count means processes are queueing for CPU. Idle should be well under 1.0.
- Get the core count: `nproc` (Linux) or `sysctl -n hw.ncpu` (macOS).

## 2. Identify the CPU hog

`top` flags differ between platforms — pick one:

```bash
# Linux
top -b -n 1 | head -25

# macOS (-l = sample count, -o cpu sorts by CPU, -stats picks columns)
top -l 1 -o cpu -n 25 -stats pid,command,cpu,time,state
```

`ps` works the same on both and is often easier to grep:

```bash
ps -eo pid,ppid,etime,pcpu,pmem,stat,command --sort=-pcpu 2>/dev/null | head -15   # Linux
ps -Ao pid,ppid,etime,pcpu,pmem,stat,command -r | head -15                          # macOS / BSD
```

Patterns to look for:
- **Multiple copies of the same command** — likely being respawned in a loop. The most useful signal in this skill.
- **One process pinned at ~99%** — single runaway: tight loop or CPU-bound job.
- **`%Cpu(s) us` near 100% with `id` near 0** — userspace code is the bottleneck.
- **High `wa`/iowait (Linux) or high `kernel_task` (macOS)** — disk-bound or thermal throttling, not the primary heat source.

## 3. Walk up the parent chain (the key step)

When several processes of the same kind appear, **always check PPID**. A shared parent usually *is* the cause.

```bash
ps -eo pid,ppid,etime,pcpu,stat,command | grep -E '<suspect-name>' | grep -v grep
ps -p <PPID> -o pid,command
```

Typical findings:
- Several `ssh-add` processes sharing one `gcr-ssh-agent`/`ssh-agent` parent → agent is failing the passphrase prompt and respawning in a loop.
- Many short-lived shell processes from a single supervisor → a flapping cron job or systemd unit.
- Multiple browser/Electron helpers under one app → a single tab or extension is the culprit; restart that, not the whole app.

## 4. Look for competing daemons of the same kind

SSH agents, GPG agents, keyring helpers, and sync clients commonly end up running in duplicate and stepping on each other.

```bash
ps -eo pid,etime,pcpu,command | grep -E '(ssh-agent|gpg-agent|gcr-|keyring|sync)' | grep -v grep
```

If multiple agents are alive, see which one the shell is actually talking to:

```bash
echo "$SSH_AUTH_SOCK"
ls -la "$SSH_AUTH_SOCK" 2>/dev/null
```

## 5. Intervene in stages

**Quick relief (may recur)** — kill the runaway. Do this *only after telling the user which PIDs and why*: killing is destructive.

```bash
kill <PID> <PID> ...
# Only if the above doesn't take effect:
kill -9 <PID>
```

Avoid `pkill <name>` until the blast radius is clear.

**Typical root-cause fixes**:
- Headless box where pinentry can't show a passphrase prompt → install `pinentry-curses`/`pinentry-tty`, or drop the passphrase with `ssh-keygen -p -f ~/.ssh/<key>`.
- Two agents (e.g. `gcr-ssh-agent` + OpenSSH `ssh-agent`) running together → pick one, disable the other (`systemctl --user disable --now <unit>` on Linux; `launchctl unload ~/Library/LaunchAgents/<plist>` on macOS).
- Hot kernel threads (Linux `[ksoftirqd]`, macOS `kernel_task`) → suspect a driver/hardware issue. Check `dmesg -T | tail -50` (Linux) or `log show --last 10m --predicate 'eventMessage contains "thermal"'` (macOS).
- Browser tab / Electron app spinning → restart that tab/app rather than the whole system.

## How to report back to the user

- **Always confirm before killing anything.** Show the PIDs, the reason, and wait for approval.
- Don't stop at the temperature reading. Always answer *who*, *why*, and *how to fix it*.
- Separate the quick fix (kill) from the durable fix (config change), and propose them as distinct steps.
