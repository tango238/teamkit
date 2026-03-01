---
description: Initialize Takt integration for TeamKit
allowed-tools: Bash, Read, Write, Glob
argument-hint: (no arguments)
---

# Setup

1.  **Set `commandName`**: `takt-init`
2.  **Set `baseDir`**: `.teamkit`

# Execution

Execute the following instructions using `baseDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications, error messages) must be in **Japanese**.
-   Do not ask for user confirmation before executing any step.
-   **Do NOT use SlashCommand tool to call other teamkit commands.** Execute all logic directly within this command.

---

# Takt Init Command

## Purpose
Set up TeamKit-Takt integration by creating a knowledge facet and a piece, then deploying them to the `.takt/` directory.
Execute the following process immediately without asking for user confirmation.

## Execution Steps

### 1. Takt Installation Check

- **Check directory**: Verify that `.takt/` directory exists in the project root.
  - If it does not exist → Display the following message and **STOP**:
    ```
    警告: `.takt/` ディレクトリが見つかりません。
    Takt がインストールされていないようです。先に Takt をセットアップしてください。

    参考: https://github.com/nrslib/takt
    ```

- If `.takt/` exists → Display "`.takt/` ディレクトリを検出しました。セットアップを開始します。" and proceed.

### 2. Create Knowledge Facet in Resources

- **Create directory**: Run `mkdir -p {{baseDir}}/resources/takt/facets/knowledge/` using Bash.

- **Create knowledge facet**: Use the Write tool to create `{{baseDir}}/resources/takt/facets/knowledge/teamkit-spec.md` with the following content:

```markdown
# TeamKit Specification Schema

TeamKit が生成する仕様ファイルのスキーマ定義。
実装時にこれらのファイル構造を理解することで、仕様の意図を正確に把握できる。

## workflow.yml

ビジネスワークフローの定義。

- **トップレベル**: `workflows` 配列
- 各 workflow:
  - `name`: ワークフロー名
  - `description`: 説明
  - `actors`: アクターの配列（`name`, `role`）
  - `steps`: ステップの配列
    - `name`: ステップ名
    - `actor`: 実行アクター
    - `action`: 実行内容
    - `event`: 発生イベント（optional）
    - `policy`: ビジネスルール（optional）
  - `external_systems`: 外部システム連携（optional）

## usecase.yml

ユースケースの定義（Robustness Analysis ベース）。

- **トップレベル**: `usecases` 配列
- 各 usecase:
  - `name`: ユースケース名
  - `actor`: アクター情報（`name`, `role`）
  - `boundary`: 境界オブジェクト（画面・API等）
  - `control`: コントロールオブジェクト（ビジネスロジック）
  - `entity`: エンティティオブジェクト（データモデル）
  - `steps`: 正常系ステップの配列
  - `alternative_flows`: 代替フロー（optional）

## ui.yml

UI 画面仕様の定義。

- **トップレベル**: `views` 配列
- 各 view:
  - `screen_id`: 画面ID
  - `title`: 画面タイトル
  - `sections`: セクションの配列
    - `name`: セクション名
    - `input_fields`: 入力フィールドの配列
      - `name`, `type`, `required`, `validation`
    - `actions`: アクションボタンの配列
      - `name`, `type`, `action`
  - `navigation`: 画面遷移定義（optional）

## screenflow.md

Mermaid 記法による画面遷移図。
画面間のナビゲーションフローを視覚化する。

## order.md

`export-to-takt` コマンドが生成する実装指示書。

- `## 背景` — 要件の要約
- `## 実装対象のワークフロー` — workflow.yml の各ワークフロー一覧
- `## 画面仕様の概要` — ui.yml の各画面一覧
- `## ユースケース概要` — usecase.yml の各ユースケース一覧
- `## 画面遷移` — screenflow.md の遷移パターン要約
- `## 完了条件（Definition of Done）` — 実装完了基準
- `## 参照仕様ファイル` — 添付ファイルリスト
- `## 注意事項` — 実装時の注意点
```

- Display "Knowledge ファセットを作成しました: {{baseDir}}/resources/takt/facets/knowledge/teamkit-spec.md"

### 3. Create Piece in Resources

- **Create directory**: Run `mkdir -p {{baseDir}}/resources/takt/pieces/` using Bash.

- **Create piece file**: Use the Write tool to create `{{baseDir}}/resources/takt/pieces/teamkit.yaml` with the following content:

```yaml
name: teamkit
description: TeamKit specification-based implementation piece
max_movements: 10
initial_movement: plan

knowledge:
  teamkit-spec: ../facets/knowledge/teamkit-spec.md

