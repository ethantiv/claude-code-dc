#!/bin/bash

# Script to setup complete development environment during DevContainer initialization
# This script:
# - Handles Codex authentication via CODEX_AUTH environment variable
# - Verifies GitHub tokens for MCP servers
# - Configures MCP servers from local mcp-servers.json
# - Sets up Claude Code configuration

set -e

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

ensure_directory() {
    local dir="$1"
    local name="$2"
    if [[ ! -d "$dir" ]]; then
        echo "📁 Creating $name directory"
        mkdir -p "$dir"
    fi
}

decode_and_validate_json() {
    local env_var="$1"
    local target_file="$2"
    local service_name="$3"
    
    local temp_file="${target_file}.tmp"
    
    if echo "${env_var}" | base64 --decode > "$temp_file" 2>/dev/null; then
        if jq empty "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$target_file"
            chmod 600 "$target_file"
            echo "✅ Successfully created $target_file from ${service_name}_AUTH"
            echo "🔒 Set file permissions to 600 (owner read/write only)"
            return 0
        else
            rm -f "$temp_file"
            echo "❌ Failed to decode ${service_name}_AUTH - invalid JSON format"
            echo "    Please ensure ${service_name}_AUTH contains valid base64-encoded JSON"
            return 1
        fi
    else
        rm -f "$temp_file"
        echo "❌ Failed to decode ${service_name}_AUTH - invalid base64 format"
        echo "    Please ensure ${service_name}_AUTH is properly base64 encoded"
        return 1
    fi
}

check_file_permissions() {
    local file="$1"
    local current_perms=$(stat -c "%a" "$file")
    if [[ "$current_perms" != "600" ]]; then
        chmod 600 "$file"
        echo "🔒 Updated file permissions to 600"
    fi
}

LOCK_FILE="/tmp/dev-env-setup.lock"

exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    echo "⚠️  Another instance of development environment setup is already running"
    echo "    Waiting for it to complete..."
    if ! flock -w 60 200; then
        echo "❌ Timeout waiting for lock. Another setup may be stuck."
        echo "    To force continue, remove: $LOCK_FILE"
        exit 1
    fi
    echo "✅ Lock acquired, continuing setup"
fi

trap 'exec 200>&-; rm -f "$LOCK_FILE"' EXIT

if [[ -n "${CODESPACE_VSCODE_FOLDER}" ]]; then
    WORKSPACE_FOLDER="${CODESPACE_VSCODE_FOLDER}"
    echo "🌍 Detected Codespaces environment: $WORKSPACE_FOLDER"
else
    WORKSPACE_FOLDER="${PWD}"
    echo "🖥️ Detected local DevContainer environment: $WORKSPACE_FOLDER"
fi

ENV_FILE="${WORKSPACE_FOLDER}/.devcontainer/.env"
MCP_CONFIG_FILE="${WORKSPACE_FOLDER}/.devcontainer/configuration/mcp-servers.json"

echo "🚀 Setting up development environment..."

# ============================================================================
# CODEX AUTHENTICATION SETUP
# ============================================================================

echo "🔐 Setting up Codex authentication..."

CODEX_DIR="$HOME/.codex"
AUTH_FILE="$CODEX_DIR/auth.json"

ensure_directory "$CODEX_DIR" ".codex"

if [[ -f "$AUTH_FILE" ]]; then
    echo "📄 Using existing ~/.codex/auth.json file"
    check_file_permissions "$AUTH_FILE"
    
elif [[ -n "${CODEX_AUTH}" ]]; then
    echo "🔑 Found CODEX_AUTH environment variable"
    
    if decode_and_validate_json "${CODEX_AUTH}" "$AUTH_FILE" "CODEX"; then
        if jq -e '.OPENAI_API_KEY' "$AUTH_FILE" >/dev/null 2>&1; then
            echo "✅ Codex authentication configured successfully"
        else
            echo "⚠️  Warning: auth.json may not contain valid OPENAI_API_KEY"
        fi
    else
        exit 1
    fi
    
else
    echo "⚠️  No CODEX_AUTH environment variable found and no existing auth.json"
    echo "    To set up Codex authentication in Codespaces:"
    echo "    1. Get your local ~/.codex/auth.json content"
    echo "    2. Encode it with: base64 -w 0 ~/.codex/auth.json"
    echo "    3. Add the result as CODEX_AUTH secret in GitHub Codespaces"
    echo "    4. Restart the DevContainer"
    echo ""
    echo "    Codex will not be authenticated but the environment is ready."
