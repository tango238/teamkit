---
description: Design application mockups
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
---

# ツール使用ルール

- **ファイル存在確認**: `Glob` ツールを使用する（`Bash(test -f)` は使用しない）
- **ファイル読み込み**: `Read` ツールを使用する
- **ファイル編集**: `Edit` ツールを使用する
- **ファイル作成**: `Write` ツールを使用する
- **ファイル検索**: `Grep` または `Glob` ツールを使用する
- **ディレクトリ作成**: `Bash(mkdir)` を使用する

# 初期変数

1. **`commandName`**: `design-app`
2. **`baseDir`**: `specs`
3. **`outputDir`**: 引数に `-o` または `--output` オプションがあればその値、なければ `app`


# リンク形式ルール

以下のルールはすべてのステップおよび生成ファイルに適用される:

- **href属性**: 同一ディレクトリ内のファイル名のみを指定する
  - 例: `facility_list.html`（○）
  - 例: `../specs/facility/mock/facility_list.html`（×）
- **CSS参照**: `css/custom.css` のみを使用する
- **禁止**: 処理対象ディレクトリ配下の `mock/` フォルダへのリンクは使用しない


# スタイルの適用方法

- TailwindCSS CDN を使用し、追加のカスタムスタイルは `css/custom.css` に定義する


# Execution Step

## 1. 初期設定

- `{{baseDir}}` 直下にあるディレクトリを「対象ディレクトリ一覧」とする
- 各ディレクトリ直下に `screenflow.md`、`ui.yml`、`status.json` があるか確認する
- すべてのファイルがあった場合、そのディレクトリ名を `処理対象ディレクトリ` に追加する
- `処理対象ディレクトリ` を表示する
- `{{baseDir}}/{{outputDir}}` フォルダの必須ファイルを確認する
  - `0_navigation.yml` が存在しない場合は、エラーを表示して終了する
  - `README.md` が存在しない場合は、エラーを表示して終了する
- `{{baseDir}}/{{outputDir}}/css` フォルダが存在しない場合は作成する

## 2. Planning

- `{{baseDir}}/{{outputDir}}/0_navigation.yml` を読み込む
- `{{baseDir}}/{{outputDir}}/README.md` を読み込む
- `{{baseDir}}/{{outputDir}}/0_navigation.yml` と `{{baseDir}}/{{outputDir}}/README.md` から以下を決定し、`{{baseDir}}/{{outputDir}}/1_layout.yml` に保存する
  - **レイアウトタイプ**:
    - `sidebar-main`: サイドバー付きの管理画面レイアウト
    - `header-main`: ヘッダーナビゲーション付きのフロントページレイアウト（ECサイト購入者向け）
    - `centered-card`: 中央配置のカードレイアウト（認証画面用）
  - **サイドバー構成**（sidebar-main の場合）: ロゴ、ナビゲーションメニュー項目
  - **サイトヘッダー構成**（header-main の場合）: ロゴ、検索バー、カテゴリナビ、カート、ユーザーメニュー
  - **コンテンツヘッダー構成**（sidebar-main の場合）: パンくずリスト、通知、ユーザーメニュー
  - 記載内容については Output Example にある layout.yml を参照
  - href はリンク形式ルールに従うこと

- `{{baseDir}}/{{outputDir}}/1_pages.yml` を作成する
- `0_navigation.yml` から全てのナビゲーション項目を抽出し、`ナビゲーション対象ページ一覧` を作成する
  - 各項目の `href`（ファイル名）と `label`（表示名）を記録する
- 処理対象ディレクトリを順番に以下の処理を進める
  - 処理対象ディレクトリ直下にある `ui.yml` および `screenflow.md` を読み込む
  - 読み込んだ `ui.yml` から `ナビゲーション対象ページ一覧` に関連するページのみを抽出し `1_pages.yml` に追記する
    - **関連ページの判定基準**:
      - ui.yml のページ名と 0_navigation.yml の `label` が一致するページ
      - ui.yml の mock ファイル名と 0_navigation.yml の `href` が一致するページ
      - `screenflow.md` で上記ページから遷移可能なページ（子ページ、モーダル、ダイアログなど）
    - 記載内容については Output Example にある pages.yml を参照

