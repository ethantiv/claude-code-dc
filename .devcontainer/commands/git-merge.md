---
description: Safely merge branches with conflict resolution and strategy selection
---

You are performing a git merge operation with careful analysis and conflict resolution.

CURRENT STATUS:

```
!`git status`
```

CURRENT BRANCH:

```
!`git branch --show-current`
```

ALL BRANCHES:

```
!`git branch -a`
```

RECENT COMMITS ON CURRENT BRANCH:

```
!`git log --oneline -10`
```

DEFAULT BRANCH:

```
!`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`
```

FETCH LATEST:

```
!`git fetch --all`
```

OBJECTIVE:
Safely merge branches with appropriate strategy and conflict resolution.

PRE-MERGE CHECKS:
1. Verify git repository
2. Check for uncommitted changes (`git status`)
3. Stash if needed: `git stash`
4. Verify branches exist

ANALYSIS:
- Compare commits: `git log --oneline TARGET..SOURCE`
- Preview changes: `git diff --name-status TARGET..SOURCE`
- Test for conflicts: `git merge --no-commit --no-ff SOURCE`

STRATEGIES (AUTOMATIC SELECTION):
1. **Already merged:** Source branch already in target - skip
2. **Fast-forward:** Direct fast-forward when possible (clean linear history)
3. **Rebase + Fast-forward:** Rebase source onto target, then fast-forward (PREFERRED)
4. **Merge commit:** Only when rebase fails (conflicts/complexity)

EXECUTION - INTELLIGENT STRATEGY:

**Check if fast-forward is possible:**
```bash
git checkout TARGET
git pull origin TARGET
if git merge-base --is-ancestor SOURCE TARGET; then
    echo "SOURCE is already merged into TARGET"
    exit 0
elif git merge-base --is-ancestor TARGET SOURCE; then
    echo "Fast-forward merge possible"
    git merge --ff-only SOURCE
else
    echo "Histories diverged - attempting rebase + fast-forward"
    git checkout SOURCE
    git rebase TARGET
    if [ $? -eq 0 ]; then
        git checkout TARGET
        git merge --ff-only SOURCE
        echo "Successfully rebased and merged with clean history"
    else
        echo "Rebase failed - using merge commit strategy"
        git rebase --abort 2>/dev/null
        git checkout TARGET
        git merge --no-ff SOURCE
    fi
fi
git push origin TARGET
```

CONFLICTS:

1. **Identify:** `git status` / `git diff --name-only --diff-filter=U`
2. **Resolve:**
   - Accept ours: `git checkout --ours <file>`
   - Accept theirs: `git checkout --theirs <file>`
   - Manual edit: Remove conflict markers
3. **Complete:** `git add . && git commit`
4. **Abort:** `git merge --abort`

POST-MERGE:
- Verify: `git log --graph --oneline -10`
- Run tests
- Push: `git push origin TARGET`
- Clean branches: `git branch -d SOURCE`

ERRORS:
- Dirty working dir: `git stash` → merge → `git stash pop`
- Undo merge: `git reset --hard HEAD~1` (before push)
- Revert merge: `git revert -m 1 <merge-commit>` (after push)

BEGIN MERGE:
