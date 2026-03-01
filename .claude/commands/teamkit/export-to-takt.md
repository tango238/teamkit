---
description: Export TeamKit specifications to Takt task queue
allowed-tools: Bash, Read, Write, Grep, Glob
argument-hint: <specDir> [--piece <name>]
---

# Setup

1.  **Set `commandName`**: `export-to-takt`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `piece`**: First, check all arguments for `--piece <name>` or `-p <name>`.
    -   If found, set `piece` to the value following `--piece` or `-p`, and remove both the flag and its value from the argument list.
    -   If not found, set `piece` to `"default"`.
4.  **Get `specDir`**: From the remaining arguments (after removing `--piece`/`-p` and its value in step 3), read the first argument that does NOT start with `--`.
    -   If no argument remains, display the error message: "エラー: `specDir` 引数が必要です。使用方法: `/teamkit:export-to-takt <specDir> [--piece <name>]`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir`, `specDir`, and `piece`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications, error messages) must be in **Japanese**.
-   Do not ask for user confirmation before executing any step.
-   **Do NOT use SlashCommand tool to call other teamkit commands.** Execute all logic directly within this command.

---

# Export to Takt Command

## Purpose
Convert TeamKit specification artifacts in `{{baseDir}}/{{specDir}}/` into a Takt task directory (`.takt/tasks/{{slug}}/`) with an AI-generated implementation instruction document (`order.md`).
Execute the following process immediately without asking for user confirmation.

## Execution Steps

### 1. Input Validation

- **Check directory**: Verify that `{{baseDir}}/{{specDir}}/` exists.
  - If it does not exist → Display "エラー: ディレクトリ `{{baseDir}}/{{specDir}}/` が見つかりません。specDir を確認してください。" and **STOP**.

- **Check required files**: Verify that ALL of the following files exist in `{{baseDir}}/{{specDir}}/`:
  - `workflow.yml`
  - `usecase.yml`
  - `ui.yml`
  - `screenflow.md`

- **Action**:
  - If all files exist → Proceed to Step 2.
  - If any files are missing → Collect the names of ALL missing files, then display:
    "エラー: 必要なファイルが不足しています: {{missing files joined by ', '}}。先に `/teamkit:generate {{specDir}}` を実行してください。"
    and **STOP**.

### 2. Metadata Extraction

- **Target File**: `{{baseDir}}/{{specDir}}/status.json`
- **Action**:
  - If `status.json` exists:
    - Read `status.json`
    - Extract `feature_name` as `{{featureName}}`
    - Extract `steps[0].workflow.version` as `{{workflowVersion}}` (if not found, set to "不明")
    - Extract `readme.checksum` as `{{readmeChecksum}}` (if not found, set to "不明")
    - Display "メタデータ取得: feature_name={{featureName}}, workflow_version={{workflowVersion}}"
  - If `status.json` does not exist:
    - Set `{{featureName}}` to `{{specDir}}`
    - Set `{{workflowVersion}}` to "不明"
    - Set `{{readmeChecksum}}` to "不明"
    - Display "メタデータ: status.json が見つからないため、デフォルト値を使用します"

### 3. Takt Directory Preparation

- **Create base directory**: Run `mkdir -p .takt/tasks/` using Bash.

- **Generate slug**: Run the following Bash command to generate a unique slug:
  ```bash
  echo "$(date +%Y%m%d-%H%M%S)-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)"
  ```
  Store the output as `{{slug}}`.

- **Create task directory**: Run `mkdir -p .takt/tasks/{{slug}}/` using Bash.

- Display "タスクディレクトリを作成しました: .takt/tasks/{{slug}}/"

### 4. Copy Specification Files

- **Required files** — Copy ALL of these using Bash `cp`:
  ```bash
  cp {{baseDir}}/{{specDir}}/workflow.yml .takt/tasks/{{slug}}/
  cp {{baseDir}}/{{specDir}}/usecase.yml .takt/tasks/{{slug}}/
  cp {{baseDir}}/{{specDir}}/ui.yml .takt/tasks/{{slug}}/
  cp {{baseDir}}/{{specDir}}/screenflow.md .takt/tasks/{{slug}}/
  ```

- **Optional files** — For each of the following, check if it exists and copy if present:
  - `README.md`
  - `acceptance-test.md`
  - `manual.md`

  Use Bash:
  ```bash
  for f in README.md acceptance-test.md manual.md; do
    if [ -f "{{baseDir}}/{{specDir}}/$f" ]; then
      cp "{{baseDir}}/{{specDir}}/$f" ".takt/tasks/{{slug}}/"
    fi
  done
  ```

- Build a list of all copied files as `{{copiedFiles}}` for use in later steps.

### 5. Generate order.md (★ Critical Step)

This is the most important step. You must READ all specification files and generate a concrete, specific implementation instruction document.

