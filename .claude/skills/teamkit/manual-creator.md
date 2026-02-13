---
description: Convert Marp-formatted manual.md to HTML and PDF
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
argument-hint: <specDir>
---

# Setup

1.  **Set `commandName`**: `manual-creator`
2.  **Set `baseDir`**: `.teamkit`
3.  **Get `specDir`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: `specDir` argument is required. Usage: `/teamkit:manual-creator <specDir>`" and **STOP** execution immediately.

# Execution

Execute the following instructions using `baseDir` and `specDir`.

**IMPORTANT**:
-   All output to the user (status messages, completion notifications) must be in **Japanese**.
-   Do not ask for user confirmation before saving files.

---

## Mission

Read the Marp-formatted `manual.md` under `.teamkit/{{specDir}}` and convert it to A4-sized HTML and PDF using Marp CLI.

**IMPORTANT**: Execute the following steps immediately without asking the user for confirmation.

---

## Execution Steps

### 1. Pre-check

- **Target File**:
  - `{{baseDir}}/{{specDir}}/manual.md`

- **Validation**:
  - If `manual.md` does not exist → Display "エラー: manual.md が存在しません。先に `/teamkit:generate-manual <specDir>` を実行してください。" and **STOP**.

### 2. Check Marp CLI Availability

Run the following command to check if Marp CLI is available:

```bash
npx --yes @marp-team/marp-cli --version
```

- If the command fails → Display "エラー: Marp CLI が利用できません。Node.js と npm がインストールされていることを確認してください。" and **STOP**.

### 3. Generate HTML with Marp

Run the following command to generate A4-sized HTML. The `--theme-set` option loads the custom `A4-Manual` theme CSS:

```bash
npx --yes @marp-team/marp-cli "{{baseDir}}/{{specDir}}/manual.md" --html --allow-local-files --theme-set .teamkit/themes/A4-Manual.css --output "{{baseDir}}/{{specDir}}/manual.html"
```

- Verify that `{{baseDir}}/{{specDir}}/manual.html` is created
- If the command fails → Display the error message and **STOP**

### 4. Generate PDF with Marp

Run the following command to convert to PDF:

```bash
npx --yes @marp-team/marp-cli "{{baseDir}}/{{specDir}}/manual.md" --pdf --allow-local-files --theme-set .teamkit/themes/A4-Manual.css --output "{{baseDir}}/{{specDir}}/manual.pdf"
```

- Verify that `{{baseDir}}/{{specDir}}/manual.pdf` is created
- If the command fails → Display the error message and **STOP**

### 5. Completion Report

Display the following completion message:

```
マニュアル作成が完了しました。

生成ファイル:
  - {{baseDir}}/{{specDir}}/manual.html (A4サイズHTML)
  - {{baseDir}}/{{specDir}}/manual.pdf (PDF)
```
