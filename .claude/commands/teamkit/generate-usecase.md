
# Setup

1.  **Set `commandName`**: `generate-usecase`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/generate-usecases <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`usecases.yml`) must be in **Japanese**. The structure keys (feature, actor, story, usecase, description, tracking) must remain in English as defined in the format.
-   Do not ask for user confirmation before saving files.

---

# Use Case Generation Command

## Purpose
Extract specific use cases (usage scenarios) from `{{baseDir}}/{{specDir}}/stories.yml` and `{{baseDir}}/{{specDir}}/check.md` validation items, and document them in YAML format.
Pay close attention to completed tasks in `check.md`.

Especially note that items in `check.md` contain instructions from the creator, so pay special attention to the content summarized in `[x]` items.

## Difference between User Story and Use Case

-   **User Story**: The "Goal/Value" the user wants to achieve (e.g., "I want to ship an order").
-   **Use Case**: The "Specific Steps/Scenario" to realize that goal (e.g., "Process standard shipping for in-stock items").

Often, multiple use cases are derived from a single user story.

## Execution Steps

### 1. Pre-check

- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Validation**:
  - If any of these files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /clean" and **STOP** execution.

### 2. Read Input Files
Read the following files and understand their content:
-   `{{baseDir}}/{{specDir}}/stories.yml`: List of user stories
-   `{{baseDir}}/{{specDir}}/check.md`: Feature validation items (TODO list format)

**How to read check.md**:
-   Lines starting with `- [x]` are completed tasks -> Use as basis for use case generation.
-   Lines starting with `- [ ]` are incomplete tasks -> Can be used as reference, but do not write as if implemented.
-   Derive concrete, working use cases from completed tasks.

### 2. Use Case Creation Policy

#### 2.1 Use Cases per Story
Create use cases for each user story considering:

**Perspectives**:
-   **Normal Flow**: Standard operation flow (most common usage).
-   **Alternative Flow**: Different routes based on conditions or choices.
-   **Exception Flow**: Behavior during errors or constraint violations.
-   **Variation**: Different means or settings for the same goal.

**Naming Convention**:
-   Concise and unique (recommended within 20 characters).
-   Start with a verb (e.g., "Create", "Edit", "Verify").
-   Include specific target (e.g., "Shipping Label", "Inventory").

**Good Use Case Examples (Logistics Domain)**:
-   ✅ 具体的: "新規出荷を作成する"
-   ✅ 明確なストーリー: "注文確認後に支払いを承認する"
-   ✅ ユニーク: "在庫僅少アラートを送信する"
-   ❌ 曖昧: "出荷を管理する"
-   ❌ ストーリーと同じ: "出荷したい"
-   ❌ 技術的すぎる: "データベースにINSERTする"

#### 2.2 Cross-Story Use Cases
Consider comprehensive use cases combining multiple stories:

**Patterns**:
-   End-to-End flow (Order -> Payment -> Pick -> Pack -> Ship).
-   Automation scenarios (Order received -> Auto-assign warehouse -> Print label -> Notify).
-   Multi-actor collaboration (Customer orders -> System validates -> Warehouse packs).

Use the `feature` and `actor` of the main story for these.

#### 2.3 Level of Detail
Include the following in the use case description:

**Essential Elements**:
1.  **Preconditions**: State before use case begins.
2.  **Trigger**: What starts the use case.
3.  **Main Steps**: Interaction between actor and system (approx. 3-7 steps).
4.  **Postconditions**: State after use case completes.
5.  **Alternative/Exception Flows**: Briefly if any.

**Description Example**:
```
前提条件: 倉庫管理者がログインしており、注文#123が「準備完了」状態である。
トリガー: 管理者が「注文処理」ボタンをクリックする。
手順:
1. システムが注文詳細を表示する。
2. 管理者が商品バーコードをスキャンする。
3. 管理者が「梱包確認」をクリックする。
4. システムが商品と注文の一致を検証する。
5. システムが注文ステータスを「梱包済み」に更新する。
6. システムが出荷ラベルを生成する。
事後条件: 注文が梱包され、ラベル印刷の準備が整う。
```

