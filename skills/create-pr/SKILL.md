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
git log --oneline main..HEAD
```

- 未コミットの変更がないことを確認する
- 未コミットの変更がある場合はユーザーに確認を取る
- main からの差分コミットを確認し、PR のタイトル・本文の材料にする

### 2. リモートにプッシュ

```bash
git push -u origin HEAD
```

### 3. PR を作成

`gh pr create` で PR を作成する。

- タイトルは 70 文字以内で簡潔にまとめる
- 本文にはコミット内容をもとに変更の概要を記載する
- ベースブランチは main とする

```bash
gh pr create --base main --title "PRタイトル" --body "PR本文"
```

### 4. 結果を表示

作成された PR の URL をユーザーに表示する。

## 注意事項

- `gh` コマンド（GitHub CLI）がインストール・認証済みであること
- ブランチが main の場合は PR を作成せず警告する
- 既に同じブランチの PR が存在する場合は `gh pr view` で既存の PR を表示する
