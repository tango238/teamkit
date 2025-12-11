---
description: Planning application mockups
role: Automated workflow executor
task: Execute a sequence of generation commands without interruption
constraints:
  - Never pause between commands
  - Never create todo lists or checkboxes
  - Never ask for user confirmation mid-workflow
output_format: Report only final completion status with any errors encountered
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - SlashCommand
---

# Setup

1.  **Set `commandName`**: `plan-app`
2.  **Set `baseDir`**: `specs`
3.  **Get `description`**: Read the first argument passed to the slash command.
    -   If no argument is provided, display the error message: "Error: The `description` argument is required. Usage: `/teamkit:plan-app <description> [-o|--output <outputDir>]`" and **STOP** execution immediately.
4.  **Check for output directory**: Check if `-o` or `--output` option is passed as any argument.
    -   If found, set `outputDir` to the value of the option.
    -   If not found, set `outputDir` to `app`.


# 出力先ディレクトリ

- すべてのファイルは `{{baseDir}}/{{outputDir}}/` 配下に生成する

# ツール使用ルール

- **ファイル存在確認**: `Glob` ツールを使用する（`Bash(test -f)` は使用しない）
- **ファイル読み込み**: `Read` ツールを使用する
- **ファイル編集**: `Edit` ツールを使用する
- **ファイル作成**: `Write` ツールを使用する
- **ファイル検索**: `Grep` または `Glob` ツールを使用する
- **ディレクトリ作成**: `Bash(mkdir)` を使用する


# 目的

ユーザーが作成するアプリケーションの概要について聞き、そこからナビゲーションメニューを考えて `{{baseDir}}/{{outputDir}}/navigation.yml` を出力する


# Execution Step

## 1. Setup

- `{{baseDir}}` 直下にあるディレクトリを「対象ディレクトリ一覧」とする
- 各ディレクトリ直下に `screenflow.md` および `ui.yml` があるか確認する
- どちらのファイルもあった場合、そのディレクトリ名を `処理対象ディレクトリ` に追加する
- `処理対象ディレクトリ` を表示する
- `{{baseDir}}/{{outputDir}}` フォルダが存在するか確認する
  - 存在する場合は、エラーを表示して終了する
  - 存在しない場合は、作成する

## 2. Planning Abstract

- `{{description}}` から `アクター` を考えて、アプリケーションの概要を考えて、それを `{{abstract}}` に設定する
- `アクター` と `{{abstract}}` を表示して、ユーザーに確認して、ユーザーが `はい` または `いいえ` で答えてもらう
  - ユーザーが `はい` と答えた場合は、`{{abstract}}` を `{{baseDir}}/{{outputDir}}/README.md` に保存する
  - ユーザーが `いいえ` と答えた場合は、理由を聞いて、再度 `{{abstract}}` を考えて、ユーザーが `はい` または `いいえ` で答えてもらうまで繰り返す

## 3. Planning Navigation
- 各処理対象ディレクトリ直下にある `screenflow.md` をすべて読み込む
- 読み込んだすべての `screenflow.md` と `{{abstract}}` から `ナビゲーションメニュー` を考える
- `ナビゲーションメニュー` を表示して、ユーザーに確認して、ユーザーが `はい` または `いいえ` で答えてもらう
  - ユーザーが `はい` と答えた場合は、`ナビゲーションメニュー` を `{{baseDir}}/{{outputDir}}/0_navigation.yml` に保存する
  - ユーザーが `いいえ` と答えた場合は、理由を聞いて、再度 `ナビゲーションメニュー` を考えて、ユーザーが `はい` または `いいえ` で答えてもらうまで繰り返す

## 4. Planning Inspection

- `0_navigation.yml` から、過不足がないか読み込んだすべての `screenflow.md` と突合する
  - **最大再試行回数**: 突合チェックは最大5回まで実行する。5回試行しても不整合が解消されない場合は、エラーを表示して終了する
- `0_navigation.yml` から、過不足がないか読み込んだすべての `ui.yml` と突合する
  - **最大再試行回数**: 突合チェックは最大5回まで実行する。5回試行しても不整合が解消されない場合は、エラーを表示して終了する
- 過不足があった場合、ユーザーに確認をして、もしユーザーが `はい` と答えた場合は、再度 `0_navigation.yml` を考えて、ユーザーが `はい` と答えてもらうまで変更を繰り返す

## 5. Report
- `{{baseDir}}/{{outputDir}}/README.md` のアプリケーションの概要を更新する
- コマンドの実行が完了したことをユーザーに報告し、アプリケーションのモックアップを生成する場合は以下のコマンドを実行するよう伝える
  - `/teamkit:design-app {{outputDir}}`


# Output Format

## Output Example

### README.md

```markdown
# ECサイト管理画面

## 概要
オンラインショップの運営者向け管理システム。
商品の登録・在庫管理から注文処理、顧客対応、売上分析まで、
EC運営に必要なすべての機能を一元的に提供する。

## 主な機能
1. **商品管理** - 商品登録・編集、カテゴリ管理、在庫管理
2. **注文管理** - 注文一覧、出荷処理、返品・キャンセル対応
3. **顧客管理** - 顧客情報、購入履歴、お問い合わせ対応
4. **売上管理** - 売上レポート、決済管理、請求書発行
5. **販促管理** - クーポン発行、セール設定、メルマガ配信
6. **設定** - ショップ情報、配送設定、支払い方法設定

## 対象ユーザー
- ECサイト運営者
- ショップ管理者
- カスタマーサポート担当者
```

### navigation.yml

```yaml
# 生成日: <<current date and time>>

# ヘッダーが必要かどうか
header: true

# フッターが必要かどうか
footer: true

# 認証ページが必要かどうか
auth_pages: true

# ナビゲーションメニュー
navigation:
  - section: null
    items:
      - ダッシュボード

  - section: 商品管理
    items:
      - 商品一覧
      - カテゴリ管理
      - 在庫管理

  - section: 注文管理
    items:
      - 注文一覧
      - 出荷管理

  - section: 顧客管理
    items:
      - 顧客一覧
      - お問い合わせ

  - section: 売上管理
    items:
      - 売上レポート
      - 決済一覧

  - section: 販促管理
    items:
      - クーポン管理
      - メルマガ配信

  - section: 設定
    items:
      - ショップ設定
      - 配送設定
      - 支払い設定
```
