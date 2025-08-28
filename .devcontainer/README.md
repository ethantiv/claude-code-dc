# DevContainer Configuration

Automatically configures a complete Claude Code and Codex environment with MCP servers and custom commands.

## What's included

**DevContainer (`devcontainer.json`)**:
- GitHub CLI, Node.js, Python, Terraform
- Claude Code CLI with configuration
- OpenAI Codex CLI with configuration
- MCP servers: AWS tools, GitHub, Playwright, Context7

**Custom slash commands**:
- `/git-commit`: Conventional commit generator
- `/code-review`: Security-focused code analysis  
- `/project-overview`: Architecture documentation
- `/github-pr-create`: Pull Request creation
- `/polish-correction`: Polish text correction

## GitHub Token Setup

**Local**: Add to `.devcontainer/.env`:
```bash
GH_TOKEN=ghp_your_token_here
```

**Codespaces**: Settings → Codespaces → Secrets → `GH_TOKEN`

Token permissions: `repo`, `read:user`, `workflow`

## Files Structure

```
.devcontainer/
├── devcontainer.json              # Container definition
├── setup-claude-environment.sh    # Automatic setup script
├── configuration/                 # Claude Code & Codex config
│   ├── mcp-servers.json          # MCP server definitions
│   └── settings.devcontainer.json # Claude settings
└── commands/                      # Custom slash commands
    ├── code-review.md
    ├── git-commit.md
    └── ... (other commands)
```

## Persistent Data Storage

**Claude Code**: Configuration stored in `/home/vscode/.claude` (volume: `claude-code-config-${devcontainerId}`)  
**Codex**: Configuration stored in `/home/vscode/.codex` (volume: `codex-config-${devcontainerId}`)

Everything is configured automatically on container startup.