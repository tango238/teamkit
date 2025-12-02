---
description: Generate use cases from stories and check list
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir> [--tmp]
---

# Setup

1.  **Set `commandName`**: `generate-usecase`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
4.  **Get `isTmp`**: Check if the second argument is `--tmp`.
    -   If `--tmp` is provided, set `isTmp` to `true`.
    -   Otherwise, set `isTmp` to `false`.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`usecase.yml`) must be in **Japanese**. The structure keys (usecase, name, stories, trackings, actor, before, after, boundary, control, entity, steps, step, label, note) must remain in English as defined in the format.
-   Do not ask for user confirmation before saving files.

---

# Use Case Generation Command

## Purpose
Extract use cases from `{{baseDir}}/{{specDir}}/story.yml` and `{{baseDir}}/{{specDir}}/check.md`, and document them in YAML format based on **Robustness Analysis**.
Ensure all stories in `story.yml` are covered (Tracking is mandatory).

## Execution Steps

### 1. Pre-check

- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Validation**:
  - If any of these files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /clean" and **STOP** execution.

### 2. Check Status (Direct Read - No SlashCommand)

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Extract `version` from the `story` step in the `steps` array
3. Set this as `{{targetVersion}}`
4. Extract `version` from the `usecase` step - this is `{{currentVersion}}`
5. **Validation**:
   - If `{{currentVersion}}` >= `{{targetVersion}}` → Display "スキップ: usecase は既に最新です (version {{currentVersion}})" and **STOP**
   - If `{{targetVersion}}` - `{{currentVersion}}` > 1 → Display warning but continue
   - Otherwise → Continue execution

### 3. Read Input Files
Read the following files and understand their content:
-   `{{baseDir}}/{{specDir}}/story.yml`: List of user stories
-   `{{baseDir}}/{{specDir}}/check.md`: Feature validation items

### 4. Use Case Creation Policy (Robustness Analysis)

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

### 5. Generate Use Cases

Generate the content for `usecase.yml` following the format below.
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
     - "story.yml:[Line] - [Summary]"
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
          label: [No. of step][Action Label]
          note: [Optional Note]
        - step: [BoundaryAlias] --> [ControlAlias]
          label: [No. of step][Action Label]
          note: [Optional Note]
        - step: [ControlAlias] --> [EntityAlias]
          label: [No. of step][Action Label]
          note: [Optional Note]
```

**Rules**:
-   **`trackings` is MANDATORY**. You must explicitly state which line in `story.yml` (and `check.md` if applicable) is being covered.
-   Use `-->` for arrows in steps.
-   Aliases (as) should be short English identifiers (e.g., Host1, LoginUI).
-   Names should be descriptive in Japanese.
-   `usecase` key should be empty (null).

### 6. Verification (Self-Correction)

**After generating the initial list of use cases, perform a check:**
1.  Review `story.yml` and ensure **EVERY** story is referenced in the `trackings` of at least one use case.
2.  If any story is missing, create an additional use case to cover it.
3.  Ensure no "orphan" stories are left behind.

### 7. File Saving
- **Determine Output Filename**:
  - If `isTmp` is `true` → Set `outputFile` to `usecases_tmp.yml`.
  - If `isTmp` is `false` → Set `outputFile` to `usecase.yml`.

#### If file exists:
-   Delete the existing `{{baseDir}}/{{specDir}}/{{outputFile}}` and regenerate it completely.

#### New creation:
-   Save generated content as `{{baseDir}}/{{specDir}}/{{outputFile}}`.
-   Save automatically without asking user.

### 8. Update Status (Direct Write - No SlashCommand)

1. Get the MD5 checksum of the saved file: `md5 -q {{baseDir}}/{{specDir}}/{{outputFile}}`
2. Get current timestamp in ISO format: `date -u +"%Y-%m-%dT%H:%M:%S"`
3. Read `{{baseDir}}/{{specDir}}/status.json`
4. Update the `usecase` step with:
   - `version`: Set to `{{targetVersion}}` (from Step 2)
   - `checksum`: Set to the MD5 hash obtained
   - `last_modified`: Set to the timestamp obtained
5. Update `last_execution`: Set to `generate-usecase`
6. Update `updated_at`: Set to current timestamp
7. Save the modified `status.json`

## Execution Example

### Input Example (story.yml)
```yaml
stories:
  - feature: 契約管理
    actor: ホスト
    story: サービスを利用開始するために、契約を申し込みたい
```

### Output Example (usecase.yml)
```yaml
usecases:
  - usecase:
    name: サービス契約の申し込みと管理アカウント作成
    stories:
      - ホストとして、Spotlyサービスを利用開始するために、サービス契約を申し込み管理アカウントを作成したい
    trackings:
     - "story.yml:5 - サービス契約を申し込み管理アカウントを作成"
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
          label: 1.基本情報を入力
          note: # if any
        - step: ContractBasicUI --> ContractValidator
          label: 2.入力内容を送信
        - step: ContractValidator --> HostAccount
          label: 3.アカウントを作成
```