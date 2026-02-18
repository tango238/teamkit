# mokkun: teamkit ui.yml 互換性の検証と対応

## 背景

[teamkit](https://github.com/tango238/teamkit) は、YAML ベースの仕様生成パイプラインを持つ AI 駆動開発ツールです。パイプラインの中で `ui.yml` を生成し、そこから HTML モックを AI が生成していましたが、トークン消費が大きく auto compaction による待ち時間がチーム作業のボトルネックになっていました。

この問題を解決するため、teamkit の `ui.yml` スキーマを mokkun 互換フォーマットに刷新しました。これにより、AI による HTML 生成を経由せず、teamkit が生成した `ui.yml` を mokkun に直接読み込ませてブラウザ上でモック表示する運用が可能になります。

## teamkit が生成する ui.yml の形式

teamkit の `generate-ui` コマンドが出力する ui.yml は以下の形式です。mokkun の `schema.json` に準拠していますが、teamkit 固有のメタデータプロパティが追加されています。

### 全体構造

```yaml
view:
  screen_id:                    # snake_case のオブジェクトキー（例: order_list, order_form）
    title: "画面名"
    description: "画面の説明"
    actor: "アクター名"          # teamkit 固有
    purpose: "目的"              # teamkit 固有

    sections:
      - section_name: "セクション名"
        input_fields:
          - id: "field_id"
            type: "field_type"
            label: "フィールド名"
            required: true
            description: "説明"
            placeholder: "プレースホルダー"
            # ... type-specific properties

    actions:
      - id: "action_id"
        type: "submit|navigate|custom|reset"
        label: "ボタン名"
        style: "primary|secondary|danger|link"
        to: "target_screen_id"
        confirm:
          title: "確認タイトル"
          message: "確認メッセージ"

    # teamkit 固有メタデータ（mokkun はレンダリング時に無視してよい）
    related_models:
      - "ModelName"
    integration:
      - "Service (Operation)"
    related_usecases:
      - "ユースケース参照文字列"

common_components:
  - component_name: "コンポーネント名"
    description: "説明"
    type: "field_group|action_group|layout|template"
    used_in: ["screen_id_a", "screen_id_b"]

validations:
  - field: "field_id"
    rule: "validation_rule_name"
```

### teamkit が使用するフィールドタイプ一覧

#### 入力フィールド
| type | 固有プロパティ |
|---|---|
| `text` | `input_type` (email/password/tel/url), `max_length`, `min_length` |
| `textarea` | `rows`, `max_length`, `resizable` |
| `number` | `min`, `max`, `step`, `unit` |
| `select` | `options: [{value, label}]`, `clearable` |
| `radio_group` | `options: [{value, label, description?}]`, `direction` (horizontal/vertical) |
| `multi_select` | `options: [{value, label}]`, `max_selections` |
| `checkbox_group` | `options: [{value, label}]`, `direction` (horizontal/vertical) |
| `checkbox` | `label_position` (left/right) |
| `toggle` | `checked_label`, `unchecked_label`, `size` |
| `date_picker` | `format` |
| `time_picker` | `use_24_hour`, `minute_step` |
| `duration_picker` | `units` |
| `duration_input` | `format`, `display_unit` |
| `combobox` | `searchable`, `options: [{value, label}]` |
| `image_uploader` | `max_files`, `max_file_size`, `accepted_formats` |
| `file_upload` | `multiple`, `max_files`, `max_size`, `accept`, `drag_drop` |
| `photo_manager` | `max_photos`, `columns` |
| `repeater` | `min_items`, `max_items`, `add_button_label`, `sortable`, `item_fields: [...]` |

#### データ表示
| type | 固有プロパティ |
|---|---|
| `data_table` | `columns: [{id, label, sortable, width, format, status_map}]`, `data: [...]`, `row_actions: [{id, label, style, confirm}]`, `selection`, `pagination: {enabled, page_size}`, `striped`, `hoverable` |

#### 表示・装飾
| type | 固有プロパティ |
|---|---|
| `heading` | `level` (2/3/4) |
| `badge` | `count`, `color` |
| `chip` | — |
| `status_label` | — |
| `timeline` | — |
| `definition_list` | — |
| `notification_bar` | `description` |
| `information_panel` | `description` |
| `tooltip` | `content`, `position`, `show_arrow` |
| `loader` | `loader_size`, `show_progress` |

#### レイアウト・ナビゲーション
| type | 固有プロパティ |
|---|---|
| `tabs` | — |
| `accordion_panel` | — |
| `disclosure` | — |
| `section_nav` | — |
| `stepper` | — |
| `pagination` | `total_items`, `current_page`, `page_size` |
| `float_area` | `position`, `float_align` |

### teamkit ui.yml の具体例

#### リスト画面

```yaml
view:
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

#### フォーム画面

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

#### 設定画面（toggle + visible_when）

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

## タスク

上記の teamkit ui.yml フォーマットを mokkun で正しくレンダリングできるか検証し、問題があれば対応してください。

### 1. teamkit 固有プロパティの扱い

teamkit の ui.yml には mokkun の `schema.json` にないプロパティが含まれます。これらはパース・レンダリング時にエラーにならず、無視される必要があります：

- 画面レベル: `actor`, `purpose`, `related_models`, `integration`, `related_usecases`
- コンポーネントレベル: `used_in` (common_components 内)

**確認**: `schema.json` で `additionalProperties: false` が設定されている場合、バリデーションでエラーになる可能性があります。teamkit 固有プロパティを許容するように `additionalProperties: true` にするか、明示的にプロパティを追加してください。

### 2. フィールドタイプの網羅性テスト

上記「teamkit が使用するフィールドタイプ一覧」の全タイプについて、mokkun で正しくレンダリングされるかテストしてください。特に以下を重点的に確認：

- `data_table` の `status_map` によるステータス表示
- `data_table` の `row_actions` に `confirm` がある場合の削除確認ダイアログ
- `repeater` の `item_fields`（`fields` ではなく `item_fields`）プロパティ名
- `combobox` の `searchable` オプション
- `toggle` の `checked_label` / `unchecked_label`
- `visible_when` による条件付きフィールド表示
- `radio_group` の `direction: "vertical"` と options 内の `description`

### 3. 画面間ナビゲーション

teamkit の ui.yml は複数画面を含みます。`actions` の `type: "navigate"` + `to: "screen_id"` で画面遷移を定義しています。

- mokkun がこのナビゲーションを正しくハンドリングし、画面切り替えができるか確認
- `to` の値は view オブジェクトのキー名（例: `"order_list"`, `"order_form"`）

### 4. sections レンダリング

teamkit は必ず `sections` を使います。各セクションは `section_name` と `input_fields` を持ちます。

- `section_name` がセクション見出しとして表示されるか
- 複数セクションが正しく区切られて表示されるか

### 5. テストケースの追加

上記の具体例（リスト画面、フォーム画面、設定画面）を使って、テストケースを追加してください。

テストファイルは `examples/teamkit-compat.yaml` として配置し、mokkun のデモで読み込めるようにしてください。
