# my-claude-skills

> Note: これは個人用のスキル管理リポジトリです。

個人的によく使う Claude Code のスキル・コマンドをまとめて管理するリポジトリです。`copy.sh` / `copy.ps1` でグローバル領域（`~/.claude/`）にコピーすることで、プロジェクトごとに毎回セットアップする手間を省きます。

## 開発環境

2026/01/27 現在、個人で Cursor と Claude Code を使って開発しています。

## 収録スキル

| スキル名 | 説明 |
|---|---|
| `check-public-repository` | リポジトリを公開する前に、機密情報や不適切なデータが含まれていないかチェックします |
| `clean-branch` | main ブランチに切り替え、マージ済みのローカルブランチを削除します |
| `quickcommit` | git status を確認し、コミットすべきでないファイルが含まれていないかチェックしてから add & commit を実行します |

## セットアップ

```bash
git clone <repository-url> ~/work/settings/my-claude-skills
```

## グローバルへのコピー

`skills/` および `commands/` の内容を `~/.claude/` 配下にコピーします。

```bash
# bash (Linux / macOS)
./copy.sh

# PowerShell (Windows)
.\copy.ps1
```

## ディレクトリ構成

| ディレクトリ | 用途 |
|---|---|
| `skills/` | グローバルにコピーするスキル（コピー元） |
| `commands/` | グローバルにコピーするコマンド（コピー元、将来用） |
| `.claude/` | このリポジトリ自体の Claude Code 設定 |
| `.cursor/` | このリポジトリ自体の Cursor 設定 |

## ライセンス

[LICENSE](./LICENSE) を参照してください。
