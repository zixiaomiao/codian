---
name: obsidian-codex-memory
description: Use when the user asks to enable Obsidian memory, read Codex memory, sync Obsidian memory, update Codex session summary, or continue with their Obsidian memory. Reads and updates the user's Codex memory note in Obsidian.
---

# Obsidian Codex Memory

Use this skill when the user says any of:

- 启用 Obsidian 记忆
- 先读我的 Obsidian
- 同步 Obsidian 记忆
- 更新 Codex 会话总结
- 用我的 Obsidian 记忆继续
- read Obsidian memory
- update Codex memory

## Vault and configuration

The memory script supports any computer. It resolves the vault in this order:

- `OBSIDIAN_VAULT` environment variable
- saved config from `obsidian_memory.py init --vault <path>`
- common Obsidian vault locations

If no vault can be found, ask the user for their Obsidian vault path and run:

```bash
python3 ~/plugins/obsidian-codex-memory/scripts/obsidian_memory.py init --vault "<path-to-vault>"
```

## Workflow

1. Before doing substantial work, read compact memory:

```bash
python3 /Users/xiao/plugins/obsidian-codex-memory/scripts/obsidian_memory.py read
```

If the plugin is installed somewhere else, use the installed plugin root instead of
`/Users/xiao/plugins/obsidian-codex-memory`.

2. Finish the user's actual task.

3. If the user asks to update memory, or the work creates a durable preference, path, fix, or operating rule, append a compact summary:

```bash
python3 /Users/xiao/plugins/obsidian-codex-memory/scripts/obsidian_memory.py append --summary "<5-8 line summary>"
```

If the plugin is installed somewhere else, use the installed plugin root instead of
`/Users/xiao/plugins/obsidian-codex-memory`.

4. For selective GitHub sync of memory files:

```bash
python3 /Users/xiao/plugins/obsidian-codex-memory/scripts/obsidian_memory.py sync-github --dry-run
python3 /Users/xiao/plugins/obsidian-codex-memory/scripts/obsidian_memory.py sync-github
```

If the plugin is installed somewhere else, use the installed plugin root instead of
`/Users/xiao/plugins/obsidian-codex-memory`.

## Rules

- Do not record API keys, passwords, tokens, or private credentials.
- Keep summaries compact. Record durable preferences, paths, conclusions, pitfalls, and verified fixes.
- Do not dump the entire memory note unless the user asks for full memory.
- Prefer UTF-8 direct file writes. Avoid shell pipelines that can corrupt Chinese text.
- For GitHub sync, only the allowed memory files may overwrite remote; all other local differences should follow GitHub.
