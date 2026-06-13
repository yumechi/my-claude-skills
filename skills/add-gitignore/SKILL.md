---
name: add-gitignore
description: プロジェクトの技術スタックを検出し、.gitignore を生成・更新します
context: fork
agent: general-purpose
model: haiku
---

# Add .gitignore

プロジェクトの技術スタックを自動検出し、適切な `.gitignore` を生成または更新します。

> このスキルは独立したサブエージェントとして実行されます。ファイルは書き込まず、
> 検出結果と `.gitignore` の生成・追記案を「提案」として返します。実際の書き込みは、
> 提案を受け取ったメインエージェントがユーザーの承認を得てから行います。
> 出力の最後に必ず「## 適用手順」セクションを付けてください。

## 実行手順

### 1. 技術スタックの検出

プロジェクトルートのファイルを確認し、使用されている言語・フレームワークを検出します。

```bash
ls -a
```

| 検出ファイル | 技術スタック |
|---|---|
| `package.json` | Node.js |
| `next.config.*` | Next.js |
| `nuxt.config.*` | Nuxt.js |
| `requirements.txt` / `pyproject.toml` / `Pipfile` | Python |
| `Gemfile` | Ruby |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `composer.json` | PHP |
| `pom.xml` / `build.gradle` | Java/Kotlin |
| `*.sln` / `*.csproj` | .NET / C# |
| `Dockerfile` | Docker |
| `terraform/` / `*.tf` | Terraform |

### 2. .gitignore の生成・更新

#### .gitignore が存在しない場合

検出結果をもとに `.gitignore` を新規生成します。以下の構成で作成します。

```gitignore
# ===========================
# OS 生成ファイル
# ===========================
.DS_Store
Thumbs.db
desktop.ini
._*

# ===========================
# IDE・エディタ
# ===========================
.idea/
.vscode/
*.swp
*.swo
*~

# ===========================
# 環境ファイル
# ===========================
.env
.env.*
!.env.example

# ===========================
# 言語・フレームワーク固有
# ===========================
# （検出結果に応じて追加）
```

#### .gitignore が既に存在する場合

既存の `.gitignore` を読み取り、不足しているパターンを特定して追記を提案します。

1. 既存の `.gitignore` の内容を確認
2. 検出された技術スタックに必要なパターンと比較
3. 不足パターンを特定
4. 追記案を提案として返す（書き込まない）

### 3. 共通パターン（常に含める）

#### OS 生成ファイル
- `.DS_Store` (macOS)
- `Thumbs.db` (Windows)
- `desktop.ini` (Windows)
- `._*` (macOS リソースフォーク)

#### IDE・エディタ設定
- `.idea/` (JetBrains)
- `.vscode/` (VS Code)
- `*.swp`, `*.swo` (Vim)
- `*~` (バックアップファイル)

#### 環境ファイル
- `.env`
- `.env.*`（`.env.example` は除外しない）

### 4. 言語・フレームワーク固有パターン

#### Node.js
```gitignore
node_modules/
dist/
build/
.next/
.nuxt/
*.tsbuildinfo
```

#### Python
```gitignore
__pycache__/
*.py[cod]
*.egg-info/
.venv/
venv/
.pytest_cache/
.mypy_cache/
```

#### Ruby
```gitignore
vendor/bundle/
.bundle/
*.gem
```

#### Go
```gitignore
/vendor/
*.exe
*.test
*.out
```

#### Rust
```gitignore
/target/
Cargo.lock  # ライブラリの場合のみ
```

#### PHP
```gitignore
/vendor/
*.cache
```

#### Java/Kotlin
```gitignore
/target/
/build/
*.class
*.jar
*.war
```

#### Docker
```gitignore
.docker/
```

#### Terraform
```gitignore
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
!*.tfvars.example
```

## 適用手順（出力の最後に必ず付ける）

メインエージェントがユーザー承認後に適用するための情報を、次の形式で明記する。

- 対象ファイル: `<書き込み先のパス（例: ./.gitignore）>`
- 操作: 新規作成 / 追記
- 書き込む内容: 新規作成なら全文、追記なら追記するブロックをコードブロックで提示

## 注意事項

- `.env.example` など、テンプレートファイルは除外対象から外す（`!` パターン）
- `Cargo.lock` はアプリケーションの場合はコミットし、ライブラリの場合は除外する。判断が難しい場合は両案を提案に併記する
- 既存の `.gitignore` を上書きせず、不足分のみ追記提案する
- このスキル自身はファイルを書き込まない。適用はメインエージェントがユーザー承認後に行う
