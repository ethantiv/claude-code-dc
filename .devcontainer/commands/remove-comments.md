---
description: Remove redundant comments while preserving valuable documentation
---

You are cleaning up code by removing obvious and redundant comments while preserving valuable documentation and explanations.

BRANCH DETECTION AND FILE SELECTION:

```
!`git branch --show-current`
```

**IF NOT on default branch:**
- Focus ONLY on files modified in current branch vs default branch
- Detect default branch automatically using git's remote HEAD reference
- Get modified files using detected default branch
- Process ONLY these files for comment removal

**IF on default branch:**
- First check if there are staged changes: `git status --porcelain | grep '^[MADRCU]'`
- If staged changes exist: Process ONLY staged files
- If no staged changes: Process ALL source files in the repository
- Use Glob tool to find all source files: `**/*.{js,ts,jsx,tsx,py,java,go,rs,php,rb,c,cpp,h,tf,tfvars}`

FILES TO PROCESS:

```
!`git branch --show-current`
```

```
!`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`
```

```
!`git status --porcelain | grep '^[MADRCU]'`
```

OBJECTIVE:
Systematically identify and remove ALL redundant, obvious comments from EVERY file in scope. This is a comprehensive cleanup operation - remove ALL comments that are classified as obvious/redundant without exception.

CRITICAL REQUIREMENTS:
1. **Complete Coverage**: Process EVERY file identified above
2. **Thorough Removal**: Remove ALL redundant comments from EACH file, not just a sample
3. **Systematic Approach**: Use MultiEdit to batch remove all identified comments in each file
4. **No Partial Work**: Do not stop after cleaning just a few files or comments

COMMENT CLASSIFICATION:

**REMOVE - Obvious Comments:**
- Stating what the code obviously does
- Restating method/variable names
- Describing basic language constructs
- Redundant function/class descriptions
- Self-evident operations

Examples to remove:
```javascript
// Create a new variable
let count = 0;

// Loop through items
for (let item of items) {
    // Add to total
    total += item.value;
}

// Constructor
constructor(name) {
    // Set name property
    this.name = name;
}
```

**PRESERVE - Valuable Comments:**
- Explaining WHY, not WHAT
- Complex business logic rationale
- Non-obvious behavior warnings
- Performance considerations
- Security implications
- TODOs, FIXMEs, HACKs
- API documentation
- Complex algorithm explanations
- Workarounds and their reasons

Examples to preserve:
```javascript
// Using setTimeout to avoid blocking the main thread during heavy computation
setTimeout(() => processLargeDataset(), 0);

// HACK: Workaround for Safari bug where touch events don't fire correctly
// TODO: Remove when Safari 16+ adoption reaches 95%
if (isSafari && version < 16) {
    handleTouchEventsSafari();
}

// This calculation follows the compound interest formula: A = P(1 + r/n)^(nt)
// where P=principal, r=annual rate, n=compounds per year, t=time in years
const futureValue = principal * Math.pow(1 + rate/periods, periods * years);
```

ANALYSIS METHODOLOGY:

**Phase 1 - File Discovery:**
1. Check current branch with `git branch --show-current`
2. Detect default branch automatically using git's remote HEAD reference
3. If NOT on default branch: Get ONLY modified files vs default branch
4. If on default branch:
   - Check for staged changes with `git status --porcelain | grep '^[MADRCU]'`
   - If staged changes exist: Process ONLY staged files
   - If no staged changes: Find ALL source files with Glob patterns
5. Create complete list of files to process
6. Verify list is complete before proceeding

**Phase 2 - Systematic Processing:**
1. For EACH file in the list (no exceptions):
   - Read entire file content
   - Identify ALL obvious/redundant comments
   - Mark ALL for removal (not just some)
   - Preserve only valuable documentation
2. Use MultiEdit for batch removal in each file
3. Process files in batches for efficiency
4. Track progress to ensure 100% coverage

**Phase 3 - Quality Assurance:**
1. Verify ALL files were processed
2. Confirm ALL obvious comments removed
3. Check preserved comments add real value
4. Ensure no functional code was affected
5. Validate syntax remains correct

**Phase 4 - Completion Verification:**
1. Re-scan ALL processed files for missed comments
2. Ensure no file was skipped or partially processed
3. Generate comprehensive report of ALL changes
4. List every file modified with comment counts
5. Provide total statistics across entire scope
6. Confirm 100% completion of task

COMMENT REMOVAL PATTERNS:

