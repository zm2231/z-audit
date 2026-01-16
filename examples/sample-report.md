# 🔐 Z-Audit Security Report

**Target:** https://acme-dashboard.vercel.app + https://acme-api.username.workers.dev  
**Date:** 2026-01-16  
**Stack:** React (Vite) + Cloudflare Workers (Hono) + Supabase + Todoist API + Google Calendar API

---

## Executive Summary

**Critical security failures identified.** The application had zero API authentication, exposing all user data including calendar events with meeting passwords, full task lists, and the ability to create/modify/delete any data. Additionally, the frontend password was hardcoded in JavaScript, making the "login" screen trivially bypassable.

**Immediate action required** to prevent data breach.

---

## 🔴 Critical Findings

### C1: Hardcoded Password in Frontend JavaScript
- **Location:** `/assets/index-a1b2c3d4.js`
- **Issue:** Login password hardcoded as string literal
- **Evidence:**
  ```javascript
  const q=Q=>{if(Q==="SuperSecret123!"){const Z=Date.now()+864e5;return localStorage.se...
  ```
- **Impact:** Anyone can view page source and find the password `SuperSecret123!`
- **Fix:** Move authentication server-side. Use Supabase Auth or Better Auth.

---

### C2: API Endpoints Have Zero Authentication
- **Location:** All `/api/*` routes
- **Issue:** No auth middleware protecting endpoints
- **Evidence:**
  ```bash
  $ curl https://acme-api.username.workers.dev/api/projects
  [{"id":"a1b2c3d4-...","name":"ACME Project",...},...]  # 200 OK - Full data returned
  ```
- **Impact:** Anyone can read ALL data without authentication
- **Fix:** Add auth middleware to verify JWT/session before processing requests

---

### C3: Full CRUD Access Without Authentication
- **Location:** All `/api/*` endpoints
- **Issue:** Can create, update, and delete any data
- **Evidence:**
  ```bash
  # CREATE - worked
  $ curl -X POST "https://acme-api.../api/projects" \
    -d '{"name":"HACKED","slug":"hacked","color":"#FF0000"}'
  {"id":"e5f6g7h8-...","name":"HACKED",...}
  
  # DELETE - worked
  $ curl -X DELETE "https://acme-api.../api/projects/e5f6g7h8-..."
  {"success":true}
  ```
- **Impact:** Attacker can delete all user data or inject malicious content
- **Fix:** Require authentication for all mutating operations

---

### C4: Calendar Data Exposed Including Meeting Passwords
- **Location:** `/api/calendar/events/today`
- **Issue:** Full Google Calendar data accessible without auth
- **Evidence:**
  ```json
  {
    "summary": "John Doe and Jane Smith - Weekly Sync",
    "description": "...Password: 123456...",
    "location": "https://us06web.zoom.us/j/12345678901?pwd=..."
  }
  ```
- **Impact:** Meeting links and passwords exposed to anyone
- **Fix:** Require authentication before returning calendar data

---

### C5: Third-Party API Keys Usable Without Auth
- **Location:** `/api/ai/generate`, `/api/tasks/*`
- **Issue:** OpenRouter and Todoist APIs accessible to anyone
- **Evidence:**
  ```bash
  $ curl -X POST "https://acme-api.../api/ai/generate" \
    -d '{"prompt":"Say hello"}'
  {"content":"Hello!","model":"gemini-2.0-flash",...}
  ```
- **Impact:** Attacker could rack up API bills or manipulate user's task manager
- **Fix:** Require authentication before proxying to third-party APIs

---

## 🟠 High Findings

### H1: API Key Hardcoded in Frontend (After "Fix" Attempt)
- **Location:** `/assets/api-x1y2z3w4.js`
- **Issue:** After initial fix, API key was hardcoded in frontend
- **Evidence:**
  ```javascript
  const n="ak_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  ```
- **Impact:** Anyone can extract the API key and access the API directly
- **Fix:** API keys must NEVER be in frontend code. Use session-based auth.

---

### H2: Client-Side Only Authentication
- **Location:** Frontend auth context
- **Issue:** Login validation happens entirely in browser
- **Evidence:**
  ```javascript
  if(Q==="SuperSecret123!"){
    localStorage.setItem("acme_session", ...)
  }
  ```
- **Impact:** Can bypass by running `localStorage.setItem("acme_session", "true")`
- **Fix:** Validate credentials server-side, return session token

---

## 🟡 Medium Findings

### M1: Auth Middleware Present But Not Configured
- **Location:** Worker source code
- **Issue:** `authMiddleware` exists but `ACME_API_KEY` secret was not set
- **Evidence:**
  ```javascript
  if (!expectedKey) {
    console.error("ACME_API_KEY not configured in environment");
    return c.json({ error: "Server configuration error" }, 500);
  }
  ```
- **Impact:** Security code existed but was non-functional
- **Fix:** Ensure all required secrets are configured before deployment

---

### M2: Verbose Error Messages
- **Location:** Various API endpoints
- **Issue:** Some errors reveal internal structure
- **Evidence:**
  ```json
  {"error":"invalid input syntax for type uuid: \"nonexistent-id-12345\""}
  ```
- **Impact:** Reveals database type and validation logic
- **Fix:** Return generic error messages to clients, log details server-side

---

## 🟢 Low / Recommendations

### L1: Missing Rate Limiting
- No rate limiting on API endpoints
- Recommendation: Add rate limiting middleware (e.g., Cloudflare Rate Limiting)

### L2: Missing Security Headers
- Some security headers could be added
- Recommendation: Add CSP, X-Frame-Options headers

---

## ✅ What's Secure

- **HTTPS enforced** - All traffic encrypted
- **Secrets stored properly** - Cloudflare secrets (not in code) for API keys
- **CORS configured** - Cross-origin requests handled
- **No SQL injection** - Using Supabase client with parameterized queries
- **Good separation** - Frontend and API properly separated

---

## 📋 Prioritized Action Plan

### Immediate (Today)
1. ✅ Add API authentication middleware (DONE - but see H1)
2. ⚠️ Remove hardcoded API key from frontend
3. ⚠️ Implement proper session-based auth (Better Auth recommended)

### This Week
1. Remove hardcoded password from frontend
2. Implement server-side password validation
3. Add rate limiting
4. Rotate all potentially exposed credentials

### This Month
1. Add security headers
2. Implement proper error handling
3. Add audit logging
4. Security review of Supabase RLS policies

---

## Appendix: Timeline

| Time | Event |
|------|-------|
| 11:19 | Audit started |
| 11:22 | Hardcoded password discovered in frontend |
| 11:23 | API confirmed to have zero authentication |
| 11:25 | Full calendar data with meeting passwords accessed |
| 11:27 | Successfully created/deleted data via API |
| 11:47 | Owner notified, began fixes |
| 11:47 | New deployment with auth middleware |
| 11:49 | Second fix deployed - API key now in frontend (worse!) |
| 11:52 | Full access restored using exposed API key |

---

**Auditor:** Z-Audit  
**Tools Used:** curl, grep, wrangler CLI, browser DevTools
