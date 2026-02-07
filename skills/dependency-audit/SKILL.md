---
name: dependency-audit
description: 依存パッケージの脆弱性をチェックします
---

# Dependency Audit

プロジェクトの依存パッケージに既知の脆弱性がないかチェックします。

## 実行手順

### 1. パッケージマネージャの検出

プロジェクトルートに存在するファイルから、使用されている言語・パッケージマネージャを自動検出します。

| ファイル | 言語 | パッケージマネージャ |
|---|---|---|
| `package-lock.json` | Node.js | npm |
| `yarn.lock` | Node.js | yarn |
| `pnpm-lock.yaml` | Node.js | pnpm |
| `package.json`（lockfile なし） | Node.js | npm（デフォルト） |
| `requirements.txt` / `Pipfile` / `pyproject.toml` | Python | pip-audit / safety |
| `Gemfile` / `Gemfile.lock` | Ruby | bundler-audit |
| `go.mod` | Go | govulncheck |
| `Cargo.toml` / `Cargo.lock` | Rust | cargo-audit |
| `composer.json` / `composer.lock` | PHP | composer |
| `pom.xml` | Java/Kotlin | Maven |
| `build.gradle` / `build.gradle.kts` | Java/Kotlin | Gradle |

```bash
ls package-lock.json yarn.lock pnpm-lock.yaml package.json requirements.txt Pipfile pyproject.toml Gemfile go.mod Cargo.toml composer.json pom.xml build.gradle build.gradle.kts 2>/dev/null
```

### 2. 検出結果に応じた audit コマンドの実行

検出されたパッケージマネージャごとに、以下のコマンドを実行します。

#### Node.js

```bash
# npm
npm audit

# yarn (v1)
yarn audit

# pnpm
pnpm audit
```

#### Python

```bash
# pip-audit（推奨）
pip-audit

# safety
safety check
```

#### Ruby

```bash
bundle audit check --update
```

#### Go

```bash
govulncheck ./...
```

#### Rust

```bash
cargo audit
```

#### PHP

```bash
composer audit
```

#### Java/Kotlin (Maven)

```bash
mvn dependency-check:check
```

### 3. 結果のサマリ表示

各 audit コマンドの結果を以下の形式で整理して表示します。

```
## 脆弱性サマリ

| 言語 | Critical | High | Medium | Low | 合計 |
|---|---|---|---|---|---|
| Node.js | 0 | 2 | 5 | 3 | 10 |
| Python | 0 | 0 | 1 | 0 | 1 |
| 合計 | 0 | 2 | 6 | 3 | 11 |
```

- Critical / High の脆弱性がある場合は、該当パッケージ名とバージョン、推奨される修正アクションを表示する
- audit ツールがインストールされていない場合は、インストール方法を案内する

## 注意事項

- 複数の言語・パッケージマネージャが混在するプロジェクトでは、検出されたすべてについてチェックを実行する
- audit ツールの出力フォーマットはバージョンによって異なる場合がある
- `npm audit` は `--audit-level` オプションで重要度のフィルタが可能
- ネットワーク接続が必要（脆弱性データベースへの問い合わせ）
