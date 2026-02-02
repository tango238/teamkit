---
description: Automatically apply all pending feedback items
role: Automated workflow executor
task: Mark all pending feedback items and apply them without interruption
constraints:
  - Never pause between steps
  - Never use TodoWrite tool
  - Never ask for user confirmation mid-workflow
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Glob
  - SlashCommand
argument-hint: <specDir>
---

# Setup

1. **Set `commandName`**: `auto-apply`
2. **Set `baseDir`**: `specs`
3. **Get `specDir`**: Read the first argument passed to the slash command.
   - If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/teamkit:auto-apply <specDir>`" and **STOP** execution immediately.

---

# Execution

## Mission

Automatically mark all pending feedback items (`[ ]` and `[p]`) as scheduled (`[o]`) in `feedback.md`, then execute the apply-feedback command to apply all changes at once.

**All output from this command must be in Japanese.**

Execute immediately without asking the user for confirmation.

---

## Execution Steps

### 1. Pre-check

Verify that required files exist before proceeding:

- **Target Files**:
  - `{{baseDir}}/{{specDir}}/feedback.md`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Validation**:
  - If `feedback.md` does not exist → Display "Error: `feedback.md` が見つかりません。先に `/teamkit:feedback` でフィードバックを登録してください。" and **STOP** execution.
  - If `status.json` does not exist → Display "Error: `status.json` が見つかりません。" and **STOP** execution.

### 2. Load and Parse feedback.md

Load the feedback file and identify pending items:

1. Read `{{baseDir}}/{{specDir}}/feedback.md`
2. Parse the `# TODO` section
3. Count items by status:
   - `[ ]`: Pending (unprocessed)
   - `[p]`: Preview (pending with preview)
   - `[o]`: Already scheduled
   - `[x]`: Already completed
   - `[~]`: Skipped

4. If there are no `[ ]` or `[p]` items:
   - Display "処理対象のフィードバック項目がありません。" and **STOP** execution.

5. Display summary:
   ```
   フィードバック項目の状況:
   - 未処理 [ ]: {{count}} 件
   - プレビュー [p]: {{count}} 件
   - 処理予定 [o]: {{count}} 件
   - 完了 [x]: {{count}} 件
   - スキップ [~]: {{count}} 件
   ```

### 3. Mark Items as Scheduled

Update all pending items to scheduled status:

1. For each `[ ]` item in the TODO section:
   - Change `- [ ]` to `- [o]`

2. For each `[p]` item in the TODO section:
   - Change `- [p]` to `- [o]`

3. Save the updated `feedback.md`

4. Display:
   ```
   ✓ {{count}} 件の項目を処理対象 [o] にマークしました
   ```

### 4. Execute Apply Feedback

Call the apply-feedback command to process all scheduled items:

1. Execute `/teamkit:apply-feedback {{specDir}}`

2. The apply-feedback command will:
   - Read all `[o]` marked items
   - Apply changes to specification files
   - Update version numbers
   - Regenerate mock files
   - Mark applied items as `[x]`

### 5. Report Results

After apply-feedback completes, display final summary:

```
=== 自動適用完了 ===
- 処理した項目数: {{count}} 件
- 更新されたファイル: (apply-feedbackの出力を参照)
- 新しいバージョン: (apply-feedbackの出力を参照)
```

---

## Execution Example

### Input

```bash
/teamkit:auto-apply YourFeature
```

### Processing Flow

1. Check `specs/YourFeature/feedback.md` exists
2. Parse TODO section, find `[ ]` and `[p]` items
3. Change all `[ ]` → `[o]`, `[p]` → `[o]`
4. Save feedback.md
5. Execute `/teamkit:apply-feedback YourFeature`
6. Report results

---

## Output Example

```
フィードバックの自動適用を開始します...

✓ feedback.md を読み込みました

フィードバック項目の状況:
- 未処理 [ ]: 2 件
- プレビュー [p]: 1 件
- 処理予定 [o]: 0 件
- 完了 [x]: 3 件
- スキップ [~]: 1 件

✓ 3 件の項目を処理対象 [o] にマークしました

apply-feedback を実行中...

[apply-feedback の出力がここに表示される]

=== 自動適用完了 ===
- 処理した項目数: 3 件
```

---

## Error Scenarios

**If feedback.md doesn't exist:**
- Display error and stop

**If no pending items (`[ ]` or `[p]`):**
- Display "処理対象のフィードバック項目がありません。" and stop

**If apply-feedback fails:**
- Display the error from apply-feedback
- Note: Some items may remain as `[o]` if partially processed

---

## Notes

- This command is designed for **batch processing** of all pending feedback
- For selective processing, use `/teamkit:apply-feedback` directly after manually marking items with `[o]`
- Preview items `[p]` are treated the same as pending items `[ ]` - both will be applied
