---
description: Create mockups
role: Automated workflow executor
task: Execute a sequence of generation commands without interruption
context:
  - This is a Claude Code slash command
  - Generates usecase, UI, screenflow, and mock from spec files
  - All sub-commands are predefined teamkit commands
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
2. **Set `baseDir`**: `specs`
3. **Get `specDir`**: Read the first argument passed to the slash command.
   - If no argument is provided, display: "Error: `specDir` argument is required. Usage: `/create-mock <specDir>`" and **STOP**.

# Execution

## ⚠️ CRITICAL: Execution Model

**Problem**: When using SlashCommand to call sub-commands (like `/teamkit:get-step-info`), the execution context is lost after the sub-command returns, causing the workflow to stop.

**Solution**: This command uses a **SEQUENTIAL EXECUTION MODEL** where each step is a single SlashCommand call, and after each call completes, YOU MUST IMMEDIATELY call the next SlashCommand without waiting.

## Main Workflow

**EXECUTION RULES:**
1. Call each SlashCommand in sequence
2. After each SlashCommand completes (you will see its output), IMMEDIATELY call the next one
3. Do NOT stop to display results or ask questions
4. Continue until all commands are complete (up to 5 if workflow.yml needs creation)

---

## Step-by-Step Execution

You will execute up to 5 SlashCommand calls. After each one completes, proceed to the next.

### Step 0: Generate Workflow (if needed)
Check if `{{baseDir}}/{{specDir}}/workflow.yml` exists.
- If it **does NOT exist**, run:
```
/teamkit:generate-workflow {{specDir}}
```
When this command finishes (workflow.yml is saved), IMMEDIATELY proceed to Step 1.
- If it **already exists**, skip this step and proceed directly to Step 1.

### Step 1: Generate Usecase
```
/teamkit:generate-usecase {{specDir}}
```
When this command finishes (usecase.yml is saved), IMMEDIATELY proceed to Step 2.

### Step 2: Generate UI
```
/teamkit:generate-ui {{specDir}}
```
When this command finishes (ui.yml is saved), IMMEDIATELY proceed to Step 3.

### Step 3: Generate Screenflow
```
/teamkit:generate-screenflow {{specDir}}
```
When this command finishes (screenflow.md is saved), IMMEDIATELY proceed to Step 4.

### Step 4: Generate Mock
```
/teamkit:generate-mock {{specDir}}
```
When this command finishes (mock/ directory is created), proceed to Completion.

---

## ⚠️ CRITICAL: After Each Sub-command Returns

Each generate-* command will internally call helper commands like:
- `/teamkit:get-step-info` - Returns version info, then parent command continues
- `/teamkit:check-status` - Returns status, then parent command continues
- `/teamkit:update-status` - Updates status, then parent command continues

**WHEN YOU SEE OUTPUT FROM THESE HELPER COMMANDS:**
1. The helper command has finished
2. You are now back in the parent generate-* command
3. **CONTINUE EXECUTING** the remaining steps of the parent command
4. Do NOT stop or wait for user input

**Example**: If you're running `generate-usecase` and it calls `get-step-info`:
```
get-step-info returns: "バージョン: 2"
↓
You are now back in generate-usecase
↓
Continue with check-status call
↓
Continue generating usecase.yml
↓
Continue with update-status call
↓
generate-usecase is COMPLETE
↓
IMMEDIATELY call generate-ui (Step 2)
```

---

## Completion

After ALL 4 steps finish:
1. Verify files exist using Glob:
   - `{{baseDir}}/{{specDir}}/usecase.yml`
   - `{{baseDir}}/{{specDir}}/ui.yml`
   - `{{baseDir}}/{{specDir}}/screenflow.md`
   - `{{baseDir}}/{{specDir}}/mock/*.html`
2. Report final status summary in Japanese

---

## 重要な注意事項

**絶対に途中で止まらないこと。**

サブコマンドが結果を返したら、それは「次のステップに進め」という合図です。
ユーザーの入力を待たずに、即座に次の処理を実行してください。

4つのステップすべてが完了し、最終レポートを出力するまで、処理を継続してください。
