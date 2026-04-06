# Review Workflow

## Trigger

This workflow starts when a markdown file appears in `Blog Articles/Review/`.

## Input Expectations

The source file should contain frontmatter and markdown body using the versioned authoring template in:

- `docs/n8n/tech-blog/authoring-template.md`

## Workflow Stages

1. Read the markdown file from `Blog Articles/Review/`.
2. Parse frontmatter and markdown body.
3. Normalize metadata and generate a slug if missing.
4. Load the draft prompt from:
   `docs/n8n/tech-blog/prompts/tech-blog-draft-prompt.md`
5. Send the prompt, metadata, and note body to ChatGPT/Codex.
6. Parse the JSON response fields:
   `title`, `slug`, `excerpt`, `summary`, `category`, `tags`, `meta_description`, `body_markdown`
7. Merge AI output with preserved metadata.
8. Increment `review_round`.
9. Update `updated_at` and set `status` to `reviewed`.
10. Write the resulting markdown file into `Blog Articles/Reviewed/`.

## Preserved Fields

- `created_at`
- existing valid `slug`
- `source_type`
- `source_path`
- `review_round`

## Failure Handling

- Do not delete the source file.
- Keep the failed source note in place or move it into a clearly named error path.
- Emit a clear failure message with enough context to retry.
