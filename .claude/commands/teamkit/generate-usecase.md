
# Setup

1.  **Set `commandName`**: `generate-usecase`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/teamkit:generate-usecases <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`usecases.yml`) must be in **Japanese**. The structure keys (usecase, name, stories, trackings, actor, before, after, boundary, control, entity, steps, step, label, note) must remain in English as defined in the format.
-   Do not ask for user confirmation before saving files.

---

# Use Case Generation Command

## Purpose
Extract use cases from `{{baseDir}}/{{specDir}}/stories.yml` and `{{baseDir}}/{{specDir}}/check.md`, and document them in YAML format based on **Robustness Analysis**.
Ensure all stories in `stories.yml` are covered (Tracking is mandatory).

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
-   `{{baseDir}}/{{specDir}}/check.md`: Feature validation items

### 3. Use Case Creation Policy (Robustness Analysis)

Create use cases based on the **Robustness Diagram** concept.
Instead of just listing steps, identify the **Actor**, **Boundary**, **Control**, and **Entity** involved in each use case.

#### Elements:
-   **Actor**: The user or external system initiating the action.
-   **Boundary**: The interface (screen, API, button) the actor interacts with.
-   **Control**: The logic or controller processing the action.
-   **Entity**: The data object being manipulated.

#### Structure:
-   **Preconditions (before)**: State before the use case starts.
-   **Postconditions (after)**: State after the use case ends.
-   **Steps**: Interaction flow (Actor -> Boundary -> Control -> Entity).

### 4. Generate Use Cases

Generate the content for `usecases.yml` following the format below.
**Group by Use Case**, not by Feature.

**Output Format**:
```yaml
usecases:
  - usecase:
    name: [Use Case Name]
    stories:
      - [Related User Story 1]
      - [Related User Story 2]
    trackings:
     - "stories.yml:[Line] - [Summary]"
     - "check.md:[Line] - [Summary]"
    actor: 
      name: "[Actor Name]" 
      as: [ActorAlias]
    before: [Precondition]
    after: [Postcondition]
    boundary: 
      name: "[Boundary Name]"
      as: [BoundaryAlias]
    control:
      name: "[Control Name]"
      as: [ControlAlias]
    entity: 
      name: "[Entity Name]"
      as: [EntityAlias]
    steps:
        - step: [ActorAlias] --> [BoundaryAlias]
          label: [Action Label]
          note: [Optional Note]
        - step: [BoundaryAlias] --> [ControlAlias]
          label: [Action Label]
        - step: [ControlAlias] --> [EntityAlias]
          label: [Action Label]
```

**Rules**:
-   **`trackings` is MANDATORY**. You must explicitly state which line in `stories.yml` (and `check.md` if applicable) is being covered.
-   Use `-->` for arrows in steps.
-   Aliases (as) should be short English identifiers (e.g., Host1, LoginUI).
-   Names should be descriptive in Japanese.
-   `usecase` key should be empty (null).

### 5. Verification (Self-Correction)

**After generating the initial list of use cases, perform a check:**
1.  Review `stories.yml` and ensure **EVERY** story is referenced in the `trackings` of at least one use case.
2.  If any story is missing, create an additional use case to cover it.
3.  Ensure no "orphan" stories are left behind.

### 6. File Saving

#### If file exists:
-   Delete the existing file and regenerate it completely.

#### New creation:
-   Save generated content as `{{baseDir}}/{{specDir}}/usecases.yml`.
-   Save automatically without asking user.

### 7. Set Version Number
- `/teamkit:get-step-info {{specDir}} story` を実行して、バージョン番号を取得し、{{versionNumber}} として設定します。

### 8. Update Status
- `/teamkit:update-status {{specDir}} {{commandName}} {{versionNumber}}` を実行し、ステータスを更新します。

## Execution Example

### Input Example (stories.yml)
```yaml
stories:
  - feature: 契約管理
    actor: ホスト
    story: サービスを利用開始するために、契約を申し込みたい
```

### Output Example (usecases.yml)
```yaml
usecases:
  - usecase:
    name: サービス契約の申し込みと管理アカウント作成
    stories:
      - ホストとして、Spotlyサービスを利用開始するために、サービス契約を申し込み管理アカウントを作成したい
    trackings:
     - "stories.yml:5 - サービス契約を申し込み管理アカウントを作成"
    actor: 
      name: "ホスト\n(スペース掲載者)" 
      as: Host1
    before: ホストがサービス利用を希望している
    after: 契約が完了し、管理画面へのログインアカウントが発行される
    boundary: 
      name: "サービス契約画面\n(基本情報入力)"
      as: ContractBasicUI
    control:
      name: "契約情報検証\nコントローラ"
      as: ContractValidator
    entity: 
      name: "ホストアカウント"
      as: HostAccount
    steps:
        - step: Host1 --> ContractBasicUI
          label: 基本情報を入力
          note: # if any
        - step: ContractBasicUI --> ContractValidator
          label: 入力内容を送信
        - step: ContractValidator --> HostAccount
          label: アカウントを作成
```