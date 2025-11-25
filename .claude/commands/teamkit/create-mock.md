
# Setup

1.  **Set `commandName`**: `create-mock`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/create-mock <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

## Execution Steps

- 1. Check if `{{baseDir}}/{{specDir}}/status.json` and `{{baseDir}}/{{specDir}}/feature.yml` exist. If not, display error and exit.
- 2. `/teamkit:generate-story {{specDir}}`
- 3. `/teamkit:generate-usecase {{specDir}}`
- 4. `/teamkit:generate-ui {{specDir}}`
- 5. `/teamkit:generate-screenflow {{specDir}}`
- 6. `/teamkit:generate-mock {{specDir}}`
