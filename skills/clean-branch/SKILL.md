---
name: clean-branch
description: mainブランチに切り替え、マージ済みのローカルブランチを削除します
context: fork
agent: general-purpose
model: haiku
---

# Clean Branch

あなたはこのスキルを実行するサブエージェントです。このファイルの内容を要約・解説してはいけません。
下記の手順を今すぐ実際に実行し、その結果に基づいた提案を返してください。会話履歴は参照できないため、
すべて git の状態から機械的に判断してください。最終的にメインエージェントがユーザー承認後にクリーンアップを行います。

ゴール: main に切り替え、リモートを更新し、マージ済みのローカルブランチを削除する提案を作る。

## 手順

1. 前提ツールを確認する。次のコマンドを実行し、`gh poi`（GitHub CLI 拡張）が未インストールなら入れる。

```bash
gh extension list | grep -q poi || gh extension install github/gh-poi
```

2. 未コミット変更を確認する。次のコマンドを実行し、出力があれば `git switch main` が失敗するため、その旨を警告して中断する。

```bash
git status --porcelain
```

3. ここまでの実際の出力をもとに、削除対象を提案として報告する。承認後に実行されるコマンドは次の1本。

```bash
git switch main && git pull && git fetch -p && gh poi
```

- `git switch main` … main へ切り替え
- `git pull` … リモートの最新で main を更新
- `git fetch -p` … リモートで消えたブランチ参照を prune
- `gh poi` … マージ済みのローカルブランチを削除

## 出力形式

- 実行予定のコマンド（上記の連結コマンド）
- 削除されうるブランチや注意点（未コミット変更がある、main が存在しない等）

ユーザー承認後、メインエージェントが上記の連結コマンドをそのまま実行する。
