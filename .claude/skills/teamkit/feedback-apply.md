---
description: Apply feedback and update specifications in one step
role: Automated workflow executor
task: Execute feedback registration with preview mode, then immediately apply the feedback to specifications
context:
  - This is a Claude Code slash command
  - Combines /teamkit:feedback -p and /teamkit:apply-feedback into a single workflow
  - First creates feedback document with [p] markers, then applies those items to specifications
constraints:
  - Never pause between feedback and apply-feedback
  - Never create todo lists or checkboxes
  - Never ask for user confirmation between commands
output_format: Report only final completion status with any errors encountered
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - SlashCommand
argument-hint: <specDir> <comment>
---

# Setup

1. **Set `commandName`**: `feedback-apply`
2. **Set `baseDir`**: `.teamkit`
3. **Get `specDir`**: Read the first argument passed to the slash command (the argument that does NOT start with `--` or `-`).
   - If no argument is provided, display: "Error: `specDir` argument and `comment` argument are required. Usage: `/teamkit:feedback-apply <specDir> <comment>`" and **STOP**.
4. **Get `comment`**: Read the second argument passed to the slash command.
   - If no argument is provided, display: "Error: `specDir` argument and `comment` argument are required. Usage: `/teamkit:feedback-apply <specDir> <comment>`" and **STOP**.

# Execution

## CRITICAL: Execution Model

This command uses a **SEQUENTIAL EXECUTION MODEL**. Each SlashCommand call completes before the next one begins. After each call completes, YOU MUST IMMEDIATELY call the next SlashCommand without waiting.

---

## Step 1: Register Feedback (Preview Mode)

Run:
```
/teamkit:feedback {{specDir}} "{{comment}}" -p
```

This will:
- Analyze the feedback comment
- Apply preview changes to ui.yml for affected screens
- Create/update `feedback.md` with TODO items marked as `[p]` (preview flag)
- Update `status.json` with preview mock version

When this command finishes (feedback.md is saved), IMMEDIATELY proceed to Step 2.

---

## Step 2: Apply Feedback

Run:
```
/teamkit:apply-feedback {{specDir}}
```

This will:
- Read `[p]` marked TODO items from `feedback.md`
- Apply modifications to specification files (screenflow.md, ui.yml, usecase.yml, workflow.yml)
- Generate approval documents
- Update `feedback.md` status from `[p]` to `[x]`
- Update all step versions in `status.json`
- Regenerate mock HTML

When this command finishes, proceed to Completion.

---

## Completion

After all steps finish, report final status summary in Japanese:

```markdown
## フィードバック適用が完了しました

### フィードバック内容
- コメント: {{comment}}
- 対象: {{specDir}}

### 実行結果
- フィードバック登録: 完了（プレビューモード）
- フィードバック適用: 完了
- 仕様ファイル更新: 完了
- モック再生成: 完了
```

---

## Important

**絶対に途中で止まらないこと。**

`/teamkit:feedback` が完了したら、ユーザーの入力を待たずに即座に `/teamkit:apply-feedback` を実行してください。
