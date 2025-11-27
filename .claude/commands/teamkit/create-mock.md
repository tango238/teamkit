---
role: Automated workflow executor
task: Execute a sequence of generation commands without interruption
context:
  - This is a Claude Code slash command
  - Generates story, usecase, UI, screenflow, and mock from spec files
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
---

# Setup

1. **Set `commandName`**: `create-mock`
2. **Set `baseDir`**: `specs`
3. **Get `specDir`**: Read the first argument passed to the slash command.
   - If no argument is provided, display: "Error: `specDir` argument is required. Usage: `/create-mock <specDir>`" and **STOP**.

# Execution

## Prerequisites
Verify `{{baseDir}}/{{specDir}}/status.json` and `{{baseDir}}/{{specDir}}/feature.yml` exist. If not, display error and exit.

## Main Workflow

**⚠️ CRITICAL EXECUTION RULES:**
1. **NEVER STOP** between commands - execute all 5 commands in immediate succession
2. **NEVER DISPLAY** intermediate results or progress to the user
3. **NEVER WAIT** for user confirmation between commands
4. **IMMEDIATELY PROCEED** to the next command after each slash command returns
5. **ONLY REPORT** final completion status after ALL 5 commands finish

**Execution sequence (run ALL without interruption):**
```
/teamkit:generate-story {{specDir}}
/teamkit:generate-usecase {{specDir}}
/teamkit:generate-ui {{specDir}}
/teamkit:generate-screenflow {{specDir}}
/teamkit:generate-mock {{specDir}}
```

**⚠️ IMPORTANT**: Each slash command will expand into instructions. After completing those instructions (including any sub-commands like `get-step-info` and `update-status`), IMMEDIATELY call the next slash command. Do NOT pause, do NOT summarize, do NOT ask questions.

## Completion
After ALL 5 commands finish:
- Verify all TODOs/FIXMEs are resolved (run `grep -r "TODO\|FIXME" {{baseDir}}/{{specDir}}` if needed)
- Report final status summary in Japanese

**Do not create a todo list. Do not pause between commands. Do not display intermediate status.**