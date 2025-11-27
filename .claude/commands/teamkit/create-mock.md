
# Setup

1.  **Set `commandName`**: `create-mock`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/create-mock <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

## Execution Steps

**IMPORTANT: Execute steps 2 through 6 continuously without stopping or asking for user confirmation between steps.**

- 1. Check if `{{baseDir}}/{{specDir}}/status.json` and `{{baseDir}}/{{specDir}}/feature.yml` exist. If not, display error and exit.
- 2. Execute `/teamkit:generate-story {{specDir}}`
- 3. Immediately after step 2 completes, execute `/teamkit:generate-usecase {{specDir}}`
- 4. Immediately after step 3 completes, execute `/teamkit:generate-ui {{specDir}}`
- 5. Immediately after step 4 completes, execute `/teamkit:generate-screenflow {{specDir}}`
- 6. Immediately after step 5 completes, execute `/teamkit:generate-mock {{specDir}}`
