
# Setup

1. **Set `baseDir`**: `specs`
2. **Get `specDir`**: Read the first argument from the slash command.
   - If no argument is provided → Display error message "エラー: `specDir` 引数が必要です。使用法: `/tk-get-step-info <specDir> <stepName>`" and **STOP** execution.
3. **Get `stepName`**: Read the second argument from the slash command.
   - If no argument is provided → Display error message "エラー: `stepName` 引数が必要です。使用法: `/tk-get-step-info <specDir> <stepName>`" and **STOP** execution.

# Execution

Using `baseDir`, `specDir`, and `stepName`, execute the following steps.

**Important**:
- All output to users (status messages, completion notifications) must be in **Japanese**.
- Save files without asking for user confirmation.

---

## Mission

Read `{{baseDir}}/{{specDir}}/status.json` and return the version information for the step specified in the arguments.
Execute the following process immediately without asking for user confirmation.

## Execution Steps

### 1. Pre-check

Verify that the following files exist:

- **Target Files**:
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Validation**:
  - If any of these files do not exist → Display the message "エラー: `status.json` または `feature.yml` が存在しません。/tk-clean を実行してください" and **STOP** execution.

### 2. Load status.json

- Read `{{baseDir}}/{{specDir}}/status.json`.

### 3. Retrieve step information

1. From `status.json`, find the object in `steps` array that matches the specified `stepName`.
2. **Set `versionNumber`**: Extract the `version` field from the matched step object.
3. **Set `checkSum`**: Extract the `checksum` field from the matched step object.
4. **Set `lastModified`**: Extract the `last_modified` field from the matched step object.

### 4. Display results

Display the result in the following format:

```
ステータス: 成功
ステップ: {{stepName}}
バージョン: {{versionNumber}}
チェックサム: {{checkSum}}
最終更新日時: {{lastModified}}
メッセージ: ステップ情報を取得しました。
```

---

## Execution Example

### Input

```bash
/tk-get-step-info 1_FacilityManagement feature
```

### Output Example

```
ステータス: 成功
ステップ: feature
バージョン: 1.0.0
チェックサム: abc123def456
最終更新日時: 2025-11-24T10:30:00+09:00
メッセージ: ステップ情報を取得しました。
```

### Output Format

The output follows this structure:
- **ステータス**: Execution status (成功 for success, 失敗 for failure)
- **ステップ**: The name of the step queried
- **バージョン**: The version number of the step
- **チェックサム**: The checksum of the step artifact
- **最終更新日時**: The last modified timestamp
- **メッセージ**: A user-friendly message in Japanese