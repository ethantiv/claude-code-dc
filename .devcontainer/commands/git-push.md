---
description: Push commits to remote repository with safety checks
---

You are pushing local commits to remote repository with safety checks.

CURRENT STATUS:

```
!`git status`
```

CURRENT BRANCH:

```
!`git branch --show-current`
```

REMOTES:

```
!`git remote -v`
```

UNPUSHED COMMITS:

```
!`git log --oneline @{u}..HEAD 2>/dev/null || echo "No upstream set or no unpushed commits"`
```

FETCH LATEST:

```
!`git fetch --all`
```

OBJECTIVE:
Push commits to remote repository with safety checks.

PRE-PUSH CHECKS:
1. Verify git repository
2. Check for uncommitted changes: `git status`
3. Check ahead/behind: `git status -sb`

EXECUTION:

**Standard push:**
```bash
git push origin BRANCH
```

**New branch (set upstream):**
```bash
git push -u origin BRANCH
```

**Push to all remotes:**
```bash
for remote in $(git remote); do
    git push $remote BRANCH
done
```

CONFLICTS:
- **Non-fast-forward:** Pull first with `git pull origin BRANCH`
- **Diverged history:** Use `git pull --rebase` or `git push --force-with-lease`

POST-PUSH:
- Verify: `git status -sb`
- Check remote: `git ls-remote origin BRANCH`

BEGIN PUSH:
