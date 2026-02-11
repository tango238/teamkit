---
description: Check if version increment is valid
allowed-tools: Bash, Read, Grep, Glob, LS
argument-hint: <specDir> <commandName> <versionNumber>
---

# Setup

1. **Set `baseDir`**: `specs`
2. **Get `specDir`**: Read the first argument from the slash command.
   - If no argument is provided, display error message "エラー: `specDir` 引数が指定されていません。使用法: `/teamkit:check-status <specDir> <commandName> <versionNumber>`" and **STOP** execution.
3. **Get `commandName`**: Read the second argument from the slash command.
   - If no argument is provided, display error message "エラー: `commandName` 引数が指定されていません。" and **STOP** execution.
4. **Get `versionNumber`**: Read the third argument from the slash command.
   - If no argument is provided, display error message "エラー: `versionNumber` 引数が指定されていません。" and **STOP** execution.

# Execution

Execute the following steps using `baseDir`, `specDir`, `commandName`, and `versionNumber`.

**Important**:
- All user-facing output must be in **Japanese**.
- Execute immediately without requesting user confirmation.

## Mission

Verify that the version update for the specified step is sequential.
Specifically, check if the difference between the scheduled update version (`versionNumber`) and the current version is greater than 1.
If a gap is detected (difference > 1), display an error and stop execution.

## Execution Steps

### 1. Load status.json
- Read `{{baseDir}}/{{specDir}}/status.json`.
- If the file does not exist, display "エラー: status.json が見つかりません。" and **STOP**.

### 2. Identify Step and Current Version
- Identify the target step based on `commandName`:
  - **Mapping Rule**:
    | Command Name        | Corresponding Step |
    |---------------------|--------------------|
    | generate-workflow   | workflow           |
    | generate-usecase    | usecase            |
    | generate-ui         | ui                 |
    | generate-screenflow | screenflow         |
    | generate-mock       | mock               |
    | create-mock         | mock               |

- **Action**:
  - If `commandName` corresponds to `<none>`, output "検証対象外のコマンドです" and **EXIT** successfully.
  - Retrieve the current version from `status.json`:
    - For `mock`: Reference root-level `mock.version`.
    - For others: Reference `version` of the corresponding key (e.g., `steps.workflow.version`) under `steps`.
  - If the step does not exist in `status.json` (first time), treat current version as `0`.

### 3. Validate Version Gap
- **Calculation**:
  - `diff = versionNumber - currentVersion`
- **Validation Logic**:
  - if `currentVersion` is `0`:
    - Display message: "バージョンチェック: OK (現在: {{currentVersion}} -> 次: {{versionNumber}})"
    - Proceed (Exit successfully).
  - If `diff > 1`:
    - Display error message: "エラー: バージョンが飛んでいます。現在のバージョン: {{currentVersion}}, 指定されたバージョン: {{versionNumber}}。バージョンは1つずつインクリメントする必要があります。"
    - **STOP** execution immediately (Exit with error).
  - If `diff <= 1`:
    - Display message: "バージョンチェック: OK (現在: {{currentVersion}} -> 次: {{versionNumber}})"
    - Proceed (Exit successfully).

## Execution Example

### Example 1: Normal Increment
**Input**:
Current Version: 1
Command: `/teamkit:check-status 1_FacilityManagement generate-usecase 2`

**Output**:
```
バージョンチェック: OK (現在: 1 -> 次: 2)
```

### Example 2: Gap Detected (Error)
**Input**:
Current Version: 1
Command: `/teamkit:check-status 1_FacilityManagement generate-usecase 3`

**Output**:
```
エラー: バージョンが飛んでいます。現在のバージョン: 1, 指定されたバージョン: 3。バージョンは1つずつインクリメントする必要があります。
```

### Example 3: First Run (Current=0)
**Input**:
Current Version: 0 (Not in status.json)
Command: `/teamkit:check-status 1_FacilityManagement generate-usecase 1`

**Output**:
```
バージョンチェック: OK (現在: 0 -> 次: 1)
```
