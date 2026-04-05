# Resume Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the HTML resume page into a recruiter-first, brand-consistent web resume that is tighter than the PDF while preserving the strongest professional details.

**Architecture:** Replace the legacy Bootstrap/XHTML resume page with a single static HTML document using the same token-driven navigation, theme handling, and footer patterns as the redesigned homepage and consulting page. Keep the page more restrained than the marketing-oriented pages by using a compact hero, experience cards, and concise supporting sections.

**Tech Stack:** Static HTML, inline CSS, inline JavaScript, existing GitHub-to-Azure Static Web Apps deployment flow

---

### Task 1: Audit And Restructure Resume Content

**Files:**
- Modify: `public/Daniel-Duggan-Resume.html`
- Reference: `docs/superpowers/specs/2026-04-05-resume-redesign-design.md`

- [ ] **Step 1: Extract the content to preserve**

Preserve these content groups from the current file:

- Contact links: email, GitHub, PDF resume
- Strongest roles: JPMorganChase, Stark Carpet Corp., Citibank
- Compressed roles: Pathways Youth & Family Services, Daemon Systems, LLC, SWBC
- Certifications and education

- [ ] **Step 2: Remove weak or repetitive phrasing during rewrite**

Apply these editing rules while rebuilding the page:

- Remove repeated troubleshooting/help desk phrasing
- Keep tool names with hiring value such as CrowdStrike, Cortex, Splunk, Exabeam, SOAR, Entra ID, InTune, SentinelOne, SonicWall, VMware, Cisco, PowerShell
- Convert long bullets into shorter outcome-oriented statements

- [ ] **Step 3: Verify the page will be shorter than the source**

Run: `Select-String -Path 'public\\Daniel-Duggan-Resume.html' -Pattern '<li>|<p class=\"s9\"|<h1>'`

Expected: legacy content is identifiable before rewrite so the new structure can be checked against it afterward.

### Task 2: Rebuild The Resume Page Shell

**Files:**
- Modify: `public/Daniel-Duggan-Resume.html`
- Reference: `public/index.html`
- Reference: `public/consulting.html`

- [ ] **Step 1: Replace the old document shell**

Rebuild the document around:

- modern HTML5 doctype
- updated metadata and title
- shared font loading
- token-based CSS
- shared navbar
- shared mobile menu
- shared footer

- [ ] **Step 2: Add the recruiter-first top section**

Include:

- Daniel Duggan name lockup
- concise positioning statement
- PDF CTA
- secondary links for email and GitHub
- highlight chips emphasizing CrowdStrike, Incident Response, Financial Sector Experience, Certifications

- [ ] **Step 3: Add core page sections**

Implement these sections in this order:

1. Top section
2. Selected experience
3. Core skills
4. Certifications
5. Education

- [ ] **Step 4: Reuse only minimal JS**

Keep JavaScript limited to:

- mobile nav toggle
- theme toggle
- optional smooth anchor handling if used

### Task 3: Curate Resume Content Into The New Layout

**Files:**
- Modify: `public/Daniel-Duggan-Resume.html`

- [ ] **Step 1: Expand the strongest roles**

Give the most visual weight and detail to:

- JPMorganChase
- Stark Carpet Corp.
- Citibank

Use short role summaries plus compact high-value bullets.

- [ ] **Step 2: Compress older roles**

Condense:

- Pathways Youth & Family Services
- Daemon Systems, LLC
- SWBC

These should remain credible but visually secondary.

- [ ] **Step 3: Tighten the support sections**

Make:

- Core skills categorized rather than a long generic list
- Certifications visually scannable, with completed certs above in-progress ones
- Education concise and low-friction

### Task 4: Verify The Static Page

**Files:**
- Modify: `public/Daniel-Duggan-Resume.html`

- [ ] **Step 1: Check git diff for the intended single-file rewrite**

Run: `git diff -- public/Daniel-Duggan-Resume.html`

Expected: one focused rewrite with no unrelated file churn.

- [ ] **Step 2: Check for obvious patch issues**

Run: `git diff --check`

Expected: no whitespace or merge-marker errors.

- [ ] **Step 3: Verify key anchors and JS hooks exist**

Run: `Select-String -Path 'public\\Daniel-Duggan-Resume.html' -Pattern 'id=\"theme-btn\"|id=\"hamburger-btn\"|id=\"mobile-nav\"|PDF Resume|CrowdStrike|Incident Response|Certifications|Education'`

Expected: all recruiter-critical and shared-shell elements are present.

- [ ] **Step 4: Preview locally**

Run: `Start-Process 'D:\\Projects\\dugganco.com\\dugganco.com\\public\\Daniel-Duggan-Resume.html'`

Expected: page opens in browser for manual review.

### Task 5: Commit The Resume Rewrite

**Files:**
- Modify: `public/Daniel-Duggan-Resume.html`

- [ ] **Step 1: Stage the resume page**

Run: `git add public/Daniel-Duggan-Resume.html`

Expected: only the resume page is staged for this feature commit.

- [ ] **Step 2: Commit the implementation**

Run: `git commit -m "Redesign HTML resume page"`

Expected: a single implementation commit is created for the page rewrite.

