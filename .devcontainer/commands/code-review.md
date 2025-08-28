---
description: Perform comprehensive code review with security focus on pending changes
---

You are conducting a comprehensive code review of the changes on this branch.

GIT STATUS:

```
!`git status`
```

FILES MODIFIED:

```
!`git diff --name-only origin/HEAD...`
```

COMMITS:

```
!`git log --no-decorate origin/HEAD...`
```

DIFF CONTENT:

```
!`git diff --merge-base origin/HEAD`
```

Review the complete diff above. This contains all code changes in the PR.

OBJECTIVE:
Perform a comprehensive code review focusing on code quality, security, performance, and best practices. Identify issues that could impact application stability, security, or maintainability.

REVIEW CATEGORIES:

**Code Quality & Best Practices:**
- DRY violations, SOLID principles, error handling, naming consistency
- Dead code, unused imports, complex functions needing refactoring

**Security Analysis:**
- Input validation, SQL/NoSQL injection, XSS, authentication issues
- Sensitive data exposure, insecure dependencies, path traversal, command injection

**Performance Considerations:**
- Inefficient algorithms, memory leaks, N+1 queries
- Missing caching, sync operations that should be async

**Testing & Coverage:**
- Missing unit tests, untested edge cases, test quality
- Integration coverage, mock usage appropriateness

**Architecture & Design:**
- Single responsibility violations, tight coupling
- Missing abstractions, API consistency, schema issues

ANALYSIS METHODOLOGY:

**Phase 1 - Context Understanding:**
Identify purpose, existing patterns, dependencies

**Phase 2 - Line-by-Line Analysis:**
Examine files, trace data flow, find edge cases

**Phase 3 - Integration Review:**
Verify compatibility, check breaking changes, validate contracts

**Phase 4 - External Research:**
Use MCP tools and web search to research security patterns and best practices when complex issues are found

REQUIRED OUTPUT FORMAT:

Structure your findings in markdown with clear categories. For each issue provide:
- **Location**: File path and line number
- **Severity**: Critical/High/Medium/Low
- **Category**: Type of issue
- **Description**: Clear explanation of the problem
- **Impact**: What could go wrong
- **Recommendation**: How to fix it

Example format:

## Critical Issues

### 1. SQL Injection Vulnerability
- **Location**: `api/users.py:45`
- **Severity**: Critical
- **Category**: Security
- **Description**: User input directly concatenated into SQL query without parameterization
- **Impact**: Attackers could execute arbitrary SQL commands, leading to data breach
- **Recommendation**: Use parameterized queries or ORM methods instead of string concatenation

## High Priority Issues
### N+1 Query Problem
- **Location**: `services/report.py:123-145`
- **Impact**: 100 records = 101 queries
- **Fix**: Use JOIN or prefetch

## Medium Priority Issues
### Missing Error Handling (`utils/parser.py:67`)

## Low Priority Issues
### Inconsistent Naming (`models/product.py:23`)

PRIORITIZATION:
- **Critical**: Security vulnerabilities, data loss, auth bypasses - fix immediately
- **High**: Performance bottlenecks, missing error handling, breaking changes
- **Medium**: Code quality, missing tests, minor security concerns
- **Low**: Style issues, minor optimizations, documentation

Focus on security first, then user-impacting performance, then stability.

EXCLUSIONS:
- Don't report formatting issues (use linters for that)
- Skip theoretical issues without practical impact
- Avoid nitpicking on subjective style preferences
- Don't report issues in generated or vendor code

EXECUTION STEPS:

1. **Create directory**: Ensure `.claude/` exists for saving review
2. **Perform review**: Analyze code following the methodology above
3. **Research with MCP tools and web search** when needed:
   - Context7: library security best practices and vulnerability patterns
   - AWS Docs: AWS service security configurations and best practices
   - AWS Terraform: infrastructure security scanning and recommendations
   - WebSearch: recent security vulnerabilities and industry practices
4. **Save to file**: Generate `review-{branch}-{timestamp}.md` using current system time
5. **Summarize**: Provide statistics and highlight critical issues by severity

REQUIREMENTS:
- **Save to file**: `.claude/review-{branch}-{timestamp}.md` (required)
- **Timestamp**: Use actual system time, not placeholders
- **Language**: English only in output file
- **Priority**: Use severity levels (Critical/High/Medium/Low), no deadlines or dates
- **Content**: Include all findings, statistics, and actionable recommendations

BEGIN REVIEW: