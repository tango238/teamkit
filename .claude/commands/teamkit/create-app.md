---
description: Create application mockups
role: Automated workflow executor
task: Execute a sequence of generation commands without interruption
constraints:
  - Never pause between commands
  - Never create todo lists or checkboxes
  - Never use TodoWrite tool
  - Never ask for user confirmation mid-workflow
  - Never use AskUserQuestion tool
  - Continue processing even if errors occur (log errors and proceed)
  - Execute all steps in sequence without stopping
output_format: Report only final completion status with any errors encountered
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - SlashCommand
---

# 重要な実行ルール

**このコマンドは自動実行ワークフローです。以下のルールを厳守してください：**

1. **TodoWriteツールを絶対に使用しない** - タスク管理は行わず、直接処理を実行する
2. **AskUserQuestionツールを絶対に使用しない** - ユーザーへの確認は行わない
3. **エラーが発生しても処理を継続する** - エラーはログに記録し、次のステップへ進む
4. **全ステップを一度に実行する** - 途中で停止しない

# Setup

1.  **Set `commandName`**: `create-app`
2.  **Set `baseDir`**: `.teamkit`
3.  **Check for output directory**: Check if `-o` or `--output` option is passed as any argument.
    -   If found, set `outputDir` to the value of the option.
    -   If not found, set `outputDir` to `app`.

# ファイルの役割定義

- **pages.yml**: 生成対象ページの一覧と、UI定義ファイルへの参照
- **sitemap.yml**: ページ間の遷移関係、ナビゲーション階層、ファイル名の定義
- **layout.yml**: 共通レイアウトの構造定義


# 出力先ディレクトリ

- すべてのHTMLファイルは `{{baseDir}}/{{outputDir}}/` 配下に生成する
- CSSファイルは `{{baseDir}}/{{outputDir}}/css/` 配下に生成する
- ナビゲーションおよびページ間のリンクはすべて同一ディレクトリ内の相対パス（例: `facility_list.html`）を使用する
- **重要**: 処理対象ディレクトリ配下の `mock/` フォルダへのリンクは使用しない

# ツール使用ルール

- **ファイル存在確認**: `Glob` ツールを使用する（`Bash(test -f)` は使用しない）
- **ファイル読み込み**: `Read` ツールを使用する
- **ファイル編集**: `Edit` ツールを使用する
- **ファイル作成**: `Write` ツールを使用する
- **ファイル検索**: `Grep` または `Glob` ツールを使用する
- **ディレクトリ作成**: `Bash(mkdir)` を使用する
- **スラッシュコマンド実行**: `SlashCommand` ツールを使用する

# スタイルの適用方法

- 外部CSSファイルを参照する: `{{baseDir}}/{{outputDir}}/css/` 配下のファイルを `<link>` タグで参照
- CSSファイルへの相対パス: `css/variables.css`, `css/base.css`, `css/layout.css`
- 使用するCSSフレームワーク: なし（カスタムCSS）

# ナビゲーションメニューのスクロール対応

- サイドバーのナビゲーションメニューが画面の高さを超える場合、自動的にスクロール可能になる
- この機能は `custom.css` の以下のスタイルで実現されている:
  - `.sidebar` は `display: flex; flex-direction: column; height: 100vh;` で固定高さ
  - `.sidebar nav` は `flex: 1; overflow-y: auto;` でスクロール可能
- **重要**: HTMLの構造は以下を維持すること:
  ```html
  <aside class="sidebar">
      <div class="logo">...</div>
      <nav class="mt-4">
          <!-- nav-section要素はすべてnav内に配置 -->
      </nav>
  </aside>
  ```
- ナビゲーションメニュー項目が10個を超える場合でも、この構造により自動的にスクロールバーが表示される


# エラーメッセージフォーマット

- 検証エラー: `[ERROR] Step {N}: {説明} - {詳細}`
- 警告: `[WARNING] Step {N}: {説明} - {詳細}`
- 情報: `[INFO] Step {N}: {説明}`


# 最終レポートに含める項目

- 生成されたファイル数
- 修正されたファイル数
- 削除されたファイル数
- 発生したエラー/警告の一覧


# Execution Step

## 1. 入力検証

- `{{baseDir}}/{{outputDir}}` フォルダが存在するか確認する
  - 存在しない場合は、エラーを表示して終了する
