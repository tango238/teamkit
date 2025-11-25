
# Setup

1.  **Set `commandName`**: `submit-feedback`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: both `specDir` argument and `comment` argument are required. Usage: `/feedback <specDir> <comment>`" and **STOP** execution immediately.
4.  **Get `comment`**: Read the second argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: both `specDir` argument and `comment` argument are required. Usage: `/feedback <specDir> <comment>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated markdown file (`feedback.md`) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.
-   Execute immediately without asking the user.

---

## Mission

Analyze the user's feedback comment and generate a structured feedback document that:
1. Records the original comment
2. Identifies specific issues and impacts across all specification files
3. Provides actionable TODO items
4. Documents recommended solutions with detailed notes for each affected specification layer

## Execution Steps

### 1. Check arguments
Verify that both `specDir` and `comment` arguments are provided. If either is missing, display the error message and stop.

### 2. Pre-check
- Check if `{{baseDir}}/{{specDir}}/status.json` exists
- If the file does not exist, display an error message and stop execution

### 3. Understand & Think
- Understand the feedback content provided in the `comment` argument
- Consider the impact on functionality and UI/UX
- Think about recommended solutions and approaches to address the feedback

### 4. Verify Impact
Verify the impact on each specification file in the following order (each step should consider the impact from the previous step):
1. Verify impact on `screen-flow.md`
2. Considering the impact from step 1, verify impact on `ui.yml`
3. Considering the impact from step 2, verify impact on `usecases.yml`
4. Considering the impact from step 3, verify impact on `stories.yml`
5. Considering the impact from step 4, verify impact on `feature.yml`

### 5. Generate Feedback Document
Based on the verification results, write out the issues and recommended corrections:

1. Check if a feedback file already exists at `{{baseDir}}/{{specDir}}/feedback.md`
2. If the file exists, append new content to the `Comment`, `TODO`, and `Summary` sections
3. If the file does not exist, create a new file following the format specified in the "Output Format" section below

**IMPORTANT**: All content must be written in **Japanese**.

---

## Execution Example

**Command**:
```
/teamkit:feedback YourFeature "施設の削除機能が必要です"
```

**Process**:
1. Verify arguments are provided
2. Check `specs/YourFeature/status.json` exists
3. Analyze the feedback: "施設の削除機能が必要です"
4. Verify impact across all specification files
5. Generate or update `specs/YourFeature/feedback.md`

---

## Output Format

### Output Example

The generated `feedback.md` should follow this structure:

```markdown

# Comment
- 1. {{Feedback comment 1}}
<!-- Add a feedback comment item when the user submits from this command -->

# TODO
- [ ] 1. {{short name of correction item 1 from feedback 1}}
- [ ] 2. {{short name of correction item 2 from feedback 1}}
- [ ] 3. {{short name of correction item 3 from feedback 1}}
<!-- Continue adding newly found items -->

# Summary
## 1. {{short name of correction item 1 from feedback 1}}
- Comment: {{Feedback comment 1}}
- Issue: {{specifically what the problem is}}
- Recommended action: {{how to fix it}}
- Notes: 
  - feature: {{if any notes or consideration if the user applies the action to this step}}
  - story: {{if any notes or consideration if the user applies the action to this step}}
  - usecase: {{if any notes or consideration if the user applies the action to this step}}
  - ui: {{if any notes or consideration if the user applies the action to this step}}
  - screenflow: {{if any notes or consideration if the user applies the action to this step}}


## 2. {{short name of correction item 2 from feedback 1}}
- Comment: {{Feedback comment 1}}
- Issue: {{specifically what the problem is}}
- Recommended action: {{how to fix it}}
- Notes: 
  - feature: {{if any notes or consideration}}
  - story: {{if any notes or consideration}}
  - usecase: {{if any notes or consideration}}
  - ui: {{if any notes or consideration}}
  - screenflow: {{if any notes or consideration}}

<!-- Continue for all correction items -->

```

### Output Location
- **Directory**: `{{baseDir}}/{{specDir}}`
- **Filename**: `feedback.md`
