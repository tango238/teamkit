---
description: Generate user stories from feature and check list
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir> [--tmp]
---

# Setup

1.  **Set `commandName`**: `generate-screenflow`
2.  **Set `baseDir`**: `specs`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
4.  **Get `isTmp`**: Check if the second argument is `--tmp`.
    -   If `--tmp` is provided, set `isTmp` to `true`.
    -   Otherwise, set `isTmp` to `false`.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   The content of the generated YAML file (`story.yml`) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

# Instruction
Please follow the steps in the Execution Steps section.
Do not ask the user and execute immediately.

---


## Mission

Extract concrete user stories from the features in `feature.yml` and verification items in `check.md`, and document them in YAML format.
You must generate stories paying attention to the content of tasks marked as completed in the TODOs of `check.md`.
In particular, the content in `check.md` includes instructions from the author, so pay special attention to the content described in the summary of items marked with `[x]`.
Execute the following processing immediately without asking the user for confirmation.
**IMPORTANT**: All content in the generated `story.yml` (including `story` and `tracking` fields) MUST be written in Japanese.

## Execution Steps

### 1. Pre-check

- **Target Files**: 
  - `{{baseDir}}/{{specDir}}/feature.yml`
  - `{{baseDir}}/{{specDir}}/status.json`

- **Validation**:
  - If any of these files do not exist → Display the message "Error: `status.json` or `feature.yml` does not exist. Please run /clean" and **STOP** execution.

### 2. Check Status (Direct Read - No SlashCommand)

1. Read `{{baseDir}}/{{specDir}}/status.json`
2. Extract `version` from the `feature` step in the `steps` array
3. Set this as `{{targetVersion}}`
4. Extract `version` from the `story` step - this is `{{currentVersion}}`
5. **Validation**:
   - If `{{currentVersion}}` >= `{{targetVersion}}` → Display "スキップ: story は既に最新です (version {{currentVersion}})" and **STOP**
   - If `{{targetVersion}}` - `{{currentVersion}}` > 1 → Display warning but continue
   - Otherwise → Continue execution

### 3. Load Input Files
Read the following files and understand their contents:
- `{{baseDir}}/{{specDir}}/feature.yml`: List of features and their descriptions
- `{{baseDir}}/{{specDir}}/check.md`: Feature verification items (in TODO list format)
- `{{baseDir}}/{{specDir}}/approval/story.yml`: (Optional) Basic rules for story generation

**How to read check.md**:
- Lines starting with `- [x]` are completed tasks → Target for user story generation
- Lines starting with `- [ ]` are incomplete tasks → Not a target for generation
- Read specific user needs from the content of completed tasks

### 4. Identify Actors
Identify the actors (users) assumed in this system by reading the `actor` list defined in `{{baseDir}}/{{specDir}}/feature.yml`.

**Action**:
- Parse the `actor` section in `feature.yml`.
- Use the `name` and `description` of each actor to understand their role.
- Do NOT use any actors not defined in `feature.yml`.

Consider which actor each feature provides value to based on these definitions.

### 5. Create User Stories

**Basic Rules**:
- If `{{baseDir}}/{{specDir}}/approval/story.yml` exists, you **MUST** follow the rules defined in it.
- The rules in `approval/story.yml` take precedence over other instructions.

#### 5-1. Existing Stories from feature.yml
**CRITICAL**: If `stories` (or `scenarios`) are defined under a feature in `feature.yml`, you MUST include ALL of them in the output.

**Conversion Rule**:
- `feature`: Feature name
- `actor`: Actor defined in `precondition` or implied by the story (if unclear, use the primary actor for the feature)
- `story`: Combine `name`, `precondition`, `steps`, and `postcondition` into a single narrative sentence.
- `tracking`: "feature.yml:[Line] - Existing story: [Story Name]"

#### 5-2. Stories from check.md (New)
For each feature (each item in `feature.yml`), create NEW user stories from the following perspectives based on `check.md`:

**Story Format**:
```
[Actor]として、[Objective]のために[Feature]を利用したい
```

**Considerations when creating**:
- There can be multiple stories per feature
- If the same feature is used by different actors, describe them as separate stories
- Extract specific use cases from completed items in `check.md`
- Describe so that business value is clear

