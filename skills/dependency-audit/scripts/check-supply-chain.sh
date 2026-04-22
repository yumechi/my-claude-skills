#!/bin/bash
# check-supply-chain.sh - サプライチェーンセキュリティの設定を確認する
set -euo pipefail

echo "=== サプライチェーンセキュリティチェック ==="
echo ""

FOUND_ISSUES=0

# --- 1. npm ignore-scripts ---
echo "--- npm ignore-scripts ---"
if [ -f package.json ]; then
  if [ -f .npmrc ] && grep -q 'ignore-scripts=true' .npmrc; then
    echo "OK: .npmrc に ignore-scripts=true が設定済み"
  else
    echo "WARNING: .npmrc に ignore-scripts=true を設定してください"
    FOUND_ISSUES=1
  fi
else
  echo "SKIP: Node.js プロジェクトではありません"
fi
echo ""

# --- 2. CI ロックファイル固定 ---
echo "--- CI ロックファイル固定 ---"
if compgen -G '.github/workflows/*.yml' > /dev/null 2>&1 || compgen -G '.github/workflows/*.yaml' > /dev/null 2>&1; then
  CI_ISSUES=0

  # pnpm
  PNPM_UNFROZEN=$(grep -rn 'pnpm install' .github/workflows/ | grep -v '\-\-frozen-lockfile' || true)
  if [ -n "$PNPM_UNFROZEN" ]; then
    echo "WARNING: pnpm install に --frozen-lockfile を追加してください"
    echo "$PNPM_UNFROZEN" | sed 's/^/  /'
    CI_ISSUES=1
  fi

  # npm install (should use npm ci)
  NPM_INSTALL=$(grep -rn '[^p]npm install\|^npm install' .github/workflows/ || true)
  if [ -n "$NPM_INSTALL" ]; then
    echo "WARNING: npm install の代わりに npm ci を使用してください"
    echo "$NPM_INSTALL" | sed 's/^/  /'
    CI_ISSUES=1
  fi

  # yarn
  YARN_UNFROZEN=$(grep -rn 'yarn install' .github/workflows/ | grep -v '\-\-frozen-lockfile\|--immutable' || true)
  if [ -n "$YARN_UNFROZEN" ]; then
    echo "WARNING: yarn install に --frozen-lockfile（v1）または --immutable（v2+）を追加してください"
    echo "$YARN_UNFROZEN" | sed 's/^/  /'
    CI_ISSUES=1
  fi

  # uv
  UV_UNFROZEN=$(grep -rn 'uv sync' .github/workflows/ | grep -v '\-\-frozen' || true)
  if [ -n "$UV_UNFROZEN" ]; then
    echo "WARNING: uv sync に --frozen を追加してください"
    echo "$UV_UNFROZEN" | sed 's/^/  /'
    CI_ISSUES=1
  fi

  if [ "$CI_ISSUES" -eq 0 ]; then
    echo "OK: CI ロックファイル固定に問題なし"
  else
    FOUND_ISSUES=1
  fi
else
  echo "SKIP: GitHub Actions ワークフローが見つかりません"
fi
echo ""

# --- 3. minimumReleaseAge ---
echo "--- 新規リリースの即時採用回避 ---"
RELEASE_AGE_CHECKED=0

if [ -f pnpm-lock.yaml ] || [ -f pnpm-workspace.yaml ]; then
  RELEASE_AGE_CHECKED=1
  if [ -f pnpm-workspace.yaml ] && grep -q 'minimumReleaseAge' pnpm-workspace.yaml; then
    echo "OK: pnpm-workspace.yaml に minimumReleaseAge が設定済み"
  elif [ -f package.json ] && grep -q 'minimumReleaseAge' package.json; then
    echo "OK: package.json に minimumReleaseAge が設定済み"
  else
    echo "WARNING: pnpm-workspace.yaml に minimumReleaseAge を追加してください（推奨: 10080（7日 = 7×24×60分））"
    echo "  設定例: minimumReleaseAge: 10080"
    FOUND_ISSUES=1
  fi
fi

if [ -f renovate.json ]; then
  RELEASE_AGE_CHECKED=1
  if grep -q 'minimumReleaseAge' renovate.json; then
    echo "OK: renovate.json に minimumReleaseAge が設定済み"
  else
    echo "WARNING: renovate.json に minimumReleaseAge を追加してください（推奨: \"7 days\"）"
    echo "  設定例: \"minimumReleaseAge\": \"7 days\""
    FOUND_ISSUES=1
  fi
