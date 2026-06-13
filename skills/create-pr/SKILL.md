---
name: create-pr
description: 現在のブランチをリモートに push し、GitHub PR を作成します
context: fork
agent: general-purpose
model: haiku
---

# Create PR

あなたは今から、現在のブランチをリモートに push して GitHub PR を作成する。
これは分析タスクではなく実行タスクである。以下のコマンドを上から順に実行すること。
判断に迷う状況（未コミット変更がある等）では推測せず中断して報告する。

## 手順

1. 状態を確認する。

```bash
git status --porcelain
git branch --show-current
git log --oneline origin/main..HEAD
```

- `git status --porcelain` に出力がある場合 → 未コミット変更の一覧を報告して中断。
- `git log origin/main..HEAD` が空の場合 → PR にする差分がないので終了。

2. main ブランチにいて差分コミットがある場合のみ、作業ブランチに移す。
   ブランチ名は先頭コミットの件名を英小文字・数字・ハイフンのスラッグにする。日本語など変換できない場合は `work-$(git rev-parse --short HEAD)` を使う。

```bash
git switch -c <ブランチ名> && git branch -f main origin/main
```

main 以外のブランチにいる場合はそのまま使う。

3. リモートに push する。

```bash
git push -u origin HEAD
```

4. 差分コミットからタイトル・本文を生成して PR を作成する。
   タイトルは 70 文字以内（コミット 1 件ならその件名、複数件なら要約した 1 行）。本文は以下の形式。

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

同じブランチの PR が既にある場合は新規作成せず `gh pr view --json url` で URL を取得する。

5. 作成（または既存）の PR の URL を報告する。

## 注意事項

- `gh`（GitHub CLI）がインストール・認証済みであること
- ベースブランチは常に `main`
