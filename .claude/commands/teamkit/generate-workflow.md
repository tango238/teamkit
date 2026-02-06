---
description: Create workflow.yml from README.md
allowed-tools: Bash, Read, Write, Grep, Glob, LS
argument-hint: <specDir>
---

# Setup

1.  **Set `commandName`**: `generate-workflow`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/generate-workflow <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`workflow.yml`) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.
-   **Do NOT use SlashCommand tool to call other teamkit commands.** Execute all logic directly within this command.

---

# Feature Creation Command

## Purpose
Extract necessary features from the requirements in `{{baseDir}}/{{specDir}}/README.md` and document them in YAML format.
Execute the following process immediately without asking for user confirmation.

## Execution Steps

### 1. Pre-check: README.md
- **Target File**: `{{baseDir}}/{{specDir}}/README.md`
- **Action**:
  - If the file exists → Proceed to Step 2.
  - If the file does not exist → Display the message "エラー: `README.md` が存在しません。作成してください。" and **STOP** execution immediately.

### 2. Check Status (Version Validation)
- **Target File**: `{{baseDir}}/{{specDir}}/status.json`
- **Action**:
  - If `status.json` exists:
    - Read `status.json`
    - Get `steps[0].workflow.version` as `currentVersion` (if not found, treat as `0`)
    - Calculate `diff = 1 - currentVersion`
    - If `diff > 1`: Display "エラー: バージョンが飛んでいます。現在のバージョン: {{currentVersion}}, 指定されたバージョン: 1" and **STOP**
    - If `diff <= 1`: Display "バージョンチェック: OK (現在: {{currentVersion}} -> 次: 1)" and proceed to Step 3
  - If `status.json` does not exist:
    - Proceed to Step 3 (will be created in Step 7)

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
- **External systems that interact with the system** (メール配信、決済、認証など)
- **Core aggregates (domain entities) that the system manages** (受注、顧客、商品など)
- **Domain events that occur in the system** (〜が作成された、〜が完了した、など)
- **Policies that react to events** (イベント発生時の自動処理ルール)

**Examples of Good Feature Definitions**:
- ✅ Specific: "Create, Edit, and Delete Orders"
- ✅ Clear Value: "Send Low Stock Alert Email"
- ❌ Ambiguous: "Order Management"
- ❌ Technical Implementation: "Database CRUD Operations"

### 5. Generate YAML File (workflow.yml)

**Output Format**:
```yaml
actor:
  - name: Actor Name (Concise name representing the role)
    description: Detailed description of responsibilities

external_system:
  - name: External System Name
    description: What this external system does and how it integrates

aggregate:
  - Aggregate Name 1
  - Aggregate Name 2

feature:
  - name: Feature Name (Concise and specific)
    description: Detailed description (What, Why, Who)
    events:
      - Event Name 1 (past tense: 〜が作成された, 〜が完了した)
      - Event Name 2
    policy:
      - name: Policy Name
        trigger: Event that triggers this policy
        action: What happens when triggered
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

**Event Storming Elements**:
-   `external_system`: List external services the system integrates with (e.g., payment gateway, email service, authentication provider). Include only systems explicitly mentioned or clearly implied in the README.
-   `aggregate`: List core domain entities as simple names. These represent the main "things" the system manages (e.g., 受注, 顧客, 商品, 在庫).
-   `events`: List domain events in past tense (〜された form). Events represent significant state changes in the system.
-   `policy`: Define automatic reactions to events. Each policy has:
    - `trigger`: The event that initiates the policy
    - `action`: What the system does in response

**Scenario Design Guidelines**:
シナリオは単純な操作ではなく、アクターが目的を達成するための**一連のフロー**として設計してください。

-   **アクター視点で考える**: アクターが「なぜ」その操作を行うのか、その背景や目的を理解した上でシナリオを構築する
-   **エンドツーエンドのフローを描く**: 単一の操作（例：「保存ボタンを押す」）ではなく、目的達成までの一連の流れを記述する
-   **現実的なユースケースを想定する**: 実際の業務や利用シーンを想像し、具体的な状況設定を行う

**良いシナリオの例**:
-   ✅ 「新規予約作成フロー」: 顧客からの電話を受け → 空き状況を確認 → 予約情報を入力 → 確認メールを送信
-   ✅ 「チケット購入フロー」: イベントを検索 → 座席を選択 → 支払い情報を入力 → 購入完了・チケット発行
-   ✅ 「管理者の在庫調整フロー」: 棚卸し結果を確認 → 差異がある商品を特定 → 在庫数を修正 → 調整履歴を記録
-   ✅ 「月次レポート作成フロー」: 対象期間を選択 → データを集計 → グラフを生成 → PDF出力・配信

**悪いシナリオの例**:
-   ❌ 「データを保存する」（単一操作、目的が不明確）
-   ❌ 「一覧画面を表示する」（操作の羅列、フローになっていない）
-   ❌ 「バリデーションエラーを表示する」（技術的な処理、アクター視点ではない）

### 6. Save File
- Save the generated content as `{{baseDir}}/{{specDir}}/workflow.yml`.
- Execute the save automatically without asking for user confirmation.

### 7. Create or Update Status File
- **If `status.json` does not exist**:
  - Retrieve the checksum of `README.md` using `md5 -q`
  - Retrieve the mtime of `README.md` using `stat -f "%Sm" -t "%Y-%m-%dT%H:%M:%S"`
  - Get the current time using `date -u +"%Y-%m-%dT%H:%M:%SZ"`
  - Create `{{baseDir}}/{{specDir}}/status.json` with the following structure:

```json
{
    "feature_name": "{{specDir}}",
    "created_at": "{{currentTime}}",
    "updated_at": "{{currentTime}}",
    "language": "Japanese",
    "last_execution": "generate-workflow",
    "readme": {
        "checksum": "{{README checksum}}",
        "last_modified": "{{README mtime}}"
    },
    "steps": [
        {
            "workflow": {
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

- **If `status.json` already exists**: Proceed to Step 8.

### 8. Update Status (Workflow Version)
- Read `{{baseDir}}/{{specDir}}/status.json`
- Retrieve the checksum of `workflow.yml` using `md5 -q`
- Retrieve the mtime of `workflow.yml` using `stat -f "%Sm" -t "%Y-%m-%dT%H:%M:%S"`
- Get the current time using `date -u +"%Y-%m-%dT%H:%M:%SZ"`
- Update `status.json` with:
  - `updated_at`: current time
  - `last_execution`: `generate-workflow`
  - `steps[0].workflow.version`: `1`
  - `steps[0].workflow.checksum`: checksum of `workflow.yml`
  - `steps[0].workflow.last_modified`: mtime of `workflow.yml`
- Save the updated `status.json`

### 9. Completion
- Display completion message: "workflow.yml の作成が完了しました。"
- Display summary of extracted features (feature names list)

## Execution Example

### Input (README.md)
```markdown
# Order Management System
A system for warehouse managers to efficiently process orders.
Allows creating, editing, and canceling orders.
Includes automatic notification to customers.
```

### Output (workflow.yml)
```yaml
actor:
  - name: 倉庫管理者
    description: 受注処理と在庫管理を担当する責任者。顧客からの注文を効率的に処理し、正確な出荷を実現することが主な目的。

external_system:
  - name: メール配信サービス
    description: 顧客への注文確認・出荷通知などのメールを自動送信する外部サービス

aggregate:
  - 受注
  - 顧客
  - 商品
  - 在庫

feature:
  - name: 受注の作成・編集・キャンセル
    description: 倉庫管理者が顧客からの注文を登録・変更・取消できる。手動入力と一括インポートの両方に対応し、日々の受注業務を効率化する。
    events:
      - 受注が作成された
      - 受注が編集された
      - 受注がキャンセルされた
    policy:
      - name: 在庫引当ポリシー
        trigger: 受注が作成された
        action: 注文商品の在庫を自動的に引き当てる
      - name: 在庫戻しポリシー
        trigger: 受注がキャンセルされた
        action: 引当済み在庫を解放して在庫数を戻す
    scenarios:
      - name: 電話受注から出荷指示までのフロー
        precondition: 倉庫管理者がログイン済み、在庫データが最新の状態
        steps:
          - 顧客から電話で注文を受ける
          - 受注画面を開き、顧客情報を検索・選択する
          - 注文商品と数量を入力し、在庫状況をリアルタイムで確認する
          - 配送希望日を確認し、出荷可能日を顧客に伝える
          - 受注内容を確定し、出荷指示を作成する
          - 顧客に注文確認メールを送信する
        postcondition: 受注が登録され、在庫が引当てられ、出荷指示が作成される
      - name: 受注内容の変更フロー
        precondition: 顧客から変更依頼があり、該当受注が出荷前の状態
        steps:
          - 受注番号または顧客名で該当受注を検索する
          - 受注詳細を開き、変更可能な状態か確認する
          - 商品の追加・削除・数量変更を行う
          - 在庫の再引当てを実行する
          - 変更後の金額と納期を顧客に連絡する
        postcondition: 受注内容が更新され、在庫引当てが再計算される

  - name: 顧客への自動通知
    description: 受注確定時、出荷時、配送完了時などのタイミングで顧客にメールを自動送信し、顧客の安心感を高める。
    events:
      - 通知メールが送信された
      - 通知送信が失敗した
    policy:
      - name: 受注確定通知ポリシー
        trigger: 受注が作成された
        action: 顧客に注文確認メールを送信する
      - name: 出荷完了通知ポリシー
        trigger: 出荷が完了した
        action: 追跡番号付きの発送完了メールを顧客に送信する
    scenarios:
      - name: 受注から配送完了までの通知フロー
        precondition: 顧客がメール通知を希望している
        steps:
          - 受注確定時に注文確認メールを自動送信する
          - 出荷準備完了時に出荷予定日を通知する
          - 運送業者への引き渡し時に追跡番号付きの発送完了メールを送信する
          - 配送完了情報を受信したら配達完了通知を送信する
        postcondition: 顧客が注文の各段階でステータスを把握できる
```

## Notes
-   **No User Confirmation**: This command is fully automated.
-   **Japanese Output**: Ensure all status messages to the user are in Japanese. Generated YAML content should be in Japanese.
-   **No SlashCommand Calls**: Do not call other slash commands (like `/teamkit:check-status` or `/teamkit:update-status`). Execute all logic directly.
