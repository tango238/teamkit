---
description: Add a new feature spec directory with README.md
role: Requirements analyst and specification writer
task: Create a new feature specification directory with initial README.md through user conversation
constraints:
  - Ask clarifying questions before creating specifications
  - Create specifications in Japanese
  - Follow consistent format matching app-init feature READMEs
output_format: Feature README.md file in spec directory
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
argument-hint: <featureName> [-o|--output <outputDir>]
---

# Setup

1. **Set `commandName`**: `add`
2. **Set `baseDir`**: `.teamkit`
3. **Get `featureName`**: Read the first argument passed to the slash command.
    - If no argument is provided, display the error message: "Error: `featureName` argument is required. Usage: `/teamkit:add <featureName> [-o|--output <outputDir>]`" and **STOP** execution immediately.
4. **Check for output directory**: Check if `-o` or `--output` option is passed as any argument.
    - If found, set `outputDir` to the value of the option.
    - If not found, set `outputDir` to `{{baseDir}}`.
5. **Generate `specDir`**: Convert `featureName` to an English kebab-case slug.
    - 例: 「勤怠管理」→ `attendance-management`
    - 例: 「チーム管理」→ `team-management`
    - 例: 「スケジュール管理」→ `schedule-management`
    - 例: 「ダッシュボード」→ `dashboard`
    - 例: 「商品管理」→ `product-management`
    - 例: 「注文管理」→ `order-management`
    - If `featureName` is already in English, convert to kebab-case directly.
6. **Set `specPath`**: `{{outputDir}}/{{specDir}}`


# 目的

ユーザーとの会話を通じて新しい機能（feature）の要件を聞き出し、`{{specPath}}/README.md` を作成する。


# ツール使用ルール

- **ファイル存在確認**: `Glob` ツールを使用する（`Bash(test -f)` は使用しない）
- **ファイル読み込み**: `Read` ツールを使用する
- **ファイル編集**: `Edit` ツールを使用する
- **ファイル作成**: `Write` ツールを使用する
- **ファイル検索**: `Grep` または `Glob` ツールを使用する
- **ディレクトリ作成**: `Bash(mkdir)` を使用する
- **ユーザーへの質問**: `AskUserQuestion` ツールを使用する


# Execution Step

## 1. 初期検証

- `{{specPath}}` が既に存在するか確認する
  - 存在する場合は警告を表示: 「`{{specPath}}` は既に存在します。上書きしますか？」と `AskUserQuestion` で確認する
    - 「はい」の場合 → 続行
    - 「いいえ」の場合 → **STOP**
- `{{outputDir}}` フォルダが存在するか確認する
  - 存在しない場合は作成する
- 開始メッセージを表示: 「{{featureName}}の要件定義を開始します。いくつか質問させてください。」

## 2. 機能詳細のヒアリング

以下の情報をユーザーから順番に聞き出す。各質問は `AskUserQuestion` ツールを使用する。

### 2.1 背景
```
「{{featureName}}」が必要になった背景を教えてください。
（どんな課題や状況があるか）
```

### 2.2 目的
```
この機能で達成したいことは何ですか？
（複数ある場合はすべて教えてください）
```

### 2.3 主要アクター
```
この機能を使うのは誰ですか？
（例：管理者、一般ユーザー、店舗スタッフなど）
複数ある場合はすべて教えてください。
```

### 2.4 業務概要
```
この機能の業務の流れを簡単に教えてください。
（誰が何をして、どうなるか）
```

### 2.5 要件
各アクターについて以下を確認する:
```
「{{アクター名}}」がこの機能でできることを教えてください。
（例：登録、一覧表示、編集、削除、承認など）
```

## 3. 要件の整理と確認

- ヒアリング内容を整理して、以下の構成でユーザーに確認する:

```markdown
## 確認: {{featureName}}

### 背景
{{背景}}

### 目的
{{目的リスト}}

### 主要アクター
{{アクターリスト}}

### 業務概要
{{業務概要}}

### 要件
{{アクターごとの要件}}

### 出力先
{{specPath}}/README.md
```

- ユーザーに確認:「この内容でREADME.mdを作成してよろしいですか？」
  - 「はい」の場合 → Step 4へ進む
  - 「いいえ」の場合 → 修正点を確認し、Step 2に戻って該当部分を再ヒアリング

## 4. ディレクトリとファイルの作成

- `{{specPath}}` ディレクトリを作成する
- `{{specPath}}/README.md` を作成する

## 5. status.json の作成

`{{specPath}}/status.json` を以下の形式で作成する:

```json
{
    "feature_name": "{{specDir}}",
    "created_at": "{{ISO 8601 timestamp}}",
    "updated_at": "{{ISO 8601 timestamp}}",
    "language": "Japanese",
    "last_execution": "add",
    "readme": {
        "checksum": "{{MD5 hash of README.md}}",
        "last_modified": "{{ISO 8601 timestamp}}"
    },
    "steps": [
        { "workflow": { "version": 0, "checksum": "", "last_modified": "" } },
        { "usecase": { "version": 0, "checksum": "", "last_modified": "" } },
        { "ui": { "version": 0, "checksum": "", "last_modified": "" } },
        { "screenflow": { "version": 0, "checksum": "", "last_modified": "" } },
        { "manual": { "version": 0, "checksum": "", "last_modified": "" } }
    ]
}
```

## 6. 作成内容のサマリー表示

すべてのファイル作成が完了したら、以下の内容をユーザーに報告する:

```markdown
## 機能仕様の作成が完了しました

### 作成されたファイル

{{specPath}}/
├── README.md        # {{featureName}}の要件定義
└── status.json      # ステータス管理

### 次のステップ

ワークフローを生成するには以下のコマンドを実行してください:

/teamkit:generate-workflow {{specDir}}

または、すべてを一括生成する場合:

/teamkit:generate {{specDir}}
```


# README.md Format

`{{specPath}}/README.md` は以下の形式で作成する:

```markdown
# {{featureName}}

## 背景
{{背景の説明}}

## 目的
- {{目的1}}
- {{目的2}}
...

## 主要アクター
- {{アクター1}}
- {{アクター2}}
...

## 業務概要
{{業務の流れの説明}}

## 要件
### {{アクター1}}
- {{要件1}}
- {{要件2}}
...

### {{アクター2}}
- {{要件1}}
- {{要件2}}
...
```


# Notes

- **日本語出力**: すべてのメッセージとファイル内容は日本語で記述する
- **段階的ヒアリング**: 一度に多くの情報を求めず、段階的に質問する
- **確認プロセス**: ファイル作成前にユーザーに確認を取る
- **スラッグ命名規則**: 機能名は英語のケバブケースに変換する
- **既存ディレクトリとの整合性**: 既存の `.teamkit/` 配下のディレクトリと同じ構造にする
