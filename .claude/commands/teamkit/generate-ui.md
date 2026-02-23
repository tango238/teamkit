---
description: Generate UI definition from use cases
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir> [--tmp]
---

# Setup

1.  **Set `commandName`**: `generate-ui`
2.  **Set `baseDir`**: `.teamkit`
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
  - `{{baseDir}}/{{specDir}}/workflow.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Existing File Handling**:
  - If some of the files do not exist → Display the message "Error: `status.json` or `workflow.yml` does not exist. Please run /clean"

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
1. Read `{{baseDir}}/{{specDir}}/usecase.yml`

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

- `{{baseDir}}/{{specDir}}/usecase.yml`: Use cases defining interactions and steps.

# Task
Generate `{{baseDir}}/{{specDir}}/ui.yml` in YAML format.

# Output Requirement
- **Format**: YAML only. No markdown prose, no code blocks wrappers (unless necessary for the file itself), no explanations.
- **Language**: The content values (names, descriptions, labels) MUST be in **Japanese**. The keys and structure must be in English as defined in the schema.

# Schema & Rules

This schema is designed for compatibility with [mokkun](https://github.com/tango238/mokkun), a browser-based YAML-to-UI renderer. The generated `ui.yml` can be loaded directly in mokkun for instant mock preview without HTML generation.

## 1. Screen Extraction
- Analyze `usecase.yml` to identify necessary screens.
- Group screens by `actor` (e.g., Host, Guest, Platform).
- Combine related use cases into single screens where logical.
- For System actors, decide if a UI is needed (Management Console) or if it's a background process.

## 2. Screen Structure

The `view` is an **object map** where each key is a screen ID (snake_case alphanumeric). Each screen definition follows this structure:

```yaml
view:
  screen_id:
    title: "Screen Name (Japanese)"
    description: "Purpose/Description (Japanese)"
    actor: "Actor Name"
    purpose: "Purpose (Japanese)"

    # Sections - Group fields into logical sections
    sections:
      - section_name: "Section Name (Japanese)"
        input_fields:
          - id: "field_id"
            type: "field_type"
            label: "Field Label (Japanese)"
            # ... field-type-specific properties (see Field Types below)

    # Actions - Screen-level buttons with explicit targets
    actions:
      - id: "action_id"
        type: "submit|navigate|custom|reset"
        label: "Button Label (Japanese)"
        style: "primary|secondary|danger|link"
        to: "target_screen_id"           # For navigate type
        confirm:                          # Optional confirmation dialog
          title: "Confirmation Title"
          message: "Confirmation Message"

    # Metadata (for specification pipeline, ignored by renderer)
    related_models:
      - "ModelName"
    integration:
      - "Service (Operation)"
    related_usecases:
      - "Exact use_case string from usecase.yml"
```

### Screen ID Convention
- Use `snake_case` alphanumeric (e.g., `order_list`, `order_form`, `order_detail`)
- List screens: `*_list` (e.g., `order_list`)
- Form screens: `*_form` (e.g., `order_form`)
- Detail screens: `*_detail` (e.g., `order_detail`)
- Dialog/Confirm screens: `*_confirm` (e.g., `order_delete_confirm`)

## 3. Sections

Sections group related fields within a screen. Every screen MUST have at least one section.

```yaml
sections:
  - section_name: "基本情報"
    input_fields:
      - id: "product_name"
        type: "text"
        label: "商品名"
        required: true
      - id: "description"
        type: "textarea"
        label: "説明"

  - section_name: "配送設定"
    input_fields:
      - id: "shipping_method"
        type: "select"
        label: "配送方法"
        options:
          - value: "standard"
            label: "通常配送"
          - value: "express"
            label: "速達"
