---
description: Generate all specifications from README
role: Automated workflow executor
task: Execute a full generation pipeline from README to mockups, with optional manual and acceptance test generation
context:
  - This is a Claude Code slash command
  - Generates workflow, usecase, UI, screenflow, mock, and optionally manual and acceptance tests from README
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
argument-hint: <specDir> [--manual] [--test] [--capture] [--all]
---

# Setup

1. **Set `commandName`**: `generate`
2. **Set `baseDir`**: `.teamkit`
3. **Get `specDir`**: Read the first argument passed to the slash command (the argument that does NOT start with `--`).
   - If no argument is provided, display: "Error: `specDir` argument is required. Usage: `/teamkit:generate <specDir> [--manual] [--test] [--capture] [--all]`" and **STOP**.
4. **Parse Options**: Check all arguments for option flags:
   - `--manual` or `-m` → Set `generateManual` to `true`
   - `--test` or `-t` → Set `generateTest` to `true`
   - `--capture` or `-c` → Set `captureScreenshots` to `true`
   - `--all` or `-a` → Set `generateManual`, `generateTest`, and `captureScreenshots` all to `true`
   - If none of these flags are provided → `generateManual`, `generateTest`, and `captureScreenshots` are all `false`

# Execution

## ⚠️ CRITICAL: Execution Model

**Problem**: When using SlashCommand to call sub-commands (like `/teamkit:get-step-info`), the execution context is lost after the sub-command returns, causing the workflow to stop.

**Solution**: This command uses a **SEQUENTIAL EXECUTION MODEL** where each step is a single SlashCommand call, and after each call completes, YOU MUST IMMEDIATELY call the next SlashCommand without waiting.

## Main Workflow

**EXECUTION RULES:**
1. Call each SlashCommand in sequence
2. After each SlashCommand completes (you will see its output), IMMEDIATELY call the next one
3. Do NOT stop to display results or ask questions
4. Continue until all commands are complete

---

## Step-by-Step Execution

You will execute up to 7 SlashCommand calls depending on options. After each one completes, proceed to the next.

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
When this command finishes (mock/ directory is created), proceed to Step 5.

### Step 5: Generate Manual (conditional)
**Only execute if `generateManual` is `true`.**
- If `captureScreenshots` is also `true`:
  ```
  /teamkit:generate-manual {{specDir}} --capture
  ```
- Otherwise:
  ```
  /teamkit:generate-manual {{specDir}}
  ```
When this command finishes (manual.md is saved), proceed to Step 6.

### Step 6: Generate Acceptance Test (conditional)
**Only execute if `generateTest` is `true`.**
```
/teamkit:generate-acceptance-test {{specDir}}
```
When this command finishes (acceptance-test.md is saved), proceed to Completion.

---

## ⚠️ CRITICAL: After Each Sub-command Returns

Each generate-* command will internally call helper commands or perform status operations.

**WHEN YOU SEE OUTPUT FROM THESE OPERATIONS:**
1. The operation has finished
2. You are now back in the parent generate-* command
3. **CONTINUE EXECUTING** the remaining steps of the parent command
4. Do NOT stop or wait for user input

**Example**: If you're running `generate-usecase` and it performs status check:
```
Status check returns: "バージョン: 2"
↓
You are now back in generate-usecase
↓
Continue generating usecase.yml
↓
Continue with status update
↓
generate-usecase is COMPLETE
↓
IMMEDIATELY call generate-ui (Step 2)
```

---

## Completion

After ALL steps finish:
1. Verify files exist using Glob:
   - `{{baseDir}}/{{specDir}}/workflow.yml`
   - `{{baseDir}}/{{specDir}}/usecase.yml`
   - `{{baseDir}}/{{specDir}}/ui.yml`
   - `{{baseDir}}/{{specDir}}/screenflow.md`
   - `{{baseDir}}/{{specDir}}/mock/*.html`
   - (If `generateManual` is true) `{{baseDir}}/{{specDir}}/manual.md`
   - (If `captureScreenshots` is true) `{{baseDir}}/{{specDir}}/mock/screenshots/*.png`
   - (If `generateTest` is true) `{{baseDir}}/{{specDir}}/acceptance-test.md`
2. Report final status summary in Japanese, including:
   - List of all generated files
   - Any steps that were skipped (already up-to-date)
   - Options that were used (--manual, --test, --capture, --all)

---

## 重要な注意事項

**絶対に途中で止まらないこと。**

サブコマンドが結果を返したら、それは「次のステップに進め」という合図です。
ユーザーの入力を待たずに、即座に次の処理を実行してください。

すべてのステップが完了し、最終レポートを出力するまで、処理を継続してください。
