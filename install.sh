#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# Codian — 多 Agent 长期记忆插件安装脚本
# 支持: codex, hermes
# macOS / Linux
# ──────────────────────────────────────────────

REPO="zixiaomiao/codian"
BRANCH="main"
GITHUB="https://github.com/$REPO.git"
TARGET="${1:-codex}"  # 默认 codex，支持 codex | hermes

case "$TARGET" in
  codex)
    SKILLS_DIR="$HOME/.codex/skills"
    CODIAN_DIR="$SKILLS_DIR/Codian"
    MARKETPLACE_FILE="$HOME/.agents/plugins/marketplace.json"
    SRC_SUBDIR="Codian"  # 从仓库 Codian/ 目录复制
    ;;
  hermes)
    SKILLS_DIR="$HOME/.hermes/skills"
    CODIAN_DIR="$SKILLS_DIR/codian"
    MARKETPLACE_FILE=""
    SRC_SUBDIR="hermes"  # 从仓库 hermes/ 目录复制
    ;;
  *)
    echo "❌ 不支持的 Agent: $TARGET"
    echo "   用法: curl -fsSL ... | bash -s codex"
    echo "        curl -fsSL ... | bash -s hermes"
    exit 1
    ;;
esac

echo "→ 安装目标: $TARGET"
echo "→ 目标目录: $CODIAN_DIR"

# ── 确保目标目录存在 ─────────────────────
mkdir -p "$CODIAN_DIR"

# ── 从 GitHub 下载并同步 ─────────
echo "→ 从 GitHub 下载并同步..."
TMP_DIR=$(mktemp -d)
git clone --depth 1 --branch "$BRANCH" "$GITHUB" "$TMP_DIR"
rsync -a --delete \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.DS_Store' \
    "$TMP_DIR/$SRC_SUBDIR/" "$CODIAN_DIR/"
rm -rf "$TMP_DIR"

# ── 注册到 Codex 个人插件市场（仅 codex 模式）──
if [[ "$TARGET" == "codex" ]]; then
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
elif [[ "$TARGET" == "hermes" ]]; then
    echo "→ Skill 已安装到 Hermes，在 Hermes 中运行 /skill codian 或 hermes -s codian 加载"
fi

echo ""
echo "✅ Codian ($TARGET) 安装完成！"
echo ""
echo "   插件目录: $CODIAN_DIR"
echo "   脚本路径: $CODIAN_DIR/scripts/obsidian_memory.py"
echo ""
echo "   首次使用请运行:"
echo "   python3 $CODIAN_DIR/scripts/obsidian_memory.py init --vault \"/path/to/your/Obsidian vault\""
echo ""
echo "   或设置环境变量:"
echo "   export OBSIDIAN_VAULT=\"/path/to/your/Obsidian vault\""
echo ""
