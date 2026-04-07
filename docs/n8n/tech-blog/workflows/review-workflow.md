# Review Workflow

## Trigger

This workflow starts when a markdown file appears in `Blog Articles/1-Review/`.

The live implementation should use Nextcloud-native n8n nodes, not local filesystem triggers on the n8n host.

## Input Expectations

The source file should contain frontmatter and markdown body using the versioned authoring template in:

- `docs/n8n/tech-blog/authoring-template.md`

## Workflow Stages

1. List markdown files from `Blog Articles/1-Review/` in Nextcloud.
2. Read one markdown file at a time from Nextcloud.
3. Parse frontmatter and markdown body.
4. Normalize metadata and generate a slug if missing.
5. Load the Codex host prompt from:
   `docs/n8n/tech-blog/prompts/codex-tech-blog-review.md`
6. Build a strict JSON payload for the host Codex wrapper.
7. Send the payload to a host-level wrapper script that calls Codex CLI:
   `docs/n8n/tech-blog/scripts/tech-blog-review-via-codex.sh`
8. Parse the JSON response fields:
   `title`, `slug`, `excerpt`, `summary`, `category`, `tags`, `meta_description`, `body_markdown`
9. Merge AI output with preserved metadata.
10. Increment `review_round`.
11. Update `updated_at` and set `status` to `reviewed`.
12. Write the resulting markdown file into `Blog Articles/2-Reviewed/`.
13. Remove or move the original source markdown out of `1-Review/` after successful write to avoid reprocessing.

## Preserved Fields

- `created_at`
- existing valid `slug`
- `source_type`
- `source_path`
- `review_round`
- `published_json_path`

## Failure Handling

- Do not delete the source file.
- Keep the failed source note in `1-Review/` or move it into a clearly named error path.
- Emit a clear failure message with enough context to retry.

## Host Execution Contract

- Codex CLI runs on VM 218 host, not inside the `n8n` container.
- n8n should call the host wrapper via the built-in `SSH` node targeting the VM 218 host.
- The wrapper should accept one JSON payload via stdin or `--base64 <payload_b64>` and print one strict JSON object to stdout.
- The wrapper should fail nonzero if Codex returns malformed output or missing keys.
