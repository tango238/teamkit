---
description: Generate screen flow diagram from use cases and UI
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir> [--tmp]
---

# Setup

1.  **Set `commandName`**: `generate-screenflow`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
4.  **Get `isTmp`**: Check if the second argument is `--tmp`.
    -   If `--tmp` is provided, set `isTmp` to `true`.
    -   Otherwise, set `isTmp` to `false`.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`workflow.yml`) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---



# Check Argument
// turbo
if [ -z "{{specDir}}" ]; then
    echo "エラー: specDir 引数が指定されていません。使用法: /generate-screenflow [specDir]"
    exit 1
fi

echo "画面遷移図を生成しています: .teamkit/{{specDir}}/screenflow.md"

# Generate Screen Flow
$ llm_prompt context=".teamkit/{{specDir}}/usecase.yml" context=".teamkit/{{specDir}}/ui.yml"

# Instruction
Please follow the steps in the Execution Steps section.
Do not ask the user and execute immediately.

## Mission

Read `usecase.yml` and `ui.yml` under `.teamkit/{{specDir}}`, and generate a comprehensive screen flow
diagram in Markdown format that visualizes the user journey across all features. The purpose is to provide developers and
stakeholders with a clear understanding of how different screens connect and what the complete user experience looks like.

**IMPORTANT**: The output content (descriptions, headers, notes, etc.) MUST be in **Japanese**.

## Success Criteria

1. Both `.teamkit/{{specDir}}/usecase.yml` and `.teamkit/{{specDir}}/ui.yml` have been read completely
2. All user flows (Host and Admin) are visualized in ASCII/text-based diagrams
3. Critical transitions and decision points are clearly marked
4. Related use cases are referenced for each screen transition
5. If `.teamkit/{{specDir}}/screenflow.md` doesn't exist, it is newly created
6. If `.teamkit/{{specDir}}/screenflow.md` already exists, it is updated with new flows while preserving existing content structure
7. The output is well-formatted Markdown with clear hierarchy and navigation aids
8. **All output text is in Japanese.**

## Execution Steps

### 1. Pre-check
- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/workflow.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Existing File Handling**:
  - If some of the files do not exist → Display the message "Error: `status.json` or `workflow.yml` does not exist. Please run /clean"

### 2. Check Status (Direct Read - No SlashCommand)

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Extract `version` from the `ui` step in the `steps` array
3. Set this as `{{targetVersion}}`
4. Extract `version` from the `screenflow` step - this is `{{currentVersion}}`
5. **Validation**:
   - If `{{currentVersion}}` >= `{{targetVersion}}` → Display "スキップ: screenflow は既に最新です (version {{currentVersion}})" and **STOP**
   - If `{{targetVersion}}` - `{{currentVersion}}` > 1 → Display warning but continue
   - Otherwise → Continue execution

### 3. Load Context

- Read `.teamkit/{{specDir}}/usecase.yml` to understand all use cases and their sequences
- Read `.teamkit/{{specDir}}/ui.yml` to understand all screens, inputs, actions, and transitions
- Identify distinct user roles (e.g., Host, Platform Admin)
- If files cannot be read, report that and exit

### 4. Extract Screen Information

- List all screens from `ui.yml` `view` object (each key is a screen ID, e.g., `order_list`, `order_form`)
- For each screen, use `title` for display name and `actor` for grouping
- Identify fields from `sections` → `input_fields`, and structured `actions` for each screen
- Map screen transitions from `actions` with `type: "navigate"` and `to` property (target screen ID)
- Note conditional flows (e.g., "if validation fails", "if no active bookings")

### 5. Map Use Cases to Screens

- Match each use case from `usecase.yml` to corresponding screens in `ui.yml`
- Identify multi-screen flows that span multiple use cases
- Note dependencies between features (e.g., "Payment method must be registered before ordering")

### 6. Identify User Journeys

Extract complete user journeys such as:
- Initial onboarding (registration → account creation → first login)
- Authentication flows (login → 2FA → dashboard)
- Settings updates (edit profile → save → view history)
- Order processing (create order → approval → shipping)

### 7. Create Flow Diagrams

Generate ASCII-based flow diagrams using:
- `[Screen Name]` for screens
- `↓` for sequential flow
- `├─→` for branching options
- `→` for navigation
- Indentation for hierarchy
- Annotations for conditions (e.g., "if error", "on success")

