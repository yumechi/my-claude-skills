$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetBase = Join-Path $env:USERPROFILE ".claude"

function Copy-Dir {
    param(
        [string]$SourceDir,
        [string]$TargetDir,
        [string]$Label
    )

    if (-not (Test-Path $SourceDir)) {
        return
    }

    # .keep のみの場合はスキップ
    $items = Get-ChildItem -Path $SourceDir -Directory
    if ($items.Count -eq 0) {
        Write-Host "${Label}: スキップ（コンテンツなし）"
        return
    }

    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    Write-Host "${Label}を ${TargetDir} にコピーします..."

    foreach ($item in $items) {
        $itemName = $item.Name
        $destPath = Join-Path $TargetDir $itemName

        Write-Host "  ${itemName}"

        if (-not (Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }

        Copy-Item -Path (Join-Path $item.FullName "*") -Destination $destPath -Recurse -Force
    }
}

Write-Host "=== Claude Code グローバルコピー ==="
Write-Host ""

Copy-Dir -SourceDir (Join-Path $ScriptDir "skills") -TargetDir (Join-Path $TargetBase "skills") -Label "Skills"
Copy-Dir -SourceDir (Join-Path $ScriptDir "commands") -TargetDir (Join-Path $TargetBase "commands") -Label "Commands"

Write-Host ""
Write-Host "コピー完了"
