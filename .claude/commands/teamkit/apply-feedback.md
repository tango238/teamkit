
# Setup

1. **Set `commandName`**: `apply-feedback`
2. **Set `baseDir`**: `specs`
3. **Get `specDir`**: Read the first argument passed to the slash command.
   - If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/apply-feedback <specDir>`" and **STOP** execution immediately.

---

# Execution

## Mission

Read TODO items from `{{baseDir}}/{{specDir}}/feedback.md` that are marked as "scheduled for processing" `[o]`, apply the modifications to the corresponding specification files under `{{baseDir}}/{{specDir}}`, and mark those items as "completed" `[x]` after successful application.

Execute immediately without asking the user for confirmation.

**All output from this command must be in Japanese.**

---

## Execution Steps

### 1. Pre-check

Verify that required files exist before proceeding:

- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Validation**:
  - If any of these files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /clean" and **STOP** execution.

### 2. Load Feedback File

Load the feedback file containing TODO items to process:

- Load `{{baseDir}}/{{specDir}}/feedback.md`
- If the file doesn't exist or cannot be read, report error and exit.

### 3. Parse TODO Items

Extract TODO items that are scheduled for processing:

- Parse the `# TODO` section in feedback.md
- Identify the status marker for each TODO item:
  - `[o]`: Extract as scheduled for processing
  - `[ ]`, `[x]`, `[~]`: Skip (not processed this time)
- If there are no scheduled `[o]` items, report "No items to process" and exit.

**TODO Status Markers:**
- `- [ ]`: Unprocessed (not yet addressed)
- `- [o]`: Scheduled (to be applied this time)
- `- [x]`: Completed (already applied)
- `- [~]`: Skipped (decided not to apply)

### 4. Load Summary Details

For each TODO item marked with `[o]`, load the detailed information:

- Load detailed information from the `# Summary` section corresponding to each `[o]` marked TODO item
- Extract the following information:
  - **Comment**: Feedback comment from the user
  - **Issue**: What is the problem
  - **Recommended Action**: How to fix it
  - **Notes**: Other important considerations

### 5. Get Latest Version Number and Increment

Determine the next version number for tracking changes:

1. Read `{{baseDir}}/{{specDir}}/status.json` directly (do NOT use slash commands)
2. Extract the version numbers from:
   - `steps[0].feature.version`
   - `steps[1].story.version`
   - `steps[2].usecase.version`
   - `steps[3].ui.version`
   - `steps[4].screenflow.version`
   - `mock.version`
3. Find the maximum version among all values
4. Add 1 to get **newVersionNumber**
5. Display: `バージョン番号: {{newVersionNumber}}`

**CRITICAL: Immediately proceed to Step 6 after determining the version number. Do not wait for user input.**

### 6. Load Target Files and Apply Changes

Process each specification file in the defined order. **Execute this process for all files continuously without interruption.**

#### 6-1. File Processing Order

Process files in the following order:

| Order | File Name      | Step Name  | Approval File Name   | 
|-------|----------------|------------|----------------------|
| 1     | screenflow.md  | screenflow | screenflow.md        |
| 2     | ui.yml         | ui         | ui.md                |
| 3     | usecase.yml    | usecase    | usecase.md           |
| 4     | story.yml      | story      | story.md             |
| 5     | feature.yml    | feature    | feature.md           |

For each file:
- Load `{{baseDir}}/{{specDir}}/{{fileName}}`
- Parse as YAML or markdown and understand the current structure
- If it cannot be loaded or YAML is broken, report error and exit

#### 6-2. Consider basic rules based on Summary

For each `[o]` TODO item, determine the specific modifications:

- Consider basic rules based on Summary's "Recommended Action" and "Notes"
- Select the most appropriate rule if multiple rules exist
- Set a list of basic rules as approval document

#### 6-3. Write the approval document

- Consider the approval document from basic rules
- If the approval directory does not exist, create it
- Write the approval document to `{{baseDir}}/{{specDir}}/approval/{{approvalFileName}}`
- If the approval document already exists, modify the existing file

#### 6-3-1. Approval Document Output Example

