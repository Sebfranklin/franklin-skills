---
name: skills-manager
description: >
  Use when the user wants to create, publish, install, sync, or manage Agent Skills
  across multiple AI CLI tools (Gemini CLI, OpenCode, Claude Code, Codex CLI, Cursor,
  etc.). Covers skill authoring, GitHub publishing, npx skills CLI usage, and
  cross-agent installation from a single source of truth.
metadata:
  author: Franklin / Church Unison Visionaries
  version: "1.0"
  spec-url: https://agentskills.io/specification
  env: termux-android
---

# Skills Manager

This skill guides the agent through the full lifecycle of Agent Skills:
authoring → organizing → publishing to GitHub → installing everywhere via `npx skills`.

---

## 1. Core Concepts

### What is a Skill?
A skill is a **folder** containing a `SKILL.md` file with:
- A YAML frontmatter block (`---`) with `name` and `description` fields
- A Markdown body with instructions the agent follows when activated

```
my-skill/
├── SKILL.md          ← required
├── scripts/          ← optional: bash/node scripts the agent can run
├── references/       ← optional: docs, API specs, cheat sheets
└── assets/           ← optional: templates, config files
```

### How Discovery Works
At session start, the agent loads **only the name + description** of every skill (cheap tokens).
When a task matches a skill's description, it calls `activate_skill` → the full `SKILL.md`
body loads into context. This is called **Progressive Disclosure** — keeps context lean.

