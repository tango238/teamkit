---
description: Generate mock HTML files from UI and screen flow
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir>
---

# Setup

1.  **Set `commandName`**: `generate-mock`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/teamkit:generate-mock <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---

<if condition="!$1">
echo "エラー: specDirを指定してください。"
echo "使用法: /generate-mock [specDir]"
exit 1
</if>

if [ ! -f ".teamkit/{{specDir}}/status.json" ] || [ ! -f ".teamkit/{{specDir}}/workflow.yml" ]; then
  echo "エラー: status.json または workflow.yml が存在しません。/generate-workflow を実行してください。"
  exit 1
fi

echo "モックHTMLを生成しています: .teamkit/{{specDir}}/mock/"

# Generate Mock HTML
$ llm_prompt context=".teamkit/{{specDir}}/ui.yml" context=".teamkit/{{specDir}}/screenflow.md"

---

## Mission

Generate mock HTML files based on UI definitions (`ui.yml`) and screen flow diagrams (`screenflow.md`). Create an index page, screen list tracker, and individual mock screens with proper navigation and minimal styling.

**IMPORTANT:** Execute the following steps immediately without asking the user for confirmation.

---

## Execution Steps

### 1. Read Input Files

Read the following files:
- `{{baseDir}}/{{specDir}}/ui.yml`
- `{{baseDir}}/{{specDir}}/screenflow.md`

### 2. Check Status (Direct Read - No SlashCommand)

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Extract `version` from the `screenflow` step in the `steps` array
3. Set this as `{{targetVersion}}`
4. Extract `version` from the `mock` section - this is `{{currentVersion}}`
5. **Validation**:
   - If `{{currentVersion}}` >= `{{targetVersion}}` → Display "スキップ: mock は既に最新です (version {{currentVersion}})" and **STOP**
   - If `{{targetVersion}}` - `{{currentVersion}}` > 1 → Display warning but continue
   - Otherwise → Continue execution

### 3. Generate Index Page

Create `{{baseDir}}/{{specDir}}/mock/index.html` (in the mock subdirectory).

**Key Requirements:**
- Extract feature name from directory name and README.md
- Group screens by category headers (##) from `screenflow.md`
- All links must use `mock/` prefix (e.g., `href="mock/facility_list.html"`)
- Include a flow diagram section summarizing the main screen flow

#### Output Example

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>【Feature Name】- Mock Screen List</title>
    <style>
        body {
            font-family: sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            font-size: 28px;
            margin-bottom: 10px;
            color: #333;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        .category {
            margin-bottom: 40px;
        }
        .category h2 {
            font-size: 20px;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #007bff;
            color: #007bff;
        }
        .screen-list {
            list-style: none;
            padding: 0;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 15px;
        }
        .screen-list li a {
            display: block;
            padding: 15px 20px;
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            text-decoration: none;
            color: #333;
            transition: all 0.2s;
        }
        .screen-list li a:hover {
            background: #007bff;
            color: white;
            border-color: #007bff;
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0,123,255,0.3);
        }
        .screen-list li a .title {
            font-weight: bold;
            font-size: 16px;
            margin-bottom: 5px;
        }
        .screen-list li a .description {
            font-size: 13px;
            color: #666;
        }
        .screen-list li a:hover .description {
            color: #e0e0e0;
        }
        .flow-diagram {
            background: #e7f3ff;
            padding: 20px;
            border-radius: 4px;
            margin-bottom: 30px;
            border-left: 4px solid #007bff;
        }
        .flow-diagram h3 {
            font-size: 16px;
            margin-bottom: 10px;
            color: #007bff;
        }
        .flow-diagram p {
            font-size: 14px;
            line-height: 1.6;
            color: #333;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>【Feature Name】 - Mock Screen List</h1>
        <p class="subtitle">【Description from dirName and README.md】</p>

        <div class="flow-diagram">
            <h3>Main Screen Flow</h3>
            <p>【Summarize main flow from screenflow.md】</p>
        </div>

        <!-- Group by Category -->
        <div class="category">
            <h2>【Category Name】</h2>
            <ul class="screen-list">
                <li>
                    <a href="mock/screen_name.html">
                        <div class="title">Screen Name</div>
                        <div class="description">Screen Description</div>
                    </a>
                </li>
            </ul>
        </div>
    </div>
</body>
</html>
```

### 4. Create Screen List Tracker

Create `{{baseDir}}/{{specDir}}/mock/screens.yml` to track generation progress.

**Steps:**
1. Extract all screen names from `screenflow.md` in order
2. Convert screen names to alphanumeric filenames (e.g., "Order Basic Info List" -> `order_list`)
3. Create directory `{{baseDir}}/{{specDir}}/mock` if it doesn't exist
4. Generate `screens.yml` with unchecked items

**Important:**
- Do not include file extensions (.html), only the screen ID
- Use `screenflow.md` headers (##) as comments for categorization
- Mark completed screens with `- [x]`

#### Output Format

```yaml
screens:
  # Category Name (Extracted from screenflow.md headers)
  - [ ] screen_id
  - [ ] another_screen_id
```

### 5. Generate Mock HTML Files

Process each `- [ ]` screen in `screens.yml` one by one and generate HTML files in `{{baseDir}}/{{specDir}}/mock/`.

#### 5-1. Basic HTML Structure

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>【Screen Name】</title>
    <style>
        /* Minimal simple style */
        body { font-family: sans-serif; margin: 20px; }
        h1 { font-size: 24px; margin-bottom: 20px; }
        /* Add only necessary minimal styles */
    </style>
</head>
<body>
    <!-- Screen Content -->
</body>
</html>
```

#### 5-2. UI Element Implementation Guidelines

**Form Elements (from `ui.yml`):**
- Wrap each input item in `.form-group`
- Use `<label>` tags; add `<span class="required">*</span>` for required fields
- Specify character limits and validation conditions in `placeholder` or `.note`
- Implement multi-language items with tab switching (Japanese/English)

**Table Display (List Screens):**
- Use `<table>` to display list data
- Put headers in `<thead>`
- Include 2-3 items of sample data (use property management domain knowledge)
- Place "Edit" and "Delete" buttons in an operation column

**Button Placement:**
- Register/Update button → Transition to list screen (`*_list.html`)
- Delete button → Transition to delete confirmation dialog (`*_delete_dialog.html`)
- New Registration button → Transition to form screen (`*_form.html`)
- Cancel button → Return to previous screen (usually list)

**Screen Transition Implementation:**
```html
<button onclick="location.href='next_screen.html'">Button Name</button>
```

#### 5-3. Design Principles

- **Minimal Decoration:** Borders, padding, basic coloring only
- **Focus:** Input types, display content, screen transition flow
- **Layout:** Simple vertical stacking, use grid if necessary
- **Color Scheme:** 
  - Gray background: #f5f5f5
  - Primary color: #007bff
  - Success: #28a745
  - Delete: #dc3545

### 6. Update Progress

After creating each mock HTML file, update the corresponding line in `screens.yml` from `- [ ]` to `- [x]`.

### 7. Update Status (Direct Write - No SlashCommand)

1. Get current timestamp in ISO format: `date -u +"%Y-%m-%dT%H:%M:%S"`
2. Read `{{baseDir}}/{{specDir}}/status.json`
3. Update the `mock` section with:
   - `version`: Set to `{{targetVersion}}` (from Step 2)
   - `last_modified`: Set to the timestamp obtained
4. Update `last_execution`: Set to `generate-mock`
5. Update `updated_at`: Set to current timestamp
6. Save the modified `status.json`

---

## Output Quality Checklist

Verify the following before completing:
- [ ] All screens are generated as HTML files
- [ ] Transition links between screens are set correctly
- [ ] Returns to list screen after Register/Update/Delete
- [ ] Multi-language items are implemented with tab switching
- [ ] All screens are accessible from `index.html`
- [ ] Design is minimal and simple
- [ ] All items from `ui.yml` are reflected

---

## Execution Example

### List Screen Example

```html
<div class="filters">
    <input type="text" placeholder="Search Order ID" />
    <button class="btn">Search</button>
</div>
<div class="actions">
    <button class="btn btn-primary" onclick="location.href='order_form.html'">New Order</button>
</div>
<table>
    <thead>
        <tr><th>Order ID</th><th>Customer</th><th>Status</th><th>Action</th></tr>
    </thead>
    <tbody>
        <tr>
            <td>ORD-001</td>
            <td>Logistics Co., Ltd.</td>
            <td>Shipped</td>
            <td>
                <button onclick="location.href='order_form.html'">Edit</button>
                <button onclick="location.href='order_delete_dialog.html'">Delete</button>
            </td>
        </tr>
    </tbody>
</table>
```

### Form Screen Example (Multi-language)

```html
<div class="tabs">
    <button class="tab active" onclick="switchTab('ja')">Japanese</button>
    <button class="tab" onclick="switchTab('en')">English</button>
</div>
<div class="tab-content active" data-lang="ja">
    <div class="form-group">
        <label>Product Name (Japanese)<span class="required">*</span></label>
        <input type="text" maxlength="100" />
        <span class="note">Within 100 characters</span>
    </div>
</div>
<div class="actions">
    <button class="btn btn-primary" onclick="location.href='product_list.html'">Register</button>
    <button class="btn btn-cancel" onclick="location.href='product_list.html'">Cancel</button>
</div>
```