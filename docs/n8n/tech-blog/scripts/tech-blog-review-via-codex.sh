#!/usr/bin/env bash
set -euo pipefail

PROMPT_FILE="${PROMPT_FILE:-/home/dduggan/codex-prompts/tech-blog-review.md}"
MODEL="${CODEX_MODEL:-gpt-5-codex}"
SANDBOX_MODE="${CODEX_SANDBOX_MODE:-read-only}"
CODEX_WORKDIR="${CODEX_WORKDIR:-/home/dduggan/codex-work}"

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI is not installed or not on PATH" >&2
  exit 127
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for JSON parsing" >&2
  exit 127
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

mkdir -p "$CODEX_WORKDIR"

WORKDIR="$(mktemp -d)"
cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

INPUT_JSON="$WORKDIR/input.json"
PROMPT_TXT="$WORKDIR/prompt.txt"
OUTPUT_JSONL="$WORKDIR/codex-output.jsonl"

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

python3 - "$INPUT_JSON" "$PROMPT_FILE" "$PROMPT_TXT" <<'PY'
import json
import pathlib
import sys

input_path = pathlib.Path(sys.argv[1])
prompt_path = pathlib.Path(sys.argv[2])
prompt_out = pathlib.Path(sys.argv[3])

payload = json.loads(input_path.read_text(encoding="utf-8"))
base_prompt = prompt_path.read_text(encoding="utf-8").strip()

prompt = f"""{base_prompt}

Input metadata:
{json.dumps(payload.get("frontmatter", {}), ensure_ascii=False)}

Input title:
{payload.get("title", "")}

Input slug:
{payload.get("slug", "")}

Raw note:
{payload.get("body_markdown", "")}
"""

prompt_out.write_text(prompt, encoding="utf-8")
PY

codex exec \
  --json \
  --skip-git-repo-check \
  -C "$CODEX_WORKDIR" \
  --sandbox "$SANDBOX_MODE" \
  -m "$MODEL" \
  "$(cat "$PROMPT_TXT")" > "$OUTPUT_JSONL"

python3 - "$OUTPUT_JSONL" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
lines = [line for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]

final_text = None

for line in lines:
  try:
    event = json.loads(line)
  except json.JSONDecodeError:
    continue

  if event.get("type") == "agent_message":
    message = event.get("message")
    if isinstance(message, str) and message.strip():
      final_text = message.strip()

  item = event.get("item")
  if isinstance(item, dict) and item.get("type") == "agent_message":
    text = item.get("text")
    if isinstance(text, str) and text.strip():
      final_text = text.strip()

if not final_text:
  raise SystemExit("No final agent message found in codex JSON output")

try:
  parsed = json.loads(final_text)
except json.JSONDecodeError as exc:
  raise SystemExit(f"Codex did not return strict JSON: {exc}")

required = [
  "title",
  "slug",
  "excerpt",
  "summary",
  "category",
  "tags",
  "meta_description",
  "body_markdown",
]

missing = [key for key in required if key not in parsed]
if missing:
  raise SystemExit(f"Codex JSON missing required keys: {', '.join(missing)}")

print(json.dumps(parsed, ensure_ascii=False))
PY
