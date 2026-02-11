---
description: Update status
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Glob
argument-hint: <specDir> <commandName> <versionNumber>
---

# Setup

1. **Set `baseDir`**: `specs`
2. **Get `specDir`**: Read the first argument from the slash command.
   - If no argument is provided, display error message "Error: `specDir` argument is required. Usage: `/update-status <specDir> <commandName> <versionNumber>`" and **terminate execution**.
3. **Get `commandName`**: Read the second argument from the slash command.
4. **Get `versionNumber`**: Read the third argument from the slash command.

# Execution

Execute the following steps using `baseDir`, `specDir`, `commandName`, and `versionNumber`.

**Important**:
- All user-facing output (status messages, completion notifications) must be in **Japanese**.
- Save files without requesting user confirmation.

## Mission

Update `{{baseDir}}/{{specDir}}/status.json`.
Execute the following process immediately without requesting user confirmation.

## Execution Steps

### 1. Load status.json
- Read `{{baseDir}}/{{specDir}}/status.json`.

### 2. Validate Version
- Retrieve the current version for the corresponding `commandName` from `status.json`.
  - For `mock`: Reference root-level `mock.version`.
  - For others: Reference `version` of the corresponding key (e.g., `workflow`, `usecase`) under `steps`.
- **Validation logic**:
  - If current version = 0: Proceed to next step.
  - If current version > `versionNumber` (argument): Display error message "The specified version ({{versionNumber}}) is less than the current version." and terminate.
  - If current version <= `versionNumber` (argument): Proceed to next step.

### 3. Update Status
- Identify the target file path:
  - `workflow` → `workflow.yml`
  - `usecase` → `usecase.yml`
  - `ui` → `ui.yml`
  - `screenflow` → `screenflow.md`
  - `mock` → `mock/screens.yml`
- Command to step mapping:
  | Command Name         | Corresponding Step |
  |---------------------|-------------------|
  | generate-workflow   | workflow          |
  | generate-usecase    | usecase           |
  | generate-ui         | ui                |
  | generate-screenflow | screenflow        |
  | create-mock         | <none>            |
  | generate-mock       | mock              |

- Get the **MD5 checksum** and **last modified timestamp (Unix Timestamp)** of the target file.
- Update `status.json`:
  - Update the `version` of the corresponding item to `versionNumber`.
  - Update the `checksum` and `last_modified` of the corresponding item.
  - Update root-level `updated_at` to the current timestamp (ISO 8601).
  - Update root-level `last_execution` to `commandName`.
- Save `status.json`.

### 4. Display Result
Display the result in the following format:

```
ステータス: 成功
コマンド: {{commandName}}
バージョン: {{versionNumber}}
日時: <current timestamp (ISO 8601)>
メッセージ: ステータスを更新しました。
```

## Execution Example

### Input
```bash
/teamkit:update-status FacilityManagement generate-usecase 2
```

### Output Example

```
ステータス: 成功
コマンド: generate-usecase
バージョン: 2
日時: 2025-11-24T16:55:32+09:00
メッセージ: ステータスを更新しました。
```

### Output Format

The command updates `status.json` with:
- Version number updated to the specified value
- Updated checksum and last_modified timestamp
- Root-level updated_at timestamp
- Root-level last_execution command name