# Resume Redesign Design

## Goal

Redesign `public/Daniel-Duggan-Resume.html` into a recruiter-first web resume that matches the new `dugganco.com` design system while remaining more concise than the PDF resume. The page should function as a high-signal professional profile, not a verbatim web copy of the full resume.

## Outcome

The new resume page should:

- Use the same site chrome and overall visual language as the redesigned homepage and consulting page
- Open with a stronger branded top section instead of a plain document header
- Prioritize recruiter scan speed and hierarchy
- Retain meaningful detail for the strongest, most relevant roles
- Treat the PDF resume as the full-detail counterpart

## Audience

Primary audience:

- Recruiters
- Hiring managers
- Security leaders reviewing candidates quickly

Secondary audience:

- General visitors who want a concise view of background and credentials

## Content Strategy

The HTML resume will be tighter than the PDF while still retaining substance.

### Keep Expanded

- JPMorganChase
- Stark Carpet Corp.
- Citibank

These roles should carry the most detail because they best support the current cybersecurity profile.

### Compress

- Pathways Youth & Family Services
- Daemon Systems, LLC
- SWBC

These roles should remain present, but with fewer bullets and more concise descriptions unless a specific item strongly reinforces the current security narrative.

### Remove or Reduce

- Repetitive troubleshooting language
- Low-signal generic support tasks
- Older duties that do not materially improve the current cybersecurity positioning

## Information Architecture

### 1. Hero / Top Section

This section replaces the current plain resume header.

It should include:

- Name
- Short positioning line oriented around cybersecurity / incident response / security operations
- Clear primary CTA to the PDF resume
- Secondary quick-link items such as email and GitHub
- 3 to 4 recruiter-facing highlight chips

Planned highlight emphasis:

- CrowdStrike
- Incident Response
- Financial Sector Experience
- Certifications

### 2. Selected Experience

This is the core of the page and should appear high on the page.

Structure:

- Featured role cards or timeline-style entries
- Most space allocated to strongest and most current roles
- Concise role summary followed by a small number of high-value bullets
- Tooling and impact should be easy to scan

### 3. Core Skills

A tight, categorized skills section rather than the current long list.

Suggested groups:

- Security Operations
- Detection / Response Tooling
- Infrastructure / Cloud
- Networking / Administration

This section should avoid keyword stuffing and instead focus on clarity and relevance.

### 4. Certifications

Keep completed certifications prominent and visually distinct.

In-progress or planned certifications should remain lower emphasis than completed certifications.

### 5. Education

Education should remain present but concise. It should not visually dominate the page.

## Layout Direction

Chosen direction: Option B, “Story + Depth”.

Rationale:

- Best fit for a recruiter-first page that still needs some depth
- Keeps the strong branded top section requested by the user
- Allows meaningful detail on the strongest roles without reverting to a dense document layout
- Adapts better to mobile than a sidebar-heavy design

## Visual Design

The page should reuse the new site visual system rather than the older Bootstrap/XHTML styling.

### Shared Design Elements

- Same top navbar structure used on homepage and consulting page
- Same overall dark-blue / white / black palette
- Same token-driven CSS approach
- Same modern typography system
- Same mobile navigation behavior
- Same footer style

### Resume-Specific Adaptation

The resume page should feel slightly more restrained than the homepage and consulting page.

It should:

- Keep premium styling, but reduce decorative intensity
- Favor clarity and spacing over visual flourish
- Use subtle section bands, cards, and dividers
- Avoid looking like a marketing landing page

The result should feel polished and modern, but still professional and credible for hiring use.

## Mobile Behavior

Mobile layout should remain highly readable and scan-friendly.

Requirements:

- Hero/top section must compress cleanly without becoming oversized
- Highlight chips should wrap neatly
- Experience entries should stack naturally
- Dense two-column patterns should collapse to one column
- PDF CTA should stay visible and easy to tap

## Navigation

The resume page should use the new global navigation, not the old dropdown-heavy menu system.

Resume-specific in-page anchor navigation may be included in a lightweight way if it improves scanning, but it must not reintroduce the old overloaded menu structure.

## Technical Plan

### Replace

- Remove Bootstrap dependency
- Remove the old XHTML-era structure and CSS patterns
- Remove duplicated / conflicting light-dark mode logic from the legacy page
- Remove the old dropdown-heavy resume section menu

### Preserve

- Existing factual resume content, selectively edited for quality and relevance
- Email, GitHub, and PDF resume links
- Theme toggle compatibility with the new site approach

### Implementation Style

- Single static HTML file
- Inline CSS and JS consistent with the rest of the current site
- Minimal JS, mostly for nav and theme behavior

## Risks

### Risk: Too much content retained

If too much legacy content is preserved, the page will still feel like a pasted document instead of a designed web resume.

Mitigation:

- Aggressively compress older roles
- Keep only the highest-signal bullets

### Risk: Too little detail retained

If the page becomes too sparse, it loses credibility for technical reviewers.

Mitigation:

- Keep detail concentrated in the strongest three roles
- Preserve named tools, platforms, and concrete responsibilities

### Risk: Overdesign

If the page inherits too much “hero page” treatment, it may feel like self-promotion instead of a professional resume.

Mitigation:

- Use restrained styling
- Keep decorative effects subtle
- Let hierarchy and typography do most of the work

## Acceptance Criteria

The redesign is successful if:

- The resume page visually matches the new site more closely than the old site
- A recruiter can identify current role focus and strongest qualifications quickly
- The page is clearly shorter and more curated than the PDF version
- CrowdStrike appears as part of the top-level qualifications emphasis
- The strongest recent roles are more detailed than older roles
- Mobile presentation remains clean and readable