```

## 4. Field Types

### 4-1. Input Fields

All input fields share these common properties:

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | **Required**. Unique field ID within the screen (snake_case) |
| `type` | string | **Required**. Field type (see table below) |
| `label` | string | **Required**. Display label (Japanese) |
| `required` | boolean | Whether the field is required |
| `description` | string | Help text or notes (Japanese) |
| `placeholder` | string | Placeholder text |
| `readonly` | boolean | Read-only field |
| `default` | any | Default value |
| `validation` | object | Validation rules (e.g., `{required: "必須です", min: 2}`) |
| `visible_when` | object | Conditional visibility (see Conditions) |

#### Input Field Type Reference

| Requirement Example | Field Type | Type-Specific Properties |
|---|---|---|
| Product Name, Customer Name | `text` | `input_type` (email/password/tel/url), `max_length`, `min_length` |
| Description, Instructions | `textarea` | `rows`, `max_length`, `resizable` |
| Price, Quantity, Weight | `number` | `min`, `max`, `step`, `unit` |
| Category, Shipping Method | `select` | `options: [{value, label}]`, `clearable` |
| Delivery Time Slot | `radio_group` | `options: [{value, label, description?}]`, `direction` (horizontal/vertical) |
| Tags, Multiple Categories | `multi_select` | `options: [{value, label}]`, `max_selections` |
| Available Days | `checkbox_group` | `options: [{value, label}]`, `direction` (horizontal/vertical) |
| Single Agree | `checkbox` | `label_position` (left/right) |
| On/Off Setting | `toggle` | `checked_label`, `unchecked_label`, `size` (small/medium/large) |
| Delivery Date | `date_picker` | `format` (e.g., "YYYY-MM-DD") |
| Pickup Time (HH:MM) | `time_picker` | `use_24_hour`, `minute_step` |
| Duration (e.g. 2 hours) | `duration_picker` | `units: ["days", "hours", "minutes"]` |
| Warranty Period (e.g. 2 years) | `duration_input` | `format`, `display_unit` |
| Searchable Select | `combobox` | `searchable`, `options: [{value, label}]` |
| Product Image | `image_uploader` | `max_files`, `max_file_size`, `accepted_formats` |
| Invoice PDF, Attachments | `file_upload` | `multiple`, `max_files`, `max_size`, `accept`, `drag_drop` |
| Photo Gallery | `photo_manager` | `max_photos`, `columns` |
| Line Items (Product, Qty, Price) | `repeater` | `min_items`, `max_items`, `add_button_label`, `sortable`, `item_fields: [...]` |

### 4-2. Data Table (for List Screens)

Use `data_table` to define list/table views with columns, sample data, and row actions:

```yaml
- id: "order_table"
  type: "data_table"
  label: "受注一覧"
  columns:
    - id: "order_id"
      label: "受注ID"
      sortable: true
      width: "120px"
    - id: "customer_name"
      label: "顧客名"
      sortable: true
    - id: "status"
      label: "ステータス"
      format: "status"
      status_map:
        pending:
          label: "処理中"
          color: "warning"
        shipped:
          label: "出荷済み"
          color: "success"
  data:
    - order_id: "ORD-001"
      customer_name: "物流株式会社"
      status: "shipped"
    - order_id: "ORD-002"
      customer_name: "配送サービス"
      status: "pending"
  row_actions:
    - id: "edit"
      label: "編集"
    - id: "delete"
      label: "削除"
      style: "danger"
      confirm:
        title: "削除確認"
        message: "この受注を削除してもよろしいですか？"
  selection: "multiple"    # none/single/multiple
  pagination:
    enabled: true
    page_size: 10
    page_size_options: [10, 25, 50]
  striped: true
  hoverable: true
```

### 4-3. Display / Decoration Fields

Use these types for headings, status indicators, and informational elements within sections:

| Type | Purpose | Key Properties |
|---|---|---|
| `heading` | Section heading within content | `level` (2/3/4) |
| `badge` | Numeric indicator | `count`, `color` (blue/green/red) |
| `chip` | Tag / label | — |
| `status_label` | Status indicator | — |
| `timeline` | Activity timeline | — |
| `definition_list` | Key-value display (confirmation screens) | — |
| `notification_bar` | System notification | `description` |
| `information_panel` | Informational message | `description` |
| `tooltip` | Help tooltip | `content`, `position`, `show_arrow` |
| `loader` | Loading indicator | `loader_size`, `show_progress` |

### 4-4. Layout / Navigation Fields

| Type | Purpose | Key Properties |
|---|---|---|
| `tabs` | Tab navigation within screen | — |
| `accordion_panel` | Collapsible section | — |
| `disclosure` | Show/hide toggle | — |
| `section_nav` | Section navigation sidebar | — |
| `stepper` | Step progress indicator | — |
| `pagination` | Page navigation | `total_items`, `current_page`, `page_size` |
| `float_area` | Floating action area | `position`, `float_align` |

### 4-5. Additional Field Types (mokkun Extended)

mokkun が追加サポートするフィールドタイプ。必要に応じて利用可能。

| Type | Purpose | Key Properties |
|---|---|---|
| `google_map_embed` | Google Maps 地図埋め込み | `width`, `height`, `zoom`, `show_open_link` |
| `browser` | 階層型ナビゲーション選択 | `items: [{value, label, children?}]`, `max_columns` (default: 3) |
| `calendar` | 月ビューカレンダー日付選択 | `from`, `to` (ISO日付), `week_starts_on` (0=日/1=月), `locale` |
| `segmented_control` | ボタングループ単一選択 | `options: [{value, label}]`, `default` |
| `line_clamp` | テキスト省略表示（展開可能） | `lines` (1-6, default: 3), `text` |
| `response_message` | ステータスメッセージ表示 | `variant` (success/error/warning/info), `message`, `details` |
| `dropdown` | メニュー/フィルタ/ソート | `variant` (menu/filter/sort), `options: [{value, label}]` |
| `delete_confirm_dialog` | 削除確認ダイアログ | `message`, `title`, `targetName`, `targetType` |

## 5. Actions

Actions define buttons and their behavior. Each action MUST have:

```yaml
actions:
  - id: "action_id"           # Required: unique identifier
    type: "submit"             # Required: submit|navigate|custom|reset
    label: "ボタン名"           # Required: display label (Japanese)
    style: "primary"           # Required: primary|secondary|danger|link
    to: "target_screen_id"     # For navigate type: target screen ID
    confirm:                   # Optional: confirmation dialog
      title: "確認"
      message: "実行してもよろしいですか？"
