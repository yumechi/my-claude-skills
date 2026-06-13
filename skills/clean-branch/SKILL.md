---
name: clean-branch
description: mainブランチに切り替え、マージ済みのローカルブランチを削除します
context: fork
agent: general-purpose
model: haiku
---

# Clean Branch

main に切り替え、リモートを更新し、マージ済みのローカルブランチを削除します。

このスキルは独立したサブエージェントとして実行されます。状態を確認したうえで提案を返し、
メインエージェントがユーザー承認後に実際のクリーンアップを行います。会話履歴は参照できないため、
すべて git の状態から機械的に判断してください。

## 手順

1. 前提ツールを確認する。`gh poi`（GitHub CLI 拡張）が未インストールなら入れる。

```bash
gh extension list | grep -q poi || gh extension install github/gh-poi
```

2. 未コミット変更を確認する。出力があれば `git switch main` が失敗するため、その旨を警告して中断する。

```bash
git status --porcelain
```

3. 削除対象を提案として報告する。実行されるコマンドは次の1本。

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
