#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/home/dduggan/.config/superpowers/worktrees/dugganco.com/tech-blog-ai-publishing}"
BRANCH="${REPO_BRANCH:-main}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 127
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required" >&2
  exit 127
fi

WORKDIR="$(mktemp -d)"
cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

INPUT_JSON="$WORKDIR/input.json"

case "${1:-}" in
  --base64)
    if [[ -z "${2:-}" ]]; then
      echo "--base64 requires a payload argument" >&2
      exit 1
    fi
    printf '%s' "$2" | base64 -d > "$INPUT_JSON"
    ;;
  --file)
    if [[ -z "${2:-}" ]]; then
      echo "--file requires a path argument" >&2
      exit 1
    fi
    cp "$2" "$INPUT_JSON"
    ;;
  "")
    cat > "$INPUT_JSON"
    ;;
  *)
    echo "Usage: $0 [--base64 <payload_b64> | --file <input_json_path>]" >&2
    exit 1
    ;;
esac

python3 - "$INPUT_JSON" "$REPO_DIR" <<'PY'
import json
import pathlib
import sys
from datetime import datetime, timezone

input_path = pathlib.Path(sys.argv[1])
repo_dir = pathlib.Path(sys.argv[2])

payload = json.loads(input_path.read_text(encoding="utf-8"))
slug = str(payload["slug"]).strip()
post_json = json.loads(payload["post_json"])
manifest_entries = json.loads(payload["manifest_json"])

posts_dir = repo_dir / "public" / "data" / "blog-posts"
posts_dir.mkdir(parents=True, exist_ok=True)

post_path = posts_dir / f"{slug}.json"
post_path.write_text(json.dumps(post_json, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

manifest = {
    "generated_at": datetime.now(timezone.utc).astimezone().isoformat(),
    "posts": manifest_entries,
}
manifest_path = repo_dir / "public" / "data" / "blog-manifest.json"
manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

cd "$REPO_DIR"

git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"
git config user.name "n8n Tech Blog"
git config user.email "n8n-tech-blog@dugganco.local"
git add public/data/blog-manifest.json public/data/blog-posts

if git diff --cached --quiet; then
  echo "No repo content changes to commit."
  exit 0
fi

COMMIT_SLUG="$(python3 - "$INPUT_JSON" <<'PY'
import json, sys
payload = json.load(open(sys.argv[1], encoding="utf-8"))
print(payload["slug"])
PY
)"

git commit -m "Publish: ${COMMIT_SLUG}"
git push origin "$BRANCH"
