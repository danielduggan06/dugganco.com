# Publish Workflow

## Trigger

This workflow starts when a markdown file appears in `Blog Articles/3-Publish/`.

The live implementation should use Nextcloud-native n8n nodes, not local filesystem triggers on the n8n host.

## Required Metadata

The reviewed markdown must have:

- `title`
- `slug`
- `excerpt`
- `category`
- `tags`
- body content

## Workflow Stages

1. List markdown files from `Blog Articles/3-Publish/` in Nextcloud.
2. Read one reviewed markdown file at a time from Nextcloud.
3. Parse metadata and body.
4. Validate title, slug, excerpt, and body presence.
5. Compute `reading_time`.
6. Build the publish artifact for `4-Published/json/posts/<slug>.json`.
7. Update `4-Published/json/blog-manifest.json`.
8. Push the same post JSON and manifest data into the website repo at `public/data/blog-posts/<slug>.json` and `public/data/blog-manifest.json`.
9. Let the normal Azure Static Web Apps deploy flow publish from `main`.
10. Set `status` to `published`, update `published_json_path`, and stamp `published_at`.
11. Move the source note into `Blog Articles/4-Published/` after success.

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

- Do not archive to `4-Published/` on failure.
- Do not leave partial JSON artifacts behind in `4-Published/json/`.
- Do not push a repo commit if the publish payload is invalid.
- Return a clear error for retry.
