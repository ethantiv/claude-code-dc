---
description: Analyze changes and create meaningful conventional commit messages
---

You are creating a well-structured git commit based on the current changes.

GIT STATUS:

```
!`git status --short`
```

UNSTAGED CHANGES:

```
!`git diff --stat`
```

STAGED CHANGES:

```
!`git diff --cached --stat`
```

RECENT COMMITS (for style reference):

```
!`git log --oneline -10`
```

DETAILED DIFF:

```
!`git diff --cached`
```

If no files are staged:
```
!`git diff`
```

OBJECTIVE:
Create a conventional commit message based on the changes. The commit message will be concise, meaningful, and follow your project's conventions if I can detect them from recent commits.

COMMIT CONVENTIONS:

**Types:** `feat` | `fix` | `docs` | `style` | `refactor` | `perf` | `test` | `build` | `ci` | `chore`

**Format:** `<type>(<scope>): <subject>` (max 50 chars, imperative mood)

**Body Format (for complex changes):**
- Use bullet points with `-` for multiple changes
- Each bullet should be a concise, descriptive line
- Claude Code signature is added automatically by default

**Analysis:**
1. Review recent commits to identify project conventions and patterns
2. Identify change type from modified files
3. Determine scope (component/area) 
4. Write clear subject line following detected conventions
5. Add body with bullet points for complex changes (explain WHAT was changed)

STAGING:

If no files staged: `git add -u` (stage all modified)
For selective: `git add <files>`

COMMIT: Use HEREDOC format for multi-line commits:
```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <subject>

- First change description
- Second change description
- Third change description
EOF
)"
```

EXAMPLES:
- `feat(commands): enhance slash commands with comprehensive implementation guides`
- `feat: add CLAUDE.md.memory for global configuration storage`
- `refactor: restructure CLAUDE.md and improve sync script backup handling`
- `feat(api)!: change to OAuth2` (breaking change)

BEGIN ANALYSIS: