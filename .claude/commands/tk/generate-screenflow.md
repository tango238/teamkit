
# Setup

1.  **Set `commandName`**: `generate-screenflow`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/tk-generate-screenflow <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`feature.yml`) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---



# Check Argument
// turbo
if [ -z "{{specDir}}" ]; then
    echo "エラー: specDir 引数が指定されていません。使用法: /tk-generate-screen-flow [specDir]"
    exit 1
fi

echo "画面遷移図を生成しています: specs/{{specDir}}/screen-flow.md"

# Generate Screen Flow
$ llm_prompt context="specs/{{specDir}}/usecases.yml" context="specs/{{specDir}}/ui.yml"

# Instruction
Please follow the steps in the Execution Steps section.
Do not ask the user and execute immediately.

## Mission

Read `usecases.yml` and `ui.yml` under `specs/{{specDir}}`, and generate a comprehensive screen flow
diagram in Markdown format that visualizes the user journey across all features. The purpose is to provide developers and
stakeholders with a clear understanding of how different screens connect and what the complete user experience looks like.

**IMPORTANT**: The output content (descriptions, headers, notes, etc.) MUST be in **Japanese**.

## Success Criteria

1. Both `specs/{{specDir}}/usecases.yml` and `specs/{{specDir}}/ui.yml` have been read completely
2. All user flows (Host and Admin) are visualized in ASCII/text-based diagrams
3. Critical transitions and decision points are clearly marked
4. Related use cases are referenced for each screen transition
5. If `specs/{{specDir}}/screen-flow.md` doesn't exist, it is newly created
6. If `specs/{{specDir}}/screen-flow.md` already exists, it is updated with new flows while preserving existing content structure
7. The output is well-formatted Markdown with clear hierarchy and navigation aids
8. **All output text is in Japanese.**

## Execution Steps

### 1. Pre-check
- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Existing File Handling**:
  - If some of the files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /tk-clean"

### 2. Load Context

- Read `specs/{{specDir}}/usecases.yml` to understand all use cases and their sequences
- Read `specs/{{specDir}}/ui.yml` to understand all screens, inputs, actions, and transitions
- Identify distinct user roles (e.g., Host, Platform Admin)
- If files cannot be read, report that and exit

### 3. Extract Screen Information

- List all screens from `ui.yml` grouped by actor
- Identify input fields, actions, and validations for each screen
- Map actions to screen transitions (e.g., "Login" button → "Authentication Code Screen")
- Note conditional flows (e.g., "if validation fails", "if no active bookings")

### 4. Map Use Cases to Screens

- Match each use case from `usecases.yml` to corresponding screens in `ui.yml`
- Identify multi-screen flows that span multiple use cases
- Note dependencies between features (e.g., "Payment method must be registered before ordering")

### 5. Identify User Journeys

Extract complete user journeys such as:
- Initial onboarding (registration → account creation → first login)
- Authentication flows (login → 2FA → dashboard)
- Settings updates (edit profile → save → view history)
- Order processing (create order → approval → shipping)

### 6. Create Flow Diagrams

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

### 7. Document Key Transitions

For critical transitions, document:
- Trigger: What action causes the transition
- Condition: What must be true for transition to succeed
- Related Use Case: Reference to `usecases.yml`
- Notes: Any special considerations

### 8. Prepare Output File

- Output destination is always `specs/{{specDir}}/screen-flow.md`
- If file doesn't exist, create it with the template structure below
- If file exists, update relevant sections while preserving structure
- Ensure all diagrams are properly formatted and readable

### 9. Quality Check

- Verify all screens from `ui.yml` are represented
- Ensure all major use cases have corresponding flows
- Check that conditional branches are clearly marked
- Confirm that related models and validations are referenced where relevant
- **Verify that the output language is Japanese.**

### 10. Set Version Number
- `/tk-get-step-info {{specDir}} ui` を実行して、バージョン番号を取得し、{{versionNumber}} として設定します。

### 11. Update Status
- `/tk-update-status {{specDir}} {{commandName}} {{versionNumber}}` を実行し、ステータスを更新します。


## Output Specification

**LANGUAGE REQUIREMENT**: All content in the generated markdown file MUST be in **Japanese**.
This includes:
- All Headers (e.g., "Screen Flow", "Overview", "User Roles") must be translated to Japanese.
- All Descriptions and Notes must be in Japanese.
- Screen names should match `ui.yml` (if `ui.yml` has Japanese names, use them; if English, keep them or use Japanese aliases if appropriate, but usually keep exact match).
- Diagram annotations (e.g., "if error") should be in Japanese.

## Output Format Template

`specs/{{specDir}}/screen-flow.md` should have the following structure (Translate headers to Japanese):

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

  - Do NOT modify `usecases.yml` or `ui.yml`
  - Ensure diagrams are properly formatted and use consistent notation
  - Keep descriptions concise but complete
  - Use exact screen names from `ui.yml`
  - Reference use case line numbers or identifiers when possible
  - Preserve existing content structure if `screen-flow.md` already exists
  - **Output MUST be in Japanese.**

  Error Scenarios & Fallback

  - If YAML files don't exist or can't be read:
    - Output "必要なYAMLファイルが見つからないため、画面遷移図を生成できませんでした" and don't create `screen-flow.md`
  - If YAML files have broken structure:
    - Document which elements couldn't be parsed and create partial flow with available data
  - If `screen-flow.md` exists but has non-standard structure:
    - Append new content at the end with proper headings rather than trying to merge