fi

echo "🎉 Codex authentication setup completed!"

# ============================================================================
# CLAUDE AUTHENTICATION SETUP
# ============================================================================

echo "🔐 Setting up Claude authentication..."

CLAUDE_DIR="$HOME/.claude"
CREDENTIALS_FILE="$CLAUDE_DIR/.credentials.json"
CLAUDE_JSON_FILE="$CLAUDE_DIR/.claude.json"

ensure_directory "$CLAUDE_DIR" ".claude"

if [[ -f "$CREDENTIALS_FILE" ]]; then
    echo "📄 Using existing ~/.claude/.credentials.json file"

elif [[ -n "${CLAUDE_AUTH}" ]]; then
    echo "🔑 Found CLAUDE_AUTH environment variable"
    
    if decode_and_validate_json "${CLAUDE_AUTH}" "$CREDENTIALS_FILE" "CLAUDE"; then
        if jq -e '.claudeAiOauth.accessToken' "$CREDENTIALS_FILE" >/dev/null 2>&1; then
            echo "✅ Claude authentication configured successfully"
            
            if [[ -f "$CLAUDE_JSON_FILE" ]]; then
                echo "🔧 Updating existing .claude.json with OAuth data..."
                
                ACCOUNT_UUID=$(jq -r '.claudeAiOauth.accountUuid // "unknown"' "$CREDENTIALS_FILE" 2>/dev/null || echo "unknown")
                EMAIL=$(jq -r '.claudeAiOauth.emailAddress // "user@example.com"' "$CREDENTIALS_FILE" 2>/dev/null || echo "user@example.com")
                ORG_UUID=$(jq -r '.claudeAiOauth.organizationUuid // "unknown"' "$CREDENTIALS_FILE" 2>/dev/null || echo "unknown")
                ORG_NAME="${EMAIL}'s Organization"
                
                if jq -e '.oauthAccount' "$CLAUDE_JSON_FILE" >/dev/null 2>&1; then
                    echo "ℹ️  OAuth account section already exists in .claude.json, skipping update"
                else
                    if jq --arg account_uuid "$ACCOUNT_UUID" \
                          --arg email "$EMAIL" \
                          --arg org_uuid "$ORG_UUID" \
                          --arg org_name "$ORG_NAME" \
                          '. + {
                            "oauthAccount": {
                              "accountUuid": $account_uuid,
                              "emailAddress": $email,
                              "organizationUuid": $org_uuid,
                              "organizationRole": "admin",
                              "workspaceRole": null,
                              "organizationName": $org_name
                            },
                            "shiftEnterKeyBindingInstalled": true,
                            "hasCompletedOnboarding": true,
                            "bypassPermissionsModeAccepted": true,
                            "hasOpusPlanDefault": true,
                            "subscriptionNoticeCount": 0,
                            "hasAvailableSubscription": false
                          }' "$CLAUDE_JSON_FILE" > "$CLAUDE_JSON_FILE.tmp" 2>/dev/null; then
                        mv "$CLAUDE_JSON_FILE.tmp" "$CLAUDE_JSON_FILE"
                        chmod 600 "$CLAUDE_JSON_FILE"
                        echo "✅ Updated .claude.json with OAuth account information for: $EMAIL"
                    else
                        rm -f "$CLAUDE_JSON_FILE.tmp"
                        echo "⚠️  Failed to update .claude.json - file may be corrupted"
                    fi
                fi
            else
                echo "📝 Creating minimal .claude.json with OAuth data..."
                
                ACCOUNT_UUID=$(jq -r '.claudeAiOauth.accountUuid // "unknown"' "$CREDENTIALS_FILE" 2>/dev/null || echo "unknown")
                EMAIL=$(jq -r '.claudeAiOauth.emailAddress // "user@example.com"' "$CREDENTIALS_FILE" 2>/dev/null || echo "user@example.com")
                ORG_UUID=$(jq -r '.claudeAiOauth.organizationUuid // "unknown"' "$CREDENTIALS_FILE" 2>/dev/null || echo "unknown")
                ORG_NAME="${EMAIL}'s Organization"
                
                if jq -n --arg account_uuid "$ACCOUNT_UUID" \
                      --arg email "$EMAIL" \
                      --arg org_uuid "$ORG_UUID" \
                      --arg org_name "$ORG_NAME" \
                      '{
                        "oauthAccount": {
                          "accountUuid": $account_uuid,
                          "emailAddress": $email,
                          "organizationUuid": $org_uuid,
                          "organizationRole": "admin",
                          "workspaceRole": null,
                          "organizationName": $org_name
                        },
                        "shiftEnterKeyBindingInstalled": true,
                        "hasCompletedOnboarding": true,
                        "bypassPermissionsModeAccepted": true,
                        "hasOpusPlanDefault": true,
                        "subscriptionNoticeCount": 0,
                        "hasAvailableSubscription": false
                      }' > "$CLAUDE_JSON_FILE" 2>/dev/null; then
                    chmod 600 "$CLAUDE_JSON_FILE"
                    echo "✅ Created minimal .claude.json with OAuth account information for: $EMAIL"
                else
                    echo "⚠️  Failed to create .claude.json - check credentials format"
                fi
            fi
            
        else
            echo "⚠️  Warning: .credentials.json may not contain valid OAuth tokens"
        fi
    else
        exit 1
    fi
    
else
    if [[ -f "$CLAUDE_JSON_FILE" ]]; then
        echo "ℹ️  Using existing .claude.json configuration"
        echo "    Claude Code authentication may already be configured"
    else
        echo "⚠️  No CLAUDE_AUTH environment variable found and no existing .credentials.json"
        echo "    To set up Claude authentication in Codespaces:"
        echo "    1. Get your local ~/.claude/.credentials.json content"
        echo "    2. Encode it with: base64 -w 0 ~/.claude/.credentials.json"
        echo "    3. Add the result as CLAUDE_AUTH secret in GitHub Codespaces"
        echo "    4. Restart the DevContainer"
        echo ""
        echo "    Claude Code will not be authenticated but the environment is ready."
    fi
fi

echo "🎉 Claude authentication setup completed!"

# ============================================================================
# GITHUB TOKEN VERIFICATION
# ============================================================================


echo "🔐 Checking GitHub token availability..."

if [[ -n "${CODESPACES}" && -n "${GH_TOKEN}" ]]; then
    echo "✅ Codespaces environment with GH_TOKEN found"
    echo "🔧 Using your personal GH_TOKEN from Codespaces secrets"
elif [[ -n "${GH_TOKEN}" ]]; then
    echo "✅ GitHub token found (GH_TOKEN)"
elif [[ -n "${GITHUB_TOKEN}" ]]; then
    echo "✅ GitHub token found (GITHUB_TOKEN)"
    export GH_TOKEN="${GITHUB_TOKEN}"
    echo "🔧 Set GH_TOKEN=${GITHUB_TOKEN:0:20}... for GitHub CLI"
else
    echo "❌ No GitHub token found (GH_TOKEN or GITHUB_TOKEN)"
    exit 1
fi


if [[ -n "${GH_TOKEN}" ]]; then
    echo "export GH_TOKEN='${GH_TOKEN}'" >> ~/.bashrc
    echo "🔧 Added GH_TOKEN to ~/.bashrc for session persistence"
fi

# ============================================================================
# MCP CONFIGURATION VALIDATION
# ============================================================================

if [[ ! -f "$MCP_CONFIG_FILE" ]]; then
    echo "❌ MCP configuration file not found at: $MCP_CONFIG_FILE"
    echo "    The file should be synchronized by GitHub Actions workflow"
    exit 1
fi

echo "📖 Using MCP config: $MCP_CONFIG_FILE"

# ============================================================================
# CLAUDE CONFIGURATION FILES SETUP
# ============================================================================

echo "📄 Copying Claude configuration files..."

CLAUDE_DIR="$HOME/.claude"
ensure_directory "$CLAUDE_DIR" ".claude"
ensure_directory "$CLAUDE_DIR/commands" ".claude/commands"

copy_claude_memory() {
    local source_file="$WORKSPACE_FOLDER/.devcontainer/configuration/CLAUDE.md.memory"
    local target_file="$CLAUDE_DIR/CLAUDE.md"
    
    if [[ -f "$source_file" ]]; then
        cp "$source_file" "$target_file"
        echo "  ✅ Copied CLAUDE.md.memory → ~/.claude/CLAUDE.md"
    else
        echo "  ⚠️  CLAUDE.md.memory not found at: $source_file"
    fi
}

copy_claude_settings() {
    local source_file="$WORKSPACE_FOLDER/.devcontainer/configuration/settings.devcontainer.json"
    local target_file="$CLAUDE_DIR/settings.json"
    
    if [[ -f "$source_file" ]]; then
        cp "$source_file" "$target_file"
        echo "  ✅ Copied settings.devcontainer.json → ~/.claude/settings.json"
    else
        echo "  ⚠️  settings.devcontainer.json not found at: $source_file"
    fi
}

copy_claude_commands() {
    local source_dir="$WORKSPACE_FOLDER/.devcontainer/commands"
    local target_dir="$CLAUDE_DIR/commands"
    
    if [[ -d "$source_dir" ]]; then
        local removed_count=0
        if [[ -d "$target_dir" ]]; then
            for existing_file in "$target_dir"/*.md; do
                if [[ -f "$existing_file" ]]; then
                    local filename=$(basename "$existing_file")
                    if [[ ! -f "$source_dir/$filename" ]]; then
                        rm -f "$existing_file"
                        removed_count=$((removed_count + 1))
                        echo "  🗑️  Removed deleted command: $filename"
                    fi
                fi
            done 2>/dev/null
        fi
        
        if [[ -n "$(ls -A "$source_dir"/*.md 2>/dev/null)" ]]; then
            cp "$source_dir"/*.md "$target_dir/" 2>/dev/null
            local copied_count=$(ls -1 "$source_dir"/*.md 2>/dev/null | wc -l)
            echo "  ✅ Copied $copied_count command files to ~/.claude/commands/"
        else
            echo "  ⚠️  No .md command files found in: $source_dir"
        fi
        
        if [[ $removed_count -gt 0 ]]; then
            echo "  🧹 Removed $removed_count obsolete command files"
        fi
    else
        echo "  ⚠️  Commands directory not found: $source_dir"
    fi
}

copy_claude_memory
copy_claude_settings
copy_claude_commands

echo "📄 Claude configuration files setup completed!"

# ============================================================================
# MCP SERVERS SETUP
# ============================================================================

add_mcp_server() {
    local server_name="$1"
    local server_config="$2"
    
    echo "➕ Adding MCP server: $server_name"
    
    if [[ "$server_config" == *"GH_TOKEN"* ]]; then
        local token="${GH_TOKEN:-$GITHUB_TOKEN}"
        if [[ -n "$token" ]]; then
            server_config="${server_config//GH_TOKEN/$token}"
            echo "  🔑 Replaced GH_TOKEN with environment variable"
        else
            echo "  ⚠️  Neither GH_TOKEN nor GITHUB_TOKEN found in environment, keeping placeholder"
        fi
    fi
    
    if output=$(claude mcp add-json "$server_name" "$server_config" 2>&1); then
        echo "  ✅ Successfully added $server_name"
    elif [[ "$output" == *"already exists"* ]]; then
        echo "  ℹ️  $server_name already configured"
    else
        echo "  ❌ Failed to add $server_name"
    fi
}

get_current_mcp_servers() {
    local output
    output=$(claude mcp list 2>/dev/null) || return 1
    echo "$output" | awk '
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*(Configured MCP servers|NAME|Name|Servers|Checking MCP server health)/ { next }
        /^[[:space:]]*\.\.\.$/ { next }
        {
          line=$0
          sub(/^[[:space:]]*[-*•]?[[:space:]]*/, "", line)
          name=line
          sub(/:.*$/, "", name)
          sub(/[[:space:]]+$/, "", name)
          if (name ~ /^[A-Za-z0-9._-]+$/) print name
        }
    ' | sort -u
}

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

echo "📖 Parsing MCP server configurations..."

if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed"
    exit 1
fi

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

jq -r '.mcpServers | to_entries | .[] | @base64' "$MCP_CONFIG_FILE" | while read -r server_data; do
    server_name=$(echo "$server_data" | base64 --decode | jq -r '.key')
    server_config=$(echo "$server_data" | base64 --decode | jq -c '.value')
    
    add_mcp_server "$server_name" "$server_config"
done

echo "🎉 MCP server setup completed!"

echo "📋 Currently configured MCP servers:"
claude mcp list || echo "  No servers configured or error listing servers"

echo "✅ Development environment setup completed successfully!"