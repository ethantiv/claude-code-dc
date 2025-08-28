# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository manages a DevContainer configuration synchronization system that automatically propagates Claude Code settings, custom slash commands, and development environment configurations across multiple projects. It serves as a centralized configuration hub with automated distribution through GitHub Actions.

## Common Commands

### Configuration Synchronization

```bash
# Manual configuration edits (scripts not present)
# Edit repository configuration directly
nano .github/workflows/sync-repos.json

# Validate configuration syntax
jq '.' .github/workflows/sync-repos.json

# Manual workflow trigger for all repositories
gh workflow run sync-devcontainer.yml

# Manual trigger for specific repository
gh workflow run sync-devcontainer.yml \
  -f target_repo="repo-name" \
  -f create_pr=true \
  -f auto_merge=false
```

### Configuration Management

```bash
# Validate JSON configuration files
jq '.' .github/workflows/sync-repos.json
jq '.' .devcontainer/configuration/mcp-servers.json

# Add new repository to sync list
jq '.repositories += [{"name":"new-repo","owner":"owner","create_pr":true,"auto_merge":true}]' \
  .github/workflows/sync-repos.json > tmp && mv tmp .github/workflows/sync-repos.json

# View current sync configuration
cat .github/workflows/sync-repos.json | jq '.'
```

### Development and Testing

```bash
# Verify required tools are installed
command -v gh && echo "GitHub CLI available"
command -v jq && echo "jq available"

# Check authentication status
gh auth status

# Monitor workflow runs
gh run list --workflow=sync-devcontainer.yml
gh run view <RUN_ID>

# View recent pull requests in target repositories
gh pr list --repo owner/target-repo
```

## Architecture Overview

### Core Components

**GitHub Actions Workflow** (`.github/workflows/sync-devcontainer.yml`)
- Triggers on changes to `.devcontainer/` directory
- Creates matrix job strategy for parallel repository updates
- Supports both PR creation and direct push modes
- Implements automatic merge capabilities with branch protection handling

**Configuration System**
- `.devcontainer/configuration/mcp-servers.json`: MCP server definitions for AWS tools, documentation, GitHub integration, and browser automation
- `.devcontainer/configuration/settings.devcontainer.json`: Permission settings with bypass mode for MCP servers
- `.devcontainer/VERSION.json`: Version tracking for synchronization (auto-incremented by workflow)
- `.github/workflows/sync-repos.json`: Repository synchronization targets and settings

**Custom Slash Commands** (`.devcontainer/commands/` directory)
- `/git-commit`: Conventional commit message generator with staging automation
- `/code-review`: Comprehensive security-focused code analysis
- `/project-overview`: Architecture documentation generator with dependency analysis
- `/git-push`, `/git-merge`: Git operations with safety checks
- `/github-pr-create`: Pull request creation automation
- `/polish-correction`: Polish language text correction
- `/remove-comments`: Code cleanup utility

### Synchronization Flow

1. **Trigger**: Changes in monitored directories (`.devcontainer/**`, excludes `VERSION.json`) or manual workflow dispatch
2. **Version Management**: Auto-increment minor version number in `VERSION.json` and commit to source repo
3. **Matrix Preparation**: Dynamic repository list generation from configuration or single target selection
4. **Parallel Sync**: Concurrent updates to all target repositories using matrix strategy
5. **Change Detection**: Git diff analysis to avoid unnecessary operations and commits
6. **Branch Management**: Timestamped branch creation (`update-devcontainer-YYYYMMDD-HHMMSS`) for pull requests
7. **Automation**: PR creation with detailed descriptions and auto-merge with retry logic and exponential backoff

### MCP Server Integration

The system includes pre-configured MCP servers:
- **aws-diagram**: AWS architecture diagram generation
- **aws-docs**: AWS documentation access and search
- **aws-terraform**: Terraform configuration and security scanning
- **context7**: Library documentation and code examples
- **github**: GitHub API integration for repository management
- **playwright**: Browser automation and E2E testing

## Configuration Patterns

### Repository Management

Target repositories are defined in `.github/workflows/sync-repos.json` with structure:
```json
{
  "repositories": [
    {
      "name": "repo-name",
      "owner": "owner",
      "create_pr": true,
      "auto_merge": true
    }
  ],
  "settings": {
    "default_create_pr": true,
    "default_auto_merge": true
  }
}
```

Example from current configuration:
```json
{
  "repositories": [
    {
      "name": "playground",
      "owner": "ethantiv",
      "create_pr": true,
      "auto_merge": true
    },
    {
      "name": "dictation-app", 
      "owner": "ethantiv",
      "create_pr": true,
      "auto_merge": true
    }
  ],
  "settings": {
    "default_create_pr": true,
    "default_auto_merge": true
  }
}
```

### Security Requirements

- **GH_TOKEN**: Personal Access Token with `repo` and `workflow` scopes (stored as repository secret)
- **Branch Protection**: Target repositories should allow auto-merge and configure appropriate review requirements
- **Permissions**: MCP servers configured with `bypassPermissions` mode for seamless operation
- **GitHub CLI Authentication**: Required for workflow execution and repository management

### Workflow Features

The system implements comprehensive workflow capabilities:
- **Multi-mode execution**: Supports both PR creation and direct push modes
- **Conditional processing**: Only processes repositories when changes are detected
- **Retry mechanisms**: Auto-merge with exponential backoff (up to 5 attempts)
- **Branch cleanup**: Automatic deletion of feature branches after merge
- **Version tracking**: Incremental versioning system with timestamps
- **Fallback handling**: Manual intervention support when auto-merge fails
- **Status reporting**: Comprehensive workflow summaries and job results

## Development Workflow

### Adding New Repositories

1. Manually edit `.github/workflows/sync-repos.json`
2. Validate with `jq '.' .github/workflows/sync-repos.json`
3. Trigger sync: `gh workflow run sync-devcontainer.yml`

### Creating Custom Commands

1. Add `.md` file to `.devcontainer/commands/` directory
2. Include `allowed-tools` header for tool permissions
3. Follow existing patterns for error handling and output formatting
4. Test command functionality before committing

### Modifying MCP Configuration

1. Update `.devcontainer/configuration/mcp-servers.json` for server definitions
2. Modify `.devcontainer/configuration/settings.devcontainer.json` for permissions
3. Changes automatically sync to configured repositories
4. Verify functionality in target development environments

### Testing and Validation

Before deployment:
- Check JSON file syntax with `jq '.' .github/workflows/sync-repos.json`
- Verify GitHub CLI authentication and repository access with `gh auth status`
- Test workflow triggers with specific repository targets

This repository serves as the central nervous system for Claude Code development environments, ensuring consistent tooling and configuration across all managed projects while maintaining security and automation best practices.