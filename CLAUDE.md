## コミュニケーション言語

このプロジェクトでは日本語でコミュニケーションを取ります。日本語を利用できない場合のみ英語でコミュニケーションします。

## 記述スタイル

スキル・コマンド・ドキュメント等のファイル内では、以下の装飾を使用しないこと。トークンの無駄になるため、強調が必要な場合も通常のテキストで記述する。

- bold 表記（`**...**`）
- 絵文字

## プロジェクトの目的

個人的によく使う Claude Code / Cursor のスキル（カスタムスラッシュコマンド）をまとめて管理するリポジトリです。PC のグローバル領域に配置することで、プロジェクトごとに毎回セットアップする手間を省きます。

## 利用技術

- Claude Code（スキル機能 / コマンド機能）

## プロジェクト構成

ディレクトリ構成の詳細は [docs/project-structure.md](docs/project-structure.md) を参照。

## スキルのモデル割り当て

コスト削減のため、各スキルは `context: fork` で独立サブエージェントとして実行し、処理の性質に応じた安いモデルを `model:` で指定しています。メインエージェントのモデル・コンテキストには影響しません。詳細な設計は [docs/skill-model-policy.md](./docs/skill-model-policy.md) を参照してください。

| スキル | model |
|---|---|
| `clean-branch` / `todo-scan` / `create-pr` / `add-gitignore` / `quickcommit` | `haiku` |
| `dependency-audit` / `check-public-repository` / `update-docs` | `opus[1m]` |

- 今後追加するスキルのデフォルトは `sonnet[1m]`。タスクの性質に応じて調整する。
- 書き込み前にユーザー確認が必要なスキル（add-gitignore / quickcommit / update-docs）は、fork されたサブエージェントが「提案」を返し、メインエージェントが承認後に適用する。

## グローバルへのコピー

`skills/` および `commands/` の内容を `~/.claude/` 配下にコピーします。

```bash
# bash
./copy.sh

# PowerShell
.\copy.ps1
```
