# Team Kit

AI駆動開発における周辺業務の自動化ツール

Team Kitは、Claude や Cursor などのAIエディタと連携して、要件定義から仕様書作成、モックアップ生成までを自動化するコマンド集です。

## 主な機能

### 📋 要件の整合性チェック
- 要件の整合性を自動検証
- ロジックの妥当性検証
- 自動的な指摘事項の生成

### 👥 ユーザー視点での評価
- カスタムフィードバックの収集と管理
- デザインや使いやすさの改善提案

### 🤖 自動化されたワークフロー
- フィーチャー定義の生成
- ユーザーストーリーの作成
- ユースケースの抽出
- UI定義の生成
- 画面遷移図の作成
- HTMLモックアップの自動生成

## インストール

### 前提条件
- Claude Code
- bash シェル環境

### インストール手順


```bash
# カレントディレクトリにインストール
curl -fsSL https://raw.githubusercontent.com/tango238/teamkit/main/install.sh | bash -s -- .

# 強制上書き（確認なし）
curl -fsSL https://raw.githubusercontent.com/tango238/teamkit/main/install.sh | bash -s -- --yes .

# 特定のディレクトリにインストール
curl -fsSL https://raw.githubusercontent.com/tango238/teamkit/main/install.sh | bash -s -- /path/to/project
```

**オプション:**
- `--yes`, `-y`, `--force`, `-f`: 既存ファイルを確認せずに上書き

インストールスクリプトは `.claude/commands/tk` ディレクトリ以下のすべてのコマンドファイルを、指定したプロジェクトディレクトリに同じ構造でコピーします。

## 基本的な使い方

Team Kitは、段階的な仕様書作成ワークフローを提供します。各ステップは `/tk-*` というスラッシュコマンドとして利用できます。

### 1. プロジェクトの初期化

まず、仕様書を管理するディレクトリを作成します:

```
your-project/
└── specs/
    └── YourFeature/
        └── README.md  # 要件を記述
```

### 2. フィーチャーの作成

`README.md` から要件を抽出し、フィーチャー定義を生成します:

```
/create-feature YourFeature
```

**生成ファイル:**
- `specs/YourFeature/feature.yml` - フィーチャー定義
- `specs/YourFeature/status.json` - ステータス管理ファイル

### 3. HTMLモックアップの生成

UI定義からインタラクティブなHTMLモックアップを生成します:

```
/create-mock YourFeature
```

**生成ファイル:**
- `specs/YourFeature/index.html` - モックアップのインデックスページ
- `specs/YourFeature/mock/*.html` - 各画面のモックアップ
- `specs/YourFeature/mock/screens.yml` - 画面生成ステータス

## 便利なコマンド

### チェック機能

仕様の整合性をチェック:

```
/check YourFeature
```

### フィードバック機能

仕様に対するフィードバックを提出:

```
/feedback YourFeature "住所フィールドを詳細に分割してください"
```

フィードバックを適用:

```
/apply-feedback YourFeature
```

### フィーチャーの更新

check.mdが更新された際にフィーチャーを再生成:

```
/update-feature YourFeature
```

### ステータス確認

現在のステップ情報を確認:

```
/get-step-info YourFeature
```

### クリーンアップ（未実装）

生成されたファイルをクリーンアップ:

```
/clean YourFeature
```

## ディレクトリ構造

インストール後、プロジェクトは以下の構造になります:

```
your-project/
├── .claude/
│   └── commands/
│       └── tk/           # Team Kitコマンド
│           ├── create-feature.md
│           ├── generate-story.md
│           ├── generate-usecase.md
│           ├── generate-ui.md
│           ├── generate-screenflow.md
│           ├── generate-mock.md
│           ├── create-mock.md
│           ├── check.md
│           ├── feedback.md
│           ├── apply-feedback.md
│           ├── update-feature.md
│           ├── get-step-info.md
│           ├── update-status.md
│           ├── generate-log.md
│           └── clean.md
└── specs/
    └── <feature-name>/
        ├── README.md          # 要件定義
        ├── feature.yml        # 機能要件の定義
        ├── stories.yml        # ユーザーストーリー
        ├── usecases.yml       # ユースケース
        ├── ui.yml             # UI定義
        ├── screen-flow.md     # 画面遷移図
        ├── status.json        # ステータス管理
        ├── feedback.md        # フィードバック
        ├── index.html         # モックアップインデックス
        ├── mock/screens.yml   # 画面生成ステータス
        └── mock/*.html        # 各画面のモックアップ
```

## ワークフロー例

典型的な開発フローの例:

```bash
# 1. 要件をREADME.mdに記述
# 2. フィーチャー定義から始める
/create-feature OrderManagement

# 3. すべてのステップを自動実行
/create-mock OrderManagement

# 4. 生成されたモックアップを確認
# specs/OrderManagement/index.html をブラウザで開く

# 5. フィードバックがあれば提出
/feedback OrderManagement "注文キャンセル機能を追加してください"

# 6. フィードバックを反映
/apply-feedback OrderManagement

# 7. 整合性チェック
/check OrderManagement
```

## 出力言語

- **コマンドの説明**: 英語
- **生成される仕様書**: 日本語
- **ステータスメッセージ**: 日本語

これにより、LLMが正確に理解しつつ、日本語の仕様書を生成できます。

## ライセンス

このプロジェクトのライセンスについては [LICENSE](LICENSE) ファイルを参照してください。

## サポート

問題が発生した場合や機能リクエストがある場合は、GitHubのIssuesセクションで報告してください。
