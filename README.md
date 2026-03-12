<div align="center">

<img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/vd7.webp" alt="logo" width="80" height="80" />

<h1>gh-template</h1>
<p><i><b>GitHub repo template with extensive AI agent configs, git hooks, automation scripts, metadata sanitzation</b></i></p>

</div>

<br/>


## Structure

```
.hooks/
├── pre-commit              ← metadata strip + collaborator check
├── pre-push                ← Touch ID gate (shelllock) + health check (large files, embedded repos)
├── post-checkout           ← identity warning
└── scripts/
    ├── setup.sh            ← one-time setup after clone
    ├── set-remote.sh       ← set origin from repo.config.json (remote.prefer / origin_url)
    ├── check-collaborator.sh ← forge-agnostic (GitHub/GitLab/Codeberg/Gitea/Bitbucket)
    ├── clearmeta.sh
    ├── gen-social.sh
    ├── health-check.sh
    └── upload-cloudinary.sh
.github/
└── templates/
    ├── README.template.md 
    ├── TODOs.template.md       ← copy to root → TODOs.md
    ├── _0/                     ← copy to root (cp -r) → gitignored working dir (_archive, _artifacts, _plans)
    ├── .gitignore.template     ← mega gitignore (set & forget)
    ├── timeline.template.json  ← project timeline/milestones
    └── [agent configs]/        ← aider, claude, codex, cursor, etc.
.gitconfig                  ← repo-level git config (core.hooksPath)
git-template/               ← optional: Git init template (post-checkout reminder after clone)
├── hooks/
│   └── post-checkout       ← prints "Run .hooks/scripts/setup.sh" until setup is run
assets/
├── icons/
│   └── agents/                 
└── social-preview-blank.png    ← social preview (1280x640)
repo.config.json 
```

<br/>

## Setup

```bash
# 1. Create repo from template (GitHub UI: "Use this template" → "Create new repository")
# 2. Clone + activate hooks (use SSH or HTTPS URL from GitHub repo page— same steps either way)
git clone <your-repo-url>   # e.g. git@github.com:username/repo.git  or  https://github.com/username/repo.git
cd <path-to-your-repo>
.hooks/scripts/setup.sh

# 3. Configure
# edit repo.config.json (project details; optional: remote.prefer or remote.origin_url — see Remote below)
cp ".github/templates/.gitignore.template" ".gitignore"       # mega gitignore (set & forget)
cp ".github/templates/timeline.template.json" "timeline.json" # AI agents auto-extend this
cp ".github/templates/TODOs.template.md" "TODOs.md"
cp -r ".github/templates/_0" .


# 4. Last: replace this README with your project README (run only when done with setup)
cp .github/templates/README.template.md README.md        # then replace PROJECT_NAME, USERNAME
```

> **Step 2 is mandatory** — hooks don't activate until you run `setup.sh`.

### Remote (SSH vs HTTPS)

In `repo.config.json`, set **`remote`** to control `origin`:

| Key | Values | Effect |
|-----|--------|--------|
| `prefer` | `"ssh"` | Set origin to `git@host:slug.git` (default; use when SSH is set globally). |
| `prefer` | `"auto"` | Leave current URL as-is. |
| `prefer` | `"https"` | Set origin to `https://host/slug.git`. |
| `origin_url` | `"git@github.com:user/repo.git"` or any URL | Overrides; use this to pin exact URL. |

Default is **`ssh`** so repos created from this template match a global SSH preference (e.g. `git config --global url.git@github.com:.insteadOf https://github.com/`). After editing, run **`.hooks/scripts/set-remote.sh`** (or re-run `setup.sh`).

<br/>

## Included

### Agent configs

