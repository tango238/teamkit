
# Setup

1.  **Set `commandName`**: `generate-ui`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/tk-generate-ui <specDir>`" and **STOP** execution immediately.

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
  echo "Error: specDir argument is required. Usage: /tk-generate-ui <specDir>"
  exit 1
fi
```

### 2. Pre-check
- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Existing File Handling**:
  - If some of the files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /tk-clean"

### 3. Read input files
1. Read `{{baseDir}}/{{specDir}}/stories.yml`
2. Read `{{baseDir}}/{{specDir}}/usecases.yml`
3. Read `{{baseDir}}/{{specDir}}/check.md` (check for `[x]` items)

### 4. Generate UI definition
Generate `{{baseDir}}/{{specDir}}/ui.yml` following the rules and schema defined below.

### 5. Set Version Number
- `/tk-get-step-info {{specDir}} ui` を実行して、バージョン番号を取得し、{{versionNumber}} として設定します。

### 6. Update Status
- `/tk-update-status {{specDir}} {{commandName}} {{versionNumber}}` を実行し、ステータスを更新します。

---

# Context
You are an expert UI/UX designer and System Architect.

Your task is to generate a UI design document `{{baseDir}}/{{specDir}}/ui.yml` based on the following inputs:

- `{{baseDir}}/{{specDir}}/check.md`: Checklist containing status and specific instructions.
- `{{baseDir}}/{{specDir}}/stories.yml`: User stories defining value and acceptance criteria.
- `{{baseDir}}/{{specDir}}/usecases.yml`: Use cases defining interactions and steps.

### 4. Set Version Number
- `/tk-get-step-info {{specDir}} usecase` を実行して、バージョン番号を取得し、{{versionNumber}} として設定します。

### 5. Update Status
- `/tk-update-status {{specDir}} {{commandName}} {{versionNumber}}` を実行し、ステータスを更新します。


# Task
Generate `{{baseDir}}/{{specDir}}/ui.yml` in YAML format.

**CRITICAL**: You must read `check.md` carefully. 

Pay special attention to items marked as completed `[x]`, as they contain finalized decisions and instructions from the author that override or clarify other documents.

# Output Requirement
- **Format**: YAML only. No markdown prose, no code blocks wrappers (unless necessary for the file itself), no explanations.
- **Language**: The content values (names, descriptions, labels) MUST be in **Japanese**. The keys and structure must be in English as defined in the schema.

# Schema & Rules

## 1. Screen Extraction
- Analyze `usecases.yml` to identify necessary screens.
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
      - "Exact use_case string from usecases.yml"
```

## 3. Field Types
Map requirements to these types. Use these Logistics/Sales examples as a guide:

| Requirement Example (Logistics/Sales) | Field Type | Note |
|---------------------|------------|------|
| Product Name, Customer Name | `text` | Single line text |
| Description, Shipping Instructions | `textarea` | Multi-line text |
| Price, Quantity, Weight | `number` | Numeric input |
| Category, Shipping Method | `select` | Dropdown |
| Delivery Time Slot | `radio_group` | Radio selection |
| Tags, Multiple Categories | `multi_select` | Multiple selection |
| Available Days | `checkbox_group` | Checkbox group |
| Delivery Date | `date_picker` | Date selection |
| Pickup Time (HH:MM) | `time_picker` | Time selection |
| Duration (e.g. 2 hours) | `duration_picker` | Duration selection |
| Warranty Period (e.g. 2 years) | `duration_input` | Number + Unit |
| Product Image, Invoice PDF | `file_upload` | File upload |
| Line Items (Product, Qty, Price) | `repeater` | Dynamic list of items |

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
- **related_usecases**: Must match `usecases.yml` exactly.
- **input_fields**: Analyze `description` in use cases carefully to find all inputs.
- **Business Rules**: Include rules like "Cannot edit after shipment" in validations.