```

### Action Type Guidelines
- **navigate**: Screen transition (specify `to` with target screen ID)
- **submit**: Form submission (specify `url` and `method` if needed)
- **custom**: Custom behavior (specify `handler` name)
- **reset**: Reset form to defaults

### Action Style Guidelines
- **primary**: Main positive action (Register, Save, Submit)
- **secondary**: Alternative action (Cancel, Back, Draft Save)
- **danger**: Destructive action (Delete, Remove)
- **link**: Text-style link action (Preview, Help)

## 6. Wizard (Multi-Step Forms)

For complex registration flows, use wizard configuration:

```yaml
wizard:
  layout: "horizontal"        # horizontal|vertical
  validate_on_step: true
  allow_back: true
  show_progress: true
  steps:
    - id: "step_id"
      title: "ステップ名"
      subtitle: "ステップの説明"
      fields:
        - id: "field_id"
          type: "text"
          label: "フィールド名"
          # ... same field properties as in sections
```

When a screen uses `wizard`, define the fields inside wizard `steps` instead of `sections`.

## 7. Conditions (Conditional Visibility)

Use `visible_when` to show/hide fields based on other field values:

```yaml
- id: "notification_frequency"
  type: "select"
  label: "通知頻度"
  visible_when:
    or:
      - field: "email_notifications"
        operator: "eq"
        value: true
      - field: "push_notifications"
        operator: "eq"
        value: true
```

Supported operators: `eq`, `ne`, `gt`, `gte`, `lt`, `lte`, `in`, `contains`, `empty`

## 8. Options Format

Options for `select`, `radio_group`, `multi_select`, `checkbox_group`, `combobox` MUST use the structured format:

```yaml
options:
  - value: "option_value"      # Programmatic value
    label: "表示名"             # Display label (Japanese)
    description: "説明"         # Optional: description for radio_group
```

**NEVER** use flat string arrays like `["Option1", "Option2"]`.

## 9. Common Components
Extract UI components used in 3+ screens.
```yaml
common_components:
  - name: "Component Name"
    description: "Description"
    type: "field_group|action_group|layout|template"
    used_in: ["screen_id_a", "screen_id_b"]
```

## 10. Validations
Extract business rules and validations from stories and use cases. ルートレベルにオブジェクトマップ形式で定義する。
```yaml
validations:
  title_required:
    rules:
      - required: true
      - min_length: 1
      - max_length: 100
    message: "タイトルは必須です（1〜100文字）"
  date_future:
    rules:
      - min: "today"
    message: "本日以降の日付を指定してください"
```

**IMPORTANT**:
- `validations` はルートレベルにのみ定義する。各画面の `view` 定義内には `validations` を含めないこと。
- オブジェクトマップ形式（`{ ruleName: { rules, message } }`）を使用する。配列形式 `[{ field, rule }]` は使用しない。

## 11. Screen Composition Examples

### List Screen Example

```yaml
order_list:
  title: "受注一覧"
  description: "受注を一覧表示・管理する"
  actor: "営業担当"
  purpose: "受注を一覧表示・管理する"
  sections:
    - section_name: "検索・フィルター"
      input_fields:
        - id: "search_keyword"
          type: "text"
          label: "キーワード検索"
          placeholder: "受注ID、顧客名で検索"
        - id: "status_filter"
          type: "select"
          label: "ステータス"
          options:
            - value: ""
              label: "すべて"
            - value: "pending"
              label: "処理中"
            - value: "shipped"
              label: "出荷済み"
          clearable: true
    - section_name: "受注一覧"
      input_fields:
        - id: "order_table"
          type: "data_table"
          label: "受注一覧"
          columns:
            - id: "order_id"
              label: "受注ID"
              sortable: true
            - id: "customer_name"
              label: "顧客名"
              sortable: true
            - id: "total_amount"
              label: "合計金額"
              sortable: true
            - id: "status"
              label: "ステータス"
              format: "status"
              status_map:
                pending:
                  label: "処理中"
                  color: "warning"
                shipped:
                  label: "出荷済み"
                  color: "success"
          data:
            - order_id: "ORD-001"
              customer_name: "物流株式会社"
              total_amount: "¥150,000"
              status: "shipped"
            - order_id: "ORD-002"
              customer_name: "配送サービス"
              total_amount: "¥89,000"
              status: "pending"
          row_actions:
            - id: "edit"
              label: "編集"
            - id: "delete"
              label: "削除"
              style: "danger"
              confirm:
                title: "受注削除"
                message: "この受注を削除してもよろしいですか？"
          pagination:
            enabled: true
            page_size: 10
          striped: true
          hoverable: true
  actions:
    - id: "add_order"
      type: "navigate"
      label: "新規受注"
      style: "primary"
      to: "order_form"
  related_usecases:
    - "受注を登録する"
    - "受注を一覧表示する"
