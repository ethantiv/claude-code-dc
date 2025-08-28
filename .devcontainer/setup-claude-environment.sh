#!/bin/bash

# Script to setup complete Claude Code environment during DevContainer initialization
# This script:
# - Clones configuration repository
# - Copies Claude configuration files (CLAUDE.md, settings.json, commands)
# - Configures MCP servers from mcp-servers.json
# - Sets up workspace with proper .gitignore

set -e

TEMP_REPO_DIR="/tmp/ethantiv-claude-code"
LOCK_FILE="/tmp/claude-mcp-setup.lock"

# Implement file locking to prevent race conditions during concurrent executions
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    echo "⚠️  Another instance of Claude setup is already running"
    echo "    Waiting for it to complete..."
    # Wait with timeout of 60 seconds
    if ! flock -w 60 200; then
        echo "❌ Timeout waiting for lock. Another setup may be stuck."
        echo "    To force continue, remove: $LOCK_FILE"
        exit 1
    fi
    echo "✅ Lock acquired, continuing setup"
fi

# Ensure lock is released on exit
trap 'exec 200>&-; rm -f "$LOCK_FILE"' EXIT

# Detect workspace folder - Codespaces vs local DevContainer
if [[ -n "${CODESPACE_VSCODE_FOLDER}" ]]; then
    WORKSPACE_FOLDER="${CODESPACE_VSCODE_FOLDER}"
    echo "🌍 Detected Codespaces environment: $WORKSPACE_FOLDER"
else
    WORKSPACE_FOLDER="${PWD}"
    echo "🖥️ Detected local DevContainer environment: $WORKSPACE_FOLDER"
fi

ENV_FILE="${WORKSPACE_FOLDER}/.devcontainer/.env"

# Prefer MCP config from the current workspace; fallback to repo clone set later
WORKSPACE_MCP_CONFIG_FILE="${WORKSPACE_FOLDER}/.devcontainer/configuration/mcp-servers.json"
MCP_CONFIG_FILE=""  # will be determined after clone if workspace file missing

echo "🚀 Setting up Claude Code environment..."

# Create empty .env file if it doesn't exist (required for runArgs in devcontainer.json)
if [[ ! -f "$ENV_FILE" ]]; then
    echo "📄 Creating empty .env file for DevContainer compatibility"
    touch "$ENV_FILE"
    echo "✅ Empty .env file created"
fi

# Optional: Load environment variables from .env file if it exists (for backward compatibility)
# Note: In DevContainer, tokens are now passed through containerEnv/remoteEnv configuration
if [[ -f "$ENV_FILE" ]]; then
    echo "📄 Loading additional environment variables from $ENV_FILE (optional)"
    # Secure loading with validation
    while IFS='=' read -r key value; do
        # Only load valid environment variable names
        if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
            export "$key"="${value//\"/}"
        fi
    done < <(grep -v '^#' "$ENV_FILE" | grep -v '^$')
fi

# Verify GitHub token is available
echo "🔐 Checking GitHub token availability..."

# Check if we're in Codespaces and can access user secrets
if [[ -n "${CODESPACES}" && -n "${GH_TOKEN}" ]]; then
    echo "✅ Codespaces environment with GH_TOKEN found"
    echo "🔧 Using your personal GH_TOKEN from Codespaces secrets"
elif [[ -n "${GH_TOKEN}" ]]; then
    echo "✅ GitHub token found (GH_TOKEN)"
elif [[ -n "${GITHUB_TOKEN}" ]]; then
    echo "✅ GitHub token found (GITHUB_TOKEN)"
    # Set GH_TOKEN to GITHUB_TOKEN for GitHub CLI compatibility
    export GH_TOKEN="${GITHUB_TOKEN}"
    echo "🔧 Set GH_TOKEN=${GITHUB_TOKEN:0:20}... for GitHub CLI"
else
    echo "❌ No GitHub token found (GH_TOKEN or GITHUB_TOKEN)"
    exit 1
fi

# Ensure the token is persistent for the session
if [[ -n "${GH_TOKEN}" ]]; then
    echo "export GH_TOKEN='${GH_TOKEN}'" >> ~/.bashrc
    echo "🔧 Added GH_TOKEN to ~/.bashrc for session persistence"
fi

# Clone the configuration repository
echo "📥 Cloning configuration repository..."
if gh repo clone ethantiv/claude-code-gh "$TEMP_REPO_DIR"; then
    echo "✅ Repository cloned successfully"
else
    echo "❌ Failed to clone repository"
    exit 1
fi

# Resolve which MCP configuration to use (workspace preferred)
if [[ -f "$WORKSPACE_MCP_CONFIG_FILE" ]]; then
    MCP_CONFIG_FILE="$WORKSPACE_MCP_CONFIG_FILE"
    echo "📖 Using workspace MCP config: $MCP_CONFIG_FILE"
else
    MCP_CONFIG_FILE="$TEMP_REPO_DIR/.devcontainer/configuration/mcp-servers.json"
    if [[ -f "$MCP_CONFIG_FILE" ]]; then
        echo "📖 Workspace MCP config not found; using repo default: $MCP_CONFIG_FILE"
    else
        echo "❌ MCP configuration file not found in workspace or repo"
        exit 1
    fi
fi

# Copy configuration files to appropriate locations
echo "📋 Copying configuration files..."

