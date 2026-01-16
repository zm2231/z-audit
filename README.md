# Z-Audit

> Security auditing for the vibe-coding era

**Z-Audit** is a comprehensive security audit skill for Claude Code that auto-detects your tech stack and runs targeted vulnerability checks. Built for developers who ship fast and need to find security holes before someone else does.

---

## Why Z-Audit?

2026 is the year of vibe-coding. Cursor, Claude, Copilot - everyone's shipping faster than ever. But speed often means security gets overlooked.

Z-Audit was born from a real security audit where we found:
- Hardcoded passwords in frontend JavaScript
- API endpoints with zero authentication
- API keys exposed in bundles
- Full CRUD access to production databases
- Calendar data with Zoom passwords exposed

**If you've vibe-coded your way to production, you probably need this.**

---

## Quick Start

### Installation

**Option 1: Plugin Marketplace (Recommended)**
```bash
# In Claude Code
/plugin marketplace add zm2231/z-audit
/plugin install z-audit@z-audit-marketplace
```

**Option 2: Manual Install**
```bash
git clone https://github.com/zm2231/z-audit.git
cd z-audit
./install.sh
```

### Usage

```bash
# Audit a live site
/z-audit https://myapp.vercel.app https://api.myapp.workers.dev

# Audit local codebase
/z-audit ./my-project

# Audit current directory
/z-audit local
```

---

## What It Checks

### Phase 0: Stack Detection
Automatically detects your tech stack before running checks:
- Frontend framework (React, Vue, Svelte, Next.js, Nuxt, etc.)
- Hosting platform (Vercel, Netlify, Cloudflare Pages)
- Backend type (Cloudflare Workers, Vercel Functions, Express, Hono)
- Database (Supabase, Firebase, Postgres, MongoDB)
- Auth solution (or lack thereof)

### Phase 1: Secrets & Credentials
Scans for hardcoded secrets in frontend bundles:
- API keys (OpenAI, Stripe, AWS, GitHub, Google, Slack)
- Hardcoded passwords
- JWTs and auth tokens
- Supabase/Firebase credentials
- Generic high-entropy strings

### Phase 2: Authentication & Authorization
- Client-side auth bypasses (localStorage manipulation)
- API endpoints without authentication
- Auth bypass techniques (null tokens, malformed headers)
- IDOR (Insecure Direct Object Reference)
- Role escalation

### Phase 3: API Security
- CRUD access without authentication
- Input validation (SQL injection, NoSQL injection, XSS)
- Rate limiting
- Error message information leakage

### Phase 4: Infrastructure-Specific
| Platform | Checks |
|----------|--------|
| **Cloudflare Workers** | Secrets list, KV namespaces, D1 databases, worker source code |
| **Vercel** | Exposed .env files, source maps, API routes |
| **Supabase** | RLS policies, anon key permissions, storage buckets |
| **Firebase** | Firestore rules, storage rules, direct database access |

### Phase 5: Security Headers & CORS
- Missing security headers (CSP, HSTS, X-Frame-Options)
- CORS misconfiguration

### Phase 6: Dependencies
- Known vulnerabilities (npm audit, pip-audit)
- Outdated packages

### Phase 7: Data Exposure
- PII in API responses
- Verbose error messages with stack traces

---

## Report Format

Z-Audit generates a structured report with severity levels:

```markdown
# Z-Audit Security Report

**Target:** https://myapp.vercel.app
**Date:** 2026-01-16
**Stack:** Next.js + Supabase + Cloudflare Workers

## Executive Summary
Critical vulnerabilities found. API has no authentication, 
exposing all user data. Immediate action required.

## Critical Findings
### C1: Hardcoded Password in Frontend
- **Location:** /assets/index-abc123.js
- **Issue:** Password in plain text
- **Impact:** Anyone can authenticate
- **Fix:** Move validation server-side

## High Findings
...

## Medium Findings
...

## What's Secure
- HTTPS enforced
- No SQL injection vulnerabilities found

## Action Plan
1. **Immediate:** Add API authentication
2. **This week:** Remove hardcoded secrets
3. **This month:** Implement rate limiting
```

---

## Severity Levels

| Level | Meaning | Examples |
|-------|---------|----------|
| **Critical** | Immediate exploitation possible | Hardcoded passwords, no API auth, exposed secrets |
| **High** | Significant risk | Exposed API keys, IDOR, missing auth on some routes |
| **Medium** | Should fix soon | Verbose errors, weak rate limiting, missing headers |
| **Low** | Best practice | Outdated deps (no exploits), missing CSP |

---

## Project Structure

```
z-audit/
├── .claude-plugin/
│   ├── plugin.json            # Plugin manifest
│   └── marketplace.json       # Marketplace catalog
├── commands/
│   └── z-audit.md             # Slash command
├── agents/
│   └── z-audit.md             # Subagent definition
├── skills/
│   └── z-audit/
│       └── skill.md           # Full audit methodology
├── examples/
│   └── sample-report.md       # Example report
├── install.sh                 # Manual installer
└── README.md
```

---

## Three Ways to Use Z-Audit

| Method | Best For |
|--------|----------|
| **Plugin Install** | Easiest, auto-updates |
| **Slash Command** | Quick audits, interactive |
| **Subagent** | Auto-delegation, background |

### Option 1: Plugin (Recommended)

```bash
/plugin marketplace add zm2231/z-audit
/plugin install z-audit@z-audit-marketplace
```

### Option 2: Slash Command

```bash
/z-audit https://myapp.vercel.app https://api.myapp.workers.dev
```

When invoked, you'll be asked:
- **Direct**: Run analysis in current conversation
- **Subagent**: Spawn dedicated agent (runs in background)

### Option 3: Auto-Delegation

Once installed, Claude can automatically delegate security audits to the z-audit subagent:
```
"Check if my app at https://myapp.vercel.app has security issues"
```

---

## Customization

### Adding New Secret Patterns

Edit `skills/z-audit/skill.md` and add patterns to Phase 1:

```bash
# Add your custom pattern
grep -oE 'mycompany_[a-zA-Z0-9]+' /tmp/bundle.js
```

### Adding New Stack Detection

Add to Phase 0 in `skills/z-audit/skill.md`:

```bash
# Detect your framework
cat package.json | grep -E '"my-framework"'
```

### Adding Infrastructure Checks

Add a new section in Phase 4 of `skills/z-audit/skill.md`.

---

## Responsible Use

Z-Audit is for **auditing your own projects** or projects you have permission to test.

- Audit your own apps
- Audit with explicit permission
- Bug bounty programs (follow their rules)
- **Never** test without authorization
- **Never** exploit vulnerabilities you find
- **Never** access data you shouldn't

**Always get permission before auditing.**

---

## Contributing

Found a common vulnerability pattern we're missing? PRs welcome!

1. Fork the repo
2. Add your checks to `skills/z-audit/skill.md`
3. Test on a sample project
4. Submit PR with description

---

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [Supabase Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Cloudflare Workers Security](https://developers.cloudflare.com/workers/platform/security/)

---

## License

MIT - Use freely, audit responsibly.
