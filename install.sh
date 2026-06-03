#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${OBSIDIAN_CODEX_MEMORY_REPO:-https://github.com/zixiaomiao/obsidian-codex-memory.git}"
PLUGIN_NAME="obsidian-codex-memory"
PLUGIN_DIR="${OBSIDIAN_CODEX_MEMORY_PLUGIN_DIR:-$HOME/plugins/$PLUGIN_NAME}"
MARKETPLACE_PATH="${OBSIDIAN_CODEX_MEMORY_MARKETPLACE:-$HOME/.agents/plugins/marketplace.json}"
SOURCE_PATH="$PLUGIN_DIR"

if [ "$PLUGIN_DIR" = "$HOME/plugins/$PLUGIN_NAME" ]; then
  SOURCE_PATH="./plugins/$PLUGIN_NAME"
fi

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

need git
need python3

mkdir -p "$(dirname "$PLUGIN_DIR")"

if [ -d "$PLUGIN_DIR/.git" ]; then
  git -C "$PLUGIN_DIR" pull --ff-only
elif [ -d "$PLUGIN_DIR" ]; then
  echo "Plugin directory already exists but is not a Git repo: $PLUGIN_DIR" >&2
  echo "Move it aside or set OBSIDIAN_CODEX_MEMORY_PLUGIN_DIR to another path." >&2
  exit 1
else
  git clone "$REPO_URL" "$PLUGIN_DIR"
fi

mkdir -p "$(dirname "$MARKETPLACE_PATH")"

python3 - "$MARKETPLACE_PATH" "$PLUGIN_NAME" "$SOURCE_PATH" <<'PY'
import json
import sys
from pathlib import Path

marketplace_path = Path(sys.argv[1]).expanduser()
plugin_name = sys.argv[2]
source_path = sys.argv[3]

if marketplace_path.exists():
    data = json.loads(marketplace_path.read_text(encoding="utf-8"))
else:
    data = {
        "name": "personal",
        "interface": {"displayName": "Personal"},
        "plugins": [],
    }

data.setdefault("name", "personal")
data.setdefault("interface", {}).setdefault("displayName", "Personal")
plugins = data.setdefault("plugins", [])

entry = {
    "name": plugin_name,
    "source": {
        "source": "local",
        "path": source_path,
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL",
    },
    "category": "Productivity",
}

for index, item in enumerate(plugins):
    if item.get("name") == plugin_name:
        plugins[index] = entry
        break
else:
    plugins.append(entry)

marketplace_path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Registered {plugin_name} in {marketplace_path}")
PY

if [ -n "${OBSIDIAN_VAULT:-}" ]; then
  python3 "$PLUGIN_DIR/scripts/obsidian_memory.py" init --vault "$OBSIDIAN_VAULT"
fi

cat <<EOF

Installed $PLUGIN_NAME at:
  $PLUGIN_DIR

Next, configure your Obsidian vault if you have not already:
  python3 "$PLUGIN_DIR/scripts/obsidian_memory.py" init --vault "/path/to/your/Obsidian vault"

Then enable "Obsidian Codex Memory" in Codex.
EOF