Example of approval document (`approval/ui.md`):

```markdown
# 承認ドキュメント: ui.yml

## 適用するTODO項目
- TODO 1: 施設登録画面の住所フィールド分割
- TODO 2: 施設更新画面の住所フィールド分割

## 基本ルール

### ルール1: 施設登録画面のinput_fieldsを修正
- 変更箇所: 施設登録画面の「住所」フィールド（行21-26）
- 変更内容: 「住所」フィールドを削除し、「都道府県」「市区町村」「番地」「建物名」の4フィールドを追加
- 詳細:
  - 都道府県: type=select, required=true, 47都道府県から選択
  - 市区町村: type=text, required=true, 100文字以内
  - 番地: type=text, required=true, 100文字以内
  - 建物名: type=text, required=false, 100文字以内
- 適用バージョン: 2

### ルール2: 施設更新画面のinput_fieldsを修正
- 変更箇所: 施設更新画面の「住所」フィールド（行71-75）
- 変更内容: 施設登録画面と同様に4フィールドに分割
- 適用バージョン: 2

### ルール3: validationsセクションに住所関連フィールドを追加
- 変更箇所: validationsセクション
- 変更内容: 都道府県、市区町村、番地、建物名のバリデーションルールを追加
- 適用バージョン: 2
```

**Approval Document Structure:**
- **適用するTODO項目**: List of TODO items being applied
- **基本ルール**: Numbered rules with:
  - 変更箇所: Where to change (with line numbers if applicable)
  - 変更内容: What to change
  - 詳細: Detailed specifications (optional)
  - 適用バージョン: Version number being applied

#### 6-4. Generate applied chages version

- How to generate:
  - Execute `/teamkit:generate-{{stepName}} {{specDir}} --tmp` command
  - This command will apply the rules from the approval document to the content of `{{fileName}}`
  - Save the result to `{{baseDir}}/{{specDir}}/{{fileName}}_tmp.yml` or `{{baseDir}}/{{specDir}}/{{fileName}}_tmp.md`

#### 6-5. Compare to applied changes version

- Compare the tmp file to the original file:
  - Check the diff and changes are appropriate or not, also there are no unexpected changes
  - If the changes are appropriate, continue to the next step
  - If the changes are not appropriate, back to 6-2

#### 6-6. Display diff when the rules in the approval document are applied to the original file

- Display diff when the rules in the approval document are applied to the original file:
  - Compare YAML/markdown before and after changes
  - Added lines displayed with `+ `
  - Deleted lines displayed with `- `
  - Changed lines displayed as `- ` and `+ ` pair
- Display diff in an easy-to-read format (unified diff or side-by-side)

### 7. Update feedback.md Status

Mark processed items as completed:

- For each applied TODO item, update status in feedback.md from `[o]` to `[x]`:
  - `- [o] item name` → `- [x] item name`
- Save feedback.md
- Do not change existing other items (`[ ]`, `[~]`, already `[x]` items)

#### 8. Update All Step Versions

Record the new version number in status.json for ALL steps:

- **IMPORTANT: Update version for ALL steps, regardless of whether changes were applied to that file or not**
- This ensures all specification files maintain synchronized version numbers
- **Do NOT use `/teamkit:update-status` slash commands here** - directly edit the `status.json` file instead to avoid interruption
- Edit `{{baseDir}}/{{specDir}}/status.json` directly:
  - Update `steps[0].feature.version` to `{{newVersionNumber}}`
  - Update `steps[1].story.version` to `{{newVersionNumber}}`
  - Update `steps[2].usecase.version` to `{{newVersionNumber}}`
  - Update `steps[3].ui.version` to `{{newVersionNumber}}`
  - Update `steps[4].screenflow.version` to `{{newVersionNumber}}`
  - Update `mock.version` to `{{newVersionNumber}}`
  - Update `updated_at` to current timestamp
  - Update `last_execution` to `apply-feedback`
- The version number represents the feedback application batch, not individual file changes
- **CRITICAL: Proceed immediately to Step 9 after updating status.json. Do not wait for user input.**