**JavaScript/TypeScript:**
```javascript
// REMOVE: Obvious
// Set the user name
this.userName = name;

// PRESERVE: Valuable context
// User name must be validated against AD before storage
// as it's used for authentication downstream
this.userName = this.validateAgainstAD(name);
```

**Python:**
```python
# REMOVE: Obvious
# Loop through users
for user in users:
    # Print user name
    print(user.name)

# PRESERVE: Important context
# Performance note: This query can be expensive with large datasets
# Consider using pagination or indexing for production use
for user in User.objects.all():
    process_user(user)
```

**Java:**
```java
// REMOVE: Obvious
// Constructor for User class
public User(String name) {
    // Set name field
    this.name = name;
}

// PRESERVE: Business logic explanation
// User validation must comply with GDPR requirements
// and company policy section 4.2.1 for data retention
public User(String name) {
    this.name = sanitizePersonalData(name);
}
```

PROCESSING STRATEGY:

**1. File Selection Based on Branch:**

The command will automatically detect the current branch and default branch, then determine which files to process:
- **Feature branch**: Only files modified vs default branch
- **Default branch with staged changes**: Only staged files
- **Default branch with no staged changes**: All source files in repository

**2. Exhaustive Comment Detection:**
- Scan EVERY line of EVERY file in scope
- Identify ALL comment patterns for each language
- Create complete inventory of removable comments
- No sampling - process 100% of identified comments
- Use language-specific parsers where needed

**3. Batch Removal Execution:**
- Group all removals per file for efficiency
- Use MultiEdit to remove ALL comments at once
- Never stop after "enough" removals
- Continue until EVERY obvious comment is gone
- Track and report on EVERY removal made

IMPLEMENTATION PROCESS:

**1. Complete File Processing:**
- Process EVERY file identified in Phase 1
- Read ENTIRE file content for each file
- Find ALL obvious comments in each file  
- Remove ALL at once using MultiEdit
- Verify syntax remains valid
- Move to next file (no skipping)

**2. Mandatory Coverage Requirements:**
- MUST process 100% of files in scope
- MUST remove 100% of obvious comments found
- MUST NOT skip any file for any reason
- MUST NOT stop until all files are processed
- MUST report on every single file touched

**3. Final Verification:**
- Count total files in scope vs files processed
- Verify counts match exactly (no missing files)
- Re-scan for any missed obvious comments
- Generate detailed report of ALL changes
- Confirm complete task execution

QUALITY CHECKS:

**Before Removal:**
- Comment contains no unique information
- Code is self-explanatory without comment
- No business logic explanation needed
- No external references or dependencies mentioned
- No performance or security implications

**After Removal:**
- Code readability maintained or improved
- No functional changes introduced
- Syntax and formatting remain correct
- Important context still available
- Documentation completeness adequate

EDGE CASES TO HANDLE:

**License Headers:**
- Always preserve copyright notices
- Keep license text intact
- Maintain attribution comments
- Preserve legal requirements

**Disabled Code:**
- Comments that disable/enable code
- Conditional compilation comments
- Debug/development toggles
- Feature flags in comments

**Generated Code:**
- Auto-generated file headers
- Template-generated comments
- Build tool annotations
- Framework-required documentation

**Documentation Comments:**
- JSDoc, Sphinx, Javadoc comments
- API documentation strings
- Type annotations in comments
- Interface specifications

REPORTING FORMAT:

**Completion Checklist:**
```
✓ Branch detected: [main/feature branch name]
✓ Staged changes checked: [yes/no]
✓ Files in scope identified: [number]
✓ Files processed: [number] (MUST equal files in scope)
✓ Files with comments found: [number]
✓ Files modified: [number]
✓ Processing completion: 100%
```

**Summary Report:**
```
SCOPE: [All files / Staged files only / Modified files only]
Files Processed: [number] of [total in scope]
Comments Removed: [total number across ALL files]
Comments Preserved: [number]
Lines Cleaned: [number]

Categories Removed:
- Obvious assignments: [number]
- Redundant descriptions: [number]
- Self-evident operations: [number]
- Basic syntax explanations: [number]

Categories Preserved:
- Business logic: [number]
- Performance notes: [number]
- TODOs/FIXMEs: [number]
- Security considerations: [number]
```

**Complete File List:**
Every single file processed with removal counts:
1. path/to/file1.js - Removed: 15 comments
2. path/to/file2.py - Removed: 8 comments
3. path/to/file3.ts - Removed: 22 comments
[... continue for ALL files ...]

**Verification Statement:**
"ALL files in scope have been processed. No files were skipped. ALL obvious comments have been removed."

BEGIN EXHAUSTIVE COMMENT CLEANUP: