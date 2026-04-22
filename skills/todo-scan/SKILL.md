---
name: todo-scan
description: コードベース内の TODO/FIXME コメントをスキャンして一覧表示します
---

# TODO Scan

コードベース内の TODO、FIXME などのコメントを検索し、カテゴリ別に整理して表示します。

## 実行手順

### 1. 検索対象パターン

以下のキーワードを含むコメントを検索します。

| キーワード | 意味 |
|---|---|
| `TODO` | 未実装・あとで対応する項目 |
| `FIXME` | 既知のバグ・修正が必要な箇所 |
| `HACK` | 一時的な回避策・きれいでない実装 |
| `XXX` | 危険な箇所・要注意の実装 |
| `WARN` | 警告・注意が必要な箇所 |
| `NOTE` | 補足説明・メモ |

### 2. 検索の実行

```bash
grep -rn --include='*' -E '\b(TODO|FIXME|HACK|XXX|WARN|NOTE)\b' . \
  --exclude-dir=node_modules \
  --exclude-dir=vendor \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=build \
  --exclude-dir=__pycache__ \
  --exclude-dir=.next \
  --exclude-dir=.nuxt \
  --exclude-dir=target \
  --exclude-dir=.venv \
  --exclude-dir=venv \
  --exclude-dir=coverage \
  --exclude='*.min.js' \
  --exclude='*.min.css' \
  --exclude='*.map' \
  --exclude='package-lock.json' \
  --exclude='yarn.lock' \
  --exclude='pnpm-lock.yaml' \
  --exclude='composer.lock' \
  --exclude='Cargo.lock'
```

### 3. 結果の整理

検索結果をカテゴリ別に分類して表示します。

```
## TODO/FIXME スキャン結果

### サマリ

| カテゴリ | 件数 |
|---|---|
| TODO | 12 |
| FIXME | 3 |
| HACK | 1 |
| XXX | 0 |
| WARN | 0 |
| NOTE | 5 |
| 合計 | 21 |

### TODO (12件)

- `src/api/client.ts:42` - TODO: エラーハンドリングを追加
- `src/utils/date.ts:15` - TODO: タイムゾーン対応
- ...

### FIXME (3件)

- `src/components/Form.tsx:88` - FIXME: バリデーションが効かない
- ...

### HACK (1件)

- `src/lib/auth.ts:23` - HACK: 一時的にハードコード
- ...

### NOTE (5件)

- `src/config.ts:10` - NOTE: 本番環境では変更が必要
- ...
```

## 注意事項

- `.gitignore` で無視されるディレクトリ（`node_modules`, `vendor` 等）は検索対象外
- ミニファイされたファイル（`*.min.js`, `*.min.css`）やロックファイルは除外
- 大規模プロジェクトでは結果が多くなる場合がある。その場合は FIXME と TODO を優先的に表示する
- 結果はファイルパスと行番号付きで表示し、該当箇所にすぐアクセスできるようにする
