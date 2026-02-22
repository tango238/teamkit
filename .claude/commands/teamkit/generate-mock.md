---
description: Launch mokkun to preview mock screens from UI definition
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir>
---

# Setup

1.  **Set `commandName`**: `generate-mock`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/teamkit:generate-mock <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---

<if condition="!$1">
echo "エラー: specDirを指定してください。"
echo "使用法: /generate-mock [specDir]"
exit 1
</if>

if [ ! -f ".teamkit/{{specDir}}/status.json" ] || [ ! -f ".teamkit/{{specDir}}/workflow.yml" ]; then
  echo "エラー: status.json または workflow.yml が存在しません。/generate-workflow を実行してください。"
  exit 1
fi

---

## Mission

Launch [mokkun](https://github.com/tango238/mokkun) to preview mock screens from the UI definition (`ui.yml`). mokkun renders YAML-defined UI structures directly in the browser without HTML generation.

**IMPORTANT:** Execute the following steps immediately without asking the user for confirmation.

---

## Execution Steps

### 1. Read Input Files

Read the following files:
- `{{baseDir}}/{{specDir}}/ui.yml`
- `{{baseDir}}/{{specDir}}/status.json`

If `ui.yml` does not exist, display "エラー: ui.yml が存在しません。先に `/teamkit:generate-ui` を実行してください。" and **STOP**.

### 2. Check Status

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Extract `version` from the `screenflow` step in the `steps` array
3. Set this as `{{targetVersion}}`
4. Extract `version` from the `mock` section - this is `{{currentVersion}}`
5. **Validation**:
   - If `{{currentVersion}}` >= `{{targetVersion}}` → Display "スキップ: mock は既に最新です (version {{currentVersion}})" and **STOP**
   - Otherwise → Continue execution

### 3. Resolve mokkun Version

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Check if `tools.mokkun.version` exists and is not empty
3. **If version exists** → Set `{{mokkunVersion}}` to that value
4. **If version does NOT exist** → Resolve the latest version:
   ```bash
   npm view mokkun version
   ```
   - Set `{{mokkunVersion}}` to the result
   - Update `status.json`: set `tools.mokkun` to:
     ```json
     {
       "version": "{{mokkunVersion}}",
       "resolved_at": "{{currentTimestamp}}"
     }
     ```
   - Save `status.json`

### 4. Launch mokkun

Run the following command via Bash:

```bash
npx mokkun@{{mokkunVersion}} {{baseDir}}/{{specDir}}/ui.yml
```

Display to the user:
```
mokkun v{{mokkunVersion}} を起動しました。
ブラウザで http://localhost:3333 を開いてモック画面を確認してください。
終了するには Ctrl+C を押してください。
```

### 5. Update Status

1. Get current timestamp in ISO format: `date -u +"%Y-%m-%dT%H:%M:%S"`
2. Read `{{baseDir}}/{{specDir}}/status.json`
3. Update the `mock` section with:
   - `version`: Set to `{{targetVersion}}` (from Step 2)
   - `last_modified`: Set to the timestamp obtained
4. Update `last_execution`: Set to `generate-mock`
5. Update `updated_at`: Set to current timestamp
6. Save the modified `status.json`
