<div align="center">

<img src="assets/icons/vd7.webp" alt="logo" width="80" height="80" />

<h1>gh-template</h1>
<p><i><b>GitHub repo template with AI agent configs, git hooks, automation scripts, metadata cleansing.</b></i></p>

</div>

<br/>


## Structure

```
.github/
├── hooks/
│   ├── pre-commit
│   ├── pre-push
│   └── post-checkout
├── scripts/
│   ├── setup.sh 
│   ├── clearmeta.sh
│   ├── gen-social.sh
│   ├── health-check.sh
│   └── upload-cloudinary.sh
└── templates/
    ├── README.template.md 
    ├── timeline.template.json  ← project timeline/milestones
    └── [agent configs]/        ← aider, claude, codex, cursor, etc.
assets/
├── icons/
│   └── agents/                 
└── social-preview-blank.png    ← GitHub social preview (1280x640)
repo.config.json 
```

<br/>

## Setup

1. Visit [Github repo template](https://github.com/vdutts7/gh-template) > **"Use this template"** > **"Create a new repository"** 
2. 

```bash
git clone https://github.com/vdutts7/gh-template.git && cd gh-template
.github/scripts/setup.sh
```

3. Update `repo.config.json` with project details- needed for other scripts to work
4. `cp .github/templates/README.template.md README.md`
5. Update `README.md` with project details:
   - `PROJECT_NAME` → GitHub repo name
   - `GITHUB_USERNAME` → GitHub username
6. Edit atop `assets/social-preview-blank.png` with your 1280x640 image (use `assets/social-preview.png` as reference), then set it in GitHub repo Settings > General > Social preview
7. `cp .github/templates/timeline.template.json timeline.json` - AI agents will extend this as you work

<br/>

## Included

### Agent configs

| | Agent | Files |
|:---:|-------|-------|
| <img src="assets/icons/agents/cursor.webp" width="16"> | Cursor | `.cursor/rules/*.mdc`, `.cursorignore` |
| <img src="assets/icons/agents/claude.webp" width="16"> | Claude | `CLAUDE.md` |
| <img src="assets/icons/agents/codex.webp" width="16"> | Codex | `AGENTS.md` |
| <img src="assets/icons/agents/copilot.webp" width="16"> | Copilot | `.github/copilot-instructions.md` |
| <img src="assets/icons/agents/gemini.webp" width="16"> | Gemini | `GEMINI.md` |
| <img src="assets/icons/agents/aider.webp" width="16"> | Aider | `.aider.conf.yml`, `CONVENTIONS.md` |
| <img src="assets/icons/agents/windsurf.webp" width="16"> | Windsurf | `.windsurfrules` |
| <img src="assets/icons/agents/zed.webp" width="16"> | Zed | `.rules` |
| <img src="assets/icons/agents/roo.webp" width="16"> | Roo | `.roomodes` |
| <img src="assets/icons/agents/codeium.webp" width="16"> | Codeium | `.codeiumignore` |
| <img src="assets/icons/agents/amazonq.webp" width="16"> | Amazon Q | `.amazonq/rules/*.md` |
| <img src="assets/icons/agents/kiro.webp" width="16"> | Kiro | `.kiro/steering/product.md`, `.kiro/steering/tech.md` |
| <img src="assets/icons/agents/opencode.webp" width="16"> | OpenCode | `opencode.json` |
| <img src="assets/icons/agents/kilo.webp" width="16"> | Kilo | `.kilocode/launchConfig.json` |
| <img src="assets/icons/agents/traycer.webp" width="16"> | Traycer | `.traycer/` |
| <img src="assets/icons/agents/amp.webp" width="16"> | Amp | `AMP.md` |
| <img src="assets/icons/agents/qoder.jpg" width="16"> | Qoder | `.qoder/` |
| <img src="assets/icons/agents/warp.webp" width="16"> | Warp | `warp.md` |
| <img src="assets/icons/agents/droid.webp" width="16"> | Droid | `.droid.yaml` |
| <img src="assets/icons/agents/cline.webp" width="16"> | Cline | `.clinerules/*.md` |
| <img src="assets/icons/agents/trae.webp" width="16"> | Trae | `.trae/project_rules.md`, `.trae/user_rules.md` |
| <img src="assets/icons/agents/antigravity.webp" width="16"> | Antigravity | `.antigravity` |
| <img src="assets/icons/agents/pearai.webp" width="16"> | Pear AI | `~/.pearai/config.json` |
| <img src="assets/icons/agents/conductor.webp" width="16"> | Conductor | `conductor.json` |
| <img src="assets/icons/agents/kimi.webp" width="16"> | Kimi CLI | `AGENTS.md` |
| <img src="assets/icons/agents/qwen.webp" width="16"> | Qwen CLI | `.env`, `.qwen-ignore` |

### Git hooks

- `pre-commit` - runs before each commit
- `pre-push` - runs before each push
- `post-checkout` - runs after checkout/clone

### Scripts

| Script | Purpose |
|--------|---------|
| `setup.sh` | initial setup after cloning |
| `clearmeta.sh` | clear metadata/caches; note: still leaves behind Apple SIP-protected provenance |
| `gen-social.sh` | generate social preview image |
| `health-check.sh` | verify repo setup |
| `upload-cloudinary.sh` | upload assets to Cloudinary |

### timeline.json

- **Append-only** project memory
- timestamped ledger / makeshift database for full traceability/auditability
- AI agents auto-extend `timeline.json` as you work (or you manually invoke via `/timeline` slash command)
> **Why:** Context persists across sessions -> when you return to a project, agents can read the timeline to understand what happened, what decisions were made, and what's blocked


<br/>


## Contact

<a href="https://vd7.io"><img src="https://img.shields.io/badge/website-000000?style=for-the-badge&logo=data:image/webp;base64,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&logoColor=white" alt="website" /></a>
<a href="https://x.com/vdutts7"><img src="https://img.shields.io/badge/vdutts7-000000?style=for-the-badge&logo=X&logoColor=white" alt="Twitter" /></a>
