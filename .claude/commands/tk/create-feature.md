
# Setup

1.  **Set `commandName`**: `create-feature`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/tk-create-feature <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`feature.yml`) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---

# Feature Creation Command

## Purpose
Extract necessary features from the requirements in `{{baseDir}}/{{specDir}}/README.md` and document them in YAML format.
Execute the following process immediately without asking for user confirmation.

## Execution Steps

### 1. Pre-check 1
- **Target File**: `{{baseDir}}/{{specDir}}/README.md`
- **Existing File Handling**:
  - If the files already exist → Proceed to Step 2.
  - If the files does not exist → Display the message "Error: `README.md` does not exist. Please create it." and **STOP** execution immediately.

### 2. Pre-check 2
- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Existing File Handling**:
  - If the `status.json` already exists and the `feature.yml` does not exist → Display the message "Error: `status.json` already exists, but `feature.yml` does not exist. Please delete `status.json` and re-run this command." and **STOP** execution immediately.
  - If the files already exist → Display the message "Error: `status.json` and `feature.yml` already exist. Please use `/tk-check` or `/tk-update-feature` to modify it." and **STOP** execution immediately.
  - If the files do not exist → Proceed to Step 3.

### 3. Read Input
- Read `{{baseDir}}/{{specDir}}/README.md`.
- Understand the requirements, objectives, use cases, etc., within the README.

### 4. Feature Extraction
Extract features from the content of README.md considering the following:

**Considerations**:
- What the user wants to achieve (Objectives)
- Specific functions the system should provide
- Granularity of features: Split into units that provide a cohesive value
- Relationships and dependencies between features

**Examples of Good Feature Definitions**:
- ✅ Specific: "Create, Edit, and Delete Orders"
- ✅ Clear Value: "Send Low Stock Alert Email"
- ❌ Ambiguous: "Order Management"
- ❌ Technical Implementation: "Database CRUD Operations"

### 5. Generate YAML File (feature.yml)

**Output Format**:
```yaml
actor:
  - name: Actor Name (Concise name representing the role)
    description: Detailed description of responsibilities

feature:
  - name: Feature Name (Concise and specific)
    description: Detailed description (What, Why, Who)
    scenarios:
      - name: Scenario Name (e.g., Success flow, Error flow)
        precondition: Precondition
        steps:
          - Step 1
          - Step 2
        postcondition: Postcondition
  - name: Next Feature Name
    ...
```

**Writing Rules**:
-   **Language**: All content (values) must be in **Japanese**.
-   `name`: Express the essence of the feature in one line (Recommended: within 30 characters).
-   `description`: Explain the purpose of the feature, target users, and the value it realizes (approx. 2-3 sentences).
-   `scenarios`: Include basic scenarios (success paths) derived from the README.
-   Arrange features in a logical order (e.g., Data Registration → Editing → Deletion → Display).

### 6. Save File
- Save the generated content as `{{baseDir}}/{{specDir}}/feature.yml`.
- Execute the save automatically without asking for user confirmation.

### 7. Create Status File
- 1. Create `{{baseDir}}/{{specDir}}/status.json`
- 2. Retrieve the checksum and mtime of `README.md` and set them to `{{checksum}}` and `{{mtime}}` respectively.
- 3. Get the current time and set it to `{{currentTime}}`.
- 4. Update the content of `status.json` with the following structure:

```
{
    "feature_name": "{{specDir}}",
    "created_at": "{{currentTime}}",
    "updated_at": "{{currentTime}}",
    "language": "ja",
    "last_execution": "{{commandName}}",
    "log": "logs",
    "readme": {
        "checksum": "{{checksum}}",
        "last_modified": "{{mtime}}"
    },
    "steps": [
        {
            "feature": {
                "version": 0,
                "checksum": ""
                "last_modified": ""
            }
        },
        {
            "story": {
                "version": 0,
                "checksum": "",
                "last_modified": ""
            }
        },
        {
            "usecase": {
                "version": 0,
                "checksum": "",
                "last_modified": ""
            }
        },
        {
            "ui": {
                "version": 0,
                "checksum": "",
                "last_modified": ""
            }
        },
        {
            "screenflow": {
                "version": 0,
                "checksum": "",
                "last_modified": ""
            }
        }
    ],
    "mock": {
        "version": 0,
        "last_modified": ""
    }
}
```

### 8. Set Version Number
- {{versionNumber}} に `1` を設定します。

### 9. Update Status
- `/tk-update-status {{specDir}} {{commandName}} {{versionNumber}}` を実行し、ステータスを更新します。



## Execution Example

### Input (README.md)
```markdown
# Order Management System
A system for warehouse managers to efficiently process orders.
Allows creating, editing, and canceling orders.
Includes automatic notification to customers.
```

### Output (feature.yml)
```yaml
actor:
  - name: Warehouse Manager
    description: Person responsible for managing order processing and inventory.

feature:
  - name: Create, Edit, and Delete Orders
    description: Allows the manager to create, modify, and cancel orders. Supports manual entry and bulk import.
    scenarios:
      - name: Manual Order Creation
        precondition: Manager is logged in
        steps:
          - Open order creation screen
          - Enter customer info and items
          - Click save button
        postcondition: Order is created and inventory is reserved
  - name: Order Search and Filtering
    description: Search and filter orders by date, customer name, status, etc.
    scenarios:
      - name: Check Today's Shipments
        precondition: Orders exist
        steps:
          - Open order list screen
          - Set date filter to "Today"
        postcondition: Only orders scheduled for today are displayed
  - name: Automatic Customer Notification
    description: Automatically send email or SMS to customers upon order confirmation, shipping, etc.
    scenarios:
      - name: Send Order Confirmation Email
        precondition: New order is created
        steps:
          - System detects new order
          - System sends confirmation email to customer
        postcondition: Customer receives email
```

## Notes
-   **No User Confirmation**: This command is fully automated.
-   **Japanese Output**: Ensure all status messages to the user are in Japanese. Generated YAML content should be in Japanese.