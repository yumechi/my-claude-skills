---
name: create-pr
description: 現在のブランチをリモートに push し、GitHub PR を作成します
---

# Create PR

現在のブランチをリモートにプッシュし、GitHub CLI で Pull Request を作成します。

## 実行手順

### 1. 現在の状態を確認

```bash
git status
git branch --show-current
git log --oneline origin/main..HEAD
```

- 未コミットの変更がないことを確認する
- 未コミットの変更がある場合はユーザーに確認を取る
- origin/main からの差分コミットを確認し、PR のタイトル・本文の材料にする

### 2. main ブランチの場合はブランチを作成

現在 main ブランチにいて、かつ origin/main より先のコミットがある場合：

1. ユーザーにブランチ名を提案する（コミット内容から推測）
2. 新しいブランチを作成してコミットを移動する

```bash
# 新しいブランチを作成（現在のコミットを引き継ぐ）
git checkout -b <ブランチ名>

# main を origin/main に戻す
git branch -f main origin/main
```

origin/main との差分コミットがない場合は、PR にする変更がないため終了する。

### 3. リモートにプッシュ

```bash
git push -u origin HEAD
```

### 4. PR を作成

`gh pr create` で PR を作成する。

- タイトルは 70 文字以内で簡潔にまとめる
- 本文にはコミット内容をもとに変更の概要を記載する
- ベースブランチは main とする

```bash
gh pr create --base main --title "PRタイトル" --body "PR本文"
```

### 5. 結果を表示

作成された PR の URL をユーザーに表示する。

## 注意事項

- `gh` コマンド（GitHub CLI）がインストール・認証済みであること
- 既に同じブランチの PR が存在する場合は `gh pr view` で既存の PR を表示する
