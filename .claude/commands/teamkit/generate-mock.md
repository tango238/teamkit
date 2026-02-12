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

Generate lo-fi wireframe mock HTML files based on UI definitions (`ui.yml`) and screen flow diagrams (`screenflow.md`). Create an index page, screen list tracker, and individual mock screens with proper navigation. All screens must use a **hand-drawn wireframe aesthetic** (monochrome, sketchy borders, placeholder feel) and be **responsive** for mobile and A4 portrait screenshot capture.

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
        * { box-sizing: border-box; }
        body {
            font-family: "Segoe UI", system-ui, sans-serif;
            margin: 0;
            padding: 16px;
            background: #fafafa;
            color: #333;
        }
        .container {
            max-width: 960px;
            margin: 0 auto;
            background: #fff;
            padding: 24px;
            border: 2px solid #333;
        }
        h1 {
            font-size: 22px;
            margin-bottom: 8px;
            border-bottom: 2px solid #333;
            padding-bottom: 8px;
        }
        .subtitle {
            color: #666;
            margin-bottom: 24px;
            font-size: 13px;
        }
        .category { margin-bottom: 32px; }
        .category h2 {
            font-size: 16px;
            margin-bottom: 12px;
            padding-bottom: 6px;
            border-bottom: 1px dashed #999;
            color: #333;
        }
        .screen-list {
            list-style: none;
            padding: 0;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 12px;
        }
        .screen-list li a {
            display: block;
            padding: 12px 16px;
            background: #f5f5f5;
            border: 1.5px solid #999;
            text-decoration: none;
            color: #333;
        }
        .screen-list li a:hover {
            background: #e8e8e8;
            border-color: #333;
        }
        .screen-list li a .title {
            font-weight: bold;
            font-size: 14px;
            margin-bottom: 4px;
        }
        .screen-list li a .description {
            font-size: 12px;
            color: #666;
        }
        .flow-diagram {
            background: #f0f0f0;
            padding: 16px;
            margin-bottom: 24px;
            border: 1.5px solid #999;
            border-left: 4px solid #333;
        }
        .flow-diagram h3 {
            font-size: 14px;
            margin-bottom: 8px;
        }
        .flow-diagram p {
            font-size: 13px;
            line-height: 1.6;
            margin: 0;
        }
        @media (max-width: 600px) {
            body { padding: 8px; }
            .container { padding: 16px; }
            .screen-list { grid-template-columns: 1fr; }
            h1 { font-size: 18px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>【Feature Name】 - Screen List</h1>
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

All mock screens MUST include the following base CSS for consistent wireframe styling and responsive layout.

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>【Screen Name】</title>
    <style>
        /* === Wireframe Base === */
        * { box-sizing: border-box; }
        body {
            font-family: "Segoe UI", system-ui, sans-serif;
            margin: 0; padding: 16px;
            background: #fafafa; color: #333;
        }
        .container { max-width: 960px; margin: 0 auto; background: #fff; padding: 24px; border: 2px solid #333; }
        h1 { font-size: 20px; border-bottom: 2px solid #333; padding-bottom: 8px; margin-bottom: 16px; }
        h2 { font-size: 16px; border-bottom: 1px dashed #999; padding-bottom: 6px; margin-top: 24px; }

        /* === Wireframe Form === */
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-weight: bold; font-size: 13px; margin-bottom: 4px; }
        .form-group .required { color: #c00; margin-left: 2px; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 8px; font-size: 14px;
            border: 1.5px solid #999; background: #fff;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            outline: none; border-color: #333;
        }
        .form-group .note { font-size: 11px; color: #888; margin-top: 2px; }

        /* === Wireframe Table === */
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        th, td { padding: 8px 10px; border: 1px solid #bbb; text-align: left; }
        th { background: #eee; font-weight: bold; white-space: nowrap; }
        .table-wrap { overflow-x: auto; -webkit-overflow-scrolling: touch; }

        /* === Wireframe Buttons === */
        .btn {
            display: inline-block; padding: 8px 20px; font-size: 13px;
            border: 1.5px solid #333; background: #fff; color: #333; cursor: pointer;
        }
        .btn:hover { background: #eee; }
        .btn-primary { background: #333; color: #fff; }
        .btn-primary:hover { background: #555; }
        .btn-danger { border-color: #999; color: #999; }
        .btn-danger:hover { background: #f5f5f5; }
        .btn-cancel { border-color: #999; color: #666; }
        .actions { margin-top: 20px; display: flex; gap: 8px; flex-wrap: wrap; }

        /* === Wireframe Filters === */
        .filters { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 16px; align-items: end; }
        .filters input, .filters select { padding: 6px 8px; border: 1.5px solid #999; font-size: 13px; }

        /* === Wireframe Tabs === */
        .tabs { display: flex; gap: 0; border-bottom: 2px solid #333; margin-bottom: 16px; }
        .tab { padding: 8px 16px; border: 1.5px solid #999; border-bottom: none; background: #f5f5f5; cursor: pointer; font-size: 13px; margin-bottom: -2px; }
        .tab.active { background: #fff; border-color: #333; font-weight: bold; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* === Wireframe Breadcrumb === */
        .breadcrumb { font-size: 12px; color: #888; margin-bottom: 12px; }
        .breadcrumb a { color: #666; text-decoration: underline; }

        /* === Wireframe Dialog === */
        .dialog-overlay { background: rgba(0,0,0,0.3); position: fixed; inset: 0; display: flex; align-items: center; justify-content: center; }
        .dialog { background: #fff; border: 2px solid #333; padding: 24px; max-width: 480px; width: 90%; }
        .dialog h2 { border: none; margin-top: 0; }

        /* === Responsive === */
        @media (max-width: 600px) {
            body { padding: 8px; }
            .container { padding: 12px; }
            h1 { font-size: 17px; }
            .form-group input, .form-group select, .form-group textarea { font-size: 16px; /* prevent zoom on iOS */ }
            .actions { flex-direction: column; }
            .actions .btn { width: 100%; text-align: center; }
            .filters { flex-direction: column; }
            .filters input, .filters select { width: 100%; }
            th, td { padding: 6px; font-size: 12px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="breadcrumb">
            <a href="../index.html">Top</a> &gt; 【Screen Name】
        </div>
        <h1>【Screen Name】</h1>
        <!-- Screen Content -->
    </div>
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
- Wrap `<table>` in `<div class="table-wrap">` for horizontal scroll on mobile
- Use `<table>` to display list data
- Put headers in `<thead>`
- Include 2-3 items of sample data (use domain knowledge)
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

#### 5-3. Design Principles (Lo-fi Wireframe)

- **Wireframe Aesthetic:** Use the base CSS from 5-1. Do NOT add shadows, gradients, rounded corners, or colorful styling. The mock should look like a hand-drawn wireframe sketch, not a finished product.
- **Monochrome Palette:** Black (#333), gray (#999, #bbb, #eee, #f5f5f5), white only. No brand colors (no blue, green, red highlights). The only exception is `.required` marker in red (#c00).
- **Solid Borders:** Use `1.5px solid` or `2px solid` borders. Use `dashed` borders for section dividers. No `border-radius`.
- **Focus:** Input types, display content, screen transition flow — NOT visual polish.
- **Layout:** Single-column vertical stacking. Use flexbox/grid only where needed (filters, action buttons). Ensure all content flows naturally on narrow viewports.
- **Responsive:** All screens must be readable at 375px width (mobile) through 960px (desktop). Tables must be wrapped in `.table-wrap` for horizontal scroll. Form inputs must be `width: 100%`.
- **Breadcrumb:** Every screen must have a breadcrumb with a link back to `../index.html`.
- **No External Dependencies:** All CSS must be inline `<style>`. No CDN links, no external fonts, no JavaScript frameworks.

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
- [ ] Design follows lo-fi wireframe style (monochrome, solid borders, no shadows/gradients/rounded corners)
- [ ] All screens are responsive (readable at 375px mobile width)
- [ ] Tables are wrapped in `.table-wrap` for horizontal scroll
- [ ] Every screen has a breadcrumb with link to `../index.html`
- [ ] All items from `ui.yml` are reflected

---

## Execution Example

### List Screen Example

```html
<div class="breadcrumb">
    <a href="../index.html">Top</a> &gt; 受注一覧
</div>
<h1>受注一覧</h1>
<div class="filters">
    <input type="text" placeholder="受注IDで検索" />
    <button class="btn">検索</button>
</div>
<div class="actions">
    <button class="btn btn-primary" onclick="location.href='order_form.html'">新規受注</button>
</div>
<div class="table-wrap">
    <table>
        <thead>
            <tr><th>受注ID</th><th>顧客名</th><th>ステータス</th><th>操作</th></tr>
        </thead>
        <tbody>
            <tr>
                <td>ORD-001</td>
                <td>物流株式会社</td>
                <td>出荷済み</td>
                <td>
                    <button class="btn" onclick="location.href='order_form.html'">編集</button>
                    <button class="btn btn-danger" onclick="location.href='order_delete_dialog.html'">削除</button>
                </td>
            </tr>
        </tbody>
    </table>
</div>
```

### Form Screen Example (Multi-language)

```html
<div class="breadcrumb">
    <a href="../index.html">Top</a> &gt; <a href="product_list.html">商品一覧</a> &gt; 商品登録
</div>
<h1>商品登録</h1>
<div class="tabs">
    <button class="tab active" onclick="switchTab('ja')">日本語</button>
    <button class="tab" onclick="switchTab('en')">English</button>
</div>
<div class="tab-content active" data-lang="ja">
    <div class="form-group">
        <label>商品名（日本語）<span class="required">*</span></label>
        <input type="text" maxlength="100" placeholder="100文字以内" />
        <span class="note">100文字以内で入力してください</span>
    </div>
</div>
<div class="actions">
    <button class="btn btn-primary" onclick="location.href='product_list.html'">登録</button>
    <button class="btn btn-cancel" onclick="location.href='product_list.html'">キャンセル</button>
</div>
```