- `1_pages.yml` に記載されたページ情報と、対応する `screenflow.md` の遷移情報から、アプリケーション全体のサイトマップを作成する
- 作成したサイトマップを `{{baseDir}}/{{outputDir}}/1_sitemap.yml` に保存する
  - 記載内容については Output Example にある sitemap.yml を参照
  - links はリンク形式ルールに従うこと
  - **file フィールドの決定ルール**:
    - ui.yml に `file` フィールドがある場合: その値を使用
    - ui.yml に `file` フィールドがない場合: `name` フィールドから生成（スネークケース + `.html`）
    - 全体で重複しない、意味が分かる長さの名前にすること
  - mock フィールドには処理対象ディレクトリの mock パスを記録（存在しない場合は省略可）
  - **セクション分類ルール**:
    - `auth`: ログイン、サインアップ、パスワードリセットなど認証関連のページ
    - `main`: 認証後にアクセスする業務機能のページ
  - **nav_level の決定ルール**:
    - `nav_level: 1`: サイドバーに直接表示されるトップレベルのページ（一覧画面など）
    - `nav_level: 2`: トップレベルから遷移する子ページ（登録・編集画面など）
  - **parent の決定ルール**:
    - `nav_level: 2` 以上のページには、遷移元となる親ページの `id` を `parent` に設定する

## 3. Planning Inspection

- `{{baseDir}}/{{outputDir}}/1_sitemap.yml` と `{{baseDir}}/{{outputDir}}/1_pages.yml` を突合し、過不足がないかチェックする
  - **突合キー**: ページ名（`name` / `title`）で突合する
  - `1_pages.yml` にしかないページがある場合は、`1_sitemap.yml` に追加する
  - **最大再試行回数**: 突合チェックは最大5回まで実行する。5回試行しても不整合が解消されない場合は、エラーを表示して終了する

## 4. 共通レイアウト生成

- `{{baseDir}}/{{outputDir}}/common_layout.html` が存在するか確認する
- `{{baseDir}}/{{outputDir}}/common_layout.html` が存在する場合は削除する
- `{{baseDir}}/{{outputDir}}/1_layout.yml` を読み込む
- 以下のルールに従って `{{baseDir}}/{{outputDir}}/common_layout.html` を生成する:
  1. `layout.type` に基づいてベースのHTML構造を決定する
     - `sidebar-main`: サイドバー + メインコンテンツのレイアウト（管理画面向け）
     - `header-main`: ヘッダー + メインコンテンツ + フッターのレイアウト（ECフロント向け）
     - `centered-card`: 中央配置のカードレイアウト（認証ページ用）
  2. `sidebar-main` の場合: `sidebar` セクションからサイドバーを生成し、`header` セクションからコンテンツエリアのヘッダー（パンくずリスト等）を生成
  3. `header-main` の場合: `header` セクションからサイトヘッダーを生成し、`footer` セクションからフッターを生成
  4. `navigation` の各項目をナビゲーションリンクとして配置
     - **重要**: リンク先は `{{baseDir}}/{{outputDir}}/` 配下のHTMLファイル名のみ（例: `product_list.html`）
     - mockディレクトリへの相対パスは使用しない
- CSSスタイルの適用方法: 外部CSSを作成して `{{baseDir}}/{{outputDir}}/css/` 配下に保存し、`<link>` タグで参照する

## 5. CSS ファイル生成

- `{{baseDir}}/{{outputDir}}/css/custom.css` を生成する
- カスタム CSS には以下のスタイルを含める:
  - サイドバー（背景色、幅、固定位置）
  - ナビゲーションアイテム（ホバー、アクティブ状態）
  - メインコンテンツエリア
  - ヘッダー
  - その他共通コンポーネント
- TailwindCSS のユーティリティクラスで対応できないスタイルのみ定義する

## 6. バージョン情報出力

- 処理対象ディレクトリごとに `status.json` を読み込む
  - パス: `{{baseDir}}/{処理対象ディレクトリ}/status.json`
- 各 `status.json` から `steps.ui.version` の値を取得する
- 取得したバージョン情報を `{{baseDir}}/{{outputDir}}/version.json` に出力する
  - 出力形式については Output Example の version.json を参照

## 7. 完了報告

- コマンドの実行完了を報告し、次のステップとして以下のコマンドを案内する
  - `/teamkit:create-app -o {{outputDir}}`


# Input Format

## Input Example

### 0_navigation.yml

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


# Output Format

## Output Example

### version.json

