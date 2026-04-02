# check-supply-chain.ps1 - サプライチェーンセキュリティの設定を確認する
$ErrorActionPreference = "Stop"

Write-Host "=== サプライチェーンセキュリティチェック ==="
Write-Host ""

$FoundIssues = 0

# --- 1. npm ignore-scripts ---
Write-Host "--- npm ignore-scripts ---"
if (Test-Path "package.json") {
    if ((Test-Path ".npmrc") -and (Select-String -Path ".npmrc" -Pattern 'ignore-scripts=true' -Quiet)) {
        Write-Host "OK: .npmrc に ignore-scripts=true が設定済み"
    } else {
        Write-Host "WARNING: .npmrc に ignore-scripts=true を設定してください"
        $FoundIssues = 1
    }
} else {
    Write-Host "SKIP: Node.js プロジェクトではありません"
}
Write-Host ""

# --- 2. CI ロックファイル固定 ---
Write-Host "--- CI ロックファイル固定 ---"
$workflowFiles = @()
if (Test-Path ".github/workflows") {
    $workflowFiles = Get-ChildItem -Path ".github/workflows" -Include "*.yml","*.yaml" -File -ErrorAction SilentlyContinue
}

if ($workflowFiles.Count -gt 0) {
    $CiIssues = 0

    # pnpm
    $pnpmUnfrozen = Select-String -Path $workflowFiles.FullName -Pattern 'pnpm install' -ErrorAction SilentlyContinue | Where-Object { $_.Line -notmatch '--frozen-lockfile' }
    if ($pnpmUnfrozen) {
        Write-Host "WARNING: pnpm install に --frozen-lockfile を追加してください"
        $pnpmUnfrozen | ForEach-Object { Write-Host "  $($_.RelativePath($(Get-Location))):$($_.LineNumber): $($_.Line.Trim())" }
        $CiIssues = 1
    }

    # npm install (should use npm ci)
    $npmInstall = Select-String -Path $workflowFiles.FullName -Pattern '(?<!p)npm install' -ErrorAction SilentlyContinue
    if ($npmInstall) {
        Write-Host "WARNING: npm install の代わりに npm ci を使用してください"
        $npmInstall | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
        $CiIssues = 1
    }

    # yarn
    $yarnUnfrozen = Select-String -Path $workflowFiles.FullName -Pattern 'yarn install' -ErrorAction SilentlyContinue | Where-Object { $_.Line -notmatch '--frozen-lockfile|--immutable' }
    if ($yarnUnfrozen) {
        Write-Host "WARNING: yarn install に --frozen-lockfile（v1）または --immutable（v2+）を追加してください"
        $yarnUnfrozen | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
        $CiIssues = 1
    }

    # uv
    $uvUnfrozen = Select-String -Path $workflowFiles.FullName -Pattern 'uv sync' -ErrorAction SilentlyContinue | Where-Object { $_.Line -notmatch '--frozen' }
    if ($uvUnfrozen) {
        Write-Host "WARNING: uv sync に --frozen を追加してください"
        $uvUnfrozen | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
        $CiIssues = 1
    }

    if ($CiIssues -eq 0) {
        Write-Host "OK: CI ロックファイル固定に問題なし"
    } else {
        $FoundIssues = 1
    }
} else {
    Write-Host "SKIP: GitHub Actions ワークフローが見つかりません"
}
Write-Host ""

# --- 3. minimumReleaseAge ---
Write-Host "--- 新規リリースの即時採用回避 ---"
$ReleaseAgeChecked = 0

if ((Test-Path "pnpm-lock.yaml") -or (Test-Path "pnpm-workspace.yaml")) {
    $ReleaseAgeChecked = 1
    if ((Test-Path "pnpm-workspace.yaml") -and (Select-String -Path "pnpm-workspace.yaml" -Pattern 'minimumReleaseAge' -Quiet)) {
        Write-Host "OK: pnpm-workspace.yaml に minimumReleaseAge が設定済み"
    } elseif ((Test-Path "package.json") -and (Select-String -Path "package.json" -Pattern 'minimumReleaseAge' -Quiet)) {
        Write-Host "OK: package.json に minimumReleaseAge が設定済み"
    } else {
        Write-Host "WARNING: pnpm-workspace.yaml に minimumReleaseAge を追加してください"
        $FoundIssues = 1
    }
}

if (Test-Path "renovate.json") {
    $ReleaseAgeChecked = 1
    if (Select-String -Path "renovate.json" -Pattern 'minimumReleaseAge' -Quiet) {
        Write-Host "OK: renovate.json に minimumReleaseAge が設定済み"
    } else {
        Write-Host "WARNING: renovate.json に minimumReleaseAge を追加してください"
        $FoundIssues = 1
    }
}

if (Test-Path "pyproject.toml") {
    $ReleaseAgeChecked = 1
    if (Select-String -Path "pyproject.toml" -Pattern 'exclude-newer' -Quiet) {
        Write-Host "OK: pyproject.toml に exclude-newer が設定済み"
    } else {
        Write-Host "INFO: uv を使用している場合、[tool.uv] に exclude-newer を設定してください"
    }
}

if ($ReleaseAgeChecked -eq 0) {
    Write-Host "SKIP: 対象の設定ファイルが見つかりません"
}
Write-Host ""

# --- 4. GitHub Actions SHA ピンニング ---
Write-Host "--- GitHub Actions SHA ピンニング ---"
if ($workflowFiles.Count -gt 0) {
    $unpinned = Select-String -Path $workflowFiles.FullName -Pattern 'uses:' -ErrorAction SilentlyContinue |
        Where-Object { $_.Line -notmatch '@[0-9a-f]{40}' } |
        Where-Object { $_.Line -notmatch '^\s*#' } |
        Where-Object { $_.Line -notmatch 'uses: \./' }
    if ($unpinned) {
        Write-Host "WARNING: 以下の Action が SHA で固定されていません:"
        $unpinned | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
        $FoundIssues = 1

        # pinact による自動修正
        if (Get-Command pinact -ErrorAction SilentlyContinue) {
            Write-Host ""
            Write-Host "pinact が利用可能です。自動修正を実行します..."
            pinact run
            Write-Host "pinact による修正が完了しました。差分を確認してください。"
        } else {
            Write-Host ""
            Write-Host "INFO: pinact をインストールすると SHA ピンニングを自動化できます"
            Write-Host "  go install github.com/suzuki-shunsuke/pinact/cmd/pinact@latest"
            Write-Host "  aqua g -i suzuki-shunsuke/pinact"
        }
    } else {
        Write-Host "OK: すべての Action が SHA で固定されています"
    }
} else {
    Write-Host "SKIP: GitHub Actions ワークフローが見つかりません"
}
Write-Host ""

# --- サマリ ---
if ($FoundIssues -eq 1) {
    Write-Host "=== WARNING が検出されました。対応を検討してください ==="
} else {
    Write-Host "=== サプライチェーンセキュリティチェック合格 ==="
}

exit $FoundIssues
