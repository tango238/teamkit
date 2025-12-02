---
description: Generate UI definition from use cases and stories
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir> [--tmp]
---

# Setup

1.  **Set `commandName`**: `generate-ui`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
4.  **Get `isTmp`**: Check if the second argument is `--tmp`.
    -   If `--tmp` is provided, set `isTmp` to `true`.
    -   Otherwise, set `isTmp` to `false`.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`ui.yml`) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---

## Execution Steps

### 1. Check arguments
```bash
if [ -z "$1" ]; then
  echo "Error: specDir argument is required. Usage: /generate-ui <specDir>"
  exit 1
fi
```

### 2. Pre-check
- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Existing File Handling**:
  - If some of the files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /clean"

### 3. Check Status (Direct Read - No SlashCommand)

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Extract `version` from the `usecase` step in the `steps` array
3. Set this as `{{targetVersion}}`
4. Extract `version` from the `ui` step - this is `{{currentVersion}}`
5. **Validation**:
   - If `{{currentVersion}}` >= `{{targetVersion}}` → Display "スキップ: ui は既に最新です (version {{currentVersion}})" and **STOP**
   - If `{{targetVersion}}` - `{{currentVersion}}` > 1 → Display warning but continue
   - Otherwise → Continue execution

### 4. Read input files
1. Read `{{baseDir}}/{{specDir}}/story.yml`
2. Read `{{baseDir}}/{{specDir}}/usecase.yml`
3. Read `{{baseDir}}/{{specDir}}/check.md` (check for `[x]` items)

### 5. Generate UI definition
- **Determine Output Filename**:
  - If `isTmp` is `true` → Set `outputFile` to `ui_tmp.yml`.
  - If `isTmp` is `false` → Set `outputFile` to `ui.yml`.

Generate `{{baseDir}}/{{specDir}}/{{outputFile}}` following the rules and schema defined below.

### 6. Update Status (Direct Write - No SlashCommand)

1. Get the MD5 checksum of the saved file: `md5 -q {{baseDir}}/{{specDir}}/{{outputFile}}`
2. Get current timestamp in ISO format: `date -u +"%Y-%m-%dT%H:%M:%S"`
3. Read `{{baseDir}}/{{specDir}}/status.json`
4. Update the `ui` step with:
   - `version`: Set to `{{targetVersion}}` (from Step 3)
   - `checksum`: Set to the MD5 hash obtained
   - `last_modified`: Set to the timestamp obtained
5. Update `last_execution`: Set to `generate-ui`
6. Update `updated_at`: Set to current timestamp
7. Save the modified `status.json`

---

# Context
You are an expert UI/UX designer and System Architect.

Your task is to generate a UI design document `{{baseDir}}/{{specDir}}/ui.yml` based on the following inputs:

- `{{baseDir}}/{{specDir}}/check.md`: Checklist containing status and specific instructions.
- `{{baseDir}}/{{specDir}}/story.yml`: User stories defining value and acceptance criteria.
- `{{baseDir}}/{{specDir}}/usecase.yml`: Use cases defining interactions and steps.

# Task
Generate `{{baseDir}}/{{specDir}}/ui.yml` in YAML format.

**CRITICAL**: You must read `check.md` carefully. 

Pay special attention to items marked as completed `[x]`, as they contain finalized decisions and instructions from the author that override or clarify other documents.

# Output Requirement
- **Format**: YAML only. No markdown prose, no code blocks wrappers (unless necessary for the file itself), no explanations.
- **Language**: The content values (names, descriptions, labels) MUST be in **Japanese**. The keys and structure must be in English as defined in the schema.

# Schema & Rules

## 1. Screen Extraction
- Analyze `usecase.yml` to identify necessary screens.
- Group screens by `actor` (e.g., Host, Guest, Platform).
- Combine related use cases into single screens where logical.
- For System actors, decide if a UI is needed (Management Console) or if it's a background process.

## 2. Screen Structure
Each screen in the YAML list `view` must follow this structure:

```yaml
view:
  - name: "Screen Name (Japanese)"
    actor: "Actor Name"
    purpose: "Purpose (Japanese)"

    # Input Fields (User entry)
    input_fields:
      - field_name: "Field Name (Japanese)"
        type: "Field Type (see below)"
        options: ["Option1", "Option2"] # For select/multi_select
        required: true
        unit: "Unit (if applicable)"
        description: "Description (Japanese)"
        validation: "Validation rules"
        placeholder: "Placeholder text"
        readonly: false
        default: "Default value"
        accepted_types: "file types" # For file_upload
        storage: "storage path" # For file_upload
        min_selection: 1 # For multi_select
        fields: [] # Sub-fields for repeater

    # Display Fields (Read-only info)
    display_fields:
      - "Field Name (Japanese)"

    # Tabs (If multiple sections exist)
    tabs:
      - "Tab Name"

    # Filters (For list views)
    filters:
      - "Filter Name"

    # Actions (Buttons, etc.)
    actions:
      - "Action Name"

    # Validations (Screen specific)
    validations:
      - "Screen specific validation rule"

    # Related Models
    related_models:
      - "ModelName"

    # Integrations
    integration:
      - "Service (Operation)"

    # Related Use Cases
    related_usecases:
      - "Exact use_case string from usecase.yml"
```

## 3. Field Types
Map requirements to these types. Use these Logistics/Sales examples as a guide:

| Requirement Example (Logistics/Sales) | Field Type        | Note                  |
|---------------------------------------|-------------------|-----------------------|
| Product Name, Customer Name           | `text`            | Single line text      |
| Description, Shipping Instructions    | `textarea`        | Multi-line text       |
| Price, Quantity, Weight               | `number`          | Numeric input         |
| Category, Shipping Method             | `select`          | Dropdown              |
| Delivery Time Slot                    | `radio_group`     | Radio selection       |
| Tags, Multiple Categories             | `multi_select`    | Multiple selection    |
| Available Days                        | `checkbox_group`  | Checkbox group        |
| Delivery Date                         | `date_picker`     | Date selection        |
| Pickup Time (HH:MM)                   | `time_picker`     | Time selection        |
| Duration (e.g. 2 hours)               | `duration_picker` | Duration selection    |
| Warranty Period (e.g. 2 years)        | `duration_input`  | Number + Unit         |
| Product Image, Invoice PDF            | `file_upload`     | File upload           |
| Line Items (Product, Qty, Price)      | `repeater`        | Dynamic list of items |

## 4. Grouping Example (Logistics Domain)
Organize screens logically. Example:

```yaml
# Warehouse Manager
- **Inventory Control**
  - Stock Adjustment Screen
  - Stock List Screen
- **Shipment Management**
  - Picking List Screen
  - Shipment Confirmation Screen

# Driver
- **Delivery**
  - Route View Screen
  - Delivery Completion Screen
```

## 5. Common Components
Extract UI components used in 3+ screens.
```yaml
common_components:
  - component_name: "Component Name"
    description: "Description"
    used_in: ["Screen A", "Screen B"]
```

## 6. Validations
Extract business rules and validations from stories and use cases.
```yaml
validations:
  - field: "Field Name"
    rule: "Validation Rule"
```

## 7. Important Principles
- **related_usecases**: Must match `usecase.yml` exactly.
- **input_fields**: Analyze `description` in use cases carefully to find all inputs.
- **Business Rules**: Include rules like "Cannot edit after shipment" in validations.

