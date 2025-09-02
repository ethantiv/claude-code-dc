# DevContainer Configuration

Automatically configures a complete Claude Code and Codex environment with MCP servers and custom commands.

## What's included

**DevContainer (`devcontainer.json`)**:
- GitHub CLI, Node.js, Python, Terraform
- Claude Code CLI with configuration
- OpenAI Codex CLI with configuration
- MCP servers

**Custom slash commands**:
- `/git-commit`: Conventional commit generator
- `/code-review`: Security-focused code analysis  
- `/project-overview`: Architecture documentation
- `/github-pr-create`: Pull Request creation
- `/polish-correction`: Polish text correction

## Authentication Setup

### GitHub Token (Required)

**Local Development**: Add to `.devcontainer/.env`:
```bash
GH_TOKEN=ghp_your_token_here
```

**Codespaces**: Settings → Codespaces → Secrets → `GH_TOKEN`

Required permissions: `repo`, `read:user`, `workflow`

### Optional Authentication (CLI Tools)

**Local Development**: Add to `.devcontainer/.env`:
```bash
# Codex authentication (encode existing auth.json)
base64 -w 0 ~/.codex/auth.json
CODEX_AUTH=your_base64_encoded_auth_json_here

# Claude Code authentication (encode existing credentials.json)  
base64 -w 0 ~/.claude/.credentials.json
CLAUDE_AUTH=your_base64_encoded_credentials_json_here
```

**Codespaces**: Add secrets in Settings → Codespaces → Secrets:

1. **CODEX_AUTH**: base64-encoded content of `~/.codex/auth.json`
2. **CLAUDE_AUTH**: base64-encoded content of `~/.claude/.credentials.json`

Files are automatically created with proper permissions (600) on container restart.

## Files Structure

```
.devcontainer/
├── devcontainer.json          # Container definition
├── setup-env.sh               # Complete environment setup script
├── configuration/             # Claude Code & Codex config
│   ├── mcp-servers.json      # MCP server definitions
│   └── settings.devcontainer.json # Claude settings
└── commands/                  # Custom slash commands
    ├── code-review.md
    ├── git-commit.md
    └── ... (other commands)
```

## Persistent Data Storage

**Claude Code**: Configuration stored in `/home/vscode/.claude` (volume: `claude-code-config-${devcontainerId}`)  
**Codex**: Configuration stored in `/home/vscode/.codex` (volume: `codex-config-${devcontainerId}`)

Everything is configured automatically on container startup.