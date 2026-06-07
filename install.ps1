#Requires -Version 5.1

<#
.SYNOPSIS
    Codian — 多 Agent 长期记忆插件安装脚本 (Windows PowerShell)
.DESCRIPTION
    支持: codex, hermes
    将 Codian 安装到对应 Agent 的 skills 目录。
#>

$ErrorActionPreference = "Stop"

$REPO        = "zixiaomiao/codian"
$BRANCH      = "main"
$GITHUB_URL  = "https://github.com/$REPO.git"

# 默认 codex，支持 codex | hermes
$TARGET = if ($args[0]) { $args[0] } else { "codex" }

switch ($TARGET) {
  "codex" {
    $SKILLS_DIR   = Join-Path $env:USERPROFILE ".codex" "skills"
    $CODIAN_DIR   = Join-Path $SKILLS_DIR "Codian"
    $MARKETPLACE_FILE = Join-Path $env:USERPROFILE ".agents" "plugins" "marketplace.json"
    $SRC_SUBDIR  = "Codian"
  }
  "hermes" {
    $SKILLS_DIR   = Join-Path $env:USERPROFILE ".hermes" "skills"
    $CODIAN_DIR   = Join-Path $SKILLS_DIR "codian"
    $MARKETPLACE_FILE = $null
    $SRC_SUBDIR  = "hermes"
  }
  default {
    Write-Host "❌ 不支持的 Agent: $TARGET"
    Write-Host "   用法: irm ... | iex (默认 codex)"
    Write-Host "        irm ... | iex -Args 'hermes'"
    exit 1
  }
}

Write-Host "→ 安装目标: $TARGET"
Write-Host "→ 目标目录: $CODIAN_DIR"

# ── 确保目标目录存在 ─────────────────────
New-Item -ItemType Directory -Force -Path $CODIAN_DIR | Out-Null

# ── 从 GitHub 下载并同步 ─────────
Write-Host "→ 从 GitHub 下载并同步..."
$TMP_DIR = Join-Path $env:TEMP "codian_$(Get-Random)"
git clone --depth 1 --branch $BRANCH $GITHUB_URL $TMP_DIR
$srcDir = Join-Path $TMP_DIR $SRC_SUBDIR
$robocopyArgs = @(
    $srcDir, $CODIAN_DIR, "/MIR",
    "/XD", ".git", "__pycache__",
    "/XF", "*.pyc", ".DS_Store"
)
& robocopy @robocopyArgs | Out-Null
if ($LASTEXITCODE -ge 8) {
    throw "robocopy 同步 $SRC_SUBDIR/ 失败 (exit code $LASTEXITCODE)"
}
Remove-Item -Recurse -Force $TMP_DIR

# ── 注册到 Codex 个人插件市场（仅 codex 模式）──
if ($TARGET -eq "codex") {
    $marketplaceDir = Split-Path $MARKETPLACE_FILE -Parent
    New-Item -ItemType Directory -Force -Path $marketplaceDir | Out-Null

    if (-not (Test-Path $MARKETPLACE_FILE)) {
        @'
{
  "name": "personal",
  "interface": {
    "displayName": "Personal"
  },
  "plugins": []
}
'@ | Set-Content -Path $MARKETPLACE_FILE -Encoding UTF8
    }

    $marketplace = Get-Content $MARKETPLACE_FILE -Raw -Encoding UTF8 | ConvertFrom-Json
    $plugins = @($marketplace.plugins)

    $entry = @{
        name   = "Codian"
        source = @{
            source = "local"
            path   = $CODIAN_DIR
        }
        policy = @{
            installation   = "AVAILABLE"
            authentication = "ON_INSTALL"
        }
        category = "Productivity"
    }

    $found = $false
    for ($i = 0; $i -lt $plugins.Count; $i++) {
        if ($plugins[$i].name -eq "Codian") {
            $plugins[$i] = $entry
            $found = $true
            break
        }
    }

    if (-not $found) {
        $plugins += $entry
        Write-Host "→ 插件 Codian 已添加到个人插件市场"
    } else {
        Write-Host "→ 插件 Codian 已在个人插件市场中，已更新路径"
    }

    $marketplace.plugins = $plugins
    $marketplace | ConvertTo-Json -Depth 10 | Set-Content -Path $MARKETPLACE_FILE -Encoding UTF8
}
elseif ($TARGET -eq "hermes") {
    Write-Host "→ Skill 已安装到 Hermes，在 Hermes 中运行 /skill codian 或 hermes -s codian 加载"
}

Write-Host "`n✅ Codian ($TARGET) 安装完成！"
Write-Host "`n   插件目录: $CODIAN_DIR"
Write-Host "   脚本路径: $(Join-Path $CODIAN_DIR 'scripts' 'obsidian_memory.py')"
Write-Host "`n   首次使用请运行:"
Write-Host "   python $(Join-Path $CODIAN_DIR 'scripts' 'obsidian_memory.py') init --vault `\"D:\path\to\your\Obsidian vault`\""
Write-Host "`n   或设置环境变量:"
Write-Host "   `$env:OBSIDIAN_VAULT = `"D:\path\to\your\Obsidian vault`""
