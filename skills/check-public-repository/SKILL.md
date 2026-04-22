---
name: check-public-repository
description: リポジトリを公開する前に、機密情報や不適切なデータが含まれていないかチェックします
---

# リポジトリ公開前チェック

このスキルはリポジトリを公開する前に、以下の項目を確認します。

## チェック項目

### 1. 必須ファイルの存在確認
- [ ] `README.md` が存在すること
- [ ] `LICENSE` または `LICENCE` ファイルが存在すること
- [ ] `.gitignore` が存在すること

### 2. 機密情報のチェック
以下のパターンがリポジトリに含まれていないことを確認してください。

#### 鍵・認証情報
- [ ] 秘密鍵ファイル（`*.pem`, `*.key`, `id_rsa`, `id_ed25519` など）
- [ ] AWS アクセスキー（`AKIA` で始まる文字列）
- [ ] API キー・トークン（`api_key`, `apikey`, `access_token`, `secret_key` など）
- [ ] GitHub トークン（`ghp_`, `gho_`, `ghu_` で始まる文字列）
- [ ] Slack トークン（`xoxb-`, `xoxp-` で始まる文字列）
- [ ] Google API キー（`AIza` で始まる文字列）
- [ ] JWT トークン（`eyJ` で始まる長い文字列）
- [ ] データベース接続文字列（`mongodb://`, `postgres://`, `mysql://` など）

#### .env ファイル
- [ ] `.env` ファイルがコミットされていないこと
- [ ] `.env.local`, `.env.production` などの環境ファイルがコミットされていないこと
- [ ] `.env.example` や `.env.sample` に実際の認証情報が含まれていないこと

#### パスワード
- [ ] ハードコードされたパスワード（`password =`, `passwd =`, `pwd =` など）

#### 個人的な環境パス
- [ ] `/Users/<username>/` のような個人のホームディレクトリパス
- [ ] `/home/<username>/` のような個人のホームディレクトリパス
- [ ] `C:\Users\<username>\` のような Windows の個人パス

#### メールアドレス
- [ ] ダミー以外の実際のメールアドレス（`example.com`, `example.org` ドメイン以外）
- [ ] 個人のメールアドレス

#### その他の個人情報
- [ ] 電話番号
- [ ] 住所
- [ ] クレジットカード番号のようなパターン
- [ ] マイナンバーのようなパターン

### 3. 不要ファイルのチェック

#### OS 生成ファイル
- [ ] `.DS_Store`（macOS）
- [ ] `Thumbs.db`（Windows）
- [ ] `desktop.ini`（Windows）
- [ ] `._*` ファイル（macOS リソースフォーク）

#### IDE・エディタ設定ファイル
- [ ] `.idea/`（JetBrains 系 IDE）
- [ ] `.vscode/settings.json`（VS Code の個人設定）
- [ ] `*.swp`, `*.swo`（Vim スワップファイル）
- [ ] `*~`（バックアップファイル）
- [ ] `.project`, `.classpath`（Eclipse）

### 4. サプライチェーンセキュリティのチェック

依存パッケージやCI環境を通じたサプライチェーン攻撃を防ぐための設定を確認します。

#### npm スクリプト実行の制限
- [ ] `.npmrc` に `ignore-scripts=true` が設定されていること（Node.js プロジェクトの場合）

#### CI でのロックファイル固定
- [ ] CI ワークフローで `--frozen-lockfile`（pnpm/yarn）または `--frozen`（uv）が使用されていること
- [ ] `npm ci`（npm の場合）が `npm install` の代わりに使用されていること

#### 新規リリースの即時採用回避
- [ ] `pnpm-workspace.yaml` に `minimumReleaseAge` が設定されていること（pnpm プロジェクトの場合）
- [ ] `renovate.json` に `minimumReleaseAge` が設定されていること（Renovate 使用の場合）
- [ ] `pyproject.toml` の `[tool.uv]` セクションに `exclude-newer` が設定されていること（uv 使用の場合）
- [ ] Dependabot を使用している場合、自動マージを即座に行わない運用であること

#### pnpm trustPolicy（信頼レベルのダウングレード検出）
- [ ] `pnpm-workspace.yaml` に `trustPolicy: no-downgrade` が設定されていること（pnpm プロジェクトの場合）
- [ ] 信頼レベルが低下したパッケージがある場合、`trustPolicyExclude` で明示的に許可リストを管理すること

#### GitHub Actions のバージョン固定（SHA ピンニング）
- [ ] GitHub Actions のバージョン指定がタグ（`v4`）ではなくコミット SHA で固定されていること
- [ ] `pinact` がインストールされている環境では、`pinact run` を実行して自動的に SHA ピンニングを適用すること

## チェック手順

1. このスキルのディレクトリにある `scripts/` 内のスクリプトをプロジェクトルートで実行する
2. 検出された問題をレポートし、修正を提案する

### スクリプトの実行

OS を判定し、適切なスクリプトを実行してください。

Linux / macOS の場合:

機密情報・不要ファイルのチェック:

```bash
bash <SKILL_DIR>/scripts/check-secrets.sh
```

サプライチェーンセキュリティのチェック:

```bash
bash <SKILL_DIR>/scripts/check-supply-chain.sh
```

Windows の場合:

機密情報・不要ファイルのチェック:

```powershell
powershell -ExecutionPolicy Bypass -File <SKILL_DIR>/scripts/check-secrets.ps1
```

サプライチェーンセキュリティのチェック:

```powershell
powershell -ExecutionPolicy Bypass -File <SKILL_DIR>/scripts/check-supply-chain.ps1
```

`<SKILL_DIR>` はこの SKILL.md が配置されているディレクトリのパスに置き換えること。

## 注意事項

- `.gitignore` に含まれているファイルはチェック対象外ですが、誤ってコミットされていないか確認してください
- 偽陽性（false positive）が発生する場合があります。検出結果を手動で確認してください
- このチェックは完全ではありません。公開前に必ず手動でも確認してください
- `ignore-scripts=true` を設定した場合、`postinstall` スクリプトに依存するパッケージ（例: `esbuild`, `sharp`）は別途手動でセットアップが必要な場合があります
- `pinact` による SHA ピンニングは、Dependabot や Renovate の Actions 自動更新と組み合わせて運用することを推奨します
