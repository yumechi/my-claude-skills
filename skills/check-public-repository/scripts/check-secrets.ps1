# check-secrets.ps1 - リポジトリ内の機密情報・不要ファイルを検出する
$ErrorActionPreference = "Stop"

Write-Host "=== 機密情報・不要ファイルチェック ==="
Write-Host ""

$FoundIssues = 0

# --- 必須ファイルの確認 ---
Write-Host "--- 必須ファイルの確認 ---"
foreach ($f in @("README.md", "LICENSE", "LICENCE", ".gitignore")) {
    if (Test-Path $f) {
        Write-Host "OK: $f"
    } else {
        Write-Host "MISSING: $f"
    }
}
Write-Host ""

# --- .env ファイルの確認 ---
Write-Host "--- .env ファイルの確認 ---"
$EnvFiles = git ls-files | Select-String -Pattern '^\.env($|\.)' | ForEach-Object { $_.Line }
if ($EnvFiles) {
    Write-Host "WARNING: 以下の .env ファイルがコミットされています:"
    $EnvFiles | ForEach-Object { Write-Host "  $_" }
    $FoundIssues = 1
} else {
    Write-Host "OK: .env ファイルなし"
}
Write-Host ""

# --- 秘密鍵ファイル ---
Write-Host "--- 秘密鍵ファイルの確認 ---"
$KeyFiles = git ls-files | Select-String -Pattern '\.(pem|key)$|id_rsa|id_ed25519' | ForEach-Object { $_.Line }
if ($KeyFiles) {
    Write-Host "WARNING: 秘密鍵ファイルが検出されました:"
    $KeyFiles | ForEach-Object { Write-Host "  $_" }
    $FoundIssues = 1
} else {
    Write-Host "OK: 秘密鍵ファイルなし"
}
Write-Host ""

# --- 認証情報パターンの検索 ---
Write-Host "--- 認証情報パターンの検索 ---"

function Check-Pattern {
    param(
        [string]$Label,
        [string]$Pattern
    )
    $result = git grep -l -E $Pattern 2>$null
    if ($result) {
        Write-Host "WARNING [$Label]: 以下のファイルで検出:"
        $result | ForEach-Object { Write-Host "  $_" }
        $script:FoundIssues = 1
    } else {
        Write-Host "OK: $Label"
    }
}

Check-Pattern "AWS アクセスキー" 'AKIA[A-Z0-9]{16}'
Check-Pattern "GitHub トークン" 'gh[pousr]_[A-Za-z0-9_]{36,}'
Check-Pattern "Slack トークン" 'xox[baprs]-[A-Za-z0-9-]+'
Check-Pattern "Google API キー" 'AIza[A-Za-z0-9_-]{35}'
Check-Pattern "JWT トークン" 'eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*'
Check-Pattern "DB 接続文字列" '(mongodb|postgres|mysql|redis)://[^/\s]+'
Check-Pattern "ハードコードされたパスワード" '(password|passwd|pwd)\s*[=:]\s*[\"'"'"'][^\"'"'"']+'
Check-Pattern "個人パス" '/(Users|home)/[a-zA-Z0-9_-]+/'
Write-Host ""

# --- メールアドレス ---
Write-Host "--- メールアドレスの確認 ---"
$EmailFiles = git grep -l -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' 2>$null
if ($EmailFiles) {
    $FilteredFiles = @()
    foreach ($file in $EmailFiles) {
        $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -notmatch 'example\.(com|org)') {
            $FilteredFiles += $file
        }
    }
    if ($FilteredFiles) {
        Write-Host "INFO: メールアドレスを含むファイル（要確認）:"
        $FilteredFiles | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "OK: 要確認のメールアドレスなし"
    }
} else {
    Write-Host "OK: 要確認のメールアドレスなし"
}
Write-Host ""

# --- OS 生成ファイル・IDE 設定ファイル ---
Write-Host "--- 不要ファイルの確認 ---"
$JunkFiles = git ls-files | Select-String -Pattern '\.DS_Store|Thumbs\.db|desktop\.ini|^\._|\.idea/|\.vscode/settings\.json|\.swp$|\.swo$|~$|\.project|\.classpath' | ForEach-Object { $_.Line }
if ($JunkFiles) {
    Write-Host "WARNING: 不要ファイルが検出されました:"
    $JunkFiles | ForEach-Object { Write-Host "  $_" }
    $FoundIssues = 1
} else {
    Write-Host "OK: 不要ファイルなし"
}
Write-Host ""

# --- サマリ ---
if ($FoundIssues -eq 1) {
    Write-Host "=== WARNING が検出されました。公開前に対応してください ==="
} else {
    Write-Host "=== すべてのチェックに合格しました ==="
}

exit $FoundIssues