#### 5.1 Read All Specification Files
Use the Read tool to read each of the following files from `{{baseDir}}/{{specDir}}/`:
- `workflow.yml`
- `usecase.yml`
- `ui.yml`
- `screenflow.md`
- `README.md` (if exists)
- `manual.md` (if exists)
- `acceptance-test.md` (if exists)

Understand the content of all files before proceeding.

#### 5.2 Generate order.md Content

Based on the content you read, generate `.takt/tasks/{{slug}}/order.md` with the following structure.

**CRITICAL**: Each section must contain **concrete, specific information** extracted from the specification files. Do NOT leave placeholder text like "（workflow.yml の各 workflow を箇条書きで列挙）". Every section must be filled with actual data from the specs.

```markdown
# 実装指示書: {{specDir}}

## 背景
（README.md の背景・目的を2-3文で要約する。README.md がない場合は workflow.yml の内容から推測して記述する）

## 実装対象のワークフロー
（workflow.yml の各 workflow を以下の形式で箇条書きにする）
- **{workflow.name}** — {workflow.description の要約}（{steps の数}ステップ）

## 画面仕様の概要
（ui.yml の各 view を以下の形式で箇条書きにする）
- **{screen_id}**: {title} — 主要入力項目: {input_fields の数}個、アクション: {actions の数}個

## ユースケース概要
（usecase.yml の各 usecase を以下の形式で箇条書きにする）
- **{usecase.name}** — アクター: {actor.name}、ステップ数: {steps の数}

## 画面遷移
（screenflow.md の遷移パターンを要約する。主要な遷移ルートを箇条書きで列挙する）

## 完了条件（Definition of Done）
- workflow.yml で定義されたすべてのフローが実装されていること
- ui.yml で定義された画面の入力項目・バリデーション・アクションが実装されていること
- usecase.yml の正常系・代替系フローが動作すること
（acceptance-test.md がある場合、以下を追加:）
- acceptance-test.md の受入テスト観点を満たすこと

## 参照仕様ファイル（同ディレクトリに添付済み）
- workflow.yml — ワークフロー定義（actor, steps, event, policy の構造）
- usecase.yml — ユースケース定義（Robustness Analysis: boundary/control/entity）
- ui.yml — UI画面仕様（sections, input_fields, actions, validation）
- screenflow.md — 画面遷移図
（以下、存在するファイルのみ記載:）
- README.md — 元の要件定義
- acceptance-test.md — 受入テスト観点
- manual.md — 操作マニュアル

## 注意事項
- 仕様に「未指定」の部分がある場合は推測で実装せず、未指定であることをレポートに明記する
- workflow.yml の external_system に定義されている外部連携は、スタブまたはインタフェースまでに留める
- 仕様間の矛盾を発見した場合は、矛盾点と採用した解釈をレポートに記録する

---
_TeamKit metadata: specDir={{specDir}}, workflow_version={{workflowVersion}}, readme_checksum={{readmeChecksum}}, exported_at={{current UTC timestamp in ISO8601}}_
```

#### 5.3 Save order.md
Use the Write tool to save the generated content as `.takt/tasks/{{slug}}/order.md`.

### 6. Update tasks.yaml

- **Read existing file**: Check if `.takt/tasks.yaml` exists.
  - If it exists: Read the file content.
  - If it does not exist: Start with an empty structure.

- **Get current timestamp**: Run `date -u +"%Y-%m-%dT%H:%M:%SZ"` using Bash to get `{{currentTimestamp}}`.

- **Generate task name**: Convert `{{specDir}}` to lowercase. The task name is `teamkit-{{specDir in lowercase}}`.

- **Add entry**: Add the following entry to the `tasks` array in the YAML file:

```yaml
- name: teamkit-{{specDir in lowercase}}
  status: pending
  task_dir: .takt/tasks/{{slug}}
  piece: {{piece}}
  created_at: "{{currentTimestamp}}"
  started_at: null
  completed_at: null
```

- **Save**: Write the updated content to `.takt/tasks.yaml` using the Write tool.
  - If the file already had content, preserve ALL existing entries and only append the new one.
  - If the file is new, create it with a `tasks:` key containing just the new entry.
  - The file format must be valid YAML.

### 7. Completion Report

Display the following report in Japanese:

```
Takt タスクを生成しました。

📁 タスクディレクトリ: .takt/tasks/{{slug}}/
📄 指示書: .takt/tasks/{{slug}}/order.md
📎 添付ファイル: {{copiedFiles をカンマ区切りで列挙}}
🎯 Piece: {{piece}}

次のステップ:
  takt run  （タスクを実行）
  takt list （タスク一覧を確認）
```

## Notes
-   **No User Confirmation**: This command is fully automated.
-   **Japanese Output**: Ensure all status messages to the user are in Japanese.
-   **No SlashCommand Calls**: Do not call other slash commands. Execute all logic directly.
-   **Concrete order.md**: The order.md MUST contain specific information from the spec files, not placeholder text.