# Copy CLAUDE.md configuration
if [[ -f "$TEMP_REPO_DIR/.devcontainer/configuration/CLAUDE.md.memory" ]]; then
    cp "$TEMP_REPO_DIR/.devcontainer/configuration/CLAUDE.md.memory" "/home/vscode/.claude/CLAUDE.md"
    echo "✅ CLAUDE.md configuration copied"
else
    echo "⚠️  CLAUDE.md.memory not found, skipping"
fi

# Copy DevContainer settings
if [[ -f "$TEMP_REPO_DIR/.devcontainer/configuration/settings.devcontainer.json" ]]; then
    cp "$TEMP_REPO_DIR/.devcontainer/configuration/settings.devcontainer.json" "/home/vscode/.claude/settings.json"
    echo "✅ DevContainer settings copied"
else
    echo "⚠️  settings.devcontainer.json not found, skipping"
fi

# Copy commands directory
if [[ -d "$TEMP_REPO_DIR/.devcontainer/commands" ]]; then
    cp -r "$TEMP_REPO_DIR/.devcontainer/commands" "/home/vscode/.claude/"
    echo "✅ Commands directory copied"
else
    echo "⚠️  commands directory not found, skipping"
fi

# Copy .gitignore if it exists
if [[ -f "$TEMP_REPO_DIR/.gitignore" ]]; then
    cp "$TEMP_REPO_DIR/.gitignore" "${WORKSPACE_FOLDER}/.gitignore"
    echo "✅ .gitignore file copied"
else
    echo "⚠️  .gitignore not found, skipping"
fi

# Function to process and add a single MCP server
add_mcp_server() {
    local server_name="$1"
    local server_config="$2"
    
    echo "➕ Adding MCP server: $server_name"
    
    # Replace GH_TOKEN placeholder with actual token from environment
    # Try GH_TOKEN first, then fallback to GITHUB_TOKEN (for Codespaces)
    if [[ "$server_config" == *"GH_TOKEN"* ]]; then
        local token="${GH_TOKEN:-$GITHUB_TOKEN}"
        if [[ -n "$token" ]]; then
            server_config="${server_config//GH_TOKEN/$token}"
            echo "  🔑 Replaced GH_TOKEN with environment variable"
        else
            echo "  ⚠️  Neither GH_TOKEN nor GITHUB_TOKEN found in environment, keeping placeholder"
        fi
    fi
    
    # Execute claude mcp add-json command
    # Suppress "already exists" messages and treat them as success
    if output=$(claude mcp add-json "$server_name" "$server_config" 2>&1); then
        echo "  ✅ Successfully added $server_name"
    elif [[ "$output" == *"already exists"* ]]; then
        echo "  ℹ️  $server_name already configured"
    else
        # Only show error for actual failures, not for "already exists"
        echo "  ❌ Failed to add $server_name"
    fi
}

# Utility: get currently configured MCP server names using plain list output
get_current_mcp_servers() {
    local output
    output=$(claude mcp list 2>/dev/null) || return 1
    echo "$output" | awk '
        /^[[:space:]]*$/ { next }
        # Skip typical headers; adjust as needed for CLI output
        /^[[:space:]]*(Configured MCP servers|NAME|Name|Servers)/ { next }
        {
          line=$0
          # Strip leading bullets, dashes, and whitespace
          sub(/^[[:space:]]*[-*•]?[[:space:]]*/, "", line)
          # Keep token up to first space or colon
          name=line
          sub(/[[:space:]:].*$/, "", name)
          if (name ~ /^[A-Za-z0-9._-]+$/) print name
        }
    ' | sort -u
}

# Utility: remove a single MCP server using the canonical command
remove_mcp_server() {
    local name="$1"
    echo "➖ Removing MCP server not in config: $name"
    if claude mcp remove "$name" >/dev/null 2>&1; then
        echo "  ✅ Removed $name"
        return 0
    fi
    echo "  ❌ Failed to remove $name"
    return 1
}

# Parse JSON and extract server configurations
echo "📖 Parsing MCP server configurations..."

# Use jq to extract server names and configurations
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed"
    exit 1
fi

# Build desired server name list for pruning
desired_servers=$(jq -r '.mcpServers | keys[]' "$MCP_CONFIG_FILE" | sort -u)

echo "🧹 Pruning MCP servers not present in configuration..."
if current_servers=$(get_current_mcp_servers); then
    while IFS= read -r existing; do
        [[ -z "$existing" ]] && continue
        if ! grep -Fxq "$existing" <<< "$desired_servers"; then
            remove_mcp_server "$existing" || true
        else
            echo "  ✅ Keeping $existing"
        fi
    done <<< "$current_servers"
else
    echo "  ⚠️  Unable to list current MCP servers; skipping prune step"
fi

# Extract each server from mcpServers object and ensure they are added/configured
jq -r '.mcpServers | to_entries | .[] | @base64' "$MCP_CONFIG_FILE" | while read -r server_data; do
    # Decode base64 and extract server name and config
    server_name=$(echo "$server_data" | base64 --decode | jq -r '.key')
    server_config=$(echo "$server_data" | base64 --decode | jq -c '.value')
    
    add_mcp_server "$server_name" "$server_config"
done

echo "🎉 MCP server setup completed!"

# List all configured servers for verification
echo "📋 Currently configured MCP servers:"
claude mcp list || echo "  No servers configured or error listing servers"

# Cleanup temporary directory
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_REPO_DIR"
echo "✅ Cleanup completed"
