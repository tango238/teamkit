
# Setup

1.  **Set `commandName`**: `update-feature`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/tk-update-feature <specDir>`" and **STOP** execution immediately.

# Instruction 
Read TODOs from `{{baseDir}}/{{specDir}}/check.md`, and applies items marked as "scheduled for processing" to update `{{baseDir}}/{{specDir}}/feature.yml` (YAML file).
Do not ask the user and execute immediately.

**All output from this command must be in Japanese.**

---

## Mission

Apply modification items (TODOs) from check.md that are marked as "scheduled for processing" to the original YAML file, then mark those TODOs as "completed" after application.

---

## Success Criteria

1. `{{baseDir}}/{{specDir}}/check.md` is correctly loaded
2. TODO item status (unprocessed/scheduled/completed/skipped) is correctly interpreted
3. Concrete action methods are considered for items marked as scheduled `[o]`
4. Change diff is clearly displayed before applying to `{{baseDir}}/{{specDir}}/feature.yml`
5. After user confirmation, diff is applied to `{{baseDir}}/{{specDir}}/feature.yml`
6. Applied items are marked as completed `[x]` in check.md

---

## TODO Status Markers

TODOs in check.md use the following status markers:

* `- [ ]`: Unprocessed (not yet addressed)
* `- [o]`: Scheduled (to be applied this time)
* `- [x]`: Completed (already applied)
* `- [~]`: Skipped (decided not to apply)

This command only processes items marked with `[o]`.

---

## Execution Steps

### 1. Pre-check
- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Existing File Handling**:
  - If some of the files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /tk-clean"

### 2. Load Check File

* If `{{baseDir}}/{{specDir}}/check.md` is specified, load that file.
* If `{{baseDir}}/{{specDir}}/check.md` is omitted, load `check.md` from the same directory as `{{baseDir}}/{{specDir}}/feature.yml`.
* If the file doesn't exist or cannot be read, report error and exit.
* Check if `{{baseDir}}/{{specDir}}/feature.yml` exists.
* If `feature.yml` does not exist, report error and exit.

### 3. Parse TODO Items

* Parse the `# TODO` section in check.md.
* Identify the status marker for each TODO item:
  * `[o]`: Extract as scheduled for processing
  * `[ ]`, `[x]`, `[~]`: Skip (not processed this time)
* If there are no scheduled `[o]` items, report "No items to process" and exit.

### 4. Load Summary Details

* Load detailed information from the `# Summary` section corresponding to each `[o]` marked TODO item.
* Extract the following information:
  * **Target**: Which YAML path/key to modify
  * **Issue**: What is the problem
  * **Recommended Action**: How to fix it
  * **Notes**: Other important considerations

### 5. Load Target YAML

* Load `{{baseDir}}/{{specDir}}/feature.yml`.
* Parse as YAML and understand the current structure.
* If it cannot be loaded or YAML is broken, report error and exit.

### 6. Plan Modifications

* For each `[o]` TODO item, determine specific modification content:
  * Consider modification method based on Summary's "Recommended Action"
  * Specify which part of the YAML structure to change and how
  * Select the most appropriate method if multiple modification approaches exist
* Display a list of modification plans.

### 7. Show Diff Preview

* Display diff when modifications are applied:
  * Compare YAML before and after changes
  * Added lines displayed with `+ `
  * Deleted lines displayed with `- `
  * Changed lines displayed as `- ` and `+ ` pair
* Display diff in an easy-to-read format (unified diff or side-by-side).

### 8. Apply

* Only apply changes to `{{baseDir}}/{{specDir}}/feature.yml` without user approval.
* Overwrite and save the original YAML file.

### 9. Update Check.md Status

* For each applied TODO item, update status in check.md from `[o]` to `[x]`:
  * `- [o] item name` → `- [x] item name`
* Save check.md.
* Do not change existing other items (`[ ]`, `[~]`, already `[x]` items).

### 10. 更新をチェックする
- 1. 9で更新があるかどうか確認する
- 2. 更新がある場合 → 11 に進む。更新がない場合 → 12 に進む

### 11. 最新のバージョン番号を取得し、 +1 したバージョンを設定する
- 1. `{{baseDir}}/{{specDir}}/status.json` を取得する
- 2. steps にあるすべてのオブジェクト情報から `version` のリストを取得
- 3. 取得した `version` リストから一番大きい値を取得する
- 4. 3の値に +1 をした値を **versionNumber** に設定する

### 12. Update Status
- `/tk-update-status {{specDir}} update-feature {{versionNumber}}` を実行し、ステータスを更新します。

### 13. Generate Downstream Artifacts

* Execute `/tk-generate-story {{specDir}}`.
* If `/tk-generate-story` completes successfully, execute `/tk-generate-usecase {{specDir}}`.
* If an error occurs during generation, report it.

### 14. Report Results

* Report processing results:
  * Number of applied items
  * Application result for each item (success/failure)
  * Updated file paths
* If problems occurred, report details.

---

## Output Examples

### Diff Display Example

```diff
# Diff for feature.yml

## Change 1: Clarify preconditions for reservation feature

--- feature.yml (before)
+++ feature.yml (after)

 reserve:
   name: Reservation feature
-  precondition: Logged in
+  precondition: 
+    - Must be logged in
+    - Available seats must exist
   steps:
     - Select date and time
     - Select seat

## Change 2: Add cancellation feature

+cancel:
+  name: Cancellation feature
+  precondition:
+    - Reservation must exist
+  steps:
+    - Select reservation
+    - Execute cancellation
+  postcondition: Reservation will be deleted
```

### check.md Update Example

```markdown
# TODO
- [x] Clarify preconditions for reservation feature
- [x] Add cancellation feature
- [ ] Add error handling
- [~] Review overly detailed granularity
```

---

## Important Constraints

* **Always obtain user approval before applying**: Do not rewrite automatically. Display diff and only apply when user answers "yes".
* **Only process items marked `[o]`**: Ignore `[ ]`, `[x]`, `[~]`.
* **Preserve original YAML structure**: Maintain comments, blank lines, indentation, etc. as much as possible.
* **Always mark as `[x]` after application**: To prevent double application.
* **If Summary information is insufficient**: Ask user for additional information or skip that item.
* **If multiple `[o]` items exist**: Display all diffs together and apply in batch (or confirm individually).

---

## Error Scenarios & Fallback

* **If check.md doesn't exist**:
  * Report `check.md not found. Please run check-features command first to perform validation.` and exit.

* **If no `[o]` marked items**:
  * Report `No scheduled items. Please mark items as [o] in check.md.` and exit.

* **If YAML is broken**:
  * Report `YAML format in {{arg1}} is invalid. Please fix it first.` and exit.

* **If no corresponding details in Summary**:
  * Skip that item and report "Skipped due to insufficient detailed information."

* **If error occurs during application**:
  * Abort changes and preserve original state.
  * Report error details.
  * Do not update check.md (leave as `[o]`).


---

## Additional Notes

* This command uses a **semi-automatic** approach:
  * AI proposes modification content
  * User selects items to process in check.md (`[o]` mark)
  * AI actually applies changes
* Safety is ensured by incorporating human judgment rather than full automation.
* When processing many items at once, the diff becomes large, so it's recommended to process important changes individually.