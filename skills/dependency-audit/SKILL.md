---
name: dependency-audit
description: 依存パッケージの脆弱性とサプライチェーンセキュリティをチェックします
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

| パッケージマネージャ | コマンド |
|---|---|
| npm | `npm audit` |
| yarn (v1) | `yarn audit` |
| pnpm | `pnpm audit` |
| Python (pip-audit) | `pip-audit` |
| Ruby (bundler) | `bundle audit check --update` |
| Go | `govulncheck ./...` |
| Rust | `cargo audit` |
| PHP (composer) | `composer audit` |
| Java/Kotlin (Maven) | `mvn dependency-check:check` |

### 3. サプライチェーンセキュリティの強化状況チェック

脆弱性チェックに加え、サプライチェーン攻撃を防ぐための設定が適切に行われているか確認します。
このスキルのディレクトリにあるスクリプトを実行してください。

OS を判定し、適切なスクリプトを実行してください。

Linux / macOS の場合:

```bash
bash <SKILL_DIR>/scripts/check-supply-chain.sh
```

Windows の場合:

```powershell
powershell -ExecutionPolicy Bypass -File <SKILL_DIR>/scripts/check-supply-chain.ps1
```

`<SKILL_DIR>` はこの SKILL.md が配置されているディレクトリのパスに置き換えること。

チェック内容:
- npm ignore-scripts: `.npmrc` に `ignore-scripts=true` が設定されているか
- CI ロックファイル固定: `--frozen-lockfile` / `--frozen` / `npm ci` が使用されているか
- minimumReleaseAge / cooldown: pnpm-workspace.yaml, renovate.json, .github/dependabot.yml, pyproject.toml で新規リリースの即時採用を回避しているか（Dependabot は `cooldown.default-days`、Renovate は `minimumReleaseAge`）
- pnpm trustPolicy: pnpm-workspace.yaml に `trustPolicy: no-downgrade` が設定されているか（パッケージの信頼レベルダウングレードを検出）
- GitHub Actions SHA ピンニング: Actions がコミット SHA で固定されているか（`pinact` が利用可能なら自動修正を実行）

#### Dependabot と Renovate の共存検出時の対応

スクリプトが `WARNING: dependabot.yml と renovate.json が両方存在します` を出力した場合、Claude は以下のフローで統一を促す。

1. ユーザーに統一方向を確認する（デフォルトは Dependabot への統一）
   - 推奨: Dependabot に統一（`renovate.json` を削除）
   - 代替: Renovate に統一（`.github/dependabot.yml` を削除）

2. Dependabot に統一する場合の設定変換

   | Renovate (renovate.json) | Dependabot (.github/dependabot.yml) |
   |---|---|
   | `manager`（npm / pip / github-actions 等） | `package-ecosystem` |
   | `schedule`（例: `["every weekend"]`） | `schedule.interval`（daily / weekly / monthly） |
   | `minimumReleaseAge`（例: `"7 days"`） | `cooldown.default-days: 7` |
   | `packageRules[].groupName` | `groups[].<groupName>` |

   変換後、次のファイルを削除する:
   - `renovate.json`
   - `.github/renovate.json` / `.github/renovate.json5` / `renovate.json5` / `.renovaterc*`（存在する場合のみ）

3. Renovate に統一する場合は上表の逆方向で変換し、`.github/dependabot.yml`（または `.yaml`）を削除する

4. 変換できない項目は手動対応を促す
   - Renovate 固有: `regexManagers`、細粒度 `packageRules`、`packageRules[].matchPackagePatterns` など
   - Dependabot 固有: `insecure-external-code-execution`、`reviewers` / `assignees` など

### 4. 結果のサマリ表示

各チェックの結果を以下の形式で整理して表示します。

```
## 脆弱性サマリ

| 言語 | Critical | High | Medium | Low | 合計 |
|---|---|---|---|---|---|
| Node.js | 0 | 2 | 5 | 3 | 10 |
| Python | 0 | 0 | 1 | 0 | 1 |
| 合計 | 0 | 2 | 6 | 3 | 11 |

## サプライチェーンセキュリティ

| チェック項目 | 状態 |
|---|---|
| ignore-scripts | OK / WARNING |
| CI ロックファイル固定 | OK / WARNING |
| minimumReleaseAge | OK / WARNING / N/A |
| pnpm trustPolicy | OK / WARNING / N/A |
| Actions SHA ピンニング | OK / WARNING |
```

- Critical / High の脆弱性がある場合は、該当パッケージ名とバージョン、推奨される修正アクションを表示する
- サプライチェーンセキュリティの WARNING 項目がある場合は、具体的な修正手順を表示する
- audit ツールがインストールされていない場合は、インストール方法を案内する

## 注意事項

- 複数の言語・パッケージマネージャが混在するプロジェクトでは、検出されたすべてについてチェックを実行する
- audit ツールの出力フォーマットはバージョンによって異なる場合がある
- `npm audit` は `--audit-level` オプションで重要度のフィルタが可能
- ネットワーク接続が必要（脆弱性データベースへの問い合わせ）
- `ignore-scripts=true` を設定した場合、`postinstall` スクリプトに依存するパッケージは別途手動でセットアップが必要な場合がある
- `pinact` による SHA ピンニング後は、Dependabot や Renovate で Actions の自動更新を設定することを推奨する