### The Open Standard
Skills follow the [agentskills.io](https://agentskills.io) open standard originally by Anthropic.
One skill works across: **Gemini CLI, OpenCode, Claude Code, Codex CLI, GitHub Copilot, Cursor, Kiro**.

---

## 2. Skill Discovery Paths Per Tool

| Tool | Global (user) path | Project (workspace) path |
|---|---|---|
| **Gemini CLI** | `~/.gemini/skills/` or `~/.agents/skills/` | `.gemini/skills/` or `.agents/skills/` |
| **OpenCode** | `~/.agents/skills/` | `.agents/skills/` |
| **Claude Code** | `~/.claude/skills/` | `.claude/skills/` |
| **Codex CLI** | `~/.codex/skills/` | `.codex/skills/` |
| **GitHub Copilot** | `~/.github/skills/` | `.github/skills/` |
| **Cursor / Windsurf / Cline** | `~/.cursor/skills/` (varies) | `.agents/skills/` |

> **Tip:** Using `~/.agents/skills/` as the global path is the most portable option — it is
> recognized as the cross-agent alias by Gemini CLI, OpenCode, and most other tools.

---

## 3. Authoring a New Skill

### Step 1 — Scaffold the skill folder

```bash
# Using npx skills init (preferred)
npx skills init <skill-name>

# Or manually in Termux
mkdir -p ~/.agents/skills/<skill-name>
touch ~/.agents/skills/<skill-name>/SKILL.md
```

### Step 2 — Write the SKILL.md

Minimum required structure:

```markdown
---
name: skill-name
description: >
  Use when [trigger condition]. Does [what it does].
  Activated by [keywords or task types].
---

# Skill Title

Brief overview of what the skill does.

## When to Use
- Condition 1
- Condition 2

## Steps
1. Do this first
2. Then do that
3. Finally output result

## Notes
- Any caveats or edge cases
```

### Step 3 — Verify it appears in Gemini CLI

```bash
# Inside a Gemini CLI session
/skills list
/skills reload    # if you just added it
```

### Step 4 — Test activation
Ask a question that matches the skill's `description` field.
Gemini will prompt for consent before activating — press Enter to allow.

---

## 4. Organizing Skills into a GitHub Repo (Your Registry)

The recommended structure for a **multi-skill repo** (your single source of truth):

```
franklin-skills/                  ← GitHub repo root
├── README.md
├── gospel-dev/
│   ├── SKILL.md
│   └── references/
│       └── stack.md
├── cuv-workflow/
│   ├── SKILL.md
│   └── scripts/
│       └── setup.sh
├── expo-nativewind/
│   └── SKILL.md
├── supabase-edge/
│   └── SKILL.md
├── skills-manager/               ← this very skill
│   └── SKILL.md
└── content-creator/
    ├── SKILL.md
    └── references/
        └── brand-guide.md
```

### Pushing to GitHub

```bash
cd ~/skills-repo           # or wherever you keep it in Termux
git init
git add .
git commit -m "feat: initial skills pack"
gh repo create franklin-skills --public
git remote add origin https://github.com/<your-username>/franklin-skills.git
git push -u origin main
```

> Once pushed, your skills are installable by anyone (including yourself on a new device)
> with a single `npx` command. No registry submission — GitHub IS the registry.

---

## 5. Installing Your Skills Everywhere via `npx skills`

### Install all skills from your GitHub repo

```bash
# Install globally (works across all agents)
npx skills add <your-username>/franklin-skills --all -g

# Install only specific skills
npx skills add <your-username>/franklin-skills --skill gospel-dev -g
npx skills add <your-username>/franklin-skills --skill cuv-workflow -g
```

### Install to specific agents only

```bash
# Only Gemini CLI
npx skills add <your-username>/franklin-skills --all -g -a gemini-cli

# Gemini CLI + OpenCode
npx skills add <your-username>/franklin-skills --all -g -a gemini-cli -a opencode

# Claude Code only
npx skills add <your-username>/franklin-skills --skill gospel-dev -g -a claude-code
```

### Install on a new device (Termux one-liner)

```bash
# One command to restore all your skills everywhere
npx skills add <your-username>/franklin-skills --all -g -y
```

The `-y` flag skips all confirmation prompts — useful for automation.

---

## 6. Syncing and Updating Skills

### Update all installed skills

```bash
npx skills update           # interactive
npx skills update -g -y     # global, no prompts
```

### Check what's installed

```bash
npx skills list             # all scopes
npx skills ls -g            # global only
npx skills ls -a gemini-cli # filter by agent
```

### Reload in an active Gemini CLI session

```bash
/skills reload
/skills list
```

### Manual sync (if npx is unavailable in Termux)

If `npx skills` fails in Termux (Node.js not set up), fall back to git:

```bash
# Clone your skills repo and symlink into agent paths
git clone https://github.com/<your-username>/franklin-skills.git ~/franklin-skills

# Symlink each skill into the global agents path
for skill in ~/franklin-skills/*/; do
  skill_name=$(basename "$skill")
  ln -sf "$skill" ~/.agents/skills/"$skill_name"
done

# Verify
ls ~/.agents/skills/
```

To update later:

```bash
cd ~/franklin-skills && git pull
# Symlinks auto-update since they point to the cloned folder
```

---

## 7. Using Skills in OpenCode

OpenCode reads from `.agents/skills/` (project) and `~/.agents/skills/` (global).
No additional config needed after installing to `~/.agents/skills/`.

If OpenCode has an MCP config file (e.g., `~/.config/opencode/config.json`), no skills
entry is required — skills are file-system-based, not MCP-based.

To verify OpenCode sees your skills, start a session and trigger a skill by describing
the task that matches its `description` field.

---

## 8. Cross-Agent Compatibility Rules

Write skills that work everywhere by following these rules:

### DO
- Keep the `SKILL.md` body in plain Markdown with no tool-specific syntax
- Use `bash` or `node` scripts in `scripts/` (both are cross-platform)
- Reference files using relative paths (`./references/stack.md`)
- Keep frontmatter to `name`, `description`, and optionally `metadata`

### AVOID
- Claude Code-specific `context: fork` directives (breaks Gemini CLI)
- OpenAI `openai.yaml` metadata (ignored by non-OpenAI tools)
- Hardcoded absolute paths (breaks portability)
- Tool-specific slash commands in instructions

### If a skill needs tool-specific behavior
Create variants using a `metadata.agent` field and document both in the body:

```markdown
---
name: gospel-dev
description: Use when building or debugging the Gospel app (Expo + Supabase stack).
metadata:
  agents: [gemini-cli, opencode, claude-code]
---
```

---

## 9. Recommended Skill Pack for Franklin's Stack

These are the skills worth building and publishing to your GitHub registry:

| Skill name | Description trigger |
|---|---|
| `gospel-dev` | Building Gospel app with Expo + NativeWind + Supabase |
| `expo-nativewind` | Expo + NativeWind v4 styling issues and patterns |
| `supabase-edge` | Supabase Edge Functions, RLS policies, realtime |
| `cloudflare-deploy` | Cloudflare Pages/Workers/R2 deployment workflows |
| `turborepo-monorepo` | Turborepo task config, caching, workspace linking |
| `cuv-workflow` | Church Unison Visionaries — app vision, brand, theology context |
| `content-creator` | Anime brand content pipeline, 9:16 image gen, TTS workflow |
| `telegram-bot` | Grammy/Telegraf + Supabase + Vercel webhook bots |
| `termux-dev` | Android/Termux dev environment, Node/git/CLI setup |
| `skills-manager` | This skill — managing and publishing the skills pack itself |

---

## 10. Quick Reference Commands

```bash
# --- AUTHORING ---
npx skills init <name>                        # scaffold new skill
/skills reload                                # reload in active Gemini CLI session

# --- PUBLISHING ---
git add . && git commit -m "feat: add <name> skill"
git push

# --- INSTALLING ---
npx skills add <user>/franklin-skills --all -g -y          # restore everything
npx skills add <user>/franklin-skills --skill <name> -g    # single skill

# --- MANAGING ---
npx skills list                               # list all
npx skills update -g -y                       # update all globally
npx skills remove <name> -g                   # remove one

# --- TERMUX FALLBACK (no npx) ---
cd ~/franklin-skills && git pull              # update cloned repo
ln -sf ~/franklin-skills/<name> ~/.agents/skills/<name>    # symlink skill
```

---

## References
- [agentskills.io spec](https://agentskills.io/specification)
- [Gemini CLI skills docs](https://geminicli.com/docs/cli/skills/)
- [npx skills CLI (Vercel Labs)](https://github.com/vercel-labs/skills)
- [skills.sh registry](https://skills.sh)
