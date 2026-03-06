---
description: Add a new feature and generate all specifications
role: Automated workflow executor
task: Create a new feature specification via conversation, then immediately run the full generation pipeline
context:
  - This is a Claude Code slash command
  - Combines /teamkit:add and /teamkit:generate into a single workflow
  - First creates README.md via conversation, then generates all specs and mockups
constraints:
  - Never pause between add and generate
  - Never create todo lists or checkboxes
  - Never ask for user confirmation between commands
output_format: Report only final completion status with any errors encountered
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - SlashCommand
argument-hint: <featureName> [-o|--output <outputDir>] [--manual] [--test] [--capture] [--all]
---

# Setup

1. **Set `commandName`**: `create`
2. **Set `baseDir`**: `.teamkit`
3. **Get `featureName`**: Read the first argument passed to the slash command (the argument that does NOT start with `--` or `-o`).
   - If no argument is provided, display: "Error: `featureName` argument is required. Usage: `/teamkit:create <featureName> [-o|--output <outputDir>] [--manual] [--test] [--capture] [--all]`" and **STOP**.
4. **Check for output directory**: Check if `-o` or `--output` option is passed as any argument.
   - If found, set `outputDir` to the value of the option.
   - If not found, set `outputDir` to `{{baseDir}}`.
5. **Parse Options**: Check all arguments for option flags:
   - `--manual` or `-m` -> Set `generateManual` to `true`
   - `--test` or `-t` -> Set `generateTest` to `true`
   - `--capture` or `-c` -> Set `captureScreenshots` to `true`
   - `--all` or `-a` -> Set all above to `true`
   - If none -> all `false`
6. **Generate `specDir`**: Convert `featureName` to an English kebab-case slug.
   - Examples: "attendance-management" -> `attendance-management`, "schedule-management" -> `schedule-management`

# Execution

## CRITICAL: Execution Model

This command uses a **SEQUENTIAL EXECUTION MODEL**. Each SlashCommand call completes before the next one begins. After each call completes, YOU MUST IMMEDIATELY call the next SlashCommand without waiting.

---

## Step 1: Add Feature

Build the output option string:
- If `outputDir` is set and different from `{{baseDir}}`: set `outputOption` to `-o {{outputDir}}`
- Otherwise: set `outputOption` to empty

Run:
```
/teamkit:add {{featureName}} {{outputOption}}
```

This will start a conversation with the user to gather requirements and create `README.md` and `status.json`.

When this command finishes (README.md and status.json are saved), IMMEDIATELY proceed to Step 2.

---

## Step 2: Generate Specifications

Build the generate options string from the parsed options:
- If `generateManual` is true: append `--manual`
- If `generateTest` is true: append `--test`
- If `captureScreenshots` is true: append `--capture`

Run:
```
/teamkit:generate {{specDir}} {{generateOptions}}
```

When this command finishes, proceed to Completion.

---

## Completion

After all steps finish, report final status summary in Japanese:

```markdown
## 機能作成が完了しました

### 作成された機能
- 機能名: {{featureName}}
- ディレクトリ: {{outputDir}}/{{specDir}}/

### 生成された成果物
- README.md (要件定義)
- workflow.yml (ワークフロー)
- usecase.yml (ユースケース)
- ui.yml (UI定義)
- screenflow.md (画面遷移)
- mokkun (モック画面)
```

---

## Important

**絶対に途中で止まらないこと。**

`/teamkit:add` が完了したら、ユーザーの入力を待たずに即座に `/teamkit:generate` を実行してください。
