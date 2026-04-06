# Tech Blog And AI Publishing Design

## Goal

Create a public tech blog on `dugganco.com` focused on security, AI, cloud infrastructure, and homelabbing, with a mobile-friendly editorial workflow driven by Nextcloud folders and automated by n8n.

## Scope

This project includes two coordinated systems:

1. A public-facing tech blog experience on the website.
2. An AI-assisted draft and publish pipeline that starts from markdown notes in Nextcloud.

The design explicitly avoids introducing a CMS. The website remains a static site, while n8n handles automation and publishing.

## Current Project Context

The website at `D:\Projects\dugganco.com\dugganco.com` is a static site served from `public/` and deployed via Azure Static Web Apps. Existing pages such as `public/index.html`, `public/consulting.html`, and `public/foodblog.html` use a custom HTML/CSS/JS approach rather than a framework-backed content system.

That existing structure makes a static blog with generated structured content the best fit. The site should consume published post data, but should not depend on a runtime backend or database.

## User Workflow

The user writes and edits article ideas primarily from a phone using Nextcloud Notes. The editorial workflow is represented by folder movement rather than a separate dashboard.

### Editorial State Folders

The workflow uses a folder hierarchy under Nextcloud:

- `Blog Articles/`
  Working notes and unfinished article ideas.
- `Blog Articles/Review/`
  Notes moved here are ready for AI drafting or redrafting.
- `Blog Articles/Reviewed/`
  n8n writes polished AI-assisted drafts here for human review and further edits.
- `Blog Articles/Publish/`
  Files moved here are approved for public publication.
- `Blog Articles/Published/`
  n8n archives successfully published source markdown here.

Folder location is the editorial state machine. No separate approval UI is required for the core workflow.

## Markdown Template

Each article note should use a frontmatter block so n8n can parse and preserve metadata cleanly.

```md
---
title: ""
slug: ""
status: draft
tags:
  - security
  - ai
category: security
created_at: 2026-04-05T00:00:00-04:00
updated_at: 2026-04-05T00:00:00-04:00
source_type: note
source_path: "Nextcloud/Notes/Blog Articles/Review/"
summary: ""
excerpt: ""
publish_at: null
canonical_url: ""
meta_description: ""
og_image: ""
review_round: 1
---

# Working Title

## Raw Thoughts
- Put rough ideas here
- Bullet points are fine
- Fragments are fine

## Context
Who is this for?
What triggered this post?
What should the reader walk away with?

## Key Points
- Main argument
- Supporting examples
- Any tools, commands, or lessons learned

## References
- Optional links or notes
```

### Metadata Rules

- `slug` is the URL-safe identifier for the post. If blank, n8n generates it from `title`.
- `status` reflects the current workflow state.
- `review_round` increments each time a note is reprocessed through `Review`.
- `created_at` remains stable from the original note.
- `updated_at` is refreshed when n8n rewrites or publishes the note.
- Existing slugs should be preserved across review cycles unless explicitly changed.

## Public Website Architecture

The public site remains static. Published content is written into the repository in structured files that the blog UI can read.

### Public Files

- `public/techblog.html`
  Main blog landing page.
- `public/data/blog-manifest.json`
  Ordered metadata list of published posts for rendering the blog index.
- `public/data/blog-posts/<slug>.json`
  Structured published content for each article.
- Optional: `public/techblog/<slug>.html`
  Dedicated article pages if clean route-based post pages are preferred over a client-rendered single-page reader.

### Public Blog Experience

The blog should visually match the modernized site design already used on the homepage and consulting page. It should present:

- A hero/introduction framing the blog around security, AI, infrastructure, cloud, and homelab work.
- A searchable and filterable list of posts.
- Topic filters based on tags and category.
- Excerpts, reading time, publish date, and article metadata.
- A post reading experience that feels intentional and editorial rather than generic.

The UI should separate index rendering from content storage so the site can be redesigned later without changing the automation pipeline.

## n8n Automation Architecture

The automation layer is responsible for monitoring folder state, invoking AI, writing reviewed drafts, and publishing approved posts to the website repo.

### Workflow 1: Review Intake

Trigger condition:
- A markdown file appears in `Blog Articles/Review/`.

