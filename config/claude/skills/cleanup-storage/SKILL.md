---
name: cleanup-storage
description: Investigate disk usage and propose safe cleanup actions on Linux. Trigger when the user asks about storage capacity, disk space being full, what's eating disk, or how to free up space.
---

# Investigating and reclaiming disk space

Don't just run `df -h` and stop. The job is: measure, find the *specific* directories driving the usage, separate trivially-reclaimable bytes (caches, old package revisions) from things that need user judgement (browser profiles, project data), and present a staged cleanup plan. Never delete without confirmation.

## 1. Measure overall usage first

```bash
df -h
```

Focus on the root filesystem (`/`) and any data partitions. `tmpfs` and `/run/credentials/*` are in-memory — ignore them. Note the **used** value and **percent** — high percent matters more than absolute size on small disks (SD cards, VMs).

If usage is under ~50%, say so up front. The user may still want a cleanup, but the framing changes from "urgent" to "tidy-up".

## 2. Find the heavy directories — top-down

Walk down one level at a time. Don't try to `du` the whole tree at once on a slow disk (SD card on a Pi will time out).

```bash
# Root: anything outside /home, /var, /usr, /nix, /snap is rarely the culprit
sudo du -h -d 1 / --exclude=/proc --exclude=/sys --exclude=/dev 2>/dev/null | sort -hr | head -15

# Home directory (most actionable for the user)
du -h -d 1 ~ 2>/dev/null | sort -hr | head -15
```

If `du /` is too slow, break it up: query each suspect separately (`du -sh /var /usr /snap /nix /home`). Run these in parallel via multiple Bash calls.

Then drill into whichever paths dominate:

```bash
du -h -d 1 /var 2>/dev/null | sort -hr | head -10
du -h -d 1 /var/lib 2>/dev/null | sort -hr | head -10
du -h -d 1 /var/cache 2>/dev/null | sort -hr | head -10
du -h -d 1 ~/.cache 2>/dev/null | sort -hr | head -10
du -h -d 1 ~/.local/share 2>/dev/null | sort -hr | head -10
du -h -d 1 ~/snap 2>/dev/null | sort -hr | head -10
```

## 3. Categorize what you found

Sort findings into three buckets. The categorization matters more than the numbers — it tells the user what's safe.

### Safe to delete (no user action lost)
- `/var/cache/apt/archives/*.deb` — already-installed package archives. Reclaim with `sudo apt clean`.
- `/var/log/journal/*` — systemd logs. Cap with `sudo journalctl --vacuum-time=30d` or `--vacuum-size=200M`.
- `~/.cache/*` — application caches; rebuilt on demand.
- Old installer files in `~/Downloads` (`.deb`, `.dmg`, `.iso`) — confirm with the user, but usually fine.
- Old versions of self-updating CLIs (e.g. `~/.local/share/claude/versions/<old>` — keep only the latest).

### Disabled/old revisions (safe but version-aware)
- **Snap**: `snap list --all` shows revisions; rows marked `disabled` are previous versions kept for rollback. Each is ~tens to hundreds of MB.
  ```bash
  snap list --all | awk '/disabled/ {print $1, $3}'
  sudo snap remove <name> --revision=<rev>
  # Reduce future retention (minimum is 2):
  sudo snap set system refresh.retain=2
  ```
- **Nix**: old generations and unreferenced store paths.
  ```bash
  nix-env --list-generations    # user generations
  nix-collect-garbage -d        # delete old generations + GC the store
  # If you use Determinate Nix or system profiles, also: sudo nix-collect-garbage -d
  ```

### Needs user judgement (may contain real data)
- Browser profiles: `~/snap/{chromium,firefox}/common`, `~/.mozilla`, `~/.config/google-chrome` — contain login state, cookies, history. Suggest clearing *cache* via the browser UI, not deleting the directory.
- Active project directories, downloads the user might still want, mail/message stores.
- For each, report the size and ask before touching.

## 4. Present a staged plan, then execute

Before running anything destructive, lay out the plan in the response with:
- What the command does
- How much it reclaims (estimate from the `du` output)
- Which bucket it falls in (safe / version-aware / judgement-required)

Group commands so the user can opt into stages. A typical structure:

> **Stage 1 — safe (~XXX MB)**: `sudo apt clean`, journal vacuum, old CLI versions, finished installers.
> **Stage 2 — old snap/nix revisions (~XXX MB)**: list specific revisions and the remove commands.
> **Stage 3 — needs your call**: browser caches, large user files; require explicit go-ahead per item.

Wait for confirmation. After running, re-check `df -h` and report what was actually reclaimed (the estimate from `du` and the real `df` delta sometimes differ — overlay filesystems, sparse files).

## Gotchas

- `sudo du /` may produce no output if it hits permission errors *and* the shell swallows stderr — run without `2>/dev/null` once if results look empty, then re-add the redirect.
- `/snap/*` itself is squashfs mounts, not real disk. The actual files are in `/var/lib/snapd/snaps/*.snap`. Look there for true reclaim.
- On Raspberry Pi, `/boot/firmware` is a small FAT partition (~500MB). High percent there is normal and not the same problem as `/` filling up.
- `apt autoremove` removes *packages*, not just cache — it can uninstall things the user wants. Prefer `apt clean` unless the user explicitly asks to prune packages.
- Never `rm -rf` a `~/.config/<app>` or `~/snap/<app>/common` directory to "clean" it — that wipes user state.
