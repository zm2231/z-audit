---
description: "Run Z-Audit: comprehensive security audit for vibe-coded projects. Auto-detects stack and runs targeted checks."
argument-hint: "[frontend-url] [api-url]" OR "local" OR "[path-to-codebase]"
---

# Z-Audit Security Audit

You are performing a comprehensive security audit using the Z-Audit skill at `~/.claude/skills/z-audit/skill.md`.

## Input
User provided: $ARGUMENTS

---

## Step 0: Ask User About Execution Mode

Before starting, ask the user:

```
How would you like to run the security audit?

1. **Direct** - I'll run the analysis here in this conversation (interactive, can ask follow-ups)
2. **Subagent** - Spawn a dedicated z-audit subagent (runs in background, returns full report)

Which do you prefer? (1 or 2)
```

- If user chooses **1 (Direct)**: Continue with the execution flow below
- If user chooses **2 (Subagent)**: Delegate to the z-audit subagent with the provided arguments and wait for results

---

## Execution Flow (Direct Mode)

### Step 1: Stack Detection (ALWAYS FIRST)
Detect the tech stack before running checks:
- If URLs: fetch frontend, identify framework, find API patterns
- If local: check config files (package.json, wrangler.toml, vercel.json, etc.)

Announce what you detected:
```
## 🔍 Stack Detected
- Frontend: [framework] hosted on [platform]
- Backend: [type] on [platform]  
- Database: [type]
- Auth: [library/method or "⚠️ NONE DETECTED"]
```

### Step 2: Run Phase-Appropriate Checks

**For Remote URLs:**
1. Fetch and scan JS bundles for hardcoded secrets
2. Test API endpoints without authentication
3. Check for CRUD access without auth
4. Test auth bypass techniques
5. Check security headers and CORS
6. Check for exposed .env, source maps

**For Local Codebase:**
1. Scan for secrets in source files
2. Check .env files and git history
3. Review auth middleware implementation
4. Analyze API route protection
5. Run dependency audit (npm audit / pip-audit)
6. Check database security (RLS policies, etc.)

### Step 3: Infrastructure-Specific Checks
Based on detected stack, run relevant checks from the skill guide:
- **Cloudflare Workers**: wrangler secrets, KV, D1
- **Vercel**: env vars, edge functions, source maps
- **Supabase**: RLS policies, anon key permissions
- **Firebase**: Firestore rules, storage rules
- **Next.js**: API routes, middleware, server actions

### Step 4: Generate Report

```markdown
# 🔐 Z-Audit Security Report

**Target:** [URLs or path]
**Date:** [today's date]  
**Stack:** [detected stack]

---

## Executive Summary
[2-3 sentences on overall security posture]

---

## 🔴 Critical Findings
### C1: [Title]
- **Location:** [where]
- **Issue:** [what's wrong]
- **Impact:** [what attacker could do]
- **Evidence:** [proof]
- **Fix:** [how to remediate]

## 🟠 High Findings
[Same format]

## 🟡 Medium Findings  
[Same format]

## 🟢 Low / Recommendations
[Same format]

---

## ✅ What's Secure
- [Positive findings]

---

## 📋 Prioritized Action Plan
1. **Immediate (today):** [critical fixes]
2. **This week:** [high fixes]
3. **This month:** [medium fixes]
```

---

## Important Guidelines

1. **Be thorough but non-destructive** - Test, don't exploit
2. **Document evidence** - Include curl commands, responses, code snippets
3. **If you find real secrets** - Flag for IMMEDIATE rotation
4. **Respect rate limits** - Don't hammer APIs
5. **Clean up** - Delete any test data you created
6. **Stack-specific** - Only run checks relevant to detected stack

---

## Example Usage

```bash
# Audit a live site with API
/z-audit https://myapp.vercel.app https://api.myapp.workers.dev

# Audit local project
/z-audit ./my-project

# Audit current directory
/z-audit local
```
