# DevContainer Configuration Sync

Automatic DevContainer configuration synchronization system between repositories.

## 🔧 How it works

The system automatically synchronizes the `.devcontainer/` directory from this repository to selected projects:

1. **Trigger**: Changes in `.devcontainer/` or configuration files trigger the workflow
2. **Sync**: Files are copied to target repositories  
3. **PR**: Pull Requests are created with auto-merge enabled

```
┌─────────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Source Repo       │───▶│  GitHub Action  │───▶│  Target Repos   │
│ .devcontainer/      │    │  sync-workflow  │    │   Update PR     │
│  ├─ configuration/  │    │                 │    │                 │
│  └─ commands/       │    │                 │    │                 │
└─────────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Setup

### 1. Create Personal Access Token

1. Go to [GitHub Settings > Personal access tokens](https://github.com/settings/tokens/new)
2. Create a **Classic token** with `repo` and `workflow` permissions
3. Add as secret: `gh secret set GH_TOKEN --body "your_token"`

### 2. Configure repositories

Edit `.github/workflows/sync-repos.json`:

```json
{
  "repositories": [
    {
      "name": "my-project",
      "owner": "my-organization", 
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

### 3. Enable auto-merge (optional)

In target repositories: **Settings → Branches → Add rule**
- Branch name pattern: `main`
- ✅ Require pull request reviews: `0`
- ✅ Allow auto-merge

## 📖 Usage

### Automatic
Workflow runs automatically on push to `main` with `.devcontainer/` changes.

### Manual
```bash
# All repositories
gh workflow run sync-devcontainer.yml

# Specific repository  
gh workflow run sync-devcontainer.yml -f target_repo="repo-name"
```

## 📂 File structure

```
.
├── .github/workflows/
│   ├── sync-devcontainer.yml      # Main workflow
│   └── sync-repos.json            # Repository list
├── .devcontainer/                 # DevContainer configuration
│   ├── devcontainer.json
│   ├── configuration/            # Claude Code config
│   └── commands/                 # Custom slash commands
├── CLAUDE.md                     # Project instructions  
└── README.md                     # This documentation
```

## 🔧 Management

```bash
# Add repository
jq '.repositories += [{"name":"new-repo","owner":"owner","create_pr":true,"auto_merge":true}]' \
  .github/workflows/sync-repos.json > tmp && mv tmp .github/workflows/sync-repos.json

# View configuration
cat .github/workflows/sync-repos.json | jq '.'

# Monitor runs
gh run list --workflow=sync-devcontainer.yml
```

## ✅ Setup checklist

- [ ] Created PAT with `repo` and `workflow` permissions
- [ ] Added token as `GH_TOKEN` secret  
- [ ] Configured `.github/workflows/sync-repos.json`
- [ ] Tested workflow execution
- [ ] Enabled auto-merge in target repositories (optional)

---

Every change in `.devcontainer/` will be automatically propagated to all configured repositories.