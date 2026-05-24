# sameh-agency

A collection of [Claude Code](https://docs.claude.com/en/docs/claude-code) skills.

## Layout

```
skills/
  <skill-name>/
    SKILL.md
```

Each skill is a directory under `skills/` containing a `SKILL.md` with YAML frontmatter (`name`, `description`) followed by the skill body. See the [Claude Code skills docs](https://docs.claude.com/en/docs/claude-code/skills) for the format.

## Skills

### `review-rounds`

Iteratively harden recent changes by running multiple rounds of parallel reviewer subagents, compiling findings into a unified fix list, applying fixes, and merging each round back to main. Defaults to 3 reviewers × 5 rounds over recent commits + uncommitted changes.

Trigger: `/review-rounds`, "run review rounds", "do N rounds of review", "multi-round review", "iterative review".

## Install

Symlink any skill into your Claude Code skills directory:

```bash
git clone https://github.com/sameh/sameh-agency.git
ln -s "$PWD/sameh-agency/skills/review-rounds" ~/.claude/skills/review-rounds
```

Or copy if you'd rather not symlink:

```bash
cp -r sameh-agency/skills/review-rounds ~/.claude/skills/
```

Restart Claude Code (or start a new session) to pick up the new skill.

## License

[MIT](LICENSE)
