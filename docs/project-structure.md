# プロジェクト構成

```
my-claude-skills/
├── skills/                            # グローバル配置用スキル（コピー元）
│   ├── add-gitignore/                 #   .gitignore 生成・更新
│   │   └── SKILL.md
│   ├── check-public-repository/       #   リポジトリ公開前の機密情報チェック
│   │   ├── SKILL.md
│   │   └── scripts/
│   │       ├── check-secrets.sh       #     機密情報・不要ファイル検出
│   │       └── check-supply-chain.sh  #     サプライチェーンセキュリティ検証
│   ├── clean-branch/                  #   マージ済みブランチの整理
│   │   └── SKILL.md
│   ├── create-pr/                     #   リモート push & PR 作成
│   │   └── SKILL.md
│   ├── dependency-audit/              #   依存パッケージ脆弱性チェック
│   │   ├── SKILL.md
│   │   └── scripts/
│   │       └── check-supply-chain.sh  #     サプライチェーンセキュリティ検証
│   ├── quickcommit/                   #   安全な git add & commit
│   │   └── SKILL.md
│   ├── todo-scan/                     #   TODO/FIXME スキャン
│   │   └── SKILL.md
│   └── update-docs/                   #   CLAUDE.md / README.md 更新
│       └── SKILL.md
├── commands/                          # グローバル配置用コマンド（コピー元、将来用）
│   └── .keep
├── docs/                              # ドキュメント
│   └── project-structure.md           #   ディレクトリ構成の詳細
├── copy.sh                            # コピースクリプト (bash)
├── copy.ps1                           # コピースクリプト (PowerShell)
├── .claude/                           # このリポジトリ自体の Claude Code 設定
├── .cursor/                           # このリポジトリ自体の Cursor 設定
├── AGENTS.md
├── CLAUDE.md
├── README.md
├── LICENSE
├── .editorconfig
└── .gitignore
```

## グローバルへのコピー

`skills/` および `commands/` の内容を `~/.claude/` 配下にコピーします。

```bash
# bash
./copy.sh

# PowerShell
.\copy.ps1
```
