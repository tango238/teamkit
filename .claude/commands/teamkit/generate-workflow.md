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

# Workflow Creation Command

## Purpose
Extract workflows from the requirements in `{{baseDir}}/{{specDir}}/README.md` and document them in YAML format.
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
    - Get `readme.checksum` from `status.json` as `savedChecksum`
    - Calculate the current MD5 checksum of `{{baseDir}}/{{specDir}}/README.md` as `currentChecksum`
    - **Idempotency Check**: If `currentVersion >= 1` AND `savedChecksum == currentChecksum`:
      - Display "スキップ: workflow は既に最新です (README未変更, version {{currentVersion}})" and **STOP**
    - Calculate `diff = 1 - currentVersion`
    - If `diff > 1`: Display "エラー: バージョンが飛んでいます。現在のバージョン: {{currentVersion}}, 指定されたバージョン: 1" and **STOP**
    - If `diff <= 1`: Display "バージョンチェック: OK (現在: {{currentVersion}} -> 次: 1)" and proceed to Step 3
  - If `status.json` does not exist:
    - Proceed to Step 3 (will be created in Step 7)

### 3. Read Input
- Read `{{baseDir}}/{{specDir}}/README.md`.
- Understand the requirements, objectives, use cases, etc., within the README.

### 4. Workflow Extraction
Extract workflows from the content of README.md considering the following:

**Considerations**:
- What the user wants to achieve (Objectives)
- Specific functions the system should provide
- Granularity of workflows: Split into end-to-end flows that achieve a cohesive goal
- Relationships and dependencies between workflows
- **External systems that interact with the system** (メール配信、決済、認証など)
- **Core aggregates (domain entities) that the system manages** (受注、顧客、商品など)
- **Domain events that occur in the system** (〜が作成された、〜が完了した、など)
- **Policies that react to events** (イベント発生時の自動処理ルール)

**Examples of Good Workflow Definitions**:
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

workflow:
  - name: Workflow Name (e.g., 電話受注から出荷指示までのフロー)
    description: Detailed description of the end-to-end flow
    trigger: The event or action that initiates this workflow
    precondition: State required before workflow starts
    steps:
      - actor: Actor Name
        activity: What the actor does in this step
        aggregate: Target aggregate (optional)
      - actor: Actor Name
        activity: What the actor does in this step
        aggregate: Target aggregate (optional)
        event: Domain Event in past tense (optional)
      - actor: system
        activity: What the system does automatically
        aggregate: Target aggregate (optional)
        event: Domain Event in past tense (optional)
        policy: Policy Name (optional)
      - actor: External System Name
        activity: What the external system does
        event: Domain Event in past tense (optional)
        policy: Policy Name (optional)
    postcondition: State after workflow completes
  - name: Next Workflow Name
    ...