- `{{baseDir}}/{{outputDir}}` フォルダ直下に次のファイルが存在するか確認する
  - sitemap.yml
  - common_layout.html
    - 上記のYAMLファイルが一部でも存在しない場合は、足りないファイル名をエラーとして表示して終了する
    - ヒント: `/teamkit:design-app` コマンドを先に実行してください

## 2. ページ生成

- `{{baseDir}}/{{outputDir}}/sitemap.yml` を読み込む
- `{{baseDir}}/{{outputDir}}/common_layout.html` を読み込み、**サイドバーナビゲーション部分（`<aside>`タグ内全体）を変数として保持する**
- sitemap.yml を再帰的に走査し、全ての `pages` 配列内の項目を収集する
- **重要**: Taskツール（サブエージェント）を使用した並列処理は禁止する。ナビゲーションの一貫性を保つため、1ページずつ順次生成する
- 各ページについて以下を実行:
  1. **出力先決定**: `{{baseDir}}/{{outputDir}}/{file}` に新規HTMLファイルを作成
     - 例: sitemap.ymlの `file: facility_list.html` → `{{baseDir}}/{{outputDir}}/facility_list.html`
  2. **UI定義の読み込み**: sitemap.ymlの `mock` フィールドからパスを解析し、対応する `ui.yml` を読み込む
     - mockパスから機能ディレクトリを特定: `{機能ディレクトリ}/mock/{file}` → `{{baseDir}}/{機能ディレクトリ}/ui.yml`
     - 例: `mock: 2-1_facility/mock/facility_list.html` → `{{baseDir}}/2-1_facility/ui.yml`
  3. **HTML生成**:
     - `common_layout.html` をベースとしてコピー
     - **ナビゲーション同期（必須）**:
       - `common_layout.html` の `<aside>` タグ（サイドバー）を**完全にそのままコピー**する
       - **絶対にナビゲーションを省略・簡略化・短縮しない**
       - `<!-- abbreviated -->` や `<!-- 省略 -->` などのコメントで置き換えることは禁止
       - 全てのナビゲーションセクション（施設管理、スタッフ管理、料金管理、予約管理、宿泊者管理、清掃管理、売上分析など）を必ず含める
     - `{{PAGE_TITLE}}` プレースホルダーを sitemap.yml の `title` 値で置換
     - `{{CONTENT}}` プレースホルダーに `ui.yml` の画面項目に基づくコンテンツを配置
     - パンくずリストを適切に設定（親ページがある場合は階層を表示）
     - 現在のページに対応するナビゲーション項目に `active` クラスを追加
  4. **コンテンツ生成ルール**:
     - `sitemap.yml` の `file` からHTMLファイル名を生成
     - `ui.yml` の該当 view の `sections` > `input_fields` から `type: "data_table"` のフィールドを探し、その `columns` からテーブルヘッダーを生成（`data` からサンプル行を生成、`row_actions` から行アクションを生成）
     - `ui.yml` の該当 view の `sections` > `input_fields` のフィルター用フィールドからフィルター要素を生成
     - `ui.yml` の該当 view の structured `actions`（`id`, `type`, `label`, `style`, `to`）からボタンを生成
     - `ui.yml` の該当 view の `sections` > `input_fields`（`id`, `type`, `label`）からフォーム要素を生成
     - サンプルデータを含めて実際のUIをシミュレート
  5. **リンク先の設定**:
     - sitemap.yml の `links` に基づいてボタンやリンクの遷移先を設定
     - **重要**: リンク先は同一ディレクトリ内のHTMLファイル名のみ（例: `facility_form.html`）
  6. **CSSファイルの生成**:
     - ページごとに必要なスタイルを適用し必要に応じてCSSファイルの修正を行う

## 3. ナビゲーション同期検証（ページ生成直後）

- 生成した各HTMLファイルについて、ナビゲーション部分が `common_layout.html` と**完全一致**しているか即座に検証する
- 検証方法:
  1. 生成したHTMLから `<aside>` タグの内容を抽出
  2. `common_layout.html` の `<aside>` タグの内容と比較
  3. **行数が異なる場合**、または**ナビゲーションセクションが欠落している場合**はエラーとして検出
- 不一致が検出された場合:
  1. エラーログを出力: `[ERROR] Step 3: Navigation mismatch in {file} - Navigation is incomplete or abbreviated`
  2. `common_layout.html` のナビゲーションで該当ファイルを**即座に上書き修正**する
  3. 修正後、再度検証を実行する

## 4. ページリスト検証

- `{{baseDir}}/{{outputDir}}/sitemap.yml` のページ一覧を確認する
- `{{baseDir}}/{{outputDir}}` フォルダにあるHTMLファイルを確認する
- sitemap.yml のページ一覧と `{{baseDir}}/{{outputDir}}` フォルダにあるHTMLファイルを検証する
  - sitemap.yml のページ一覧にしかないページがある場合は、`{{baseDir}}/{{outputDir}}` フォルダに追加生成する
  - `{{baseDir}}/{{outputDir}}` フォルダにあるHTMLファイルにしかないページがある場合は、HTMLファイルを削除する
- **削除対象から除外するファイル**:
  - `common_layout.html`（共通レイアウトテンプレート）
  - `css/` フォルダ配下のファイル
  - `*.yml` ファイル

## 5. ページ項目検証

- `{{baseDir}}/{{outputDir}}` フォルダにあるHTMLファイルを確認する
- 各HTMLファイルについて、対応する `ui.yml` を参照する
  - sitemap.yml の `mock` フィールドから機能ディレクトリを特定
  - ui.ymlのパス構築: `{{baseDir}}/{機能ディレクトリ}/ui.yml`
- `ui.yml` に定義された画面項目と、対応するHTMLファイル内の項目を検証する
  - 検証の際、`ui.yml` をマスターデータとし、過不足があればHTMLファイルを修正する
  - 修正後、再度検証を実行する（最大3回まで）
  - **3回実行しても差分が解消されない場合**:
    1. 残存する差分をエラーログとして出力
    2. 処理を継続する

## 6. 画面遷移検証

- `{{baseDir}}/{{outputDir}}` フォルダにあるHTMLファイルを確認する
- `{{baseDir}}/{{outputDir}}/sitemap.yml` に基づいてHTMLファイル内のリンク先を検証する
  - sitemap.yml を再帰的に走査し、全ての `pages` 配列内の項目を収集する
  - 各ページの `links` 配列に定義されたリンク先が、HTMLファイル内に正しく設定されているかチェック
  - **重要**: リンク先は同一ディレクトリ内のファイル名のみ（mockディレクトリへのパスは不正）
  - 検証の際、`sitemap.yml` をマスターデータとし、差分があればHTMLファイルを修正する
  - 修正後、再度検証を実行する（最大3回まで）
  - **3回実行しても差分が解消されない場合**:
    1. 残存する差分をエラーログとして出力
    2. 処理を継続する

## 7. ナビゲーション検証

- `{{baseDir}}/{{outputDir}}/common_layout.html` と `{{baseDir}}/{{outputDir}}/sitemap.yml` を読み込む
- sitemap.yml を再帰的に走査し、全ての `pages` 配列内の項目を収集する
- 各ページの `nav_level` プロパティを確認する
- `sitemap.yml` の `nav_level: 1` のページと `{{baseDir}}/{{outputDir}}/common_layout.html` のナビゲーションを検証する
  - 検証の際、`sitemap.yml` の `nav_level: 1` のページをマスターデータとし、`common_layout.html` 内のナビゲーションと一致しているかチェックする
  - **チェック項目**:
    1. ナビゲーションに `nav_level: 1` のページのみが含まれているか
    2. `nav_level: 2` 以上のページがナビゲーションに含まれていないか
    3. 各項目のラベル（表示テキスト）が一致しているか
    4. **リンク先が同一ディレクトリ内のファイル名になっているか**（mockへのパスは不正）
  - 差分があればHTMLファイルを修正する

