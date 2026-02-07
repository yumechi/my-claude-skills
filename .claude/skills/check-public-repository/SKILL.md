---
name: check-public-repository
description: リポジトリを公開する前に、機密情報や不適切なデータが含まれていないかチェックします
---

# リポジトリ公開前チェック

このスキルはリポジトリを公開する前に、以下の項目を確認します。

## チェック項目

### 1. 必須ファイルの存在確認
- [ ] `README.md` が存在すること
- [ ] `LICENSE` または `LICENCE` ファイルが存在すること
- [ ] `.gitignore` が存在すること

### 2. 機密情報のチェック
以下のパターンがリポジトリに含まれていないことを確認してください。

#### 鍵・認証情報
- [ ] 秘密鍵ファイル（`*.pem`, `*.key`, `id_rsa`, `id_ed25519` など）
- [ ] AWS アクセスキー（`AKIA` で始まる文字列）
- [ ] API キー・トークン（`api_key`, `apikey`, `access_token`, `secret_key` など）
- [ ] GitHub トークン（`ghp_`, `gho_`, `ghu_` で始まる文字列）
- [ ] Slack トークン（`xoxb-`, `xoxp-` で始まる文字列）
- [ ] Google API キー（`AIza` で始まる文字列）
- [ ] JWT トークン（`eyJ` で始まる長い文字列）
- [ ] データベース接続文字列（`mongodb://`, `postgres://`, `mysql://` など）

#### .env ファイル
- [ ] `.env` ファイルがコミットされていないこと
- [ ] `.env.local`, `.env.production` などの環境ファイルがコミットされていないこと
- [ ] `.env.example` や `.env.sample` に実際の認証情報が含まれていないこと

#### パスワード
- [ ] ハードコードされたパスワード（`password =`, `passwd =`, `pwd =` など）

#### 個人的な環境パス
- [ ] `/Users/<username>/` のような個人のホームディレクトリパス
- [ ] `/home/<username>/` のような個人のホームディレクトリパス
- [ ] `C:\Users\<username>\` のような Windows の個人パス

#### メールアドレス
- [ ] ダミー以外の実際のメールアドレス（`example.com`, `example.org` ドメイン以外）
- [ ] 個人のメールアドレス

#### その他の個人情報
- [ ] 電話番号
- [ ] 住所
- [ ] クレジットカード番号のようなパターン
- [ ] マイナンバーのようなパターン

### 3. 不要ファイルのチェック

#### OS 生成ファイル
- [ ] `.DS_Store`（macOS）
- [ ] `Thumbs.db`（Windows）
- [ ] `desktop.ini`（Windows）
- [ ] `._*` ファイル（macOS リソースフォーク）

#### IDE・エディタ設定ファイル
- [ ] `.idea/`（JetBrains 系 IDE）
- [ ] `.vscode/settings.json`（VS Code の個人設定）
- [ ] `*.swp`, `*.swo`（Vim スワップファイル）
- [ ] `*~`（バックアップファイル）
- [ ] `.project`, `.classpath`（Eclipse）

## チェック手順

1. `README.md`、`LICENSE`/`LICENCE`、`.gitignore` ファイルの存在を確認
2. `git ls-files` でトラッキングされているファイル一覧を取得
3. `.env` ファイルがコミットされていないか確認
4. OS 生成ファイル・IDE 設定ファイルがコミットされていないか確認
5. 機密情報のパターンを grep で検索
6. 検出された問題をレポート

## 実行例

```bash
# 必須ファイルの確認
ls README.md LICENSE LICENCE .gitignore 2>/dev/null

# .env ファイルがコミットされていないか確認
git ls-files | grep -E '^\.env($|\.)'

# 秘密鍵ファイルの検索
git ls-files | grep -E '\.(pem|key)$|id_rsa|id_ed25519'

# AWS キーのパターン検索
git grep -E 'AKIA[A-Z0-9]{16}'

# GitHub トークンの検索
git grep -E 'gh[pousr]_[A-Za-z0-9_]{36,}'

# Slack トークンの検索
git grep -E 'xox[baprs]-[A-Za-z0-9-]+'

# Google API キーの検索
git grep -E 'AIza[A-Za-z0-9_-]{35}'

# JWT トークンの検索
git grep -E 'eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*'

# データベース接続文字列の検索
git grep -E '(mongodb|postgres|mysql|redis)://[^/\s]+'

# パスワードパターンの検索
git grep -iE '(password|passwd|pwd)\s*[=:]\s*["\x27][^"\x27]+'

# 個人パスの検索
git grep -E '/(Users|home)/[a-zA-Z0-9_-]+/'

# メールアドレスの検索（example.com/org 以外）
git grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | grep -v 'example\.\(com\|org\)'

# OS 生成ファイルの検索
git ls-files | grep -E '\.DS_Store|Thumbs\.db|desktop\.ini|^\._'

# IDE・エディタ設定ファイルの検索
git ls-files | grep -E '\.idea/|\.vscode/settings\.json|\.swp$|\.swo$|~$|\.project|\.classpath'
```

## 注意事項

- `.gitignore` に含まれているファイルはチェック対象外ですが、誤ってコミットされていないか確認してください
- 偽陽性（false positive）が発生する場合があります。検出結果を手動で確認してください
- このチェックは完全ではありません。公開前に必ず手動でも確認してください