```

**Step Field Reference**:

| Field | Required | Description |
|-------|----------|-------------|
| `actor` | Yes | Who executes this step: an actor name from `actor`, an external system name from `external_system`, or `system` for policy-driven automation |
| `activity` | Yes | Concrete action performed in this step |
| `aggregate` | No | Target aggregate being operated on |
| `event` | No | Domain event produced by this step (past tense: 〜が作成された, 〜が完了した) |
| `policy` | No | Policy name when the step is triggered by an automated rule |

**Writing Rules**:
-   **Language**: All content (values) must be in **Japanese**.
-   `name`: Express the essence of the workflow in one line (Recommended: within 30 characters).
-   `description`: Explain the purpose of the workflow, target actors, and the value it realizes (approx. 2-3 sentences).
-   `trigger`: The initiating event or action that starts the workflow (e.g., 顧客から電話で注文を受ける).
-   `steps`: Each step must have `actor` and `activity`. Add `aggregate`, `event`, `policy` where applicable.
-   Arrange workflows in a logical order (e.g., main flow first, then alternative/exception flows).

**Event Storming Elements**:
-   `external_system`: List external services the system integrates with (e.g., payment gateway, email service, authentication provider). Include only systems explicitly mentioned or clearly implied in the README.
-   `aggregate`: List core domain entities as simple names. These represent the main "things" the system manages (e.g., 受注, 顧客, 商品, 在庫).
-   `event` (in steps): Domain events in past tense (〜された form). Events represent significant state changes in the system. Place them on the step where the state change occurs.
-   `policy` (in steps): Policy name for automated reactions. The `actor` should be `system` or an external system name when a policy drives the step.

**Actor Usage Guidelines**:
-   **Human actors**: Use the actor name defined in the top-level `actor` list (e.g., 倉庫管理者, 営業担当者)
-   **`system`**: Use for automated processing triggered by policies (e.g., 在庫引当、バリデーション)
-   **External systems**: Use the external system name defined in `external_system` (e.g., メール配信サービス, 決済サービス)

**Workflow Design Guidelines**:
ワークフローは単純な操作ではなく、アクターが目的を達成するための**一連のフロー**として設計してください。
各ステップに actor を明示することで、スイムレーン図の生成が可能になります。

-   **アクター視点で考える**: アクターが「なぜ」その操作を行うのか、その背景や目的を理解した上でフローを構築する
-   **エンドツーエンドのフローを描く**: 単一の操作（例：「保存ボタンを押す」）ではなく、目的達成までの一連の流れを記述する
-   **現実的なユースケースを想定する**: 実際の業務や利用シーンを想像し、具体的な状況設定を行う
-   **イベントとポリシーをステップに埋め込む**: ドメインイベントが発生するステップには `event` を、ポリシー駆動のステップには `policy` を付与する

**良いワークフローの例**:
-   ✅ 「新規予約作成フロー」: 受付担当者が電話を受け → 空き状況を確認 → 予約情報を入力 → system が確認メールを送信
-   ✅ 「チケット購入フロー」: 購入者がイベントを検索 → 座席を選択 → 決済サービスが支払い処理 → system がチケット発行
-   ✅ 「管理者の在庫調整フロー」: 管理者が棚卸し結果を確認 → 差異がある商品を特定 → 在庫数を修正 → system が調整履歴を記録
-   ✅ 「月次レポート作成フロー」: 管理者が対象期間を選択 → system がデータを集計 → グラフを生成 → PDF出力・配信

**悪いワークフローの例**:
-   ❌ 「データを保存する」（単一操作、目的が不明確）
-   ❌ 「一覧画面を表示する」（操作の羅列、フローになっていない）
-   ❌ actor が省略されたステップ（スイムレーン図が生成できない）

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
- Display summary of extracted workflows (workflow names list)

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

workflow:
  - name: 電話受注から出荷指示までのフロー
    description: 倉庫管理者が顧客からの電話注文を受けて出荷指示を作成するまでのフロー
    trigger: 顧客から電話で注文を受ける
    precondition: 倉庫管理者がログイン済み、在庫データが最新の状態
    steps:
      - actor: 倉庫管理者
        activity: 顧客情報を検索・選択する
        aggregate: 顧客
      - actor: 倉庫管理者
        activity: 注文商品と数量を入力し在庫状況を確認する
        aggregate: 受注
      - actor: 倉庫管理者
        activity: 配送希望日を確認し出荷可能日を顧客に伝える
        aggregate: 受注
      - actor: 倉庫管理者
        activity: 受注内容を確定し出荷指示を作成する
        aggregate: 受注
        event: 受注が作成された
      - actor: system
        activity: 注文商品の在庫を引き当てる
        aggregate: 在庫
        event: 在庫が引き当てられた
        policy: 在庫引当ポリシー
      - actor: メール配信サービス
        activity: 顧客に注文確認メールを送信する
        event: 通知メールが送信された
        policy: 受注確定通知ポリシー
    postcondition: 受注が登録され、在庫が引当てられ、出荷指示が作成される

  - name: 受注内容の変更フロー
    description: 顧客からの変更依頼を受けて受注内容を修正し在庫を再引当てするフロー
    trigger: 顧客から受注内容の変更依頼を受ける
    precondition: 顧客から変更依頼があり、該当受注が出荷前の状態
    steps:
      - actor: 倉庫管理者
        activity: 受注番号または顧客名で該当受注を検索する
        aggregate: 受注
      - actor: 倉庫管理者
        activity: 受注詳細を開き変更可能な状態か確認する
        aggregate: 受注
      - actor: 倉庫管理者
        activity: 商品の追加・削除・数量変更を行う
        aggregate: 受注
        event: 受注が編集された
      - actor: system
        activity: 在庫の再引当てを実行する
        aggregate: 在庫
        event: 在庫が再引当てされた
        policy: 在庫引当ポリシー
      - actor: 倉庫管理者
        activity: 変更後の金額と納期を顧客に連絡する
        aggregate: 受注
    postcondition: 受注内容が更新され、在庫引当てが再計算される
```

## Notes
-   **No User Confirmation**: This command is fully automated.
-   **Japanese Output**: Ensure all status messages to the user are in Japanese. Generated YAML content should be in Japanese.
-   **No SlashCommand Calls**: Do not call other slash commands (like `/teamkit:check-status` or `/teamkit:update-status`). Execute all logic directly.