```json
{
  "generated_at": "<<current date and time in ISO 8601 format>>",
  "sources": {
    "auth": "1",
    "product": "2",
    "order": "1"
  }
}
```

### 1_pages.yml

```yaml
features:
  - name: auth
    pages:
      - name: "ログイン画面"
        actor: "ショップ管理者"
        tracking: "auth/ui.yml:12"
      - name: "パスワードリセット画面"
        actor: "ショップ管理者"
        tracking: "auth/ui.yml:35"
      ...
  - name: product
    pages:
      - name: "商品一覧画面"
        actor: "ショップ管理者"
        tracking: "product/ui.yml:18"
      - name: "商品登録・編集画面"
        actor: "ショップ管理者"
        tracking: "product/ui.yml:45"
      ...
  - name: order
    pages:
      - name: "注文一覧画面"
        actor: "ショップ管理者"
        tracking: "order/ui.yml:12"
      ...
```

### 1_sitemap.yml

```yaml
# 生成日時: <<current date and time>>

sitemap:
  name: <<application name from `{{README.md}}`>>
  description: <<application description from `{{README.md}}`>>

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

### 1_layout.yml

```yaml
# 生成日: <<current date and time>>

layout:
  type: sidebar-main
  description: サイドバー付きの管理画面レイアウト

sidebar:
  class: sidebar
  logo:
    text: <<application name from `{{README.md}}`>>
    class: logo

  navigation:
    - section: null
      items:
        - id: dashboard
          label: ダッシュボード
          href: dashboard.html
          visible: true

    - section: 商品管理
      items:
        - id: product-list
          label: 商品一覧
          href: product_list.html
          visible: true
        - id: category-list
          label: カテゴリ管理
          href: category_list.html
          visible: true
        - id: inventory-list
          label: 在庫管理
          href: inventory_list.html
          visible: true

    - section: 注文管理
      items:
        - id: order-list
          label: 注文一覧
          href: order_list.html
          visible: true
        - id: shipping-list
          label: 出荷管理
          href: shipping_list.html
          visible: true
    ...

header:
  class: header
  components:
    - id: breadcrumb
      class: breadcrumb
      description: パンくずリスト

    - id: header-actions
      class: header-actions
      components:
        - id: notification-badge
          class: notification-badge
          icon: bell
          visible: true
        - id: user-menu
          class: user-menu
          components:
            - id: user-avatar
              class: user-avatar
            - id: user-name

auth_pages:
  layout:
    type: centered-card
    pages:
      - id: login
        href: login.html
        label: ログイン
      - id: signup
        href: signup.html
        label: 新規登録
      - id: password-reset
        href: password_reset.html
        label: パスワードリセット
```

### css/custom.css（sidebar-main レイアウト用）

```css
/* Sidebar Styles */
.sidebar {
  width: 240px;
  height: 100vh;
  position: fixed;
  left: 0;
  top: 0;
  overflow-y: auto;
}

.nav-item {
  display: block;
  padding: 12px 20px;
  transition: all 0.2s;
}

.nav-item:hover {
  background: rgba(255, 255, 255, 0.1);
}

.nav-item.active {
  background: rgba(255, 255, 255, 0.15);
  border-left: 3px solid #6c5ce7;
}

/* Main Content */
.main-content {
  margin-left: 240px;
  min-height: 100vh;
}

/* Header */
.header {
  padding: 15px 30px;
  border-bottom: 1px solid #eee;
}
```

### css/custom.css（header-main レイアウト用）

```css
/* ===========================================
   カラーテーマの変更方法:
   --color-primary を変更するだけでボタン、リンク、
   バッジなどの色が一括で変わります。

   例: 緑系 → --color-primary: #10b981;
   例: 青系 → --color-primary: #3b82f6;
   例: 赤系 → --color-primary: #ef4444;
   =========================================== */

:root {
  /* プライマリカラー（ブランドカラーとして変更可能） */
  --color-primary: #4f46e5;
  --color-primary-dark: #4338ca;
  --color-primary-light: #818cf8;

  /* ヘッダー・フッター */
  --header-bg: #1f2937;
  --header-secondary: #374151;

  /* テキスト */
  --text-primary: #111827;
  --text-secondary: #6b7280;
  --text-light: #9ca3af;

  /* リンク */
  --link-color: #4f46e5;

  /* ボーダー・背景 */
  --border-color: #e5e7eb;
  --bg-light: #f9fafb;
  --bg-white: #ffffff;

  /* アクセント */
  --accent-success: #10b981;
  --accent-warning: #f59e0b;
}