- **nav_level検証**:
  - `common_layout.html` のナビゲーションに含まれる全てのリンクを抽出する
  - 各リンクが `sitemap.yml` のどのページに対応するか特定する
  - 対応するページの `nav_level` が `2` 以上の場合:
    1. 警告メッセージを表示: `[WARNING] Step 7: '{画面名}' has nav_level: {level} - Removing from navigation menu.`
    2. `common_layout.html` のナビゲーションから該当リンクを削除する
  - `sitemap.yml` で `nav_level: 1` だが `common_layout.html` のナビゲーションに含まれていないページがある場合:
    1. 警告メッセージを表示: `[WARNING] Step 7: '{画面名}' has nav_level: 1 but is missing from navigation - Adding to navigation menu.`
    2. `common_layout.html` のナビゲーションに該当リンクを追加する
  - 修正後、再度検証を実行する（最大3回まで）
  - **3回実行しても差分が解消されない場合**:
    1. 残存する差分をエラーログとして出力
    2. 処理を継続する

- **ナビゲーション完全一致検証（必須）**:
  - `common_layout.html` から `<aside>` タグ全体を抽出し、基準ナビゲーションとして保持する
  - `common_layout.html` 内の `<div class="nav-section">` の数をカウントする（基準セクション数）
  - `{{baseDir}}/{{outputDir}}` フォルダにあるHTMLファイル（`common_layout.html` を除く）を1ファイルずつチェックする
  - 各HTMLファイルについて:
    1. `<aside>` タグ全体を抽出する
    2. `<div class="nav-section">` の数をカウントする
    3. **セクション数が基準セクション数と一致しない場合**:
       - エラーログを出力: `[ERROR] Step 7: Navigation incomplete in {file} - Expected {基準セクション数} nav-sections, found {実際の数}`
       - **即座に修正**: `common_layout.html` の `<aside>` タグ全体で該当ファイルの `<aside>` タグを置換する
       - 置換後、現在のページに対応するナビゲーション項目に `active` クラスを追加する
    4. **`<!-- abbreviated -->` や `<!-- 省略 -->` などのコメントが含まれている場合**:
       - エラーログを出力: `[ERROR] Step 7: Navigation abbreviated in {file} - Abbreviated navigation is not allowed`
       - 上記と同様に即座に修正する
  - 修正後、再度検証を実行する（最大3回まで）
  - **3回実行しても差分が解消されない場合**:
    1. 残存する差分をエラーログとして出力
    2. 処理を継続する


# Input Format

## Input Example

### sitemap.yml

```yaml
# 生成日時: <<current date and time>>

sitemap:
  name: ECサイト管理画面
  description: オンラインショップの運営者向け管理システム

  auth:
    name: 認証
    pages:
      - id: login
        file: login.html
        title: ログイン
        mock: auth/mock/login.html
        links:
          - signup.html
          - password_reset.html
      - id: signup
        file: signup.html
        title: 新規登録
        mock: auth/mock/signup.html
        links:
          - login.html
      - id: password-reset
        file: password_reset.html
        title: パスワードリセット
        mock: auth/mock/password_reset.html
        links:
          - login.html

  main:
    dashboard:
      name: ダッシュボード
      pages:
        - id: dashboard
          file: dashboard.html
          title: ダッシュボード
          mock: dashboard/mock/dashboard.html
          nav_level: 1

    product:
      name: 商品管理
      pages:
        - id: product-list
          file: product_list.html
          title: 商品一覧
          mock: product/mock/product_list.html
          nav_level: 1
          links:
            - product_form.html
            - product_delete_dialog.html
        - id: product-form
          file: product_form.html
          title: 商品登録・編集
          mock: product/mock/product_form.html
          nav_level: 2
          parent: product-list
        - id: category-list
          file: category_list.html
          title: カテゴリ管理
          mock: product/mock/category_list.html
          nav_level: 1
        - id: inventory-list
          file: inventory_list.html
          title: 在庫管理
          mock: product/mock/inventory_list.html
          nav_level: 1

    order:
      name: 注文管理
      pages:
        - id: order-list
          file: order_list.html
          title: 注文一覧
          mock: order/mock/order_list.html
          nav_level: 1
          links:
            - order_detail.html
        - id: order-detail
          file: order_detail.html
          title: 注文詳細
          mock: order/mock/order_detail.html
          nav_level: 2
          parent: order-list
        - id: shipping-list
          file: shipping_list.html
          title: 出荷管理
          mock: order/mock/shipping_list.html
          nav_level: 1
    ...

  statistics:
    total_pages: <<number of total pages>>
    auth_pages: <<number of auth pages>>
    main_pages: <<number of main pages>>
```
