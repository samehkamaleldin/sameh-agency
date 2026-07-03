# sameh-agency

Tools and extensions for [Claude Code](https://docs.claude.com/en/docs/claude-code).

## Layout

```
skills/                    # Claude Code skills
  <skill-name>/
    SKILL.md
claude/
  status-line/             # powerline-style status bar for Claude Code
```

## Requirements

Everything here runs inside [Claude Code](https://docs.claude.com/en/docs/claude-code) — set that up first. Each component then has its own prerequisites.

### `review-rounds` skill

| Requirement | Why | Required |
|-------------|-----|----------|
| Claude Code with subagent (`Agent`) support | Reviewers and the fixer run as parallel subagents | Yes\* |
| Model access to **`opus`** | All reviewer and fixer subagents run on Opus | Yes\* |
| `git` | Each round branches, stashes, tags, and merges — nothing is pushed | Yes |
| A project check command (typecheck / tests) | Powers the regression gate that halts a round if a fix breaks the build | Optional — auto-detected, skipped if none found |

> \* Default (subagent) mode. Running `/review-rounds subagents=off` executes the reviewers and fixer inline on your session model — no subagent support or Opus access required.

### Status line

| Requirement | Why | Required |
|-------------|-----|----------|
| **Python 3.10+** | Runs `statusline.py` — stdlib only, zero pip installs | Yes |
| A **Nerd Font**, set as your terminal font | Every icon (git, language logos, powerline caps) is a Nerd Font glyph; without one you get missing-glyph boxes | Yes |
| A 256-color terminal | The palette uses 256-color indices | Yes (any modern terminal) |
| `git` | Drives the project / branch / git-health segments | For the git segments |
| `gh` CLI, authenticated | PR-status segment (draft / open / approved / merged) | Optional |
| `node` · `go` · `rustc` · `ruby` · `python3` on `PATH` | Adds version numbers to stack badges; absence just omits the version | Optional |

Install a Nerd Font (macOS):

```bash
brew install font-hack-nerd-font   # or font-fira-code-nerd-font, font-jetbrains-mono-nerd-font
```

Then select the Nerd Font variant in your terminal's font settings. Per-OS instructions and a glyph self-test are in [`claude/status-line/README.md`](claude/status-line/README.md#nerd-font-required).

## Status line

`claude/status-line/` — a zero-dependency Python statusline for Claude Code (git, stacks, model, cost, context window). See [`claude/status-line/README.md`](claude/status-line/README.md) for setup. Upstream repo: [sameh-statusline](https://github.com/samehkamaleldin/sameh-statusline).

## Skills

Each skill is a directory under `skills/` containing a `SKILL.md` with YAML frontmatter (`name`, `description`) followed by the skill body. See the [Claude Code skills docs](https://docs.claude.com/en/docs/claude-code/skills) for the format.

### `review-rounds`

Iteratively harden recent changes by running multiple rounds of parallel reviewer subagents, compiling findings into a unified fix list, applying fixes, and merging each round back to main. Defaults to 3 reviewers × 5 rounds over recent commits + uncommitted changes.

Trigger: `/review-rounds`, "run review rounds", "do N rounds of review", "multi-round review", "iterative review".

## Install

**macOS / Linux** — clone, then symlink the skill into your Claude Code skills directory (or `cp -r` to copy instead):

```bash
git clone https://github.com/samehkamaleldin/sameh-agency.git
mkdir -p ~/.claude/skills   # create it if this is a fresh Claude Code install
ln -s "$PWD/sameh-agency/skills/review-rounds" ~/.claude/skills/review-rounds
# to copy instead of symlinking: cp -r sameh-agency/skills/review-rounds ~/.claude/skills/
```

**Windows (PowerShell)** — clone, then copy (or symlink, which needs Developer Mode or an elevated shell):

```powershell
git clone https://github.com/samehkamaleldin/sameh-agency.git
New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null
Copy-Item -Recurse .\sameh-agency\skills\review-rounds "$HOME\.claude\skills\"
# to symlink instead: New-Item -ItemType SymbolicLink -Path "$HOME\.claude\skills\review-rounds" -Target (Resolve-Path .\sameh-agency\skills\review-rounds)
```

> On Windows, [WSL](https://learn.microsoft.com/windows/wsl/) or Git Bash lets you run the macOS / Linux commands as-is.

Restart Claude Code (or start a new session) to pick up the new skill.

## License

[MIT](LICENSE)
