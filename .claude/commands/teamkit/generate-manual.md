---
description: Generate user manual from specifications
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir>
---

# Setup

1.  **Set `commandName`**: `generate-manual`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/teamkit:generate-manual <specDir>`" and **STOP** execution immediately.

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

### 4. Generate Manual

Generate the manual following the structure and rules below.

#### Output Structure

```markdown
# 【Feature Name】操作マニュアル

## 目次
- [1. 概要](#1-概要)
- [2. 画面一覧](#2-画面一覧)
- [3. 操作手順](#3-操作手順)
- [4. 入力ルール](#4-入力ルール)
- [5. 画面遷移](#5-画面遷移)
- [6. 注意事項](#6-注意事項)

## 1. 概要

### 1.1 機能の目的
[README.md から抽出した機能の目的・背景]

### 1.2 対象ユーザー
[usecase.yml の actor 情報から抽出]

| ロール | 説明 |
|--------|------|
| ロール名 | そのロールの責務 |

## 2. 画面一覧

### 2.1 【アクター名】向け画面

| # | 画面名 | 用途 | 主な操作 |
|---|--------|------|----------|
| 1 | 画面名 | 目的 | アクション一覧 |

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

### 5. Save File

- Output destination: `{{baseDir}}/{{specDir}}/manual.md`
- If file exists, delete and regenerate completely
- Save automatically without asking user

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
