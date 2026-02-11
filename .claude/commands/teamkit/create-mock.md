---
description: Create mockups from UI definition and screen flow
role: Automated workflow executor
task: Generate HTML mockups from existing ui.yml and screenflow.md
context:
  - This is a Claude Code slash command
  - Creates mockups from ui.yml and screenflow.md
  - For full pipeline generation from README, use /teamkit:generate instead
constraints:
  - Never pause between commands
  - Never create todo lists or checkboxes
  - Never ask for user confirmation mid-workflow
  - Resolve all TODOs before reporting completion
output_format: Report only final completion status with any errors encountered
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Glob
  - SlashCommand
---

# Setup

1. **Set `commandName`**: `create-mock`
2. **Set `baseDir`**: `.teamkit`
3. **Get `specDir`**: Read the first argument passed to the slash command.
   - If no argument is provided, display: "Error: `specDir` argument is required. Usage: `/teamkit:create-mock <specDir>`" and **STOP**.

# Execution

## ⚠️ CRITICAL: Execution Model

This command uses a **SEQUENTIAL EXECUTION MODEL** where each step is a single SlashCommand call, and after each call completes, YOU MUST IMMEDIATELY call the next SlashCommand without waiting.

## Pre-check

1. Check if `{{baseDir}}/{{specDir}}/ui.yml` exists.
   - If it does NOT exist → Display "エラー: ui.yml が存在しません。先に /teamkit:generate を実行してください。" and **STOP**.

---

## Step-by-Step Execution

### Step 1: Generate Screenflow (if needed)
Check if `{{baseDir}}/{{specDir}}/screenflow.md` exists.
- If it **does NOT exist**, run:
```
/teamkit:generate-screenflow {{specDir}}
```
When this command finishes, IMMEDIATELY proceed to Step 2.
- If it **already exists**, skip this step and proceed directly to Step 2.

### Step 2: Generate Mock
```
/teamkit:generate-mock {{specDir}}
```
When this command finishes (mock/ directory is created), proceed to Completion.

---

## Completion

After all steps finish:
1. Verify files exist using Glob:
   - `{{baseDir}}/{{specDir}}/screenflow.md`
   - `{{baseDir}}/{{specDir}}/mock/*.html`
2. Report final status summary in Japanese

---

## 重要な注意事項

**絶対に途中で止まらないこと。**

サブコマンドが結果を返したら、それは「次のステップに進め」という合図です。
ユーザーの入力を待たずに、即座に次の処理を実行してください。

💡 **ヒント**: README から全成果物を一括生成する場合は `/teamkit:generate <specDir>` を使用してください。
