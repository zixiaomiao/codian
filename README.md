# Codian

把 Obsidian 变成 Codex 的长期记忆。

## 解决什么

- **每次跟 Codex 聊天都要从头说上下文** → Codian 记住了，不用重复
- **Codex 不记得之前的项目决策和偏好** → 分类保存，下回直接读到
- **想回顾但找不到之前的会话** → 按关键词检索，不会翻几百条记录
- **装了一大堆插件，配置越来越重** → 一个 Obsidian 仓库就搞定，纯文本可读可改

一个 Codex **插件**，不是 Obsidian 社区插件。它在你的 Obsidian 仓库里创建 `Codian Memory/` 目录，分层保存上下文、决策、待办、修复经验、偏好和会话日志，让 Codex 读得到、找得到、记得住。

## 一行安装

macOS / Linux：

```bash
curl -fsSL https://raw.githubusercontent.com/zixiaomiao/codian/main/install.sh | bash
```

Windows PowerShell：

```powershell
irm https://raw.githubusercontent.com/zixiaomiao/codian/main/install.ps1 | iex
```

## 第一次用

安装后，告诉 Codex：

> **初始化**

Codex 会问你仓库路径，然后自动建好 `Codian Memory/` 目录和全部结构。

## 之后每次用

直接跟 Codex 说就行，不用记命令：

- **读取记忆** → "读取我的 Codex 记忆" 或 "我之前做过什么"
- **记住事情** → "把这个记住" 或 "记录到 Codex"
- **更新总结** → "更新会话总结"
- **同步** → "同步 Obsidian 记忆"
- **特定项目** → "看看 项目X 的上下文"

Codex 会自己读取入口、上下文、项目摘要，按关键词找到相关记忆，不会翻全部的日志。

## 它在 Obsidian 里长这样

```
Codian Memory/
  README.md
  AGENTS.md
  10-Context-上下文/
  20-Memory-记忆/
  30-Logs-日志/
  40-Workflows-工作流/
  90-Archive-归档/
```

纯 Markdown 文件，你在 Obsidian 里也能看能改。

## 规则

- 不记 API key、密码、token 等敏感内容
- 写入前 Codex 会先跟你确认
- 默认只读摘要和命中日志，不展开全部历史

## 环境要求

- Codex 桌面版
- Python 3
- 一个本地 Obsidian 仓库

## 许可证

MIT
