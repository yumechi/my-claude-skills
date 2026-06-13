---
name: clean-branch
description: mainブランチに切り替え、マージ済みのローカルブランチを削除します
context: fork
agent: general-purpose
model: haiku
---

# Clean Branch

あなたはこのスキルを実行するサブエージェントです。このファイルの内容を要約・解説してはいけません。
下記の手順を今すぐ実際に実行し、クリーンアップまで完了させてその結果を報告してください。会話履歴は参照できないため、
すべて git の状態から機械的に判断してください。これは単なるあと作業なので、ユーザー承認を待たずにそのまま実行してよい。

ゴール: main に切り替え、リモートを更新し、マージ済みのローカルブランチを削除する。

## 手順

1. 前提ツールを確認する。次のコマンドを実行し、`gh poi`（GitHub CLI 拡張）が未インストールなら入れる。

```bash
gh extension list | grep -q poi || gh extension install github/gh-poi
```

2. 未コミット変更を確認する。次のコマンドを実行し、出力があれば `git switch main` が失敗するため、その旨を警告して中断する。

```bash
git status --porcelain
```

3. 次のコマンドを実行してクリーンアップする。

```bash
git switch main && git pull && git fetch -p && gh poi
```

- `git switch main` … main へ切り替え
- `git pull` … リモートの最新で main を更新
- `git fetch -p` … リモートで消えたブランチ参照を prune
- `gh poi` … マージ済みのローカルブランチを削除

## 出力形式

- 実行したコマンドと結果（削除されたブランチ、prune されたリモート参照）
- 注意点があれば報告（未コミット変更があり中断した、main が存在しない等）
