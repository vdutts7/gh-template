<div align="center">

<img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/vd7.webp" alt="logo" width="80" height="80" />

<h1>gh-template</h1>
<p><i><b>GitHub repo template with AI agent configs, git hooks, automation scripts, metadata cleansing.</b></i></p>

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

| | Agent | Files |
|:---:|-------|-------|
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/cursor.webp" width="16"> | Cursor | `.cursor/rules/*.mdc`, `.cursorignore` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/claude.webp" width="16"> | Claude | `CLAUDE.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/codex.webp" width="16"> | Codex | `AGENTS.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/copilot.webp" width="16"> | Copilot | `.github/copilot-instructions.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/gemini.webp" width="16"> | Gemini | `GEMINI.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/aider.webp" width="16"> | Aider | `.aider.conf.yml`, `CONVENTIONS.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/codeium.webp" width="16"> | Windsurf | `.windsurfrules` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/zed.webp" width="16"> | Zed | `.rules` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/roocode.webp" width="16"> | Roo | `.roomodes` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/codeium.webp" width="16"> | Codeium | `.codeiumignore` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/amazonq.webp" width="16"> | Amazon Q | `.amazonq/rules/*.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/kiro.webp" width="16"> | Kiro | `.kiro/steering/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/opencode.webp" width="16"> | OpenCode | `opencode.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/kilo.webp" width="16"> | Kilo | `.kilocode/launchConfig.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/traycer.webp" width="16"> | Traycer | `.traycer/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/amp.webp" width="16"> | Amp | `AMP.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/qoder.webp" width="16"> | Qoder | `.qoder/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/warp.webp" width="16"> | Warp | `warp.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/droid.webp" width="16"> | Droid | `.droid.yaml` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/cline.webp" width="16"> | Cline | `.clinerules/*.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/trae.webp" width="16"> | Trae | `.trae/project_rules.md`, `.trae/user_rules.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/antigravity.webp" width="16"> | Antigravity | `.antigravity` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/pearai.webp" width="16"> | Pear AI | `~/.pearai/config.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/conductor.webp" width="16"> | Conductor | `conductor.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/kimi.webp" width="16"> | Kimi CLI | `AGENTS.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/qwen.webp" width="16"> | Qwen CLI | `.env`, `.qwen-ignore` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/greptile.webp" width="16"> | Greptile | `.greptile/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/coderabbit.webp" width="16"> | CodeRabbit | `.coderabbit.yaml` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/graphite.webp" width="16"> | Graphite | `.graphite/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/cody.webp" width="16"> | Cody | `.sourcegraph/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/tabnine.webp" width="16"> | Tabnine | `.tabnine/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/supermaven.webp" width="16"> | Supermaven | `.supermaven/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/continue.webp" width="16"> | Continue | `.continue/config.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/devin.webp" width="16"> | Devin | `devin.md` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/replit.webp" width="16"> | Replit | `.replit` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/bolt.webp" width="16"> | Bolt | `bolt.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/v0.webp" width="16"> | v0 | `v0.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/lovable.webp" width="16"> | Lovable | `lovable.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/blackbox.webp" width="16"> | Blackbox | `.blackbox/` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/superset.webp" width="16"> | Superset | `.superset/config.json` |
| <img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/goose.webp" width="16"> | Goose | `.goosehints` |

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
- AI agents extend `timeline.json` as you work (or manually invoke via `/timeline` slash command -> `.github/templates/cursor/commands/timeline.md`)
> **Why:** Context persists across sessions -> when you return to a project, agents can read timeline to understand what happened, what decisions were made, what's blocked


<br/>


## Contact

<a href="https://vd7.io" style="display:inline-block;background:#000;color:#fff;padding:5px 14px;min-height:28px;box-sizing:border-box;border-radius:999px;border:1px solid rgba(255,255,255,0.25);text-decoration:none;font-size:12px;font-weight:500;font-family:'JetBrains Mono','SF Mono','Fira Code',monospace;vertical-align:middle;line-height:18px;"><img src="https://res.cloudinary.com/ddyc1es5v/image/upload/v1773284159/vd7-website/vd7-circle.webp" alt="" width="18" height="18" style="vertical-align:middle;margin-right:6px;" />vd7.io</a>
<a href="https://x.com/vdutts7" style="display:inline-block;background:#000;color:#fff;padding:5px 14px;min-height:28px;box-sizing:border-box;border-radius:999px;border:1px solid rgba(255,255,255,0.25);text-decoration:none;font-size:12px;font-weight:500;font-family:'JetBrains Mono','SF Mono','Fira Code',monospace;vertical-align:middle;line-height:18px;"><img src="https://raw.githubusercontent.com/vdutts7/squircle/main/webp/x.webp" alt="" width="18" height="18" style="vertical-align:middle;margin-right:6px;" />/vdutts7</a>