```

### Form Screen Example

```yaml
order_form:
  title: "受注登録"
  description: "新規受注を登録する"
  actor: "営業担当"
  purpose: "新規受注を登録する"
  sections:
    - section_name: "基本情報"
      input_fields:
        - id: "customer_name"
          type: "combobox"
          label: "顧客名"
          required: true
          searchable: true
          options:
            - value: "customer_001"
              label: "物流株式会社"
            - value: "customer_002"
              label: "配送サービス"
        - id: "order_date"
          type: "date_picker"
          label: "受注日"
          required: true
          format: "YYYY-MM-DD"
    - section_name: "明細"
      input_fields:
        - id: "order_items"
          type: "repeater"
          label: "受注明細"
          min_items: 1
          max_items: 20
          add_button_label: "明細を追加"
          sortable: true
          item_fields:
            - id: "product_name"
              type: "text"
              label: "商品名"
              required: true
            - id: "quantity"
              type: "number"
              label: "数量"
              required: true
              min: 1
            - id: "unit_price"
              type: "number"
              label: "単価"
              required: true
              unit: "円"
    - section_name: "配送"
      input_fields:
        - id: "shipping_method"
          type: "radio_group"
          label: "配送方法"
          required: true
          direction: "vertical"
          options:
            - value: "standard"
              label: "通常配送"
              description: "3-5営業日"
            - value: "express"
              label: "速達"
              description: "翌営業日"
        - id: "delivery_date"
          type: "date_picker"
          label: "希望納品日"
        - id: "notes"
          type: "textarea"
          label: "備考"
          rows: 4
          placeholder: "特記事項があれば入力してください"
  actions:
    - id: "save"
      type: "submit"
      label: "登録"
      style: "primary"
    - id: "cancel"
      type: "navigate"
      label: "キャンセル"
      style: "secondary"
      to: "order_list"
  related_usecases:
    - "受注を登録する"
```

### Settings Screen with Toggles and Conditions

```yaml
notification_settings:
  title: "通知設定"
  description: "通知の有効/無効と頻度を設定する"
  actor: "管理者"
  purpose: "通知の有効/無効と頻度を設定する"
  sections:
    - section_name: "メール通知"
      input_fields:
        - id: "email_enabled"
          type: "toggle"
          label: "メール通知"
          checked_label: "有効"
          unchecked_label: "無効"
          default: true
        - id: "email_frequency"
          type: "select"
          label: "メール通知頻度"
          visible_when:
            field: "email_enabled"
            operator: "eq"
            value: true
          options:
            - value: "realtime"
              label: "リアルタイム"
            - value: "daily"
              label: "1日1回"
            - value: "weekly"
              label: "週1回"
  actions:
    - id: "save_settings"
      type: "submit"
      label: "保存"
      style: "primary"
      confirm:
        title: "設定を保存"
        message: "変更を保存してもよろしいですか？"
    - id: "reset"
      type: "reset"
      label: "リセット"
      style: "link"
```

## 12. Important Principles
- **Screen IDs**: Use descriptive snake_case IDs. The screen ID doubles as the HTML filename (e.g., `order_list` → `order_list.html`).
- **related_usecases**: Must match `usecase.yml` exactly.
- **input_fields**: Analyze `description` in use cases carefully to find all inputs.
- **Business Rules**: Include rules like "Cannot edit after shipment" in validations.
- **Options**: ALWAYS use `{value, label}` format. Never use flat string arrays.
- **Sections**: ALWAYS group fields into sections, even if there's only one section.
- **Actions**: ALWAYS use structured actions with `id`, `type`, `label`, `style`. Include `to` for navigation.
- **Navigation targets**: `to` で指定する遷移先は、同じ `actor` の画面に限定する。異なるアクターの画面への遷移は設計しない。
- **Data Tables**: For list/table screens, use `data_table` with columns, sample data (2-3 rows), and row_actions. Do NOT use flat `display_fields`.