/* Site Header */
.site-header {
  background: var(--header-bg);
  color: white;
}

.header-top {
  display: flex;
  align-items: center;
  padding: 10px 20px;
  gap: 20px;
}

.logo {
  font-size: 1.5rem;
  font-weight: bold;
  color: white;
}

.search-bar {
  flex: 1;
  max-width: 600px;
  display: flex;
}

.search-bar input {
  flex: 1;
  padding: 10px 15px;
  border: none;
  border-radius: 4px 0 0 4px;
}

.search-bar button {
  padding: 10px 20px;
  background: var(--color-primary);
  border: none;
  border-radius: 0 4px 4px 0;
  color: white;
  cursor: pointer;
}

.cart-icon .badge {
  background: var(--color-primary);
  color: white;
  border-radius: 50%;
  padding: 2px 6px;
  font-size: 0.75rem;
}

/* Category Navigation */
.category-nav {
  background: var(--header-secondary);
  padding: 8px 20px;
}

/* Main Content */
.main-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
  background: var(--bg-white);
}

/* Breadcrumb */
.breadcrumb a {
  color: var(--link-color);
}

/* Product Card */
.product-card {
  background: var(--bg-white);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 15px;
}

.product-rating .stars {
  color: var(--accent-warning);
}

.delivery-badge {
  background: var(--accent-success);
  color: white;
  padding: 2px 8px;
  border-radius: 3px;
  font-size: 0.7rem;
}

.add-to-cart {
  width: 100%;
  padding: 10px;
  background: var(--color-primary);
  border: none;
  border-radius: 6px;
  color: white;
  cursor: pointer;
  font-weight: 500;
}

.add-to-cart:hover {
  background: var(--color-primary-dark);
}

/* Pagination */
.pagination .active {
  background: var(--color-primary);
  color: white;
}

/* Site Footer */
.site-footer {
  background: var(--header-bg);
  color: white;
  padding: 40px 20px 20px;
}

.footer-bottom {
  background: #111827;
  text-align: center;
  padding: 20px;
  color: var(--text-light);
}
```

# 生成されるHTMLファイルの例

## common_layout.html（sidebar-main レイアウト：管理画面向け）

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{PAGE_TITLE}} - ECショップ管理</title>
    <link rel="stylesheet" href="css/custom.css">
</head>
<body>
    <aside class="sidebar">
        <div class="logo">ECショップ管理</div>
        <nav class="nav-section">
            <a href="dashboard.html" class="nav-item">ダッシュボード</a>
        </nav>
        <nav class="nav-section">
            <div class="nav-section-title">商品管理</div>
            <a href="product_list.html" class="nav-item">商品一覧</a>
            <a href="category_list.html" class="nav-item">カテゴリ管理</a>
            <a href="inventory_list.html" class="nav-item">在庫管理</a>
        </nav>
        <nav class="nav-section">
            <div class="nav-section-title">注文管理</div>
            <a href="order_list.html" class="nav-item">注文一覧</a>
            <a href="shipping_list.html" class="nav-item">出荷管理</a>
        </nav>
        <!-- ... -->
    </aside>
    <main class="main-content">
        <header class="header">
            <div class="breadcrumb">
                <a href="dashboard.html">ホーム</a>
                <span>&gt;</span>
                <span>{{PAGE_TITLE}}</span>
            </div>
            <!-- ... -->
        </header>
        <div class="page-content">
            {{CONTENT}}
        </div>
    </main>
</body>
</html>
```

## common_layout.html（header-main レイアウト：ECフロント向け）

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{PAGE_TITLE}} - ECショップ</title>
    <link rel="stylesheet" href="css/custom.css">