Responsibilities:
- Read the markdown file and frontmatter.
- Validate required fields and normalize metadata.
- Generate a slug if missing.
- Invoke the AI drafting step.
- Write the polished draft into `Blog Articles/Reviewed/`.
- Update metadata such as `status`, `updated_at`, and `review_round`.
- Preserve enough workflow metadata to support debugging and traceability.

Result:
- The user receives a reviewed markdown draft back inside Nextcloud, ready for manual edits.

### Workflow 2: Publish Intake

Trigger condition:
- A markdown file appears in `Blog Articles/Publish/`.

Responsibilities:
- Read the reviewed markdown and metadata.
- Validate publishability requirements such as title, slug, excerpt, and body presence.
- Transform the markdown into the structured website publish format.
- Write or update `public/data/blog-posts/<slug>.json`.
- Rebuild or update `public/data/blog-manifest.json`.
- Archive the source markdown into `Blog Articles/Published/`.

Result:
- The website repo contains a new published article artifact and updated manifest data.

## AI Drafting Architecture

The AI drafting step uses ChatGPT/Codex as the writer model, with a dedicated natural-language prompt asset that pushes output away from generic AI phrasing and toward a more human-written technical voice.

### AI Inputs

The prompt should include:

- The raw note body.
- The frontmatter metadata.
- A style/voice instruction set.
- A natural-language writing prompt asset.
- Clear constraints on structure, tone, and factual discipline.
- Output formatting instructions requiring structured fields plus markdown body.

### AI Outputs

The AI response should be parsed into:

- `title`
- `slug`
- `excerpt`
- `summary`
- `tags`
- `category`
- `meta_description`
- polished markdown body

The AI step should not directly publish anything. It only prepares reviewed drafts.

### AI Behavior Requirements

- Preserve the user’s main ideas and technical claims.
- Improve readability and narrative flow.
- Avoid exaggerated marketing tone.
- Avoid obviously synthetic “AI blog voice.”
- Respect existing slugs unless the user intentionally changes them.
- Be deterministic enough that reruns are manageable and traceable.

## Data Model

Published articles should use a stable structured format. Each published post object should include:

- `title`
- `slug`
- `excerpt`
- `category`
- `tags`
- `published_at`
- `updated_at`
- `reading_time`
- `meta_description`
- `body_html` or `body_markdown`
- `source_note`

The manifest should contain only the metadata required to render lists efficiently, while per-post files hold full content.

## Error Handling

The pipeline should fail explicitly rather than silently skipping issues.

### Review Errors

If a note in `Review` cannot be parsed or drafted:

- n8n should not delete the source note.
- The file should remain in place or be moved to a clearly named error location.
- A notification should be sent through the chosen alert channel if configured.

### Publish Errors

If a note in `Publish` fails publication:

- No partial public update should be left behind.
- The note should not be archived to `Published/`.
- The failure reason should be logged clearly for retry.

## Testing And Verification

The implementation should verify:

- Notes moved into `Review/` produce reviewed drafts in `Reviewed/`.
- Re-reviewing an edited draft increments `review_round` correctly.
- Notes moved into `Publish/` generate website publish artifacts.
- The blog index renders published posts correctly.
- Individual article rendering works with representative post data.
- Duplicate slugs are handled safely.
- Missing metadata fails with useful errors.

## Security And Boundaries

- Nextcloud remains the source of authoring truth.
- n8n handles automation, not long-term article storage.
- The public site only consumes published artifacts from the repo.
- Secrets for AI API access and any repo automation must stay in n8n credentials or secure storage, not in article files.

## Recommended Implementation Order

1. Create the public blog page and content rendering structure in the website repo.
2. Define the published post JSON schema and manifest format.
3. Implement the `Review` intake workflow in n8n.
4. Implement the AI prompt asset and structured output parsing.
5. Implement the `Publish` intake workflow in n8n.
6. Verify end-to-end movement from Nextcloud note to public post.

## Decisions Made

- The blog will be a static site feature, not a CMS.
- The input source will be Nextcloud Notes folders, optimized for mobile use.
- Editorial state will be represented by folder movement.
- AI drafting will use ChatGPT/Codex with a natural-language prompt asset.
- Reviewed drafts will be returned to Nextcloud for human edits.
- Publication will happen only when a reviewed note is moved into `Publish/`.
- n8n will monitor both `Review/` and `Publish/` and own the automation pipeline.
