---
name: create-pr
description: 現在のブランチをリモートに push し、GitHub PR を作成します
context: fork
agent: general-purpose
model: haiku
---

# Create PR

現在のブランチをリモートにプッシュし、GitHub CLI で Pull Request を作成します。

> このスキルは独立したサブエージェントとして自律実行されます。会話履歴は参照できないため、
> すべての判断は git の状態から機械的に行います。判断に迷う状況（未コミット変更がある等）では
> 推測せず中断してレポートします。

## 実行手順

### 1. 現在の状態を確認

```bash
git status --porcelain
git branch --show-current
git log --oneline origin/main..HEAD
```

判定ルール:

- `git status --porcelain` に出力がある（未コミットの変更がある）場合 → 何もせず中断し、未コミット変更の一覧を報告して終了する。
- `git log --oneline origin/main..HEAD` が空（origin/main との差分コミットがない）場合 → PR にする変更がないため終了する。

### 2. main ブランチの場合は作業ブランチを作成

現在のブランチが `main` で、かつ origin/main より先のコミットがある場合のみ実行する。

ブランチ名は以下のルールで機械的に生成する:

1. 先頭コミット（`git log origin/main..HEAD --reverse --format=%s | head -1`）の件名をもとにする
2. 英小文字・数字・ハイフンのスラッグに変換する（日本語など変換できない場合は `work-<短いハッシュ>` を使う。短いハッシュは `git rev-parse --short HEAD`）

```bash
# 作業ブランチを作成（現在のコミットを引き継ぐ）
git switch -c <ブランチ名>

# main を origin/main に戻す
git branch -f main origin/main
```

main 以外のブランチにいる場合は、そのブランチをそのまま使う。

### 3. リモートにプッシュ

```bash
git push -u origin HEAD
```

### 4. PR を作成

差分コミットから PR のタイトル・本文を機械的に生成する。

- タイトル: 70 文字以内。
  - コミットが 1 件の場合はその件名をそのまま使う。
  - コミットが複数件の場合は、変更内容を端的にまとめた件名を 1 行で作る。
- 本文: 以下の形式でコミット一覧から生成する。

```markdown
## 変更概要

<差分全体の 1〜2 行の要約>

## コミット

- <コミット1 の件名>
- <コミット2 の件名>
```

```bash
gh pr create --base main --title "PRタイトル" --body "PR本文"
```

既に同じブランチの PR が存在する場合は、新規作成せず `gh pr view --json url` で既存 PR の URL を取得する。

### 5. 結果を報告

作成（または既存）の PR の URL を報告する。

## 注意事項

- `gh` コマンド（GitHub CLI）がインストール・認証済みであること
- ベースブランチは常に `main`
