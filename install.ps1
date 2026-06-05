#Requires -Version 5.1

<#
.SYNOPSIS
    Codian — Codex + Obsidian 长期记忆插件安装脚本 (Windows PowerShell)
.DESCRIPTION
    将 Codian 插件安装到 Codex 的 skills 目录，并注册到个人插件市场。
#>

$ErrorActionPreference = "Stop"

$REPO        = "zixiaomiao/codian"
$BRANCH      = "main"
$GITHUB_URL  = "https://github.com/$REPO.git"

$SKILLS_DIR         = Join-Path $env:USERPROFILE ".codex" "skills"
$CODIAN_DIR         = Join-Path $SKILLS_DIR "Codian"
$MARKETPLACE_FILE   = Join-Path $env:USERPROFILE ".agents" "plugins" "marketplace.json"

# ── 2. 确保目标目录存在 ─────────────────────
New-Item -ItemType Directory -Force -Path $CODIAN_DIR | Out-Null

# ── 3. 从 GitHub 下载并同步插件到 skills/Codian ─────────
Write-Host "→ 从 GitHub 下载并同步插件到 $CODIAN_DIR"
$TMP_DIR = Join-Path $env:TEMP "codian_$(Get-Random)"
git clone --depth 1 --branch $BRANCH $GITHUB_URL $TMP_DIR
$codianSrc = Join-Path $TMP_DIR "Codian"
$robocopyArgs = @(
    $codianSrc, $CODIAN_DIR, "/MIR",
    "/XD", ".git", "__pycache__",
    "/XF", "*.pyc", ".DS_Store"
)
& robocopy @robocopyArgs | Out-Null
if ($LASTEXITCODE -ge 8) {
    throw "robocopy 同步 Codian/ 失败 (exit code $LASTEXITCODE)"
}
Remove-Item -Recurse -Force $TMP_DIR

# ── 4. 注册到 Codex 个人插件市场 ─────────────
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

Write-Host "`n✅ Codian 安装完成！"
Write-Host "`n   插件目录: $CODIAN_DIR"
Write-Host "   脚本路径: $(Join-Path $CODIAN_DIR 'scripts' 'obsidian_memory.py')"
Write-Host "`n   首次使用请运行:"
Write-Host "   python $(Join-Path $CODIAN_DIR 'scripts' 'obsidian_memory.py') init --vault `"D:\path\to\your\Obsidian vault`""
