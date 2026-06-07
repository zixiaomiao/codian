---
name: codian
description: "Read and update long-term memory stored in an Obsidian vault. Use when the user says '读取记忆', '记住', '记录到', '更新会话总结', '同步 Obsidian', or asks about past sessions. Covers vault discovery, compact read with keyword-matched log retrieval, append with tags/source/keywords, project summary generation, and categorized memory (decisions, todos, bugs, preferences)."
version: 1.0.5
author: zixiaomiao
license: MIT
platforms: [linux, macos]
---

# Codian Memory

把 Obsidian vault 作为长期记忆，支持读、写、摘要、分类。

## 脚本路径

Skill 自带的脚本在 `<skill_dir>/scripts/obsidian_memory.py`。

## 配置

**首次使用** — 运行以下命令，输入你的 Obsidian vault 路径：

```bash
python3 <skill_dir>/scripts/obsidian_memory.py init
```

或者设置环境变量 `OBSIDIAN_VAULT=/path/to/vault`。

## 触发词

- `读取记忆` / `我之前做过什么`
- `把这个记住` / `以后记住` / `记录到`
- `更新会话总结` / `同步 Obsidian`
- `初始化 Codian`

## Workflow

### 1. 读取记忆

```bash
python3 <skill_dir>/scripts/obsidian_memory.py read --query "<关键词>" --logs-limit 3
```

完整读取（仅在用户明确要求时）：

```bash
python3 <skill_dir>/scripts/obsidian_memory.py read --full
```

### 2. 写入记忆

写入前先确认内容：

```bash
python3 <skill_dir>/scripts/obsidian_memory.py append \
  --summary "<总结内容>" \
  --tags "#memory" \
  --source "当前 Hermes 会话" \
  --keywords "key1, key2"
```

### 3. 生成项目摘要

```bash
python3 <skill_dir>/scripts/obsidian_memory.py project-summary --max-logs 20
```

### 4. 生成分类记忆

```bash
python3 <skill_dir>/scripts/obsidian_memory.py memory-categories --max-logs 80
```

## Vault 目录结构

```
Codian Memory/
  README.md
  AGENTS.md
  10-Context-上下文/        # 项目摘要
  20-Memory-记忆/           # 分类：decisions, todos, bugs, preferences
  30-Logs-日志/             # 会话日志
  40-Workflows-工作流/
  90-Archive-归档/
```

## 安全规则

- 不记录 API key、密码、token 等敏感信息
- 写入前先向用户确认内容
- 默认只读摘要 + 命中的日志，不全量展开历史