**Examples of Good Stories**:
- ✅ Concrete: "倉庫管理者として、トラックの到着を整理するために、固定時間枠で出荷計画を作成したい"
- ✅ Value is clear: "顧客として、荷物が到着する前に追跡番号を自動的に受け取りたい"
- ❌ Ambiguous: "管理者として、計画を管理したい"
- ❌ Technical: "システムとして、出荷情報をデータベースに保存したい"

#### 5-3. Cross-Functional Stories
Consider values realized by combining multiple features:

**Stories to consider**:
- A sequence of Order Placement → Payment → Shipment → Delivery
- Automated flow of Inventory Update → Reorder Alert → Supplier Notification
- New value created by combining Feature A and B

If a cross-functional story is found, list the representative feature name in the `feature` field.

#### 5-4. Verification
**Final Check**:
- Review the generated list of stories.
- Confirm that **ALL** stories originally defined in `feature.yml` are included.
- If any are missing, add them to the list immediately.

### 6. Record Tracking Information
Record which requirement each story was derived from:

**Format**:
```
"Filename:LineNumber - 該当箇所の簡潔な要約"
```

**Example**:
```yaml
tracking: "feature.yml:5 - 物流向けの出荷計画を作成する"
tracking: "check.md:12 - 固定時間枠設定の検証完了"
```

### 7. Generate YAML File

**Output Format**:
```yaml
stories:
  # Comment: Feature name for grouping
  - feature: Feature Name
    actor: Actor Name
    story: User Story (Concise, 1 sentence)
    tracking: "Source File:LineNumber - Summary of content"
  - feature: Another story for the same feature
    actor: Another Actor Name
    story: User story from another perspective
    tracking: "Source File:LineNumber - Summary of content"
```

**Description Rules**:
- `feature`: Must match the feature name described in feature.yml
- `actor`: Use the actor name identified above
- `story`: Describe in the format "[Actor]として、[Objective]のために[Feature]を利用したい" (Recommended within 60 characters). MUST be in Japanese.
- `tracking`: Must specify the source in Japanese (Ensure verifiability)
- Group by feature with comments to improve readability

### 8. Save File
- **Determine Output Filename**:
  - If `isTmp` is `true` → Set `outputFile` to `story_tmp.yml`.
  - If `isTmp` is `false` → Set `outputFile` to `story.yml`.

- **Processing existing files**: If `{{baseDir}}/{{specDir}}/{{outputFile}}` already exists, delete all contents
- Save the generated content to `{{baseDir}}/{{specDir}}/{{outputFile}}`
- Automatically overwrite and save without asking the user for confirmation

### 9. Update Status (Direct Write - No SlashCommand)

1. Get the MD5 checksum of the saved file: `md5 -q {{baseDir}}/{{specDir}}/{{outputFile}}`
2. Get current timestamp in ISO format: `date -u +"%Y-%m-%dT%H:%M:%S"`
3. Read `{{baseDir}}/{{specDir}}/status.json`
4. Update the `story` step with:
   - `version`: Set to `{{targetVersion}}` (from Step 2)
   - `checksum`: Set to the MD5 hash obtained
   - `last_modified`: Set to the timestamp obtained
5. Update `last_execution`: Set to `generate-story`
6. Update `updated_at`: Set to current timestamp
7. Save the modified `status.json`



## Execution Example

### Input Example

**feature.yml**:
```yaml
feature:
  - name: Shipment Tracking
    description: Function for customers to track their package status.
```

**check.md**:
```markdown
## Shipment Tracking
- [x] Tracking by tracking number is implemented
- [x] Real-time status updates are displayed
- [ ] Map view of location (Not implemented)
```

### Output Example (story.yml)

```yaml
stories:
  # Shipment Tracking
  - feature: Shipment Tracking
    actor: Customer
    story: 顧客として、配送状況を知るために、追跡番号を使って荷物を追跡したい
    tracking: "feature.yml:2 - 顧客が荷物のステータスを追跡するための機能"
  - feature: Shipment Tracking
    actor: Customer
    story: 顧客として、荷物がどこにあるか正確に知るために、リアルタイムのステータス更新を見たい
    tracking: "check.md:2 - リアルタイムのステータス更新が表示される"
```

## Notes
- **Fully Automatic Execution**: No user confirmation required. Do not display interruption or confirmation prompts.
- **Overwrite Existing File**: Existing `story.yml` will be completely replaced.
- **Completed Items Only**: Target only `[x]` items in `check.md`.
- **Traceability**: Must attach `tracking` information to all stories.
- **1 Story 1 Record**: Do not split a story, describe it as one clear value.