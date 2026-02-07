## コミュニケーション言語

このプロジェクトでは日本語でコミュニケーションを取ります。日本語を利用できない場合のみ英語でコミュニケーションします。

## プロジェクトの目的

個人的によく使う Claude Code / Cursor のスキル（カスタムスラッシュコマンド）をまとめて管理するリポジトリです。PC のグローバル領域に配置することで、プロジェクトごとに毎回セットアップする手間を省きます。

## 利用技術

- Claude Code（スキル機能 / コマンド機能）

## プロジェクト構成

```
my-claude-skills/
├── skills/                            # グローバル配置用スキル（デプロイ元）
│   ├── check-public-repository/       #   リポジトリ公開前の機密情報チェック
│   │   └── SKILL.md
│   └── quickcommit/                   #   安全な git add & commit
│       └── SKILL.md
├── commands/                          # グローバル配置用コマンド（デプロイ元、将来用）
│   └── .keep
├── deploy.sh                          # デプロイスクリプト (bash)
├── deploy.ps1                         # デプロイスクリプト (PowerShell)
├── .claude/                           # このリポジトリ自体の Claude Code 設定
├── .cursor/                           # このリポジトリ自体の Cursor 設定
├── AGENTS.md
├── CLAUDE.md
├── README.md
├── LICENSE
├── .editorconfig
└── .gitignore
```

## デプロイ

`skills/` および `commands/` の内容を `~/.claude/` 配下にコピーします。

```bash
# bash
./deploy.sh

# PowerShell
.\deploy.ps1
```
