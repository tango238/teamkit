---
description: Generate acceptance test cases from specifications
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir>
---

# Setup

1.  **Set `commandName`**: `generate-acceptance-test`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/teamkit:generate-acceptance-test <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated acceptance test must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---

## Mission

Read `usecase.yml` and `ui.yml` under `.teamkit/{{specDir}}`, and generate comprehensive acceptance test cases in Markdown format. The test cases should enable QA engineers and stakeholders to verify that the system meets all specified requirements.

**IMPORTANT**: Execute the following steps immediately without asking the user for confirmation.

---

## Execution Steps

### 1. Pre-check

- **Target Files**:
  - `{{baseDir}}/{{specDir}}/usecase.yml`
  - `{{baseDir}}/{{specDir}}/ui.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Validation**:
  - If any of these files do not exist → Display "エラー: 必要なファイルが存在しません。先に /teamkit:generate コマンドを実行してください。" and **STOP**.

### 2. Check Status (Direct Read - No SlashCommand)

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Extract `version` from the `ui` step in the `steps` array
3. Set this as `{{targetVersion}}`
4. Check if `acceptance_test` entry exists in `steps`:
   - If it exists, extract `version` as `{{currentVersion}}`
   - If it does not exist, set `{{currentVersion}}` to `0`
5. **Validation**:
   - If `{{currentVersion}}` >= `{{targetVersion}}` → Display "スキップ: acceptance_test は既に最新です (version {{currentVersion}})" and **STOP**
   - Otherwise → Continue execution

### 3. Load Context

Read the following files and understand their content:
- `{{baseDir}}/{{specDir}}/usecase.yml` - Use case definitions (test scenario basis)
- `{{baseDir}}/{{specDir}}/ui.yml` - Screen definitions (view object map with sections, input_fields, actions, data_table)
- `{{baseDir}}/{{specDir}}/README.md` - Original requirements (acceptance criteria basis)

### 4. Generate Acceptance Test Cases

Generate the test cases following the structure and rules below.

#### Output Structure

```markdown
# 【Feature Name】受入テスト項目

## テスト概要

### 対象機能
[README.md から抽出した機能名と概要]

### テスト範囲
[テスト対象のユースケース一覧]

### 前提条件
[全テスト共通の前提条件]

---

## テストケース一覧

### 正常系テスト

#### TC-001: 【ユースケース名】- 基本フロー

| 項目 | 内容 |
|------|------|
| **テストID** | TC-001 |
| **ユースケース** | [usecase.yml のユースケース名] |
| **テスト区分** | 正常系 |
| **優先度** | 高/中/低 |

**前提条件**:
- [usecase.yml の before から抽出]

**操作手順**:

| # | 画面 | 操作 | 入力データ |
|---|------|------|------------|
| 1 | 画面名 | 操作内容 | テストデータ例 |
| 2 | 画面名 | 操作内容 | テストデータ例 |
| 3 | 画面名 | ボタンをクリック | - |

**期待結果**:
- [usecase.yml の after から抽出]
- [画面遷移の確認]
- [データの保存確認]

**確認ポイント**:
- [ ] [具体的な確認項目1]
- [ ] [具体的な確認項目2]
- [ ] [具体的な確認項目3]

---

### バリデーションテスト

#### TC-NNN: 【画面名】- 必須項目チェック

| 項目 | 内容 |
|------|------|
| **テストID** | TC-NNN |
| **対象画面** | [ui.yml の view の title] |
| **テスト区分** | バリデーション |
| **優先度** | 高 |

**操作手順**:

| # | 操作 | 入力データ |
|---|------|------------|
| 1 | 必須項目を空のまま送信 | (空) |

**期待結果**:
- 必須エラーメッセージが表示される
- 画面遷移しない

**確認ポイント**:
- [ ] [必須フィールド名] にエラーが表示される
- [ ] 他の入力値が保持される

---

### 画面遷移テスト

#### TC-NNN: 【遷移名】

| 項目 | 内容 |
|------|------|
| **テストID** | TC-NNN |
| **テスト区分** | 画面遷移 |
| **優先度** | 中 |

**操作手順**:

| # | 操作 | 期待する遷移先 |
|---|------|----------------|
| 1 | [ボタン名]をクリック | [遷移先画面名] |

**期待結果**:
- [遷移先画面名] が表示される

---

## テストサマリー

| テスト区分 | テストケース数 | 優先度高 | 優先度中 | 優先度低 |
|------------|---------------|----------|----------|----------|
| 正常系 | N | N | N | N |
| バリデーション | N | N | N | N |
| 画面遷移 | N | N | N | N |
| **合計** | **N** | **N** | **N** | **N** |
```

#### Generation Rules

1. **ユースケースベース**: `usecase.yml` の各ユースケースに対して最低1つの正常系テストケースを作成
2. **バリデーションテスト**: `ui.yml` の各 view > `sections` > `input_fields` 内の `required: true` フィールドおよびバリデーションルールに対してテストケースを作成
3. **画面遷移テスト**: `ui.yml` の各 view > structured `actions`（`id`, `type`, `label`, `style`, `to`）から主要な画面遷移をテストケースとして作成
4. **テストデータ**: 具体的なテストデータ例を記載（ドメインに即したリアルなデータ）
5. **優先度の付与**:
   - **高**: 主要なユースケースの正常系、必須項目バリデーション
   - **中**: 副次的なユースケース、画面遷移
   - **低**: エッジケース、オプション項目のバリデーション
6. **確認ポイント**: チェックリスト形式（`- [ ]`）で具体的に記載
7. **テストID**: TC-001 から連番で付与、カテゴリをまたいで一意にする
8. **異常系の網羅**:
   - 必須項目の未入力
   - 文字数上限超過（`sections` > `input_fields` のバリデーションに記載がある場合）
   - 不正な入力形式（数値フィールドに文字列など）
   - 選択肢の未選択（`type: select`, `type: radio_group` で `options: [{value, label}]` 形式のフィールド）

### 5. Save File

- Output destination: `{{baseDir}}/{{specDir}}/acceptance-test.md`
- If file exists, delete and regenerate completely
- Save automatically without asking user

### 6. Update Status (Direct Write - No SlashCommand)

1. Get the MD5 checksum of the saved file: `md5 -q {{baseDir}}/{{specDir}}/acceptance-test.md`
2. Get current timestamp in ISO format: `date -u +"%Y-%m-%dT%H:%M:%S"`
3. Read `{{baseDir}}/{{specDir}}/status.json`
4. Check if `acceptance_test` entry exists in `steps`:
   - If not, add a new entry: `{ "acceptance_test": { "version": 0, "checksum": "", "last_modified": "" } }` to the `steps` array
5. Update the `acceptance_test` step with:
   - `version`: Set to `{{targetVersion}}` (from Step 2)
   - `checksum`: Set to the MD5 hash obtained
   - `last_modified`: Set to the timestamp obtained
6. Update `last_execution`: Set to `generate-acceptance-test`
7. Update `updated_at`: Set to current timestamp
8. Save the modified `status.json`

---

## Quality Checklist

- [ ] All use cases from `usecase.yml` have at least one normal-case test
- [ ] All required fields from `ui.yml` views' `sections` > `input_fields` have validation tests
- [ ] All major screen transitions have test cases
- [ ] Test data examples are realistic and domain-appropriate
- [ ] All test cases have clear expected results
- [ ] Confirmation points are specific and checkable
- [ ] Test IDs are sequential and unique
- [ ] Test summary counts are accurate
- [ ] All content is in Japanese