</head>
<body>
    <header class="site-header">
        <div class="header-top">
            <a href="index.html" class="logo">ECショップ</a>
            <div class="search-bar">
                <input type="text" placeholder="商品を検索">
                <button type="submit">検索</button>
            </div>
            <div class="header-actions">
                <div class="user-menu">
                    <span>アカウント</span>
                </div>
                <a href="cart.html" class="cart-icon">
                    <span>カート</span>
                    <span class="badge">0</span>
                </a>
            </div>
        </div>
        <nav class="category-nav">
            <a href="category_list.html">すべてのカテゴリ</a>
            <a href="product_list.html?filter=new">新着商品</a>
            <a href="ranking.html">ランキング</a>
            <a href="product_list.html?filter=sale">セール</a>
        </nav>
    </header>

    <main class="main-content">
        <div class="breadcrumb">
            <a href="index.html">ホーム</a>
            <span>&gt;</span>
            <span>{{PAGE_TITLE}}</span>
        </div>
        <div class="page-content">
            {{CONTENT}}
        </div>
    </main>

    <footer class="site-footer">
        <div class="footer-nav">
            <section>
                <h4>ショッピングガイド</h4>
                <a href="guide.html">ご利用ガイド</a>
                <a href="payment.html">お支払い方法</a>
                <a href="shipping.html">配送について</a>
                <a href="returns.html">返品・交換</a>
            </section>
            <section>
                <h4>カスタマーサポート</h4>
                <a href="faq.html">よくある質問</a>
                <a href="contact.html">お問い合わせ</a>
            </section>
            <section>
                <h4>会社情報</h4>
                <a href="about.html">会社概要</a>
                <a href="terms.html">利用規約</a>
                <a href="privacy.html">プライバシーポリシー</a>
            </section>
        </div>
        <div class="footer-bottom">
            © 2024 ECショップ. All rights reserved.
        </div>
    </footer>
</body>
</html>
```

## product_list.html（生成例：管理画面 sidebar-main）

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品一覧 - ECショップ管理</title>
    <link rel="stylesheet" href="css/custom.css">
</head>
<body>
    <aside class="sidebar">
        <!-- common_layout.html と同じナビゲーション -->
    </aside>
    <main class="main-content">
        <header class="header">
            <div class="breadcrumb">
                <a href="dashboard.html">ホーム</a>
                <span>&gt;</span>
                <span>商品一覧</span>
            </div>
            <!-- ... -->
        </header>
        <div class="page-content">
            <h1>商品一覧</h1>
            <div class="filters">
                <!-- ui.yml の filters から生成 -->
            </div>
            <div class="actions">
                <button class="btn btn-primary" onclick="location.href='product_form.html'">新規商品登録</button>
            </div>
            <table>
                <!-- ui.yml の display_fields から生成 -->
            </table>
        </div>
    </main>
</body>
</html>
```

## product_list.html（生成例：ECフロント header-main）

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品一覧 - ECショップ</title>
    <link rel="stylesheet" href="css/custom.css">
</head>
<body>
    <header class="site-header">
        <!-- common_layout.html と同じヘッダー -->
    </header>

    <main class="main-content">
        <div class="breadcrumb">
            <a href="index.html">ホーム</a>
            <span>&gt;</span>
            <span>商品一覧</span>
        </div>
        <div class="page-content">
            <div class="product-list-header">
                <h1>商品一覧</h1>
                <div class="sort-options">
                    <select>
                        <option>おすすめ順</option>
                        <option>価格が安い順</option>
                        <option>価格が高い順</option>
                        <option>新着順</option>
                    </select>
                </div>
            </div>

            <div class="product-list-container">
                <aside class="filter-sidebar">
                    <div class="filter-section">
                        <h3>カテゴリ</h3>
                        <!-- ui.yml の filters から生成 -->
                    </div>
                    <div class="filter-section">
                        <h3>価格帯</h3>
                        <!-- 価格フィルター -->
                    </div>
                </aside>

                <div class="product-grid">
                    <!-- 商品カード -->
                    <div class="product-card">
                        <a href="product_detail.html">
                            <img src="images/product1.jpg" alt="商品画像" class="product-image">
                            <div class="product-info">
                                <h3 class="product-name">商品名</h3>
                                <p class="product-price">¥1,980</p>
                                <div class="product-rating">
                                    <span class="stars">★★★★☆</span>
                                    <span class="review-count">(24)</span>
                                </div>
                                <span class="delivery-badge">翌日配送</span>
                            </div>
                        </a>
                        <button class="add-to-cart">カートに追加</button>
                    </div>
                    <!-- ... 他の商品カード -->
                </div>
            </div>

            <div class="pagination">
                <!-- ページネーション -->
            </div>
        </div>
    </main>

    <footer class="site-footer">
        <!-- common_layout.html と同じフッター -->
    </footer>
</body>
</html>
```
