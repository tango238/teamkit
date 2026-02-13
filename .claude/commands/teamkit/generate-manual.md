---
description: Generate user manual from specifications
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, mcp__playwright__browser_navigate, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_close, mcp__playwright__browser_resize
argument-hint: <specDir> [--capture]
---

# Setup

1.  **Set `commandName`**: `generate-manual`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command (the argument that does NOT start with `--` or `-`).
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/teamkit:generate-manual <specDir> [--capture]`" and **STOP** execution immediately.
4.  **Get `captureScreenshots`**: Check if `--capture` or `-c` argument is provided.
    -   If provided, set `captureScreenshots` to `true`
    -   Otherwise, set `captureScreenshots` to `false`

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated manual must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---

## Mission

Read `usecase.yml`, `ui.yml`, and `screenflow.md` under `.teamkit/{{specDir}}`, and generate a comprehensive user operation manual in Markdown format. The manual should enable end users to understand and operate all features of the system.

**IMPORTANT**: Execute the following steps immediately without asking the user for confirmation.

---

## Execution Steps

### 1. Pre-check

- **Target Files**:
  - `{{baseDir}}/{{specDir}}/usecase.yml`
  - `{{baseDir}}/{{specDir}}/ui.yml`
  - `{{baseDir}}/{{specDir}}/screenflow.md`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Validation**:
  - If any of these files do not exist → Display "エラー: 必要なファイルが存在しません。先に /teamkit:generate コマンドを実行してください。" and **STOP**.

### 2. Check Status (Direct Read - No SlashCommand)

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Extract `version` from the `screenflow` step in the `steps` array
3. Set this as `{{targetVersion}}`
4. Check if `manual` entry exists in `steps`:
   - If it exists, extract `version` as `{{currentVersion}}`
   - If it does not exist, set `{{currentVersion}}` to `0`
5. **Validation**:
   - If `{{currentVersion}}` >= `{{targetVersion}}` → Display "スキップ: manual は既に最新です (version {{currentVersion}})" and **STOP**
   - Otherwise → Continue execution

### 3. Load Context

Read the following files and understand their content:
- `{{baseDir}}/{{specDir}}/usecase.yml` - Use case definitions (operation procedures)
- `{{baseDir}}/{{specDir}}/ui.yml` - Screen definitions (screen names, fields, actions)
- `{{baseDir}}/{{specDir}}/screenflow.md` - Screen flow diagrams (operation flow)
- `{{baseDir}}/{{specDir}}/README.md` - Original requirements (feature overview)

### 3.5. Capture Mock Screenshots (conditional)

**Only execute this step if `captureScreenshots` is `true`.** If `captureScreenshots` is `false`, skip entirely to Step 4.

#### Pre-check

1. Verify `{{baseDir}}/{{specDir}}/mock/screens.yml` exists
2. Verify at least one `.html` file exists in `{{baseDir}}/{{specDir}}/mock/`
3. If either check fails → Display "警告: モックファイルが見つかりません。スクリーンショットのキャプチャをスキップします。" and set `captureScreenshots` to `false`, then skip to Step 4.

#### Capture Process

1. Create the screenshots directory via Bash: `mkdir -p {{baseDir}}/{{specDir}}/mock/screenshots`
2. Read `{{baseDir}}/{{specDir}}/mock/screens.yml` and extract all screen IDs (lines matching `- [x] screen_id` or `- [ ] screen_id`)
3. Start a local HTTP server to serve mock HTML files (Playwright MCP blocks `file://` protocol):
   - Via Bash (run in background): `cd {{baseDir}}/{{specDir}}/mock && python3 -m http.server 18923 &`
   - Store the server PID for cleanup
   - Wait 1 second for the server to start
4. Resize browser viewport to 1280x800 via `mcp__playwright__browser_resize`
5. For each screen ID:
   a. Navigate to the mock HTML file via `mcp__playwright__browser_navigate` with URL: `http://localhost:18923/{screen_id}.html`
   b. Take a screenshot via `mcp__playwright__browser_take_screenshot` with:
      - `filename`: `{{baseDir}}/{{specDir}}/mock/screenshots/{screen_id}.png`
      - `type`: `png`
   c. Record the mapping: screen_id → `mock/screenshots/{screen_id}.png`
6. Close the browser via `mcp__playwright__browser_close`
7. Stop the HTTP server via Bash: `kill <server_pid>`
8. Store the screenshot mapping for use in Step 4

### 4. Generate Manual

Generate the manual following the structure and rules below.

#### Output Structure

```markdown
---
marp: true
theme: A4-Manual
paginate: true
---

# 【Feature Name】操作マニュアル

---

<!-- class: content -->

## 目次
- [1. 概要](#1-概要)
- [2. 操作ガイド](#2-操作ガイド)
- [3. 操作手順](#3-操作手順)
- [4. 入力ルール](#4-入力ルール)
- [5. 画面遷移](#5-画面遷移)
- [6. 注意事項](#6-注意事項)

---

## 1. 概要

### 1.1 機能の目的
[README.md から抽出した機能の目的・背景]

### 1.2 対象ユーザー
[usecase.yml の actor 情報から抽出]

| ロール | 説明 |
|--------|------|
| ロール名 | そのロールの責務 |

## 2. 操作ガイド

### 2.1 全体の流れ

[screenflow.md のメインフローと usecase.yml を元に、システムをどのような流れで使うのかを自然な文章で説明する。各ステップに**画面名**を含め、ユーザーがシステム全体の使い方を俯瞰できるようにする。番号付きリストで、主要な操作を順に記述する。]

例:
1. **タスクを確認する** — 「タスク一覧」画面で登録済みのタスクをステータス・担当者・優先度で絞り込み、進捗を確認します。
2. **タスクを登録する** — 「タスク一覧」画面の「新規作成」から「タスク登録・編集」画面を開き、タイトル・担当者・期限などを入力して保存します。
3. **タスクを編集する** — 「タスク一覧」画面で対象タスクの「編集」をクリックし、「タスク登録・編集」画面で内容を修正して保存します。
4. **タスクを削除する** — 「タスク一覧」画面で「削除」をクリックし、「タスク削除確認」画面で内容を確認してから削除します。

---

### 2.2 管理する情報

[usecase.yml の entity と ui.yml の input_fields/display_fields を元に、このシステムで扱う情報の概要を表にまとめる。]

| 情報 | 内容 | 主な操作画面 |
|------|------|-------------|
| エンティティ名 | 管理する情報の概要（どのような項目を持つか） | 関連する画面名 |

---

### 2.3 画面一覧

[ui.yml の全画面と usecase.yml の各ユースケースを統合し、各画面の用途・操作・画面遷移の流れを1つのテーブルにまとめる。アクター別にサブセクション（### 2.3 【アクター名】向け画面一覧）を設ける。]

| # | 画面名 | 用途 | 主な操作 | 画面の流れ |
|---|--------|------|----------|-----------|
| 1 | 画面名 | 目的 | アクション一覧 | 画面A → 画面B → 画面A |

## 3. 操作手順

### 3.1 【ユースケース名】

**前提条件**: [usecase.yml の before]

**操作手順**:

1. **【画面名】を開く**
   - [画面へのアクセス方法]

2. **【操作内容】**
   - 入力項目:
     | 項目名 | 必須 | 入力形式 | 説明 |
     |--------|------|----------|------|
     | フィールド名 | ○/- | text/select等 | バリデーション含む説明 |
   - 注意事項: [特記事項があれば]

3. **【ボタン操作】**
   - [ボタン名]をクリック → [遷移先・結果]

**完了条件**: [usecase.yml の after]

---

[上記パターンを全ユースケースについて繰り返す]

## 4. 入力ルール

### 4.1 バリデーション一覧

| 画面名 | 項目名 | ルール | エラー時の動作 |
|--------|--------|--------|----------------|
| 画面名 | フィールド名 | バリデーション内容 | エラーメッセージ等 |

### 4.2 共通ルール
[ui.yml の validations セクションから抽出]

## 5. 画面遷移

### 5.1 メインフロー
[screenflow.md の主要フローを簡潔に記述]

### 5.2 主要な画面遷移

| 操作 | 遷移元 | 遷移先 | 条件 |
|------|--------|--------|------|
| ボタン名 | 画面A | 画面B | 条件があれば |

## 6. 注意事項
[業務上の注意点、制約事項など]
```

#### Generation Rules

1. **ユースケースベース**: `usecase.yml` の各ユースケースを操作手順の単位とする
2. **画面情報の反映**: `ui.yml` の `input_fields`, `display_fields`, `actions` を操作手順に反映
3. **遷移情報の反映**: `screenflow.md` のフロー図を画面遷移セクションに反映
4. **必須項目の明示**: `required: true` のフィールドは操作手順で明確に示す
5. **バリデーションの記載**: `ui.yml` の `validation` を入力ルールセクションに集約
6. **アクター別の整理**: 複数のアクターがいる場合はアクター別にセクションを分ける
7. **具体的な記述**: 抽象的な表現を避け、具体的な操作手順として記述する
8. **改ページの挿入**: 以下の箇所に Marp のページ区切り（`---`）を必ず挿入する
   - **タイトル（`# 【Feature Name】操作マニュアル`）** の直後
   - **目次** の直後（`## 1. 概要` の直前）
   - **`## 2. 操作ガイド`** の直前
   - **`### 2.2 管理する情報`** の直前
   - **`### 2.3 画面一覧`** の直前
   - **各画面キャプチャ（スクリーンショット画像）** の直前
9. **ページレイアウト**: テーマ `A4-Manual` を使用する。共有テーマファイル `.teamkit/themes/A4-Manual.css` を利用する（specDir 内にローカル CSS を生成しない）
   - 1ページ目（タイトル）: 縦中央寄せ（デフォルト）
   - 2ページ目以降: 縦上寄せ。タイトルの後の改ページの直後に `<!-- class: content -->` を挿入する（グローバルディレクティブで以降全スライドに適用される）
   - `<style>` タグによるインラインスタイルは使用しない（テーマ CSS に集約する）
10. **操作ガイドの生成**: Section 2 は以下のルールに従って生成する
   - **2.1 全体の流れ**: `screenflow.md` のメインフローと `usecase.yml` のユースケースを元に、システムの使い方の全体像を番号付きリストで記述する。各項目に必ず「画面名」を含め、どの画面で何をするのかが一目でわかるようにする。操作手順 (Section 3) の詳細に入る前の俯瞰的な説明として機能すること。
   - **2.2 管理する情報**: `usecase.yml` の entity と `ui.yml` の `input_fields`/`display_fields` を元に、システムで扱う情報（エンティティ）をテーブルにまとめる。情報ごとにどのような項目を持ち、どの画面で操作できるかを記載する。
   - **2.3 画面一覧**: `ui.yml` の全画面と `usecase.yml` の各ユースケースを統合し、1つのテーブルにまとめる。各画面の用途・主な操作・画面の流れ（画面A → 画面B の形式）を含める。アクターが複数いる場合はアクター別にサブセクションを設ける。スクリーンショットがある場合はテーブルの後に各画面のスクリーンショットを配置する。

#### Screenshot Embedding Rules (only when `captureScreenshots` is `true`)

When `captureScreenshots` is `true` and screenshots were captured in Step 3.5:

1. **Section 2.3 画面一覧**: After each screen entry in the table, add a page break (`---`) followed by the screen name (bold), main operations, and a screenshot for each screen:
   ```markdown
   ---

   **{画面名}**
   主な操作: {主な操作（テーブルの「主な操作」列の内容）}

   ![{画面名} w:560](mock/screenshots/{screen_id}.png)
   ```

2. **Section 3. 操作手順**: スクリーンショットは埋め込まない。画面キャプチャは Section 2.3 にのみ配置する。

3. **Marp image syntax**: Always use `w:560` directive for half-width display on A4 slides:
   ```markdown
   ![{alt_text} w:560](mock/screenshots/{screen_id}.png)
   ```

4. **Path**: Use relative paths from the manual.md location: `mock/screenshots/{screen_id}.png`

### 5. Save File

- Output destination: `{{baseDir}}/{{specDir}}/manual.md`
- If file exists, delete and regenerate completely
- Save automatically without asking user

### 5.5. Convert to PDF using shared A4-Manual theme

1. Convert manual.md to PDF via Bash using the shared theme file:
```bash
npx --yes @marp-team/marp-cli {{baseDir}}/{{specDir}}/manual.md --pdf --allow-local-files --html --theme-set {{baseDir}}/themes/A4-Manual.css -o {{baseDir}}/{{specDir}}/manual.pdf
```

2. Verify PDF was generated: check that `{{baseDir}}/{{specDir}}/manual.pdf` exists

### 6. Update Status (Direct Write - No SlashCommand)

1. Get the MD5 checksum of the saved file: `md5 -q {{baseDir}}/{{specDir}}/manual.md`
2. Get current timestamp in ISO format: `date -u +"%Y-%m-%dT%H:%M:%S"`
3. Read `{{baseDir}}/{{specDir}}/status.json`
4. Check if `manual` entry exists in `steps`:
   - If not, add a new entry: `{ "manual": { "version": 0, "checksum": "", "last_modified": "" } }` to the `steps` array
5. Update the `manual` step with:
   - `version`: Set to `{{targetVersion}}` (from Step 2)
   - `checksum`: Set to the MD5 hash obtained
   - `last_modified`: Set to the timestamp obtained
6. Update `last_execution`: Set to `generate-manual`
7. Update `updated_at`: Set to current timestamp
8. Save the modified `status.json`

---

## Quality Checklist

- [ ] All use cases from `usecase.yml` are covered in operation procedures
- [ ] All screens from `ui.yml` appear in the screen list
- [ ] All input fields with their types and validation rules are documented
- [ ] Screen transitions match `screenflow.md`
- [ ] Required fields are clearly marked
- [ ] Manual is written in Japanese
- [ ] Instructions are specific and actionable (not vague)
- [ ] (If `--capture`) All mock screens have corresponding screenshots in `mock/screenshots/`
- [ ] (If `--capture`) Screenshots are embedded in Section 2.3 画面一覧 with screen name, main operations, and Marp `w:560` syntax
- [ ] (If `--capture`) Section 3 操作手順 does NOT contain screenshots
