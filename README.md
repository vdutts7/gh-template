<div align="center">

<img src="assets/icons/vd7.webp" alt="logo" width="80" height="80" />

<h1>gh-template</h1>
<p><i><b>GitHub repo template with AI agent configs, git hooks, and automation scripts.</b></i></p>

</div>

<br/>

## Setup

1. Visit [Github repo template](https://github.com/vdutts7/gh-template) > **"Use this template"** > **"Create a new repository"**
2. Clone new repo locally
3. Run setup:

```bash
.github/scripts/setup.sh
```

4. Update `repo.config.json` with project details
5. Copy README template:

```bash
cp .github/templates/README.template.md README.md
```

6. Find + replace placeholders in `README.md`:
   - `PROJECT_NAME` → your repo name
   - `GITHUB_USERNAME` → your GitHub username

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
| <img src="assets/icons/agents/qodo.webp" width="16"> | Qodo | `.ai_config.toml` |
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

- `pre-commit`- runs before each commit

### Scripts

| Script | Purpose |
|--------|---------|
| `setup.sh` | Initial setup after cloning |
| `clearmeta.sh` | Clear metadata/caches |

<br/>

## File structure

```
.github/
├── hooks/
│   └── pre-commit
├── scripts/
│   ├── setup.sh
│   └── clearmeta.sh
└── templates/
    └── README.template.md    ← copy this to README.md
assets/
└── icons/
    └── agents/               ← AI agent icons
repo.config.json              ← project configuration
```

<br/>

## Contact

<a href="https://vd7.io"><img src="https://res.cloudinary.com/ddyc1es5v/image/upload/h_28/v1768050242/gh-repos/gh-template/code.png" alt="vd7.io" /></a>
<a href="https://x.com/vdutts7"><img src="https://img.shields.io/badge//vdutts7-000000?style=for-the-badge&logo=X&logoColor=white" alt="Twitter" /></a>
