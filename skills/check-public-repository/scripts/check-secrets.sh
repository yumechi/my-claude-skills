#!/bin/bash
# check-secrets.sh - リポジトリ内の機密情報・不要ファイルを検出する
set -euo pipefail

echo "=== 機密情報・不要ファイルチェック ==="
echo ""

FOUND_ISSUES=0

# --- 必須ファイルの確認 ---
echo "--- 必須ファイルの確認 ---"
for f in README.md LICENSE LICENCE .gitignore; do
  if [ -f "$f" ]; then
    echo "OK: $f"
  else
    echo "MISSING: $f"
  fi
done
echo ""

# --- .env ファイルの確認 ---
echo "--- .env ファイルの確認 ---"
ENV_FILES=$(git ls-files | grep -E '^\.env($|\.)' || true)
if [ -n "$ENV_FILES" ]; then
  echo "WARNING: 以下の .env ファイルがコミットされています:"
  echo "$ENV_FILES"
  FOUND_ISSUES=1
else
  echo "OK: .env ファイルなし"
fi
echo ""

# --- 秘密鍵ファイル ---
echo "--- 秘密鍵ファイルの確認 ---"
KEY_FILES=$(git ls-files | grep -E '\.(pem|key)$|id_rsa|id_ed25519' || true)
if [ -n "$KEY_FILES" ]; then
  echo "WARNING: 秘密鍵ファイルが検出されました:"
  echo "$KEY_FILES"
  FOUND_ISSUES=1
else
  echo "OK: 秘密鍵ファイルなし"
fi
echo ""

# --- 認証情報パターンの検索 ---
echo "--- 認証情報パターンの検索 ---"

check_pattern() {
  local label="$1"
  local pattern="$2"
  local result
  result=$(git grep -l -E "$pattern" 2>/dev/null || true)
  if [ -n "$result" ]; then
    echo "WARNING [$label]: 以下のファイルで検出:"
    echo "$result" | sed 's/^/  /'
    FOUND_ISSUES=1
  else
    echo "OK: $label"
  fi
}

check_pattern "AWS アクセスキー" 'AKIA[A-Z0-9]{16}'
check_pattern "GitHub トークン" 'gh[pousr]_[A-Za-z0-9_]{36,}'
check_pattern "Slack トークン" 'xox[baprs]-[A-Za-z0-9-]+'
check_pattern "Google API キー" 'AIza[A-Za-z0-9_-]{35}'
check_pattern "JWT トークン" 'eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*'
check_pattern "DB 接続文字列" '(mongodb|postgres|mysql|redis)://[^/\s]+'
check_pattern "ハードコードされたパスワード" '(password|passwd|pwd)\s*[=:]\s*["'"'"'][^"'"'"']+'
check_pattern "個人パス" '/(Users|home)/[a-zA-Z0-9_-]+/'
echo ""

# --- メールアドレス ---
echo "--- メールアドレスの確認 ---"
EMAILS=$(git grep -l -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' 2>/dev/null | xargs grep -l -v -E 'example\.(com|org)' 2>/dev/null || true)
if [ -n "$EMAILS" ]; then
  echo "INFO: メールアドレスを含むファイル（要確認）:"
  echo "$EMAILS" | sed 's/^/  /'
else
  echo "OK: 要確認のメールアドレスなし"
fi
echo ""

# --- OS 生成ファイル・IDE 設定ファイル ---
echo "--- 不要ファイルの確認 ---"
JUNK_FILES=$(git ls-files | grep -E '\.DS_Store|Thumbs\.db|desktop\.ini|^\._|\.idea/|\.vscode/settings\.json|\.swp$|\.swo$|~$|\.project|\.classpath' || true)
if [ -n "$JUNK_FILES" ]; then
  echo "WARNING: 不要ファイルが検出されました:"
  echo "$JUNK_FILES" | sed 's/^/  /'
  FOUND_ISSUES=1
else
  echo "OK: 不要ファイルなし"
fi
echo ""

# --- サマリ ---
if [ "$FOUND_ISSUES" -eq 1 ]; then
  echo "=== WARNING が検出されました。公開前に対応してください ==="
else
  echo "=== すべてのチェックに合格しました ==="
fi

exit $FOUND_ISSUES
