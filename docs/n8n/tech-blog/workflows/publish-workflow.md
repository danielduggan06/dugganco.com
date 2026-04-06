# Publish Workflow

## Trigger

This workflow starts when a markdown file appears in `Blog Articles/Publish/`.

## Required Metadata

The reviewed markdown must have:

- `title`
- `slug`
- `excerpt`
- `category`
- `tags`
- body content

## Workflow Stages

1. Read the reviewed markdown from `Blog Articles/Publish/`.
2. Parse metadata and body.
3. Validate title, slug, excerpt, and body presence.
4. Compute `reading_time`.
5. Build the publish artifact for `public/data/blog-posts/<slug>.json`.
6. Update `public/data/blog-manifest.json`.
7. Move the source note into `Blog Articles/Published/` after success.

## Target Post Contract

```json
{
  "title": "string",
  "slug": "string",
  "excerpt": "string",
  "category": "string",
  "tags": ["string"],
  "published_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "reading_time": 0,
  "meta_description": "string",
  "body_markdown": "string",
  "source_note": "string"
}
```

## Manifest Rules

- Keep the manifest ordered newest-first by `published_at`.
- Store only list-facing metadata in the manifest.
- Preserve existing published posts when adding a new one.

## Duplicate Slug Handling

- If the slug already exists and this is a deliberate republish, update the existing JSON file and manifest entry.
- If the slug collides unexpectedly, stop and surface a clear error instead of silently overwriting unrelated content.

## Failure Handling

- Do not archive to `Published/` on failure.
- Do not leave partial public data behind.
- Return a clear error for retry.
