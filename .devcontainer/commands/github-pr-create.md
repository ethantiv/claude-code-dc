---
description: Create GitHub pull request from current branch changes
---

You are creating a GitHub pull request from the current branch.

CURRENT STATUS:

```
!`git status`
```

CURRENT BRANCH:

```
!`git branch --show-current`
```

REMOTE:

```
!`git remote get-url origin`
```

DEFAULT BRANCH:

```
!`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`
```

COMMITS:

```
!`git log --oneline origin/HEAD..HEAD`
```

CHANGES:

```
!`git diff --stat origin/HEAD..HEAD`
```

DETAILED DIFF:

```
!`git diff origin/HEAD..HEAD`
```

OBJECTIVE:
Create GitHub pull request from current branch.

PRE-PR CHECKS:
1. Verify feature branch (not main/master)
2. Push branch if needed: `git push -u origin BRANCH`
3. Extract owner/repo from remote URL

PR FORMAT:

**Title:** `<type>(<scope>): <description>` (conventional commit format)

**Body Template:**
```markdown
## Summary
Brief description of changes

## Changes Made
- List of main changes

## Testing
- How it was tested

## Related Issues
Closes #issue_number
```

EXECUTION:
1. Push branch: `git push -u origin BRANCH`
2. Extract owner/repo from remote URL
3. Generate title from commits and changes
4. Create PR using `mcp__github__create_pull_request`
5. Return PR URL

IMPORTANT: Pass PR body as plain string to `mcp__github__create_pull_request`:
```
body: "## Summary\nDescription here\n\n## Changes Made\n- Change 1\n- Change 2"
```

Never use heredoc or command substitution in body parameter.

BEGIN PR CREATION: