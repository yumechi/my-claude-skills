---
name: quickcommit
description: git status を確認し、問題がなければ add と commit を実行します
context: fork
agent: general-purpose
model: haiku
---

# Quick Commit

変更をステージングしてコミットする前に、コミットすべきでないファイルが含まれていないかチェックします。

> このスキルは独立したサブエージェントとして実行されます。add / commit は実行せず、
> 安全性チェックの結果・ステージング対象・コミットメッセージ案を「提案」として返します。
> 実際のコミットは、提案を受け取ったメインエージェントがユーザーの承認を得てから行います。
> 会話履歴は参照できないため、コミットメッセージは `git diff` / `git status` から機械的に作成します。
> 出力の最後に必ず「## 適用手順」セクションを付けてください。

## 実行手順

### 1. git status の確認

```bash
git status
```

### 2. コミットすべきでないファイルのチェック

以下のパターンに一致するファイルが含まれていないか確認してください。

#### 機密情報を含む可能性のあるファイル
- `.env`, `.env.local`, `.env.production` など環境ファイル
- `*.pem`, `*.key`, `id_rsa`, `id_ed25519` など秘密鍵
- `credentials.json`, `secrets.json` など認証情報ファイル

#### OS 生成ファイル
- `.DS_Store`
- `Thumbs.db`
- `desktop.ini`
- `._*`

#### IDE・エディタ設定ファイル
- `.idea/`
- `.vscode/settings.json`
- `*.swp`, `*.swo`
- `*~`

#### その他
- `node_modules/`, `vendor/` など依存ディレクトリ
- `*.log` ログファイル
- `*.tmp`, `*.temp` 一時ファイル

### 3. 提案を作成する（add / commit は実行しない）

- 危険なファイルが含まれていなければ、ステージング対象とコミットメッセージ案を提案する。
- `git diff` / `git status` の内容から、変更内容を簡潔に説明するコミットメッセージ案を作成する。
- 危険なファイルが含まれている場合は、それを警告として明記し、除外を提案する。

## チェック用コマンド

```bash
# 危険なファイルが含まれていないか確認
git status --porcelain | grep -E '\.env|\.pem|\.key|id_rsa|id_ed25519|credentials\.json|secrets\.json|\.DS_Store|Thumbs\.db|desktop\.ini|^\?\? \._|\.idea/|\.vscode/settings\.json|\.swp$|\.swo$|~$'
```

## 適用手順（出力の最後に必ず付ける）

メインエージェントがユーザー承認後に実行するためのコマンドを、次の形式で明記する。

```bash
# ステージング（対象を明示。危険ファイルは含めない）
git add <対象ファイル>

# コミット
git commit -m "<コミットメッセージ案>"
```

## 注意事項

- チェックで何も出力されなければ、提案どおりコミットして問題ない。
- 出力があった場合は、そのファイルをコミット対象から除外するか、`.gitignore` への追加を提案する。
- このスキル自身は add / commit を実行しない。適用はメインエージェントがユーザー承認後に行う。
