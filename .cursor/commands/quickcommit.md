# Quick Commit

変更をステージングしてコミットする前に、コミットすべきでないファイルが含まれていないかチェックします。

## 実行手順

1. `git status` で変更ファイルを確認
2. 以下のファイルが含まれていないかチェック：
   - 環境ファイル（`.env`, `.env.local`, `.env.production` など）
   - 秘密鍵（`*.pem`, `*.key`, `id_rsa`, `id_ed25519`）
   - 認証情報（`credentials.json`, `secrets.json`）
   - OS 生成ファイル（`.DS_Store`, `Thumbs.db`, `desktop.ini`）
   - IDE 設定（`.idea/`, `.vscode/settings.json`, `*.swp`）
3. 問題がなければ `git add .` と `git commit` を実行

## チェックコマンド

```bash
git status --porcelain | grep -E '\.env|\.pem|\.key|id_rsa|id_ed25519|credentials\.json|secrets\.json|\.DS_Store|Thumbs\.db|desktop\.ini|^\?\? \._|\.idea/|\.vscode/settings\.json|\.swp$|\.swo$|~$'
```

上記コマンドで何も出力されなければ、コミットして問題ありません。
