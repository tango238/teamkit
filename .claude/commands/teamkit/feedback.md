---
description: Generate feedback document
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Glob
argument-hint: <specDir> <comment> [-p|--preview]
---

# Setup

1.  **Set `commandName`**: `feedback`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: both `specDir` argument and `comment` argument are required. Usage: `/feedback <specDir> <comment> [-p|--preview]`" and **STOP** execution immediately.
4.  **Get `comment`**: Read the second argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: both `specDir` argument and `comment` argument are required. Usage: `/feedback <specDir> <comment> [-p|--preview]`" and **STOP** execution immediately.
5.  **Check for preview mode**: Check if `-p` or `--preview` option is passed as any argument.
    -   If found, set `previewMode` to `true`.
    -   If not found, set `previewMode` to `false`.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated markdown file (`feedback.md`) must be in **Japanese**.
-   Do not ask for user confirmation before saving files. Execute immediately without asking the user.
-   **Preview mode behavior**:
    -   If `previewMode` is `true`:
        -   Save the file with TODO items marked as `[p]` (preview flag) instead of `[ ]`.
        -   Generate preview mock HTML files for affected screens only (see Step 6).
    -   If `previewMode` is `false`: Save the file with TODO items marked as `[ ]` (normal unchecked state).

---

## Mission

Analyze the user's feedback comment and generate a structured feedback document that:
1. Records the original comment
2. Identifies specific issues and impacts across all specification files
3. Provides actionable TODO items
4. Documents next actions with detailed notes for each affected specification layer

## Execution Steps

### 1. Check arguments
Verify that both `specDir` and `comment` arguments are provided. If either is missing, display the error message and stop.

### 2. Pre-check
- Check if `{{baseDir}}/{{specDir}}/status.json` exists
- If the file does not exist, display an error message and stop execution

### 3. Understand & Think
- Understand the feedback content provided in the `comment` argument
- Consider the impact on functionality and UI/UX
- Think about next actions and approaches to address the feedback

### 4. Generate Preview Mock (Preview Mode Only)
**Skip this step if `previewMode` is `false`.**

If `previewMode` is `true`, generate preview mock HTML files for the affected screens first, so the user can visually confirm the changes:

1. **Identify affected screens**: Based on the feedback comment, identify which screens in `screenflow.md` and `ui.yml` are likely affected.

2. **Read status.json**: Read `{{baseDir}}/{{specDir}}/status.json` and get the current `mock` version number.

3. **Generate mock files**: For each affected screen:
   - Apply the feedback content to the screen
   - Overwrite the existing mock file to: `{{baseDir}}/{{specDir}}/mock/{{screen_name}}.html`

4. **Update status.json**: Update the `mock` version number as preview version (e.g. `v1-preview`) in `{{baseDir}}/{{specDir}}/status.json`.

5. **Output**: Display the list of updated mock files to the user.

### 5. Verify Impact
Verify the impact on each specification file in the following order (each step should consider the impact from the previous step):
1. Verify impact on `screenflow.md`
2. Considering the impact from step 1, verify impact on `ui.yml`
3. Considering the impact from step 2, verify impact on `usecase.yml`
4. Considering the impact from step 3, verify impact on `workflow.yml`

### 6. Generate Feedback Document
Based on the verification results, write out the issues and next actions:

1. Check if a feedback file already exists at `{{baseDir}}/{{specDir}}/feedback.md`
2. Generate the content following the format specified in the "Output Format" section below
3. **TODO marker based on mode**:
   - If `previewMode` is `true`: Use `[p]` for TODO items (preview flag)
   - If `previewMode` is `false`: Use `[ ]` for TODO items (normal unchecked state)
4. **Verify TODO duplication and consolidate** (see "TODO Consolidation Rules" section below)
5. Save the file:
   - If the file exists, append new content to the `Comment`, `TODO`, and `Summary` sections
   - If the file does not exist, create a new file

**IMPORTANT**: All content must be written in **Japanese**.

### 7. TODO Consolidation Rules

Before finalizing the TODO list, verify that there are no duplicate or overlapping items:

#### Principle: One Feedback = One TODO
- **1つのフィードバックコメントに対して、原則として1つのTODO項目を作成する**
- 複数のレイヤー（workflow, usecase, ui, screenflow）に影響がある場合でも、それらは1つのTODO項目のNext actionセクション内で記述する
- TODO項目を「レイヤーごと」や「ファイルごと」に分割しない

#### Duplication Check
TODO項目を作成する前に、以下の重複パターンをチェックする：

1. **同一修正内容の重複**: 異なるTODO項目が同じファイルの同じ箇所を修正しようとしている
2. **包含関係の重複**: あるTODO項目の修正内容が、別のTODO項目の修正内容に完全に含まれている
3. **レイヤー分割の重複**: 1つの論理的な変更を、レイヤーごとに別々のTODO項目として分割している

#### Consolidation Process
重複が検出された場合：
1. 重複するTODO項目を1つに統合する
2. 統合後のTODO項目名は、変更の本質を表す簡潔な名前にする
3. Next actionセクションに、全ての影響レイヤーへの変更内容を記載する

#### Bad Example (重複あり - NG)
```markdown
# TODO
- [ ] 1. パスワードリセット画面から本人確認機能を削除
- [ ] 2. 本人確認関連のストーリーを削除      ← TODO 1と重複
- [ ] 3. ユースケースから本人確認ステップを削除  ← TODO 1と重複
- [ ] 4. 画面遷移図から本人確認フローを削除    ← TODO 1と重複
```

#### Good Example (統合済み - OK)
```markdown
# TODO
- [ ] 1. パスワードリセットから本人確認機能を削除

# Summary
## 1. パスワードリセットから本人確認機能を削除
- Next action:
  - workflow: シナリオから本人確認ステップを削除
  - usecase: 本人確認関連ステップを削除
  - ui: 本人確認入力フィールドを削除
  - screenflow: 本人確認フローを削除
```

---

## Execution Example

**Command (通常モード)**:
```
/teamkit:feedback YourFeature "施設の削除機能が必要です"
```

**Command (プレビューモード)**:
```
/teamkit:feedback YourFeature "施設の削除機能が必要です" -p
```
または
```
/teamkit:feedback YourFeature "施設の削除機能が必要です" --preview
```

**Process**:
1. Verify arguments are provided
2. Check for `-p` or `--preview` option
3. Check `.teamkit/YourFeature/status.json` exists
4. Analyze the feedback: "施設の削除機能が必要です"
5. (Preview mode only) Generate preview mock HTML files first:
   - Read `mock` version from `status.json`
   - Apply feedback to affected screens
   - Overwrite existing mock files in `.teamkit/YourFeature/mock/`
   - Update `status.json` with preview version
6. Verify impact across all specification files
7. Generate or update `.teamkit/YourFeature/feedback.md`
   - If preview mode: TODO items are marked with `[p]`
   - If normal mode: TODO items are marked with `[ ]`

---

## Output Format

### Output Example

The generated `feedback.md` should follow this structure:

```markdown

# Comment
- 1. {{Feedback comment 1}}
<!-- Add a feedback comment item when the user submits from this command -->

# TODO
- [ ] 1. {{short name of correction item 1 from feedback 1}}
- [ ] 2. {{short name of correction item 2 from feedback 1}}
- [p] 3. {{short name of correction item 3 from feedback 2 (created in preview mode)}}
<!--
  - [ ] = normal mode (unchecked)
  - [p] = preview mode (preview flag)
  - [x] = completed
  Continue adding newly found items
-->

# Summary
## 1. {{short name of correction item 1 from feedback 1}}
- Comment: {{Feedback comment 1}}
- Issue: {{specifically what the problem is}}
- Next action:
  - workflow: {{how to fix it and consideration}}
  - usecase: {{how to fix it and consideration}}
  - ui: {{how to fix it and consideration}}
  - screenflow: {{how to fix it and consideration}}
- Notes: {{if any notes or consideration}}

## 2. {{short name of correction item 2 from feedback 1}}
- Comment: {{Feedback comment 1}}
- Issue: {{specifically what the problem is}}
- Next action:
  - workflow: {{how to fix it and consideration}}
  - usecase: {{how to fix it and consideration}}
  - ui: {{how to fix it and consideration}}
  - screenflow: {{how to fix it and consideration}}
- Notes: {{if any notes or consideration}}
<!-- Continue for all correction items -->  

```

### 「次のアクション」の記載ルール
- 1つのTODO項目に対して、影響を受ける全ての仕様ファイル（feature, story, usecase, ui, screenflow）への変更指示を**1つの統合された説明**として記載する
- プロセスごとに分けずに、論理的な流れで変更内容を説明する
- 具体的なファイル名や変更箇所は必要に応じて言及するが、箇条書きでプロセス別に分けない
- 「次のアクション」は、ユーザーが迷わず修正できるよう、**具体的な変更内容と例を必ず記載**してください。

**NG例（曖昧で具体性がない）:**
- 「意図を明確にしてください」
- 「具体的に記述してください」
- 「適切な値を設定してください」
- 「検討してください」

**OK例（具体的で実行可能）:**
- 「`description: 適宜処理する` を `description: 入力値が空の場合はエラーメッセージ"必須項目です"を表示する` に変更する」
- 「`precondition` に `ユーザーがログイン済みであること` を追加する」
- 「`error_cases` セクションを追加し、以下のケースを記載する: 1) 入力値が空の場合、2) 文字数が100文字を超える場合、3) 不正な文字が含まれる場合」
- 「`役割: 管理者` を `役割: システム管理者（全機能へのアクセス権限を持つ）` に変更し、権限の範囲を明示する」
- 「重複している `feature_A` と `feature_A_new` を統合し、`feature_A` に一本化する。`feature_A_new` 固有の内容は `feature_A.scenarios` 配下に移動する」


### Output Location
- **Directory**: `{{baseDir}}/{{specDir}}`
- **Filename**: `feedback.md`