| | Agent | Files | Site |
|:---:|-------|-------|------|
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/cursor.webp) | Cursor | `.cursor/rules/*.mdc`, `.cursorignore` | [cursor.com](https://www.cursor.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/claude.webp) | Claude | `CLAUDE.md` | [anthropic.com](https://www.anthropic.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/codex.webp) | Codex | `AGENTS.md` | [openai.com](https://openai.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/copilot.webp) | Copilot | `.github/copilot-instructions.md` | [GitHub Copilot](https://github.com/features/copilot) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/gemini.webp) | Gemini | `GEMINI.md` | [ai.google.dev](https://ai.google.dev) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/aider.webp) | Aider | `.aider.conf.yml`, `CONVENTIONS.md` | [aider.chat](https://aider.chat) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/codeium.webp) | Windsurf | `.windsurfrules` | [codeium.com](https://codeium.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/zed.webp) | Zed | `.rules` | [zed.dev](https://zed.dev) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/roocode.webp) | Roo | `.roomodes` | [roo.codes](https://roo.codes) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/codeium.webp) | Codeium | `.codeiumignore` | [codeium.com](https://codeium.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/amazonq.webp) | Amazon Q | `.amazonq/rules/*.md` | [AWS Amazon Q](https://aws.amazon.com/q) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/kiro.webp) | Kiro | `.kiro/steering/` | [kiro.ai](https://kiro.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/opencode.webp) | OpenCode | `opencode.json` | [opencode.ai](https://opencode.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/kilo.webp) | Kilo | `.kilocode/launchConfig.json` | [kilocode.com](https://kilocode.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/traycer.webp) | Traycer | `.traycer/` | [traycer.com](https://traycer.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/amp.webp) | Amp | `AMP.md` | [useamp.com](https://useamp.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/qoder.webp) | Qoder | `.qoder/` | [qoder.com](https://qoder.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/warp.webp) | Warp | `warp.md` | [warp.dev](https://www.warp.dev) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/droid.webp) | Droid | `.droid.yaml` | [droid.ai](https://droid.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/cline.webp) | Cline | `.clinerules/*.md` | [cline.dev](https://cline.dev) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/trae.webp) | Trae | `.trae/project_rules.md`, `.trae/user_rules.md` | [gettrae.com](https://gettrae.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/antigravity.webp) | Antigravity | `.antigravity` | [antigravity.dev](https://antigravity.dev) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/pearai.webp) | Pear AI | `~/.pearai/config.json` | [pear.ai](https://pear.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/conductor.webp) | Conductor | `conductor.json` | [conductor.com](https://conductor.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/kimi.webp) | Kimi CLI | `AGENTS.md` | [moonshot.cn](https://www.moonshot.cn) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/qwen.webp) | Qwen CLI | `.env`, `.qwen-ignore` | [qwen.ai](https://qwen.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/greptile.webp) | Greptile | `.greptile/` | [greptile.com](https://greptile.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/coderabbit.webp) | CodeRabbit | `.coderabbit.yaml` | [coderabbit.ai](https://coderabbit.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/graphite.webp) | Graphite | `.graphite/` | [graphite.com](https://graphite.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/cody.webp) | Cody | `.sourcegraph/` | [sourcegraph.com](https://sourcegraph.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/tabnine.webp) | Tabnine | `.tabnine/` | [tabnine.com](https://tabnine.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/supermaven.webp) | Supermaven | `.supermaven/` | [supermaven.com](https://supermaven.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/continue.webp) | Continue | `.continue/config.json` | [continue.dev](https://continue.dev) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/devin.webp) | Devin | `devin.md` | [devin.ai](https://devin.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/replit.webp) | Replit | `.replit` | [replit.com](https://replit.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/bolt.webp) | Bolt | `bolt.json` | [bolt.new](https://bolt.new) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/v0.webp) | v0 | `v0.json` | [v0.dev](https://v0.dev) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/lovable.webp) | Lovable | `lovable.json` | [lovable.dev](https://lovable.dev) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/blackbox.webp) | Blackbox | `.blackbox/` | [blackbox.ai](https://blackbox.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/superset.webp) | Superset | `.superset/config.json` | [superset.com](https://superset.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/goose.webp) | Goose | `.goosehints` | [goose.ai](https://goose.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/augment.webp) | Augment / Auggie | `.augment/`, `.augment/commands/` | [augmentcode.com](https://www.augmentcode.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/junie.webp) | Junie | `.junie/AGENTS.md`, `.junie/guidelines.md`, `.junie/skills/`, `.junie/mcp/mcp.json` | [junie.jetbrains.com](https://junie.jetbrains.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/geminicli.webp) | Gemini CLI | `GEMINI.md`, `.gemini/settings.json` | [geminicli.com](https://geminicli.com) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/sourcery.webp) | Sourcery | `.sourcery.yaml` | [sourcery.ai](https://sourcery.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/qodo.webp) | Qodo | `.qodo/` | [qodo.ai](https://www.qodo.ai) |
| ![](https://raw.githubusercontent.com/vdutts7/squircle/main/webp/zencoder.webp) | Zencoder | `.zencoder/` | [zencoder.ai](https://zencoder.ai) |

### Git hooks (platform-agnostic)

Hooks live in `.hooks/` (not `.github/hooks/`) — works with any git platform (GitHub, GitLab, Codeberg, Gitea, Bitbucket, self-hosted).

One-time setup after clone: `.hooks/scripts/setup.sh`

**Post-clone reminder (optional):** To see a terminal message after every clone reminding you to run `setup.sh`, set Git's template once per machine (from this repo): `git config --global init.templateDir "$(pwd)/git-template"`. Then every new clone of any repo created from this template will print the reminder until you run `.hooks/scripts/setup.sh`. The template dir can live anywhere; point `init.templateDir` at it.

| Hook | Trigger | What it does |
|------|---------|-------------|
| `pre-commit` | before commit | strips file metadata, checks collaborator access |
| `pre-push` | before push | Touch ID gate when [shelllock](https://github.com/vdutts7/shelllock-macos) is installed (blocks AI push); then health check (large files, embedded repos) |
| `post-checkout` | after checkout | warns if user.name doesn't match collaborator |

### Scripts

> usage instructions per script at top of file

| Script | Purpose |
|--------|---------|
| `setup.sh` | one-time setup after cloning (activates hooks) |
| `set-remote.sh` | set origin from repo.config.json (remote.prefer or origin_url) |
| `check-collaborator.sh` | forge-agnostic collaborator check (auto-detects from remote URL) |
| `clearmeta.sh` | NUCLEAR metadata strip; note: Apple SIP-protected provenance may persist |
| `gen-social.sh` | generate social preview image |
| `health-check.sh` | pre-push health check |
| `upload-cloudinary.sh` | upload assets to Cloudinary (set `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_UPLOAD_PRESET` env vars) |

### timeline.json

- **Append-only** project memory
- timestamped ledger/makeshift database for full traceability/auditability
- AI agents extend `timeline.json` as you work (or manually invoke via `/timeline` slash command → `.github/templates/cursor/commands/timeline.md`)
> **Why:** Context persists across sessions → when you return to a project, agents can read timeline to understand what happened, what decisions were made, what's blocked


<br/>


## Contact

<a href="https://vd7.io"><img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI5NyIgaGVpZ2h0PSI0MCIgdmlld0JveD0iMCAwIDk3IDQwIj48ZGVmcz48bGluZWFyR3JhZGllbnQgaWQ9ImNpcmNsZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIxMDAlIiB5Mj0iMCUiPjxzdG9wIG9mZnNldD0iMCUiIHN0eWxlPSJzdG9wLWNvbG9yOiM1ZGQzZmYiLz48c3RvcCBvZmZzZXQ9IjEwMCUiIHN0eWxlPSJzdG9wLWNvbG9yOiMyMmE4YzkiLz48L2xpbmVhckdyYWRpZW50PjwvZGVmcz48cmVjdCB4PSIwIiB5PSIwIiB3aWR0aD0iOTciIGhlaWdodD0iNDAiIHJ4PSIyMCIgcnk9IjIwIiBmaWxsPSIjMDAwIiBzdHJva2U9InJnYmEoMjU1LDI1NSwyNTUsMC4yKSIgc3Ryb2tlLXdpZHRoPSIxIi8+PGcgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTMsIDApIj48Y2lyY2xlIGN4PSI5IiBjeT0iMjAiIHI9IjkiIGZpbGw9InVybCgjY2lyY2xlKSIvPjx0ZXh0IHg9IjI2IiB5PSIyNSIgZmlsbD0iI2ZmZiIgZm9udC1mYW1pbHk9IidKZXRCcmFpbnMgTW9ubycsJ1NGIE1vbm8nLCdGaXJhIENvZGUnLG1vbm9zcGFjZSIgZm9udC1zaXplPSIxMyIgZm9udC13ZWlnaHQ9IjUwMCI+dmQ3LmlvPC90ZXh0PjwvZz48L3N2Zz4=" alt="vd7.io" height="40" /></a> &nbsp; <a href="https://x.com/vdutts7"><img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMTgiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCAxMTggNDAiPjxyZWN0IHg9IjAiIHk9IjAiIHdpZHRoPSIxMTgiIGhlaWdodD0iNDAiIHJ4PSIyMCIgcnk9IjIwIiBmaWxsPSIjMDAwIiBzdHJva2U9InJnYmEoMjU1LDI1NSwyNTUsMC4yKSIgc3Ryb2tlLXdpZHRoPSIxIi8+PGcgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTMsIDApIj48ZyB0cmFuc2Zvcm09InRyYW5zbGF0ZSg5LCAyMCkgc2NhbGUoMC41NSkgdHJhbnNsYXRlKC0xMiwgLTEyKSI+PHBhdGggZD0iTTE4LjI0NCAyLjI1aDMuMzA4bC03LjIyNyA4LjI2IDguNTAyIDExLjI0SDE2LjE3bC01LjIxNC02LjgxN0w0Ljk5IDIxLjc1SDEuNjhsNy43My04LjgzNUwxLjI1NCAyLjI1SDguMDhsNC43MTMgNi4yMzF6bS0xLjE2MSAxNy41MmgxLjgzM0w3LjA4NCA0LjEyNkg1LjExN3oiIGZpbGw9IiNmZmYiLz48L2c+PHRleHQgeD0iMjYiIHk9IjI1IiBmaWxsPSIjZmZmIiBmb250LWZhbWlseT0iJ0pldEJyYWlucyBNb25vJywnU0YgTW9ubycsJ0ZpcmEgQ29kZScsbW9ub3NwYWNlIiBmb250LXNpemU9IjEzIiBmb250LXdlaWdodD0iNTAwIj4vdmR1dHRzNzwvdGV4dD48L2c+PC9zdmc+" alt="/vdutts7" height="40" /></a>
