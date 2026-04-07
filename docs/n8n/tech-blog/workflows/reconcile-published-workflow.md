# Reconcile Published Workflow

## Trigger

This workflow runs on a schedule and treats `Blog Articles/4-Published/` as the canonical live state.

## Purpose

It keeps every downstream surface aligned with what still exists in `4-Published/`:

- `4-Published/json/posts/*.json`
- `4-Published/json/blog-manifest.json`
- website repo `public/data/blog-posts/*.json`
- website repo `public/data/blog-manifest.json`

If a published markdown file is removed from `4-Published/`, this workflow removes the matching generated JSON and repo post too.

## Workflow Stages

1. List markdown files in `Blog Articles/4-Published/`.
2. Derive canonical slugs from the published markdown filenames.
3. List generated post JSON files in `Blog Articles/4-Published/json/posts/`.
4. Compute:
   - `orphan_json_paths`: generated JSON files whose slug is no longer canonical
   - `keep_slugs`: surviving slugs that should still remain live
5. Delete orphaned JSON files from `4-Published/json/posts/`.
6. Download the existing generated manifest if present.
7. Filter the manifest entries down to the surviving slugs.
8. Upload the filtered `4-Published/json/blog-manifest.json`.
9. Send the surviving slug set plus filtered manifest to a host wrapper script:
   - `docs/n8n/tech-blog/scripts/tech-blog-reconcile-published-to-repo.sh`
10. The host wrapper deletes repo orphan post JSON files, rewrites the repo manifest, commits, and pushes only when there is a diff.

## Canonical Slug Rule

The workflow derives canonical slugs from markdown filenames in `4-Published/`.

Expected filename shape:

- `YYYY-MM-DD-<slug>.md`

If a markdown filename does not match that shape, it is ignored by this workflow.

## Failure Handling

- Do not touch the repo if the reconcile payload is malformed.
- Do not commit partial repo state.
- Leave remaining valid JSON files in place if a later step fails.
- Emit a clear error so the next schedule run can retry.
