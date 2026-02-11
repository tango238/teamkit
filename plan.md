# Plan: `generate` コマンド新設と `create-mock` 簡略化

## 概要

READMEから一気に全成果物を生成する `generate` コマンドを新設し、既存の `create-mock` を単純化する。

---

## 変更対象ファイル

### 新規作成

| # | ファイル | 説明 |
|---|---------|------|
| 1 | `.claude/commands/teamkit/generate.md` | 新オーケストレーションコマンド |
| 2 | `.claude/commands/teamkit/generate-manual.md` | マニュアル生成コマンド |
| 3 | `.claude/commands/teamkit/generate-acceptance-test.md` | 受入テスト項目生成コマンド |

### 変更

| # | ファイル | 説明 |
|---|---------|------|
| 4 | `.claude/commands/teamkit/create-mock.md` | ui.yml + screenflow.md からモック生成のみに簡略化 |
| 5 | `README.md` | コマンド説明の更新 |
| 6 | `docs/commands.html` | コマンド一覧ドキュメント更新 |

---

## 1. `generate` コマンド（新規）

### 概要
READMEから全ステップを一気通貫で実行するオーケストレーションコマンド。現在の `create-mock` のパイプラインに加えて、オプションでマニュアルと受入テスト項目の生成が可能。

### 使い方
```
/teamkit:generate <specDir>                    # 基本パイプライン（モックまで）
/teamkit:generate <specDir> --manual           # + マニュアル生成
/teamkit:generate <specDir> --test             # + 受入テスト項目生成
/teamkit:generate <specDir> --all              # + マニュアル + 受入テスト
```

### 実行パイプライン
```
Step 0: generate-workflow  (workflow.yml がなければ)
Step 1: generate-usecase   (usecase.yml)
Step 2: generate-ui        (ui.yml)
Step 3: generate-screenflow (screenflow.md)
Step 4: generate-mock      (mock/*.html)
--- ここまで基本パイプライン ---
Step 5: generate-manual           (--manual or --all 時)
Step 6: generate-acceptance-test  (--test or --all 時)
```

### 実装方針
- 現在の `create-mock.md` の構造（Sequential Execution Model）をベースにする
- オプション解析をSetupセクションに追加
- 基本パイプラインは現行 `create-mock` と同一
- Step 5, 6 はオプションフラグに応じて条件実行

---

## 2. `generate-manual` コマンド（新規）

### 概要
usecase.yml、ui.yml、screenflow.md からユーザー向け操作マニュアルを生成する。

### 入力
- `usecase.yml` - ユースケース定義（操作手順の根拠）
- `ui.yml` - 画面定義（画面名、フィールド説明）
- `screenflow.md` - 画面遷移図（操作フロー）

### 出力
- `.teamkit/<specDir>/manual.md` - Markdown形式の操作マニュアル

### マニュアル構成（案）
```markdown
# 【機能名】操作マニュアル

## 目次

## 1. 概要
- 機能の目的
- 対象ユーザー

## 2. 画面一覧
- 各画面の概要説明

## 3. 操作手順
### 3.1 【ユースケース名】
- 前提条件
- 操作手順（番号付きステップ）
  - 画面名、操作内容、入力項目、注意事項
- 完了条件

## 4. 入力ルール
- バリデーション一覧

## 5. 画面遷移
- フローの概要
```

### ステータス管理
- `status.json` の `steps` に `manual` エントリを追加
- バージョン管理は既存ステップと同じ仕組み

---

## 3. `generate-acceptance-test` コマンド（新規）

### 概要
usecase.yml、ui.yml からシナリオベースの受入テスト項目を生成する。

### 入力
- `usecase.yml` - ユースケース定義（テストシナリオの根拠）
- `ui.yml` - 画面定義（入力項目、バリデーション）

### 出力
- `.teamkit/<specDir>/acceptance-test.md` - Markdown形式の受入テスト項目

### テスト項目構成（案）
```markdown
# 【機能名】受入テスト項目

## テスト概要
- テスト対象機能
- 前提条件

## テストケース

### TC-001: 【ユースケース名】- 正常系
- **前提条件**: ...
- **操作手順**:
  1. 〇〇画面を開く
  2. △△を入力する
  3. 登録ボタンを押す
- **期待結果**: ...
- **確認ポイント**: ...

### TC-002: 【ユースケース名】- 異常系（バリデーション）
- ...

### TC-003: 画面遷移テスト
- ...
```

### ステータス管理
- `status.json` の `steps` に `acceptance_test` エントリを追加

---

## 4. `create-mock` 簡略化

### 現在の動作
workflow → usecase → ui → screenflow → mock の全パイプラインを実行（= `generate` に移行）

### 変更後の動作
ui.yml と screenflow.md が既に存在する前提で、モックHTML生成のみを実行。

```
前提: ui.yml, screenflow.md が存在すること
Step 1: generate-mock を呼び出し
```

- パイプライン全体は `generate` コマンドに委譲
- `create-mock` は screenflow.md が存在しない場合に `generate-screenflow` も呼ぶ（フォールバック）
- SlashCommand の呼び出しを最小限に

---

## 5. README.md 更新

- `generate` コマンドを基本フローに追加
- `create-mock` の説明を簡略版に変更
- ワークフロー例を更新

---

## 6. docs/commands.html 更新

- `generate` コマンドをオーケストレーションセクションに追加
- `generate-manual` と `generate-acceptance-test` をコア生成パイプラインに追加
- `create-mock` の説明を更新

---

## 実装順序

1. `generate-manual.md` 作成
2. `generate-acceptance-test.md` 作成
3. `generate.md` 作成
4. `create-mock.md` 簡略化
5. `README.md` 更新
6. `docs/commands.html` 更新