### 3. Record Tracking Information
Record which requirement each use case was derived from:

**Format**:
```
"Filename:LineNumber - Brief summary of relevant part"
```

**Example**:
```yaml
tracking: "stories.yml:5 - Want to process bulk orders"
tracking: "check.md:12 - Bulk order validation logic verified"
```

### 4. Generate YAML File

**Output Format**:
```yaml
usecases:
  # Comment: Group by Feature Name
  - feature: Feature Name
    actor: Actor Name
    story: Original User Story
    usecase: Use Case Name (Concise & Unique)
    description: |
      Preconditions: ...
      Trigger: ...
      Steps:
      1. ...
      2. ...
      Postconditions: ...
    tracking: "SourceFile:Line - Summary of content"
  - feature: Same Feature
    actor: Same Actor
    story: Same User Story
    usecase: Another Use Case Name
    description: |
      Details...
    tracking: "SourceFile:Line - Summary of content"
```

**Writing Rules**:
-   `feature`: Inherit from `stories.yml`.
-   `actor`: Inherit from `stories.yml`.
-   `story`: Inherit from `stories.yml`.
-   `usecase`: Unique name (max 20 chars).
-   `description`: Multi-line description using `|`.
-   `tracking`: Must specify source.
-   Group by feature using comments.
-   **Language**: All values (except keys) must be in **Japanese**.

### 5. File Saving and Diff Management

#### If file exists:
-   Delete the existing file and regenerate it completely.

#### New creation:
-   Save generated content as `{{baseDir}}/{{specDir}}/usecases.yml`.
-   Save automatically without asking user.

### 6. Set Version Number
- `/teamkit:get-step-info {{specDir}} story` を実行して、バージョン番号を取得し、{{versionNumber}} として設定します。

### 7. Update Status
- `/teamkit:update-status {{specDir}} {{commandName}} {{versionNumber}}` を実行し、ステータスを更新します。


## Execution Example

### Input Example

**stories.yml**:
```yaml
stories:
  # 注文管理
  - feature: 注文処理
    actor: 倉庫管理者
    story: 即日出荷を保証するために、注文を効率的に処理したい。
    tracking: "feature.yml:2 - 注文処理機能"
```

**check.md**:
```markdown
## 注文処理
- [x] 一括注文選択の実装
- [x] ワンクリックラベル生成
- [x] 在庫検証ロジック
- [ ] 海外発送（未実装）
```

### Output Example (usecases.yml)

```yaml
usecases:
  # 注文管理
  - feature: 注文処理
    actor: 倉庫管理者
    story: 即日出荷を保証するために、注文を効率的に処理したい。
    usecase: 一括注文処理
    description: |
      前提条件: 複数の「準備完了」ステータスの注文が存在する。
      トリガー: 管理者が注文を選択し、「一括処理」ボタンをクリックする。
      手順:
      1. システムが選択された全注文の在庫を検証する。
      2. システムが有効な注文の出荷ラベルを生成する。
      3. システムがステータスを「出荷済み」に更新する。
      4. システムがサマリーレポートを表示する。
      事後条件: 選択された注文が出荷済みとなり、ラベルが生成される。
    tracking: "stories.yml:4 - 注文を効率的に処理"

  - feature: 注文処理
    actor: 倉庫管理者
    story: 即日出荷を保証するために、注文を効率的に処理したい。
    usecase: 在庫切れ対応
    description: |
      前提条件: 注文に在庫切れの商品が含まれている。
      トリガー: 管理者が注文処理を試みる。
      手順:
      1. システムが在庫不足を検知する。
      2. システムが注文を「入荷待ち」フラグを立てる。
      3. システムが購買部門に通知する。
      事後条件: 注文が一時停止され、通知が送信される。
    tracking: "check.md:3 - 在庫検証ロジック"
```

## Notes
-   **Fully Automated**: No user confirmation. No interruption.
-   **Auto Apply**: Automatically update/save.
-   **Detail**: Write for implementers.
-   **Traceability**: Always include `tracking`.
-   **1 Use Case = 1 Record**.
-   **Multi-line**: Use `|` for `description`.