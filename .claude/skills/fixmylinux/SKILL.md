---
name: fixmylinux
description: Diagnose, repair, and sync this machine's dotfiles. Use when the user says "fix my linux", "/fixmylinux", "check my dotfiles", "is my config healthy", "doctor my setup", "my sway/zsh/tmux is broken", or asks to verify/repair/update their dotfiles. Wraps the `fixmylinux` script with AI diagnosis of failures.
---

# fixmylinux

Drive the `fixmylinux` script (in this dotfiles repo, stowed to `~/.local/bin`) to
check this machine's health, then **interpret** any failures the script can only
report mechanically — read the offending config, find the root cause, propose a fix.

## The script

| Command | Mutates? | What it does |
|---------|----------|--------------|
| `fixmylinux doctor` | no | Health report: git state, stow symlinks, config validity (sway/zsh/tmux/git), dev tools, machine wiring. Exit 1 on any FAIL. |
| `fixmylinux fix` | yes | Restow all packages + reseed sway `local.conf`, then doctor. No git pull. |
| `fixmylinux` (or `update`) | yes | Full sync: stash → `git pull --rebase` → bootstrap → restow → reseed → doctor. |

## Workflow

1. **Always start read-only.** Run `fixmylinux doctor`. This never changes anything.
2. **Report** the PASS/WARN/FAIL summary to the user plainly.
3. **Diagnose every ✗ FAIL and meaningful ⚠ WARN.** The script only prints one line;
   you go deeper:
   - **sway config error** → read `~/.config/sway/config` (and `config.d/local.conf`)
     around the reported issue; run `sway -C --unsupported-gpu` yourself to see full
     output; explain the actual broken directive.
   - **~/.zshrc syntax error** → run `zsh -n ~/.zshrc`, read the cited line, explain.
   - **dangling/missing symlink** → check `ls -l` of the target and the repo source;
     usually a missing `stow -R`.
   - **missing dev tools** → name them; the fix is bootstrap (full run).
   - **local.conf not seeded** → the fix is `fixmylinux fix`.
4. **Propose the fix and CONFIRM before mutating.** Never run `fix` or the full sync
   without the user's explicit OK in this turn. State exactly what will change
   (restow touches symlinks; full sync pulls git + runs bootstrap + may stash).
5. After the user approves, run the chosen command and re-report the doctor summary.

## Rules

- `doctor` is free to run anytime, unprompted, to gather facts.
- `fix` and `fixmylinux`/`update` are **mutating** — get explicit confirmation first.
- If `doctor` shows all PASS, say so and stop. Don't fix what isn't broken.
- If a FAIL is something the script's `fix`/`update` can't resolve (e.g. a genuine
  conflict in the config, a hardware-specific output line), edit the relevant file
  directly with the user — don't loop the script.
- The script auto-detects the repo via its own path; you don't need to pass paths.
