---
description: Analyze project structure and generate architecture documentation
---

You are analyzing the project to document its architecture and implementation.

PROJECT DIRECTORY STRUCTURE:

```
!`find . -type f -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.lock" | head -20`
```

CONFIGURATION FILES:

```
!`ls -la package*.json requirements*.txt Cargo.toml composer.json pom.xml build.gradle setup.py Makefile 2>/dev/null | head -10`
```

MAIN SOURCE DIRECTORIES:

```
!`find . -type d -name "src" -o -name "lib" -o -name "app" -o -name "components" -o -name "modules" | head -10`
```

DOCUMENTATION FILES:

```
!`find . -name "README*" -o -name "CHANGELOG*" -o -name "LICENSE*" -o -name "CONTRIBUTING*" | head -10`
```

CODE STATISTICS:

```
!`find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" -o -name "*.go" -o -name "*.rs" -o -name "*.php" -o -name "*.rb" | wc -l`
```

OBJECTIVE:
Generate project documentation analyzing architecture, dependencies, and implementation.

ANALYSIS PHASES:

1. **Discovery:** Project type, technologies, structure
2. **Architecture:** Design patterns, components, data flow  
3. **Implementation:** Code organization, testing, security
4. **Documentation:** Generate comprehensive analysis with recommendations

ANALYSIS AREAS:

1. **Project:** Type, technologies, framework, purpose
2. **Architecture:** Patterns, layers, components, modularization
3. **Dependencies:** Packages, versions, security vulnerabilities
4. **Data:** Database, models, caching, validation
5. **API:** Design, authentication, documentation
6. **Testing:** Framework, coverage, CI/CD
7. **Security:** Auth, validation, headers, vulnerabilities
8. **Performance:** Optimization, caching, scalability

EXECUTION:

1. Discover project type and dependencies
2. Analyze architecture and code organization
3. Check security vulnerabilities with `npm audit` or equivalent
4. Use MCP tools and web research:
   - Context7: library documentation and versions
   - AWS Docs: AWS service documentation
   - AWS Terraform: Terraform best practices and security
   - WebSearch: latest technology trends and alternatives
5. Generate analysis document in `.claude/` directory

COMPREHENSIVE ANALYSIS TEMPLATE:

# Project Analysis: [Project Name]

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Directory Structure](#2-directory-structure)
3. [System Architecture](#3-system-architecture)
4. [Dependencies and Libraries](#4-dependencies-and-libraries)
5. [Data Flow & Performance](#5-data-flow--performance)
6. [API and Interfaces](#6-api-and-interfaces)
7. [Testing and Quality](#7-testing-and-quality)
8. [Security Analysis](#8-security-analysis)
9. [Conclusions and Recommendations](#9-conclusions-and-recommendations)

## 1. Project Overview
- **Project type**: [web application, CLI tool, library, etc.]
- **Primary technologies**: [JavaScript/TypeScript, Python, etc.]
- **Framework**: [React, Django, Express, etc.]
- **Project purpose**: [functionality description]
- **Development status**: [active, maintained, experimental]

## 2. Directory Structure
```
[Directory tree with description of each function]
```

## 3. System Architecture
- **Architectural pattern**: [MVC, MVVM, Component-based]
- **Layer separation**: [presentation, business, data]
- **Design patterns**: [Factory, Observer, Strategy, etc.]
- **Code organization**: [modularization, namespace]

## 4. Dependencies and Libraries

### Main Dependencies (Current → Latest Available):
- **Framework**: Next.js 15.1.6 → 15.4.6 (3 versions behind)
- **Runtime**: React 19.0.0 → 19.0.0 (current)
- **Database**: Drizzle ORM 0.38.4 → 0.43.0 (5 versions behind)
- **API**: tRPC 11.0.0-next.123 → 11.2.1 (stable available)

### Development Dependencies:
- **TypeScript**: 5.7.3 (current)
- **Build tools**: Vite/Webpack version and status
- **Linting**: ESLint/Biome configuration and rules

### Security Vulnerabilities:
- **Critical**: [specific CVEs with package names]
- **High**: [high-severity issues requiring attention]
- **Audit summary**: [total vulnerabilities by severity]

## 5. Data Flow & Performance
- **Data sources**: [databases, APIs, files]
- **Data transformation**: [how data is processed]
- **State management**: [Redux, Context, local]
- **Component communication**: [communication patterns]
- **Performance optimizations**: [caching, lazy loading, code splitting]
- **Monitoring**: [metrics, logs, APM tools]
- **Scaling strategies**: [horizontal/vertical scaling approaches]
- **Bottlenecks**: [identified performance bottlenecks]

## 6. API and Interfaces
- **API endpoints**: [list of main endpoints with examples]
- **Authentication**: [auth mechanisms - JWT, OAuth, sessions]
- **Input validation**: [validation libraries and patterns used]
- **Documentation**: [API documentation quality and tools]

## 7. Testing and Quality
- **Testing framework**: [Jest, Vitest, PyTest, etc. with coverage %]
- **Quality tools**: [ESLint, Prettier, Biome, Black - specific rules enabled]
- **CI/CD**: [pipeline configuration and deployment process]
- **Code review**: [automated checks and manual review process]

## 8. Security Analysis
- **Authentication & Authorization**: [implementation details and role systems]
- **Input validation**: [sanitization and validation patterns]
- **Security headers**: [CORS, CSP, HSTS implementation status]
- **Vulnerability assessment**: [specific security issues found with severity levels]
- **Dependency security**: [audit results and vulnerable packages]

## 9. Conclusions and Recommendations

#### **Project Strengths**
- [well-implemented aspects and architectural decisions]

#### **Technology Update Plan**
**Critical Security Fixes**: [immediate security patches with version numbers]
**High Priority Updates**: [important framework/library upgrades]
**Medium Priority**: [development tooling and minor updates]

#### **Critical Updates & Actions**
- [remaining critical security vulnerabilities and system-breaking issues after technology updates]

#### **Recommended Improvements**
- [important enhancements for stability, security, performance, and user experience not addressed by updates]

#### **Technical Risk Assessment**
[brief assessment of technical debt and architectural concerns in paragraph form]

DOCUMENTATION STANDARDS:

- **Language:** Write in English
- **Evidence:** Base on actual code examination
- **Priority:** Use Critical/High/Medium/Low levels
- **No duplication:** Each finding in ONE section only
- **Actionable:** Specific recommendations, not general advice
- **File:** Save as `.claude/analysis-{project}-{timestamp}.md`

VERSION CHECKING COMMANDS:

- **JavaScript/Node.js:** `npm view [package] version`, `npm audit`
- **Python:** `pip list --outdated`, `pip-audit`
- **Rust:** `cargo search [package] --limit 1`
- **PHP:** `composer show [package] --latest`
- **Ruby:** `gem list [package] --remote --exact`
- **Java:** `mvn versions:display-dependency-updates`
- **Go:** `go list -m -u all`

Use MCP tools and web research:
- **Context7:** Breaking changes and migration paths
- **AWS Docs:** AWS services and best practices documentation
- **AWS Terraform:** Infrastructure security and optimization
- **WebSearch:** Current technology trends and alternatives


FINAL STEPS:

1. Create `.claude` directory if needed
2. Generate comprehensive analysis using template above
3. Check versions with language-specific commands
4. Research with MCP tools and web search:
   - Context7 for library versions and upgrade paths
   - AWS Docs for AWS services documentation
   - AWS Terraform for infrastructure best practices
   - WebSearch for current technology trends
5. Save as `.claude/analysis-{project}-{timestamp}.md`

REQUIREMENTS:
- Write in English
- Use priority levels (Critical/High/Medium/Low)
- Include current → target version numbers
- No duplication between sections
- Base on actual code examination

BEGIN ANALYSIS: