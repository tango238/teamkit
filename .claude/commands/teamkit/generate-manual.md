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

Read `usecase.yml`, `ui.yml`, and `screenflow.md` under `.teamkit/{{specDir}}`, and generate a comprehensive user operation manual in **Marp-compatible Markdown format**. The manual should enable end users to understand and operate all features of the system, and can be directly converted to A4-sized HTML/PDF via Marp CLI.

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

Generate the manual in **Marp-compatible Markdown format** following the structure and rules below.

#### 4-1. Marp Front Matter

The file MUST begin with the following Marp front matter. Replace `【Feature Name】` with the actual feature name extracted from `README.md`.

```markdown
---
marp: true
theme: default
size: A4
paginate: true
header: "【Feature Name】操作マニュアル"
footer: ""
style: |
  section {
    font-family: "Hiragino Kaku Gothic ProN", "Noto Sans JP", "Meiryo", sans-serif;
    font-size: 16px;
    padding: 40px;
  }
  h1 {
    font-size: 28px;
    color: #333;
    border-bottom: 2px solid #007bff;
    padding-bottom: 10px;
  }
  h2 {
    font-size: 22px;
    color: #007bff;
  }
  h3 {
    font-size: 18px;
    color: #555;
  }
  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }
  th {
    background: #007bff;
    color: white;
    padding: 8px 12px;
    text-align: left;
  }
  td {
    border: 1px solid #dee2e6;
    padding: 8px 12px;
  }
  tr:nth-child(even) {
    background: #f8f9fa;
  }
  header {
    font-size: 12px;
    color: #999;
  }
  footer {
    font-size: 10px;
    color: #999;
  }
---
```

#### 4-2. Slide Structure Rules

1. **Title Slide** (first slide): Create from the feature name
   ```markdown
   # 【Feature Name】操作マニュアル

   **Version**: 1.0
   **Date**: {{current date in YYYY-MM-DD}}
   ```

2. **Table of Contents Slide**: Insert `---` separator, then the table of contents

3. **Section Separators**: Insert Marp slide separators (`---`) at each `## heading` boundary
   - Each `## heading` starts a new slide
   - If a section is too long (contains multiple `### headings`), split it into multiple slides at each `### heading`

4. **Long Content Handling**:
   - If a single section has more than 30 lines of content, split it across multiple slides
   - Add a continuation marker like "（続き）" in the heading for continuation slides

5. **Tables**: Write tables in standard Markdown format (Marp renders them natively)

#### 4-3. Content Structure

The manual content across slides should cover the following sections:

```
Slide: Title
Slide: 目次
Slide(s): 1. 概要 (機能の目的, 対象ユーザー)
Slide(s): 2. 画面一覧 (アクター別)
Slide(s): 3. 操作手順 (ユースケースごと)
Slide(s): 4. 入力ルール (バリデーション一覧, 共通ルール)
Slide(s): 5. 画面遷移 (メインフロー, 遷移表)
Slide(s): 6. 注意事項
```

**Section details:**

**1. 概要**
- 1.1 機能の目的: Extract from `README.md`
- 1.2 対象ユーザー: Extract actor info from `usecase.yml`
  | ロール | 説明 |
  |--------|------|

**2. 画面一覧** (grouped by actor)
  | # | 画面名 | 用途 | 主な操作 |
  |---|--------|------|----------|

**3. 操作手順** (one or more slides per use case)
- **前提条件**: from `usecase.yml` `before`
- **操作手順**: numbered steps with screen names, input fields table, button actions
  | 項目名 | 必須 | 入力形式 | 説明 |
  |--------|------|----------|------|
- **完了条件**: from `usecase.yml` `after`

**4. 入力ルール**
- バリデーション一覧 table
  | 画面名 | 項目名 | ルール | エラー時の動作 |
  |--------|--------|--------|----------------|
- 共通ルール from `ui.yml` validations

**5. 画面遷移**
- メインフロー summary from `screenflow.md`
- 遷移表
  | 操作 | 遷移元 | 遷移先 | 条件 |
  |------|--------|--------|------|

**6. 注意事項**
- Business-level notes and constraints

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

1. Get the MD5 checksum of the saved file: `md5sum {{baseDir}}/{{specDir}}/manual.md | awk '{print $1}'`
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
- [ ] Marp front matter includes `marp: true` and `size: A4`
- [ ] Slide separators (`---`) are placed at `##` heading boundaries
- [ ] Long sections are split across multiple slides with "（続き）" markers
