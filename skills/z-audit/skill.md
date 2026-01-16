# Z-Audit: Security Audit for Vibe-Coded Projects

> "2026 is the year of vibe-coding. Ship fast, audit faster."

## Overview
A comprehensive, adaptive security audit that detects your stack and runs targeted checks. Designed for developers who moved fast and need to find vulnerabilities before someone else does.

---

## Phase 0: Stack Detection (ALWAYS RUN FIRST)

Before auditing, detect what you're working with. This determines which checks to run.

### 0.1 If Given URLs (Remote Audit)

```bash
# Fetch frontend and identify framework
curl -s "[FRONTEND_URL]" | grep -oE '(react|vue|svelte|next|nuxt|astro|vite)'

# Find JS bundles
curl -s "[FRONTEND_URL]" | grep -oE '[^"]+\.(js|mjs)"' | head -10

# Identify API type from URL patterns
# .workers.dev = Cloudflare Workers
# .vercel.app = Vercel Serverless
# .netlify.app = Netlify Functions
# .supabase.co = Supabase direct
# .firebaseapp.com = Firebase
```

### 0.2 If Given Local Codebase

```bash
# Detect from config files
ls -la | grep -E "package.json|requirements.txt|go.mod|Cargo.toml|wrangler.toml|vercel.json|netlify.toml|supabase|firebase"

# Check package.json for framework
cat package.json | grep -E '"(react|vue|svelte|next|nuxt|hono|express|fastify|elysia)"'

# Check for auth libraries
cat package.json | grep -E '"(@supabase|firebase|@clerk|@auth0|better-auth|lucia|next-auth)"'
```

### 0.3 Stack Detection Matrix

| Signal | Stack | Special Checks |
|--------|-------|----------------|
| `wrangler.toml` | Cloudflare Workers | Check secrets, KV, D1 |
| `vercel.json` | Vercel | Check env vars, edge functions |
| `supabase/` dir | Supabase | Check RLS, anon key permissions |
| `firebase.json` | Firebase | Check Firestore rules, Auth |
| `next.config.js` | Next.js | Check API routes, middleware |
| `nuxt.config.ts` | Nuxt | Check server routes, nitro |
| `hono` in deps | Hono API | Check middleware chain |
| `express` in deps | Express | Check middleware order |

---

## Phase 1: Secrets & Credentials Audit

### 1.1 Frontend Bundle Scan (CRITICAL)

**For Remote Sites:**
```bash
# Get main bundle URL
BUNDLE=$(curl -s "[FRONTEND_URL]" | grep -oE 'src="[^"]+\.js"' | head -1 | cut -d'"' -f2)
curl -s "[FRONTEND_URL]$BUNDLE" > /tmp/bundle.js

# Scan for secrets
```

**Universal Secret Patterns:**
```bash
# API Keys by provider
grep -oE 'sk-[a-zA-Z0-9]{20,}' /tmp/bundle.js              # OpenAI
grep -oE 'sk_live_[a-zA-Z0-9]+' /tmp/bundle.js             # Stripe Live
grep -oE 'sk_test_[a-zA-Z0-9]+' /tmp/bundle.js             # Stripe Test
grep -oE 'pk_live_[a-zA-Z0-9]+' /tmp/bundle.js             # Stripe Publishable
grep -oE 'AKIA[A-Z0-9]{16}' /tmp/bundle.js                 # AWS Access Key
grep -oE 'ghp_[a-zA-Z0-9]{36}' /tmp/bundle.js              # GitHub PAT
grep -oE 'gho_[a-zA-Z0-9]{36}' /tmp/bundle.js              # GitHub OAuth
grep -oE 'glpat-[a-zA-Z0-9\-]{20}' /tmp/bundle.js          # GitLab PAT
grep -oE 'xox[baprs]-[a-zA-Z0-9\-]+' /tmp/bundle.js        # Slack Token
grep -oE 'ya29\.[a-zA-Z0-9_-]+' /tmp/bundle.js             # Google OAuth
grep -oE 'AIza[a-zA-Z0-9_-]{35}' /tmp/bundle.js            # Google API Key
grep -oE 'eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*' /tmp/bundle.js  # JWTs

# Supabase specific
grep -oE 'eyJ[a-zA-Z0-9_=-]+\.[a-zA-Z0-9_=-]+\.[a-zA-Z0-9_=-]+' /tmp/bundle.js  # Supabase anon/service key
grep -oE 'https://[a-z]+\.supabase\.co' /tmp/bundle.js     # Supabase URL

# Firebase specific
grep -oE 'AIza[a-zA-Z0-9_-]{35}' /tmp/bundle.js            # Firebase API Key
grep -oE '[a-z]+-[a-z0-9]+\.firebaseapp\.com' /tmp/bundle.js

# Generic high-entropy strings (potential secrets)
grep -oE '"[a-zA-Z0-9_-]{32,64}"' /tmp/bundle.js | head -20

# Hardcoded passwords
grep -oiE '(password|passwd|pwd|secret)["\x27\s]*[=:]["\x27\s]*["\x27][^"\x27]{4,}["\x27]' /tmp/bundle.js
```

### 1.2 Local Codebase Secrets Scan

```bash
# Check for .env files committed
find . -name ".env*" -not -path "./node_modules/*" 2>/dev/null

# Check git history for secrets
git log -p --all -S 'password' --since="1 year ago" -- '*.js' '*.ts' '*.json' 2>/dev/null | head -50
git log -p --all -S 'secret' --since="1 year ago" -- '*.js' '*.ts' '*.json' 2>/dev/null | head -50
git log -p --all -S 'sk-' --since="1 year ago" 2>/dev/null | head -50

# Scan source files
grep -rn --include="*.ts" --include="*.js" --include="*.tsx" \
  -E '(api_key|apikey|api-key|secret|password|token)\s*[=:]\s*["\x27][^"\x27]+["\x27]' . 2>/dev/null

# Check for hardcoded in config
grep -rn --include="*.json" --include="*.yaml" --include="*.yml" \
  -E '(key|secret|password|token)' . 2>/dev/null | grep -v node_modules
```

---

## Phase 2: Authentication & Authorization

### 2.1 Client-Side Auth Detection

```bash
# localStorage/sessionStorage auth (weak)
grep -oE 'localStorage\.(get|set)Item\(["\x27][^"\x27]*(auth|session|token|user|login)[^"\x27]*' /tmp/bundle.js
grep -oE 'sessionStorage\.(get|set)Item\(["\x27][^"\x27]*(auth|session|token|user|login)[^"\x27]*' /tmp/bundle.js

# Check for client-side password validation (CRITICAL vulnerability)
grep -oE 'if\s*\([^)]*===\s*["\x27][^"\x27]+["\x27]\s*\)' /tmp/bundle.js | head -10

# Find auth context/provider
grep -oE '(AuthContext|AuthProvider|useAuth|isAuthenticated|isLoggedIn)' /tmp/bundle.js
```

### 2.2 API Authentication Testing

```bash
API_URL="[YOUR_API_URL]"

# Test endpoints without auth
ENDPOINTS=("users" "projects" "tasks" "items" "data" "config" "settings" "admin" "me" "profile")
for ep in "${ENDPOINTS[@]}"; do
  echo "=== /api/$ep ==="
  curl -s -w "\nHTTP: %{http_code}\n" "$API_URL/api/$ep" | tail -5
done

# Test with malformed auth
curl -s "$API_URL/api/users" -H "Authorization: Bearer null"
curl -s "$API_URL/api/users" -H "Authorization: Bearer undefined"
curl -s "$API_URL/api/users" -H "Authorization: Bearer [object Object]"
curl -s "$API_URL/api/users" -H "X-API-Key: null"
curl -s "$API_URL/api/users" -H "Cookie: session=admin"

# Test path traversal
curl -s "$API_URL/api/../../../etc/passwd"
curl -s "$API_URL/api/users/../../admin"
```

### 2.3 Authorization (Access Control)

```bash
# If you can get a valid token, test accessing other users' data
# IDOR (Insecure Direct Object Reference)
curl -s "$API_URL/api/users/1" -H "Authorization: Bearer [your-token]"
curl -s "$API_URL/api/users/2" -H "Authorization: Bearer [your-token]"

# Test role escalation
curl -s "$API_URL/api/admin" -H "Authorization: Bearer [regular-user-token]"
curl -s -X PUT "$API_URL/api/users/me" -H "Authorization: Bearer [token]" \
  -d '{"role":"admin"}'
```

---

## Phase 3: API Security

### 3.1 CRUD Access Without Auth

```bash
API_URL="[YOUR_API_URL]"

# CREATE
curl -s -X POST "$API_URL/api/projects" \
  -H "Content-Type: application/json" \
  -d '{"name":"z-audit-test","test":true}'

# READ (already tested above)

# UPDATE
curl -s -X PUT "$API_URL/api/projects/1" \
  -H "Content-Type: application/json" \
  -d '{"name":"hacked"}'

# DELETE
curl -s -X DELETE "$API_URL/api/projects/1"

# If any of these succeed without auth = CRITICAL
```