### 9. Execute Create Mock

Regenerate all files to reflect the changes:

- Delete all files in `{{baseDir}}/{{specDir}}/mock` and `{{baseDir}}/{{specDir}}/index.html`
- Execute `/teamkit:generate-mock {{specDir}}`
- If an error occurs during generation, report it

### 10. Report Results

Display the processing results:

- Report processing results:
  - Number of applied items
  - Application result for each item (success/failure)
  - Updated file paths
- If problems occurred, report details

---

## Execution Example

### Input

```bash
/teamkit:apply-feedback YourFeature
```

### Processing Flow

1. Load `specs/YourFeature/feedback.md`
2. Find TODO items marked with `[o]`
3. Load corresponding details from Summary section
4. Read `status.json` directly and calculate new version number (max version + 1)
5. For each file (screenflow.md, ui.yml, usecase.yml, story.yml, feature.yml):
   - Load file
   - Plan modifications based on TODO items
   - Show diff preview
   - Apply changes (if applicable)
6. Update feedback.md: change `[o]` to `[x]`
7. Directly edit `status.json` to update ALL step versions to newVersionNumber (do NOT use slash commands)
8. Execute `/teamkit:generate-mock YourFeature`
9. Report results

---

## Output Example

### Output Format

```
フィードバックの適用を開始します...

✓ feedback.md を読み込みました
✓ 処理対象のTODO項目: 2件

バージョン番号: 5

=== ファイル処理: screenflow.md ===
変更プラン:
- TODO 1: 住所フィールドを詳細化

Diff:
- address: 住所
+ postal_code: 郵便番号
+ prefecture: 都道府県
+ city: 市区町村
+ street: 番地
+ building: 建物名
+ room: 部屋番号

✓ screenflow.md を更新しました

=== ファイル処理: ui.yml ===
...

✓ feedback.md のステータスを更新しました
✓ status.json を直接更新しました (version: 5)
  - feature: 5
  - story: 5
  - usecase: 5
  - ui: 5
  - screenflow: 5
  - mock: 5
✓ モックHTMLを生成しました

処理完了:
- 適用項目数: 2件
- 更新ファイル: screenflow.md, ui.yml, usecase.yml, story.yml, feature.yml
- バージョン: 5 (全ステップ共通)
```

### feedback.md Update Example

Before:
```markdown
# TODO
- [x] 1. Clarify preconditions for reservation feature
- [o] 2. Add detailed address fields
- [ ] 3. Add error handling
- [~] 4. Review overly detailed granularity
```

After:
```markdown
# TODO
- [x] 1. Clarify preconditions for reservation feature
- [x] 2. Add detailed address fields
- [ ] 3. Add error handling
- [~] 4. Review overly detailed granularity
```

---

## Important Constraints

- **Only process items marked `[o]`**: Ignore `[ ]`, `[x]`, `[~]`
- **Preserve original file structure**: Maintain comments, blank lines, indentation, etc. as much as possible
- **Always mark as `[x]` after application**: To prevent double application
- **If Summary information is insufficient**: Ask user for additional information or skip that item
- **If multiple `[o]` items exist**: Display all diffs together and apply in batch (or confirm individually)

---

## Error Scenarios & Fallback

**If feedback.md doesn't exist:**
- Report `feedback.md not found.` and exit

**If no `[o]` marked items:**
- Report `No scheduled items. Please mark items as [o] in feedback.md.` and exit

**If YAML is broken:**
- Report `YAML format in {{fileName}} is invalid. Please fix it first.` and exit

**If no corresponding details in Summary:**
- Skip that item and report "Skipped due to insufficient detailed information."

**If error occurs during application:**
- Abort changes and preserve original state
- Report error details
- Do not update feedback.md (leave as `[o]`)

---

## Additional Notes

- This command uses a **semi-automatic** approach:
  - AI proposes modification content
  - User selects items to process in feedback.md (`[o]` mark)
  - AI actually applies changes
- Safety is ensured by incorporating human judgment rather than full automation
- When processing many items at once, the diff becomes large, so it's recommended to process important changes individually