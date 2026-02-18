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

### ui.yml Format

The `ui.yml` uses an **object map** format where:
- `view` is an object with screen IDs as keys (e.g., `order_list`, `order_form`)
- Each screen has `title`, `description`, `actor`, `purpose`
- Fields are organized in `sections` → `input_fields` (each field has `id`, `type`, `label`)
- Actions are structured objects with `id`, `type`, `label`, `style`, `to`
- Options use `{value, label}` format
- List screens use `data_table` type with `columns`, `data`, `row_actions`

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
- Screen links use the screen ID as filename: `href="mock/{screen_id}.html"` (screen IDs are the keys of the `view` object in `ui.yml`)
- Use `title` and `description` from each screen definition for display
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

        <!-- Group by Category from screenflow.md headers -->
        <div class="category">
            <h2>【Category Name】</h2>
            <ul class="screen-list">
                <li>
                    <a href="mock/screen_id.html">
                        <div class="title">【screen.title from ui.yml】</div>
                        <div class="description">【screen.description from ui.yml】</div>
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
1. Extract all screen IDs from the `view` object keys in `ui.yml`
2. The screen ID is already in snake_case format (e.g., `order_list`, `order_form`)
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
    <title>【screen.title】</title>
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

        /* === Wireframe Section === */
        .section { margin-bottom: 24px; }
        .section-title { font-size: 15px; font-weight: bold; border-bottom: 1px dashed #999; padding-bottom: 6px; margin-bottom: 12px; }

        /* === Wireframe Toggle === */
        .toggle-group { margin-bottom: 16px; }
        .toggle-group label { font-weight: bold; font-size: 13px; margin-bottom: 4px; display: block; }
        .toggle { display: inline-flex; align-items: center; gap: 8px; font-size: 13px; }
        .toggle-switch { width: 44px; height: 24px; border: 1.5px solid #999; background: #eee; display: inline-block; position: relative; cursor: pointer; }
        .toggle-switch::after { content: ""; position: absolute; width: 18px; height: 18px; top: 2px; left: 2px; background: #999; transition: 0.2s; }
        .toggle-switch.on { background: #ccc; border-color: #333; }
        .toggle-switch.on::after { left: 22px; background: #333; }

        /* === Wireframe Radio/Checkbox Group === */
        .radio-group, .checkbox-group { margin-bottom: 16px; }
        .radio-group label.group-label, .checkbox-group label.group-label { display: block; font-weight: bold; font-size: 13px; margin-bottom: 8px; }
        .radio-option, .checkbox-option { display: block; padding: 4px 0; font-size: 13px; }
        .radio-option.horizontal, .checkbox-option.horizontal { display: inline-block; margin-right: 16px; }
        .option-description { display: block; font-size: 11px; color: #888; margin-left: 20px; }

        /* === Wireframe Repeater === */
        .repeater { border: 1.5px solid #999; padding: 12px; margin-bottom: 16px; }
        .repeater-item { border-bottom: 1px dashed #ccc; padding: 8px 0; display: flex; gap: 8px; align-items: end; flex-wrap: wrap; }
        .repeater-item:last-child { border-bottom: none; }
        .repeater-add { margin-top: 8px; }

        /* === Wireframe Pagination === */
        .pagination { display: flex; gap: 4px; align-items: center; margin-top: 12px; font-size: 13px; }
        .pagination .page { padding: 4px 10px; border: 1px solid #999; cursor: pointer; }
        .pagination .page.active { background: #333; color: #fff; border-color: #333; }
        .pagination .page-info { margin-left: 12px; color: #888; }

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
            <a href="../index.html">Top</a> &gt; 【screen.title】
        </div>
        <h1>【screen.title】</h1>
        <!-- Screen Content: render each section -->
    </div>
</body>
</html>
```

#### 5-2. UI Element Rendering Rules (from `ui.yml`)

For each screen, iterate over `sections` and render each `input_fields` entry based on its `type`.

**Field-to-HTML Mapping:**

| `type` in ui.yml | HTML Rendering |
|---|---|
| `text` | `<input type="{input_type or text}">` in `.form-group` |
| `textarea` | `<textarea rows="{rows or 4}">` in `.form-group` |
| `number` | `<input type="number" min="{min}" max="{max}" step="{step}">` with `unit` suffix |
| `select` | `<select>` with `<option>` for each item in `options` |
| `radio_group` | Radio buttons in `.radio-group`; use `direction` for layout |
| `checkbox_group` | Checkboxes in `.checkbox-group`; use `direction` for layout |
| `checkbox` | Single `<input type="checkbox">` with label |
| `toggle` | `.toggle` with `.toggle-switch` + `checked_label`/`unchecked_label` |
| `combobox` | `<input type="text" list="...">` + `<datalist>` or `<select>` with search |
| `date_picker` | `<input type="date">` in `.form-group` |
| `time_picker` | `<input type="time">` in `.form-group` |
| `duration_picker` | `<select>` for value + `<select>` for unit |
| `duration_input` | `<input type="number">` + unit label |
| `multi_select` | Multiple checkboxes or multi-select element |
| `file_upload` | `<input type="file">` with accept and description |
| `image_uploader` | File input with image preview placeholder |
| `photo_manager` | Grid of image placeholders with add button |
| `repeater` | `.repeater` with sample rows from `item_fields`; add/remove buttons |
| `data_table` | `<table>` in `.table-wrap` with columns from `columns`, sample data from `data`, `row_actions` in last column, pagination below |
| `heading` | `<h{level}>` tag |
| `badge` | `<span>` with count and label |
| `tabs` | `.tabs` with tab buttons |
| `accordion_panel` | Collapsible section with toggle |
| `disclosure` | Show/hide toggle section |
| `pagination` | `.pagination` with page numbers |

**Section Rendering:**
- Each `section` in ui.yml becomes an `<h2>` heading (from `section_name`) followed by rendered fields
- Wrap each section in `.section` div

**Action Rendering:**
- Actions are structured objects: use `style` to determine CSS class
  - `primary` → `.btn .btn-primary`
  - `secondary` → `.btn .btn-cancel`
  - `danger` → `.btn .btn-danger`
  - `link` → `<a>` style text link
- For `type: "navigate"`: use `onclick="location.href='{to}.html'"` with the `to` screen ID
- For `type: "submit"`: use standard button
- For actions with `confirm`: add `onclick="if(confirm('{message}')) ..."`

**Required Fields:**
- If `required: true`, add `<span class="required">*</span>` after the label text

**Description/Notes:**
- If `description` exists, render as `<span class="note">{description}</span>` below the input

**Data Table Rendering (List Screens):**
- Render `columns` as `<thead>` headers (use `label` property)
- Render `data` array as `<tbody>` rows
- Add a final "操作" column for `row_actions` (buttons with `label` and optional `style`)
- Wrap in `.table-wrap` for mobile scroll
- If `pagination` is configured, add `.pagination` below the table

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
- [ ] All screens from `view` object in `ui.yml` are generated as HTML files
- [ ] All `sections` and `input_fields` are rendered in each screen
- [ ] Transition links between screens use correct screen IDs (from `actions[].to`)
- [ ] `data_table` columns, sample data, and row_actions are rendered correctly
- [ ] All screens are accessible from `index.html`
- [ ] Design follows lo-fi wireframe style (monochrome, solid borders, no shadows/gradients/rounded corners)
- [ ] All screens are responsive (readable at 375px mobile width)
- [ ] Tables are wrapped in `.table-wrap` for horizontal scroll
- [ ] Every screen has a breadcrumb with link to `../index.html`
- [ ] Required fields show `*` marker
- [ ] Action buttons use correct style classes (primary/danger/secondary)

---

## Execution Example

### List Screen Example (from ui.yml data_table)

```html
<div class="breadcrumb">
    <a href="../index.html">Top</a> &gt; 受注一覧
</div>
<h1>受注一覧</h1>

<!-- Section: 検索・フィルター -->
<div class="section">
    <h2>検索・フィルター</h2>
    <div class="filters">
        <div class="form-group" style="flex:1; min-width:200px; margin-bottom:0;">
            <label>キーワード検索</label>
            <input type="text" placeholder="受注ID、顧客名で検索" />
        </div>
        <div class="form-group" style="min-width:150px; margin-bottom:0;">
            <label>ステータス</label>
            <select>
                <option value="">すべて</option>
                <option value="pending">処理中</option>
                <option value="shipped">出荷済み</option>
            </select>
        </div>
    </div>
</div>

<!-- Section: 受注一覧 (data_table) -->
<div class="section">
    <h2>受注一覧</h2>
    <div class="actions" style="margin-bottom:12px; margin-top:0;">
        <button class="btn btn-primary" onclick="location.href='order_form.html'">新規受注</button>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr><th>受注ID</th><th>顧客名</th><th>合計金額</th><th>ステータス</th><th>操作</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td>ORD-001</td>
                    <td>物流株式会社</td>
                    <td>¥150,000</td>
                    <td>出荷済み</td>
                    <td>
                        <button class="btn">編集</button>
                        <button class="btn btn-danger">削除</button>
                    </td>
                </tr>
                <tr>
                    <td>ORD-002</td>
                    <td>配送サービス</td>
                    <td>¥89,000</td>
                    <td>処理中</td>
                    <td>
                        <button class="btn">編集</button>
                        <button class="btn btn-danger">削除</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div class="pagination">
        <span class="page active">1</span>
        <span class="page">2</span>
        <span class="page">3</span>
        <span class="page-info">全20件中 1-10件</span>
    </div>
</div>
```

### Form Screen Example (sections with structured fields)

```html
<div class="breadcrumb">
    <a href="../index.html">Top</a> &gt; <a href="order_list.html">受注一覧</a> &gt; 受注登録
</div>
<h1>受注登録</h1>

<!-- Section: 基本情報 -->
<div class="section">
    <h2>基本情報</h2>
    <div class="form-group">
        <label>顧客名<span class="required">*</span></label>
        <input type="text" list="customer_list" placeholder="検索して選択" />
        <datalist id="customer_list">
            <option value="物流株式会社">
            <option value="配送サービス">
        </datalist>
    </div>
    <div class="form-group">
        <label>受注日<span class="required">*</span></label>
        <input type="date" />
    </div>
</div>

<!-- Section: 明細 (repeater) -->
<div class="section">
    <h2>明細</h2>
    <div class="repeater">
        <div class="repeater-item">
            <div class="form-group" style="flex:2;">
                <label>商品名<span class="required">*</span></label>
                <input type="text" />
            </div>
            <div class="form-group" style="flex:1;">
                <label>数量<span class="required">*</span></label>
                <input type="number" min="1" />
            </div>
            <div class="form-group" style="flex:1;">
                <label>単価<span class="required">*</span></label>
                <input type="number" /> <span class="note">円</span>
            </div>
            <button class="btn btn-danger" style="align-self:end;">✕</button>
        </div>
        <button class="btn repeater-add">明細を追加</button>
    </div>
</div>

<!-- Section: 配送 -->
<div class="section">
    <h2>配送</h2>
    <div class="radio-group">
        <label class="group-label">配送方法<span class="required">*</span></label>
        <label class="radio-option">
            <input type="radio" name="shipping_method" value="standard" /> 通常配送
            <span class="option-description">3-5営業日</span>
        </label>
        <label class="radio-option">
            <input type="radio" name="shipping_method" value="express" /> 速達
            <span class="option-description">翌営業日</span>
        </label>
    </div>
    <div class="form-group">
        <label>希望納品日</label>
        <input type="date" />
    </div>
    <div class="form-group">
        <label>備考</label>
        <textarea rows="4" placeholder="特記事項があれば入力してください"></textarea>
    </div>
</div>

<!-- Actions -->
<div class="actions">
    <button class="btn btn-primary">登録</button>
    <button class="btn btn-cancel" onclick="location.href='order_list.html'">キャンセル</button>
</div>
```