Example format (Logistics Domain):
[1] Dashboard
↓ select shipment
[2] Shipment Details (if status is pending)
├─→ [3] Edit Shipment (action: edit)
└─→ [4] Cancel Shipment (action: cancel)

### 8. Document Key Transitions

For critical transitions, document:
- Trigger: What action causes the transition
- Condition: What must be true for transition to succeed
- Related Use Case: Reference to `usecase.yml`
- Notes: Any special considerations

### 9. Prepare Output File
- **Determine Output Filename**:
  - If `isTmp` is `true` → Set `outputFile` to `screenflow_tmp.md`.
  - If `isTmp` is `false` → Set `outputFile` to `screenflow.md`.

- Output destination is always `.teamkit/{{specDir}}/{{outputFile}}`
- If file doesn't exist, create it with the template structure below
- If file exists, update relevant sections while preserving structure
- Ensure all diagrams are properly formatted and readable

### 10. Quality Check

- Verify all screens from `ui.yml` are represented
- Ensure all major use cases have corresponding flows
- Check that conditional branches are clearly marked
- Confirm that related models and validations are referenced where relevant
- **Verify that the output language is Japanese.**

### 11. Update Status (Direct Write - No SlashCommand)

1. Get the MD5 checksum of the saved file: `md5 -q {{baseDir}}/{{specDir}}/{{outputFile}}`
2. Get current timestamp in ISO format: `date -u +"%Y-%m-%dT%H:%M:%S"`
3. Read `{{baseDir}}/{{specDir}}/status.json`
4. Update the `screenflow` step with:
   - `version`: Set to `{{targetVersion}}` (from Step 2)
   - `checksum`: Set to the MD5 hash obtained
   - `last_modified`: Set to the timestamp obtained
5. Update `last_execution`: Set to `generate-screenflow`
6. Update `updated_at`: Set to current timestamp
7. Save the modified `status.json`


## Output Specification

**LANGUAGE REQUIREMENT**: All content in the generated markdown file MUST be in **Japanese**.
This includes:
- All Headers (e.g., "Screen Flow", "Overview", "User Roles") must be translated to Japanese.
- All Descriptions and Notes must be in Japanese.
- Screen names should match `ui.yml` (if `ui.yml` has Japanese names, use them; if English, keep them or use Japanese aliases if appropriate, but usually keep exact match).
- Diagram annotations (e.g., "if error") should be in Japanese.

## Output Format Template

`.teamkit/{{specDir}}/screenflow.md` should have the following structure (Translate headers to Japanese):

  ```markdown
  # Screen Flow - [Feature Name]

  ## Overview
  [Brief description of what this feature accomplishes and who uses it]

  ## User Roles
  - **[Role 1]**: [Description]
  - **[Role 2]**: [Description]

  ## [Role 1] User Flows

  ### Main Flow: [Flow Name]
  [ASCII diagram of the main user journey]

  Related Use Cases:
  - [Use case reference]

  ### Alternative Flow: [Flow Name]
  [ASCII diagram of alternative paths]

  ## [Role 2] User Flows

  [Similar structure for other roles]

  ## Key Transitions

  ### [Transition Name]
  - **From**: [Screen A]
  - **To**: [Screen B]
  - **Trigger**: [Action that causes transition]
  - **Condition**: [What must be true]
  - **Related Use Case**: [Reference to use-cases.yml]
  - **Notes**: [Any special considerations]

  ## Integration Points
  [Document where external systems are involved, e.g., Stripe, Email]

  ## Error Flows
  [Document error states and recovery paths]

  ## Notes
  [Any additional context or considerations]
  ```

  Important Constraints

  - Do NOT modify `usecase.yml` or `ui.yml`
  - Ensure diagrams are properly formatted and use consistent notation
  - Keep descriptions concise but complete
  - Use exact screen `title` values from `ui.yml` for display, and screen IDs (object keys) for references
  - Reference use case line numbers or identifiers when possible
  - Preserve existing content structure if `screenflow.md` already exists
  - **Output MUST be in Japanese.**

  Error Scenarios & Fallback

  - If YAML files don't exist or can't be read:
    - Output "必要なYAMLファイルが見つからないため、画面遷移図を生成できませんでした" and don't create `screenflow.md`
  - If YAML files have broken structure:
    - Document which elements couldn't be parsed and create partial flow with available data
  - If `screenflow.md` exists but has non-standard structure:
    - Append new content at the end with proper headings rather than trying to merge