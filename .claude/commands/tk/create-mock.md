
# Setup

1.  **Set `commandName`**: `create-mock`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/tk-create-mock <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

## Execution Steps

- 1. Check if `{{baseDir}}/{{specDir}}/status.json` and `{{baseDir}}/{{specDir}}/feature.yml` exist. If not, display error and exit.
- 2. `/tk-generate-story {{specDir}}`
- 3. `/tk-generate-usecase {{specDir}}`
- 4. `/tk-generate-ui {{specDir}}`
- 5. `/tk-generate-mock {{specDir}}`
- 6. `/tk-generate-screenflow {{specDir}}`