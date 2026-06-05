#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# Codian — Codex + Obsidian 长期记忆插件安装脚本
# macOS / Linux
# ──────────────────────────────────────────────

REPO="zixiaomiao/codian"
BRANCH="main"
GITHUB="https://github.com/$REPO.git"

SKILLS_DIR="$HOME/.codex/skills"
CODIAN_DIR="$SKILLS_DIR/Codian"
MARKETPLACE_FILE="$HOME/.agents/plugins/marketplace.json"

# ── 2. 确保目标目录存在 ─────────────────────
mkdir -p "$CODIAN_DIR"

# ── 3. 从 GitHub 下载并同步插件到 skills/Codian ─────────
echo "→ 从 GitHub 下载并同步插件到 $CODIAN_DIR"
TMP_DIR=$(mktemp -d)
git clone --depth 1 --branch "$BRANCH" "$GITHUB" "$TMP_DIR"
rsync -a --delete \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.DS_Store' \
    "$TMP_DIR/Codian/" "$CODIAN_DIR/"
rm -rf "$TMP_DIR"

# ── 4. 注册到 Codex 个人插件市场 ─────────────
mkdir -p "$(dirname "$MARKETPLACE_FILE")"

if [[ ! -f "$MARKETPLACE_FILE" ]]; then
    cat > "$MARKETPLACE_FILE" << 'JSONEOF'
{
  "name": "personal",
  "interface": {
    "displayName": "Personal"
  },
  "plugins": []
}
JSONEOF
fi

# 插件注册信息
PLUGIN_PATH="$(cd "$CODIAN_DIR" && pwd)"

python3 - "$PLUGIN_PATH" "$MARKETPLACE_FILE" << 'PYEOF'
import json, sys

plugin_path = sys.argv[1]
marketplace_file = sys.argv[2]

entry = {
    "name": "Codian",
    "source": {
        "source": "local",
        "path": plugin_path
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
    },
    "category": "Productivity"
}

with open(marketplace_file) as f:
    data = json.load(f)

plugins = data.get("plugins", [])
found = False
for i, p in enumerate(plugins):
    if p.get("name") == "Codian":
        plugins[i] = entry
        found = True
        break

if not found:
    plugins.append(entry)
    print("→ 插件 Codian 已添加到个人插件市场")
else:
    print("→ 插件 Codian 已在个人插件市场中，已更新路径")

data["plugins"] = plugins
with open(marketplace_file, "w") as f:
    json.dump(data, f, indent=2)
PYEOF

echo ""
echo "✅ Codian 安装完成！"
echo ""
echo "   插件目录: $CODIAN_DIR"
echo "   脚本路径: $CODIAN_DIR/scripts/obsidian_memory.py"
echo ""
echo "   首次使用请运行:"
echo "   python3 $CODIAN_DIR/scripts/obsidian_memory.py init --vault \"/path/to/your/Obsidian vault\""
echo ""
echo "   或设置环境变量:"
echo "   export OBSIDIAN_VAULT=\"/path/to/your/Obsidian vault\""
