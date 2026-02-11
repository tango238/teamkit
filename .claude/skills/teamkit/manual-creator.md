---
description: Create PDF manual from manual.md using Marp
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

Read `manual.md` under `.teamkit/{{specDir}}`, convert it to Marp-compatible Markdown, generate A4-sized HTML using Marp CLI, and then convert it to PDF.

**IMPORTANT**: Execute the following steps immediately without asking the user for confirmation.

---

## Execution Steps

### 1. Pre-check

- **Target Files**:
  - `{{baseDir}}/{{specDir}}/manual.md`

- **Validation**:
  - If `manual.md` does not exist → Display "エラー: manual.md が存在しません。先に `/teamkit:generate-manual <specDir>` を実行してください。" and **STOP**.

### 2. Check Marp CLI Availability

Run the following command to check if Marp CLI is available:

```bash
npx --yes @marp-team/marp-cli --version
```

- If the command fails → Display "エラー: Marp CLI が利用できません。Node.js と npm がインストールされていることを確認してください。" and **STOP**.

### 3. Read manual.md

Read the file `{{baseDir}}/{{specDir}}/manual.md` and store its full content.

### 4. Create Marp Markdown

Create a new file `{{baseDir}}/{{specDir}}/manual-slides.md` with the following structure:

#### 4-1. Front Matter

Add Marp directives at the top of the file:

```markdown
---
marp: true
theme: default
size: A4
paginate: true
header: "【Feature Name】操作マニュアル"
footer: ""
style: |
  section {
    font-family: "Hiragino Kaku Gothic ProN", "Noto Sans JP", "Meiryo", sans-serif;
    font-size: 16px;
    padding: 40px;
  }
  h1 {
    font-size: 28px;
    color: #333;
    border-bottom: 2px solid #007bff;
    padding-bottom: 10px;
  }
  h2 {
    font-size: 22px;
    color: #007bff;
  }
  h3 {
    font-size: 18px;
    color: #555;
  }
  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }
  th {
    background: #007bff;
    color: white;
    padding: 8px 12px;
    text-align: left;
  }
  td {
    border: 1px solid #dee2e6;
    padding: 8px 12px;
  }
  tr:nth-child(even) {
    background: #f8f9fa;
  }
  header {
    font-size: 12px;
    color: #999;
  }
  footer {
    font-size: 10px;
    color: #999;
  }
---
```

#### 4-2. Content Conversion Rules

Convert `manual.md` content into Marp slides following these rules:

1. **Title Slide**: Create a title slide from the first `# heading` of manual.md
   ```markdown
   # 【Feature Name】操作マニュアル

   **Version**: 1.0
   **Date**: {{current date}}
   ```

2. **Table of Contents Slide**: Create a table of contents slide from the `## 目次` section

3. **Section Separators**: Insert Marp slide separators (`---`) at each `## heading` boundary
   - Each `## heading` starts a new slide
   - If a section is too long (contains multiple `### headings`), split it into multiple slides at each `### heading`

4. **Tables**: Keep tables as-is (Marp renders Markdown tables natively)

5. **Long Content Handling**:
   - If a single section has more than 30 lines of content, split it across multiple slides
   - Add a continuation marker like "（続き）" in the heading for continuation slides

6. **Feature Name Extraction**: Extract the feature name from the first `#` heading in manual.md and use it in the header directive

### 5. Generate HTML with Marp

Run the following command to generate A4-sized HTML:

```bash
npx --yes @marp-team/marp-cli "{{baseDir}}/{{specDir}}/manual-slides.md" --html --output "{{baseDir}}/{{specDir}}/manual.html"
```

- Verify that `{{baseDir}}/{{specDir}}/manual.html` is created
- If the command fails → Display the error message and **STOP**

### 6. Generate PDF with Marp

Run the following command to convert to PDF:

```bash
npx --yes @marp-team/marp-cli "{{baseDir}}/{{specDir}}/manual-slides.md" --pdf --output "{{baseDir}}/{{specDir}}/manual.pdf"
```

- Verify that `{{baseDir}}/{{specDir}}/manual.pdf` is created
- If the command fails → Display the error message and **STOP**

### 7. Completion Report

Display the following completion message:

```
マニュアル作成が完了しました。

生成ファイル:
  - {{baseDir}}/{{specDir}}/manual-slides.md (Marp形式Markdown)
  - {{baseDir}}/{{specDir}}/manual.html (A4サイズHTML)
  - {{baseDir}}/{{specDir}}/manual.pdf (PDF)
```

---

## Quality Checklist

- [ ] `manual.md` content is fully reflected in `manual-slides.md`
- [ ] Marp front matter includes `size: A4`
- [ ] Slide separators (`---`) are placed at appropriate section boundaries
- [ ] Long sections are split across multiple slides
- [ ] HTML file is generated successfully
- [ ] PDF file is generated successfully
- [ ] All output messages are in Japanese