movements:
  - name: plan
    persona: planner
    knowledge: teamkit-spec
    edit: false
    allowed_tools: [Read, Glob, Grep, WebSearch, WebFetch]
    rules:
      - condition: Plan complete
        next: implement
      - condition: Cannot proceed
        next: ABORT
    instruction_template: |
      Read the order.md and all attached specification files in the task directory.
      Understand the TeamKit specification schemas from the knowledge facet.
      Create a concrete implementation plan based on the specifications.

      Key points:
      - Identify all workflows, use cases, and screens to implement
      - Determine the implementation order based on dependencies
      - Note any external_system integrations that need stubs
      - Flag any ambiguities or conflicts between spec files

  - name: implement
    persona: coder
    knowledge: teamkit-spec
    edit: true
    pass_previous_response: true
    required_permission_mode: edit
    allowed_tools: [Read, Glob, Grep, Edit, Write, Bash, WebSearch, WebFetch]
    rules:
      - condition: Implementation complete
        next: COMPLETE
      - condition: Cannot proceed
        next: ABORT
    instruction_template: |
      Implement based on the plan and TeamKit specifications.

      Requirements:
      - Implement all workflows defined in workflow.yml
      - Build UI screens matching ui.yml definitions (input_fields, validations, actions)
      - Implement use case flows from usecase.yml (normal + alternative flows)
      - Follow screen navigation from screenflow.md
      - External system integrations: implement as stubs/interfaces only
      - If spec is ambiguous, document the assumption rather than guessing
```

- Display "Piece を作成しました: {{baseDir}}/resources/takt/pieces/teamkit.yaml"

### 4. Deploy to .takt/ Directory

- **Create target directories**: Run the following using Bash:
  ```bash
  mkdir -p .takt/facets/knowledge/
  mkdir -p .takt/pieces/
  ```

- **Copy knowledge facet**:
  ```bash
  cp {{baseDir}}/resources/takt/facets/knowledge/teamkit-spec.md .takt/facets/knowledge/
  ```

- **Copy piece**:
  ```bash
  cp {{baseDir}}/resources/takt/pieces/teamkit.yaml .takt/pieces/
  ```

- Display "`.takt/` ディレクトリへのデプロイが完了しました。"

### 5. tasks.yaml Check

- **Check file**: Verify if `.takt/tasks.yaml` exists.
  - If it exists:
    - Read the file using the Read tool.
    - Count the number of entries in the `tasks` array. Store as `{{taskCount}}`.
    - Display "tasks.yaml を確認しました（{{taskCount}} 件のタスク）"
  - If it does not exist:
    - Create `{{baseDir}}/resources/takt/tasks.yaml` with `tasks: []` using the Write tool.
    - Copy it to `.takt/tasks.yaml`:
      ```bash
      cp {{baseDir}}/resources/takt/tasks.yaml .takt/tasks.yaml
      ```
    - Set `{{taskCount}}` to `0`.
    - Display "tasks.yaml を初期化しました。"

### 6. Completion Report

Display the following report:

```
Takt 連携の初期化が完了しました。

セットアップ内容:
  Knowledge: .takt/facets/knowledge/teamkit-spec.md
  Piece:     .takt/pieces/teamkit.yaml
  Tasks:     .takt/tasks.yaml（{{taskCount}} 件のタスク）

使い方:

  1. TeamKit で仕様を生成する
     /teamkit:generate <specDir>

  2. 仕様を Takt タスクキューにエクスポートする
     /teamkit:export-to-takt <specDir> --piece teamkit

  3. Takt でタスクを実行する
     takt run

Piece について:
  teamkit piece は plan → implement の2段階で実装を行います。
  TeamKit の仕様スキーマ（workflow.yml, usecase.yml, ui.yml 等）を
  knowledge ファセットとして参照するため、仕様の構造を正確に理解して実装します。

  カスタマイズする場合は .takt/pieces/teamkit.yaml を直接編集してください。
  デフォルトの piece を使いたい場合は --piece オプションを省略してください。
```

## Notes
-   **No User Confirmation**: This command is fully automated.
-   **Japanese Output**: Ensure all status messages to the user are in Japanese.
-   **No SlashCommand Calls**: Do not call other slash commands. Execute all logic directly.
-   **Resources First**: Always create files in `{{baseDir}}/resources/takt/` first, then copy to `.takt/`. Never write directly to `.takt/`.
-   **Non-destructive**: This command does not modify any existing `.takt/` files other than deploying the knowledge facet and piece. Existing tasks, runs, and config are preserved.