### 3.2 Input Validation

```bash
# SQL Injection
curl -s "$API_URL/api/users?id=1' OR '1'='1"
curl -s "$API_URL/api/users?id=1; DROP TABLE users;--"

# NoSQL Injection
curl -s -X POST "$API_URL/api/login" \
  -H "Content-Type: application/json" \
  -d '{"email":{"$gt":""},"password":{"$gt":""}}'

# XSS payloads in input
curl -s -X POST "$API_URL/api/projects" \
  -H "Content-Type: application/json" \
  -d '{"name":"<script>alert(1)</script>"}'

# Command Injection
curl -s "$API_URL/api/export?filename=test;ls"
```

### 3.3 Rate Limiting

```bash
# Send 100 requests rapidly
for i in {1..100}; do
  curl -s -o /dev/null -w "%{http_code}\n" "$API_URL/api/projects" &
done
wait

# Should see 429 (Too Many Requests) eventually
# If all return 200 = no rate limiting
```

### 3.4 Error Handling

```bash
# Trigger errors and check for info leakage
curl -s "$API_URL/api/projects/undefined"
curl -s "$API_URL/api/projects/null"
curl -s "$API_URL/api/projects/NaN"
curl -s -X POST "$API_URL/api/projects" -H "Content-Type: application/json" -d 'invalid-json'

# Check if stack traces are exposed
# Red flags: file paths, line numbers, package versions
```

---

## Phase 4: Infrastructure-Specific Checks

### 4.1 Cloudflare Workers

```bash
# If you have wrangler access
ACCOUNT_ID="[account-id]"
WORKER_NAME="[worker-name]"

# List secrets (names only, not values)
wrangler secret list --name $WORKER_NAME

# Check for missing critical secrets
# Should have: AUTH_SECRET, JWT_SECRET, or similar

# List KV namespaces (might contain sensitive data)
wrangler kv namespace list

# Check D1 databases
wrangler d1 list

# Download worker code for review
curl -s "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/workers/scripts/$WORKER_NAME" \
  -H "Authorization: Bearer [CF_API_TOKEN]" > worker.js
```

### 4.2 Vercel

```bash
DOMAIN="[your-domain.vercel.app]"

# Check for exposed env files
curl -s "https://$DOMAIN/.env"
curl -s "https://$DOMAIN/.env.local"
curl -s "https://$DOMAIN/.env.production"

# Check for source maps
curl -s "https://$DOMAIN/_next/static/chunks/main.js.map"

# Check for exposed API routes
curl -s "https://$DOMAIN/api"
curl -s "https://$DOMAIN/api/auth"

# Check Next.js specific
curl -s "https://$DOMAIN/_next/data/[build-id]/index.json"
```

### 4.3 Supabase

```bash
PROJECT_URL="https://[project-ref].supabase.co"
ANON_KEY="[anon-key-from-frontend]"

# Test anon key permissions (should be limited)
# List all tables
curl -s "$PROJECT_URL/rest/v1/" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY"

# Try to read users table
curl -s "$PROJECT_URL/rest/v1/users?select=*" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY"

# Try to read auth.users (should always fail)
curl -s "$PROJECT_URL/rest/v1/auth.users?select=*" \
  -H "apikey: $ANON_KEY"

# Check if RLS is enabled by trying to insert
curl -s -X POST "$PROJECT_URL/rest/v1/[table]" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Check storage buckets
curl -s "$PROJECT_URL/storage/v1/bucket" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY"
```

### 4.4 Firebase

```bash
# Check Firestore rules
# If rules are: allow read, write: if true; = CRITICAL

# Test direct database access
curl -s "https://[project].firebaseio.com/.json"

# Check storage rules
curl -s "https://firebasestorage.googleapis.com/v0/b/[project].appspot.com/o/"
```

---

## Phase 5: Security Headers & CORS

### 5.1 Security Headers Check

```bash
curl -sI "[FRONTEND_URL]" | grep -iE '^(strict-transport|content-security|x-frame|x-content-type|x-xss|referrer-policy|permissions-policy):'

# Expected headers:
# Strict-Transport-Security: max-age=31536000
# Content-Security-Policy: default-src 'self'
# X-Frame-Options: DENY
# X-Content-Type-Options: nosniff
# Referrer-Policy: strict-origin-when-cross-origin
```

### 5.2 CORS Check

