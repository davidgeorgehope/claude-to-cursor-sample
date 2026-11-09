# Claude → Cursor sample

A small, customer-safe sample that shows how **Claude Code** skills, hooks, `CLAUDE.md`, and marketplace layout work in **Cursor** with little or no rewriting — and how the same content looks in Cursor-native paths.

## Cursor loads your `.claude` files as they are

Cursor reads Claude Code content straight from disk. You do not need to convert it first. Cursor loads:

- `CLAUDE.md` project instructions
- Skills in `.claude/skills/` (project) and `~/.claude/skills/` (user)
- Hooks in `.claude/settings.json` and `~/.claude/settings.json`
- Claude plugin marketplaces (`.claude-plugin/marketplace.json`)

This works when **Settings → Agents → Include Third-Party Plugins, Skills, and Other Configs** is on. It is on by default. Claude Code does not need to be installed. The Cursor-native copies in this repo show the target format if you later want to move off the Claude paths.

This repo is a side-by-side reference, not a product dependency. Copy what you need into your own projects.

## What this shows

| Artifact | Claude layout (works in Cursor) | Cursor-native layout |
|---|---|---|
| Project instructions | `CLAUDE.md` | `AGENTS.md` |
| Skill | `.claude/skills/secure-commit/SKILL.md` | `.cursor/skills/secure-commit/SKILL.md` |
| Hook | `.claude/settings.json` (`PreToolUse` / `Bash`) | `.cursor/hooks.json` (`preToolUse` / `Shell`) |
| Marketplace | `.claude-plugin/marketplace.json` | `.cursor-plugin/marketplace.json` |
| Example plugin | `plugins/secure-commit/` (dual manifests) | same |

Skills and `CLAUDE.md` are read natively when **Settings → Agents → Include Third-Party Plugins, Skills, and Other Configs** is on. That setting is **on by default**. You do **not** need to rewrite skills to migrate. Optionally copy skills into `.cursor/skills` later so they no longer depend on the third-party setting.

`AGENTS.md` is always loaded. If both `AGENTS.md` and `CLAUDE.md` exist in the same folder, Cursor prefers `AGENTS.md`.

Claude Code does **not** need to be installed for Cursor to read these files from disk.

## Hook event mapping (Claude → Cursor)

| Claude Code | Cursor | Supported? |
|---|---|---|
| `PreToolUse` | `preToolUse` | Yes |
| `PostToolUse` | `postToolUse` | Yes |
| `UserPromptSubmit` | `beforeSubmitPrompt` | Yes |
| `Stop` | `stop` | Yes |
| `SubagentStop` | `subagentStop` | Yes |
| `SessionStart` | `sessionStart` | Yes |
| `SessionEnd` | `sessionEnd` | Yes |
| `PreCompact` | `preCompact` | Yes |
| `Notification` | — | **Not supported** |
| `PermissionRequest` | — | **Not supported** |

Cursor also has hooks Claude Code does not (for example before/after shell and MCP execution, after file edit, workspace open).

### Tool name remaps

| Claude | Cursor |
|---|---|
| `Bash` | `Shell` |
| `Edit` / `Write` | `Write` |
| `Read` | `Read` |
| `Grep` | `Grep` |
| `Task` | `Task` |
| MCP tools | remapped |

### Behavior notes

- **Exit code 2** still means block (deny), matching Claude Code.
- Cursor also accepts Claude-style JSON permission decisions as well as Cursor’s `allow` / `deny` / `ask`.
- `SessionStart` and `PreCompact` **trigger matchers** (startup/resume/…, manual/auto) are **not filtered** in Cursor — those hooks fire for all triggers.
- Prefer a **single command string** in `command`, not an `args` array, until you confirm your Cursor build handles args.
- There is no separate Claude `shell` selector in Cursor.

## Avoiding double-firing hooks

This repo includes **both** `.claude/settings.json` and `.cursor/hooks.json`, both calling `./scripts/deny-rm-rf.sh`, so you can compare formats. With both present, Cursor may load both (and may dedupe identical command strings). For a clean A/B test of one format:

1. **Claude format only:** rename `.cursor/hooks.json` → `.cursor/hooks.json.off`, keep third-party imports on.
2. **Cursor format only:** rename `.claude/settings.json` → `.claude/settings.json.off`, *or* turn off **Include Third-Party Plugins, Skills, and Other Configs**.
3. Restore the renamed file when you are done.

For production, pick one layout (or keep Claude files for compatibility and add Cursor-native copies when you want toggle-independent behavior).

## Team distribution options

- Commit skills, rules, and hooks in the **repo** or workspace image (best for remote workspaces)
- Dashboard **team rules**
- Dashboard **team hooks** (admin-managed scripts)
- Dashboard **team plugin marketplace** / required plugins
- Enterprise / MDM `hooks.json` on the hosts (on Linux, typically under `/etc/cursor/`)

Org-wide disable of Claude third-party import is not available today; the control is the per-user Agents setting.

## Remote workspaces (Coder or any Remote-SSH)

When Cursor is connected over Remote-SSH:

- **Project** skills, rules, hooks, `CLAUDE.md`, and `AGENTS.md` must live in the **remote workspace** (this git repo or the image).
- **User-level** Claude/Cursor skills and hook settings must live in the **remote user’s home** on the host, not only on the laptop.
- Files that exist only under `~/.claude` on the laptop are **not** seen by a remote session.
- Enterprise / MDM hooks are read from the **remote** machine paths.
- Slash commands and some MCP user configs may resolve from the **local** machine — keep that distinction in mind.

Recommended: bake `.claude/skills`, `.cursor/skills`, and either `.claude/settings.json` or `.cursor/hooks.json` into the remote template or repo.

## How to try it (smoke test)

1. Open this folder in Cursor.
2. Confirm **Settings → Agents → Include Third-Party Plugins, Skills, and Other Configs** is on (default).
3. Confirm the `secure-commit` skill is listed (from `.claude/skills` and/or `.cursor/skills`).
4. In Agent chat, ask the model to run something like `rm -rf /tmp/x` (or any force-remove). The `deny-rm-rf.sh` hook should **block** it (exit code 2) and print a reason.
5. Ask it to run a harmless command (for example `ls`) and confirm that is allowed.
6. Optionally rename one hook config (see above) and repeat to test a single format.

You can also exercise the script outside Cursor:

```bash
# Should exit 2 (blocked)
echo '{"tool_input":{"command":"rm -rf /tmp/x"}}' | ./scripts/deny-rm-rf.sh; echo exit:$?

# Should exit 0 (allowed)
echo '{"tool_input":{"command":"ls -la"}}' | ./scripts/deny-rm-rf.sh; echo exit:$?
```

## Repo layout

```
.
├── AGENTS.md                          # Cursor project instructions
├── CLAUDE.md                          # Claude project instructions
├── LICENSE
├── README.md
├── .claude/
│   ├── settings.json                  # Claude hooks (PreToolUse → Bash)
│   └── skills/secure-commit/SKILL.md
├── .claude-plugin/
│   └── marketplace.json
├── .cursor/
│   ├── hooks.json                     # Cursor hooks (preToolUse → Shell)
│   └── skills/secure-commit/SKILL.md  # same skill body
├── .cursor-plugin/
│   └── marketplace.json
├── plugins/
│   └── secure-commit/                 # minimal marketplace plugin
│       ├── .claude-plugin/plugin.json
│       ├── .cursor-plugin/plugin.json
│       └── skills/secure-commit/SKILL.md
└── scripts/
    └── deny-rm-rf.sh                  # shared blocker (exit 2)
```

## Known unknowns

These are called out so you can verify on your own build and remote setup rather than treating them as settled:

- Whether marketplace auto-import finds Claude plugins under the **remote** home over Remote-SSH (without a local Claude install).
- Whether nested `CLAUDE.md` files behave the same as nested `AGENTS.md` across the IDE and CLI.
- Whether an org-wide admin control for Claude third-party imports has shipped (today the toggle is per-user).

A one-skill / one-hook smoke test on a single remote workspace (loaded from both the repo and the remote home) is the fastest way to confirm your environment.