fi

if [ -f .github/dependabot.yml ] || [ -f .github/dependabot.yaml ]; then
  RELEASE_AGE_CHECKED=1
  DEPENDABOT_FILE=".github/dependabot.yml"
  [ -f .github/dependabot.yaml ] && DEPENDABOT_FILE=".github/dependabot.yaml"
  if grep -q 'cooldown:' "$DEPENDABOT_FILE"; then
    echo "OK: $DEPENDABOT_FILE に cooldown が設定済み"
  else
    echo "WARNING: $DEPENDABOT_FILE に cooldown を追加してください（推奨: default-days: 7）"
    echo "  設定例（各 updates エントリ内に記述）:"
    echo "    cooldown:"
    echo "      default-days: 7"
    FOUND_ISSUES=1
  fi
fi

if [ -f pyproject.toml ]; then
  RELEASE_AGE_CHECKED=1
  if grep -q 'exclude-newer' pyproject.toml; then
    echo "OK: pyproject.toml に exclude-newer が設定済み"
  else
    echo "INFO: uv を使用している場合、[tool.uv] に exclude-newer を設定してください（推奨: \"3 days\"）"
    echo "  設定例: [tool.uv]"
    echo "          exclude-newer = \"3 days\""
  fi
fi

if [ "$RELEASE_AGE_CHECKED" -eq 0 ]; then
  echo "SKIP: 対象の設定ファイルが見つかりません"
fi
echo ""

# --- 4. pnpm trustPolicy ---
echo "--- pnpm trustPolicy ---"
if [ -f pnpm-lock.yaml ] || [ -f pnpm-workspace.yaml ]; then
  if [ -f pnpm-workspace.yaml ] && grep -q 'trustPolicy' pnpm-workspace.yaml; then
    echo "OK: pnpm-workspace.yaml に trustPolicy が設定済み"
  else
    echo "WARNING: pnpm-workspace.yaml に trustPolicy: no-downgrade を追加してください"
    echo "  パッケージの信頼レベルのダウングレード（例: Trusted Publisher → 署名なし）を検出し、"
    echo "  侵害された可能性のあるバージョンのインストールを防止します"
    echo "  設定例:"
    echo "    trustPolicy: no-downgrade"
    echo "    trustPolicyExclude:"
    echo "      - 'chokidar@4.0.3'"
    FOUND_ISSUES=1
  fi
else
  echo "SKIP: pnpm プロジェクトではありません"
fi
echo ""

# --- 5. GitHub Actions SHA ピンニング ---
echo "--- GitHub Actions SHA ピンニング ---"
if compgen -G '.github/workflows/*.yml' > /dev/null 2>&1 || compgen -G '.github/workflows/*.yaml' > /dev/null 2>&1; then
  UNPINNED=$(grep -rn 'uses:' .github/workflows/ | grep -v '@[0-9a-f]\{40\}' | grep -v '^\s*#' | grep -v 'uses: \./' || true)
  if [ -n "$UNPINNED" ]; then
    echo "WARNING: 以下の Action が SHA で固定されていません:"
    echo "$UNPINNED" | sed 's/^/  /'
    FOUND_ISSUES=1

    # pinact による自動修正
    if command -v pinact > /dev/null 2>&1; then
      echo ""
      echo "pinact が利用可能です。自動修正を実行します..."
      pinact run
      echo "pinact による修正が完了しました。差分を確認してください。"
    else
      echo ""
      echo "INFO: pinact をインストールすると SHA ピンニングを自動化できます"
      echo "  go install github.com/suzuki-shunsuke/pinact/cmd/pinact@latest"
      echo "  aqua g -i suzuki-shunsuke/pinact"
    fi
  else
    echo "OK: すべての Action が SHA で固定されています"
  fi
else
  echo "SKIP: GitHub Actions ワークフローが見つかりません"
fi
echo ""

# --- サマリ ---
if [ "$FOUND_ISSUES" -eq 1 ]; then
  echo "=== WARNING が検出されました。対応を検討してください ==="
else
  echo "=== サプライチェーンセキュリティチェック合格 ==="
fi

exit $FOUND_ISSUES