```bash
# Check if API allows any origin
curl -sI "$API_URL/api/projects" \
  -H "Origin: https://evil.com" | grep -i "access-control"

# If Access-Control-Allow-Origin: * = potential issue
# If it reflects back the evil origin = CRITICAL
```

---

## Phase 6: Dependency Audit

### 6.1 NPM/Yarn

```bash
# Check for known vulnerabilities
npm audit --json 2>/dev/null | jq '.metadata.vulnerabilities'

# Or with yarn
yarn audit --json 2>/dev/null | head -50

# Check for outdated packages
npm outdated
```

### 6.2 Python

```bash
# Using pip-audit
pip-audit

# Or safety
safety check
```

---

## Phase 7: Sensitive Data Exposure

### 7.1 API Response Analysis

```bash
# Check what data is returned
curl -s "$API_URL/api/users" | jq 'if type == "array" then .[0] else . end | keys'

# Red flags in responses:
# - password / password_hash / hashed_password
# - credit_card / card_number
# - ssn / social_security
# - api_key / secret_key
# - internal_id that reveals info
# - created_by showing other user IDs
```

### 7.2 Error Message Analysis

```bash
# Intentionally trigger errors
curl -s "$API_URL/api/users/99999999"
curl -s -X POST "$API_URL/api/users" -d '{}'

# Red flags:
# - Full stack traces
# - Database table/column names
# - File system paths
# - Package versions
```

---

## Severity Classification

| Level | Criteria | Examples |
|-------|----------|----------|
| 🔴 **CRITICAL** | Immediate exploitation, data breach possible | Hardcoded passwords, no API auth, exposed secrets |
| 🟠 **HIGH** | Significant risk, needs quick fix | Exposed API keys, missing auth on some routes, IDOR |
| 🟡 **MEDIUM** | Should fix soon | Verbose errors, weak rate limiting, missing security headers |
| 🟢 **LOW** | Best practice improvements | Outdated dependencies (no known exploits), missing CSP |

---

## Report Template

```markdown
# 🔐 Z-Audit Security Report

**Target:** [Project Name / URLs]
**Date:** [Date]
**Stack Detected:** [e.g., Next.js + Supabase + Cloudflare Workers]

---

## Executive Summary
[2-3 sentences: Overall posture, critical issues count, immediate actions needed]

---

## 🔴 Critical Findings

### C1: [Title]
- **Location:** [File/URL/Endpoint]
- **Issue:** [Description]
- **Impact:** [What an attacker could do]
- **Evidence:** [Screenshot/curl command/code snippet]
- **Remediation:** [How to fix]

---

## 🟠 High Findings
[Same format as Critical]

---

## 🟡 Medium Findings
[Same format]

---

## 🟢 Low Findings / Recommendations
[Same format]

---

## ✅ What's Secure
- [Positive finding 1]
- [Positive finding 2]

---

## 📋 Prioritized Action Plan
1. **Immediate (today):** [Critical fixes]
2. **This week:** [High fixes]
3. **This month:** [Medium fixes]
4. **Backlog:** [Low priority improvements]

---

## Appendix: Tools Used
- Z-Audit skill
- curl, grep, jq
- [Other tools]
```

---

## Stack-Specific Fix Guides

### Supabase Auth Setup
```typescript
// 1. Enable RLS on all tables
ALTER TABLE your_table ENABLE ROW LEVEL SECURITY;

// 2. Create policies
CREATE POLICY "Users can only see own data" ON your_table
  FOR SELECT USING (auth.uid() = user_id);

// 3. Frontend auth
const { data: { session } } = await supabase.auth.getSession()
```

### Better Auth Setup
```typescript
// auth.ts
import { betterAuth } from 'better-auth'
 
export const auth = betterAuth({
  emailAndPassword: { enabled: true },
  socialProviders: { google: { clientId, clientSecret } }
})

// Protect API routes
app.use('/api/*', auth.middleware)
```

### Cloudflare Workers Auth
```typescript
// Add auth middleware
app.use('/api/*', async (c, next) => {
  const token = c.req.header('Authorization')?.split(' ')[1]
  if (!token) return c.json({ error: 'Unauthorized' }, 401)
  
  try {
    const payload = await verify(token, c.env.JWT_SECRET)
    c.set('user', payload)
    await next()
  } catch {
    return c.json({ error: 'Invalid token' }, 401)
  }
})
```

---

## Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/row-level-security)
- [Better Auth Docs](https://www.better-auth.com/)
- [Cloudflare Workers Security](https://developers.cloudflare.com/workers/platform/security/)
