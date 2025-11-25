
# Setup

1. **Set `commandName`**: `apply-feedback`
2. **Set `baseDir`**: `specs`
3. **Get `specDir`**: Read the first argument passed to the slash command.
   - If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/tk-apply-feedback <specDir>`" and **STOP** execution immediately.

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
  - If any of these files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /tk-clean" and **STOP** execution.

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

1. Load `{{baseDir}}/{{specDir}}/status.json`
2. Extract all `version` values from all objects in the `steps` array
3. Find the maximum value from the extracted version list
4. Add 1 to the maximum value and set it as **versionNumber**

### 6. Load Target Files and Apply Changes

Process each specification file in the defined order:

#### 6-1. File Processing Order

Process files in the following order:

| Order | File Name      | Command Name      |
|-------|----------------|-------------------|
| 1     | screen-flow.md | update-screenflow |
| 2     | ui.yml         | update-ui         |
| 3     | usecases.yml   | update-usecase    |
| 4     | stories.yml    | update-story      |
| 5     | feature.yml    | update-feature    |

For each file:
- Load `{{baseDir}}/{{specDir}}/{{fileName}}`
- Parse as YAML or markdown and understand the current structure
- If it cannot be loaded or YAML is broken, report error and exit

#### 6-2. Plan Modifications

For each `[o]` TODO item, determine the specific modifications:

- Consider modification method based on Summary's "Recommended Action" and "Notes"
- Specify which part of the YAML/markdown structure to change and how
- Select the most appropriate method if multiple modification approaches exist
- Display a list of modification plans

#### 6-3. Show Diff Preview

Display the changes before applying:

- Display diff when modifications are applied:
  - Compare YAML/markdown before and after changes
  - Added lines displayed with `+ `
  - Deleted lines displayed with `- `
  - Changed lines displayed as `- ` and `+ ` pair
- Display diff in an easy-to-read format (unified diff or side-by-side)

#### 6-4. Apply Changes

Apply the modifications to the file:

- Apply changes to each file without user approval
- Overwrite and save the original file

#### 6-5. Update Step Status

Record the processing step in status.json:

- Execute `/tk-update-status {{specDir}} {{commandName}} {{versionNumber}}` to update the status

**Repeat steps 6-1 through 6-5 for each file in the order specified in step 6-1.**

### 7. Update feedback.md Status

Mark processed items as completed:

- For each applied TODO item, update status in feedback.md from `[o]` to `[x]`:
  - `- [o] item name` → `- [x] item name`
- Save feedback.md
- Do not change existing other items (`[ ]`, `[~]`, already `[x]` items)

### 8. Execute Generate Mock

Regenerate mock HTML files to reflect the changes:

- Execute `/tk-generate-mock {{specDir}}`
- If an error occurs during generation, report it

### 9. Report Results

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
/tk-apply-feedback 1_FacilityManagement
```

### Processing Flow

1. Load `specs/1_FacilityManagement/feedback.md`
2. Find TODO items marked with `[o]`
3. Load corresponding details from Summary section
4. Get latest version from `status.json` and increment
5. For each file (screen-flow.md, ui.yml, usecases.yml, stories.yml, feature.yml):
   - Load file
   - Plan modifications based on TODO items
   - Show diff preview
   - Apply changes
   - Update status
6. Update feedback.md: change `[o]` to `[x]`
7. Execute `/tk-generate-mock 1_FacilityManagement`
8. Report results

---

## Output Example

### Output Format

```
フィードバックの適用を開始します...

✓ feedback.md を読み込みました
✓ 処理対象のTODO項目: 2件

バージョン番号: 5

=== ファイル処理: screen-flow.md ===
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

✓ screen-flow.md を更新しました
✓ ステータスを更新しました (update-screenflow, version: 5)

=== ファイル処理: ui.yml ===
...

✓ feedback.md のステータスを更新しました
✓ モックHTMLを生成しました

処理完了:
- 適用項目数: 2件
- 更新ファイル: screen-flow.md, ui.yml, usecases.yml, stories.yml, feature.yml
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