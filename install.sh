#!/bin/bash
set -e

# カラー出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHubリポジトリ情報
REPO_OWNER="tango238"
REPO_NAME="teamkit"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

# スクリプトのディレクトリを取得（ローカル実行判定用）
# curl | bash の場合、BASH_SOURCE[0] が空になるためリモートモードを強制
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "bash" ]; then
    LOCAL_MODE=false
    SCRIPT_DIR=""
    LOCAL_SOURCE_DIR=""
    LOCAL_SKILLS_DIR=""
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    LOCAL_SOURCE_DIR="$SCRIPT_DIR/.claude/commands/teamkit"
    LOCAL_SKILLS_DIR="$SCRIPT_DIR/.claude/skills/teamkit"

    # ローカルモード判定（ローカルにソースファイルが存在するか）
    if [ -d "$LOCAL_SOURCE_DIR" ]; then
        LOCAL_MODE=true
    else
        LOCAL_MODE=false
    fi
fi

# 引数チェック
FORCE_OVERWRITE=false
TARGET_DIR=""

# 引数を解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y|--force|-f)
            FORCE_OVERWRITE=true
            shift
            ;;
        *)
            if [ -z "$TARGET_DIR" ]; then
                TARGET_DIR="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$TARGET_DIR" ]; then
    echo -e "${RED}エラー: ターゲットディレクトリのパスを指定してください${NC}"
    echo ""
    echo "使用方法:"
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/install.sh | bash -s -- <ターゲットディレクトリのパス>"
    echo ""
    echo "オプション:"
    echo "  --yes, -y, --force, -f  既存ファイルを確認せずに上書き"
    echo ""
    echo "例:"
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/install.sh | bash -s -- ."
    echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}/install.sh | bash -s -- --yes /path/to/target-project"
    exit 1
fi

# ターゲットディレクトリの存在確認と作成
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}警告: ターゲットディレクトリが存在しません: $TARGET_DIR${NC}"
    echo -e "${BLUE}ディレクトリを作成します...${NC}"
    mkdir -p "$TARGET_DIR"
fi

# 絶対パスに変換
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# ローカルモードでソースとターゲットが同一ディレクトリの場合はリモートモードにフォールバック
if [ "$LOCAL_MODE" = true ] && [ "$SCRIPT_DIR" = "$TARGET_DIR" ]; then
    LOCAL_MODE=false
fi

echo -e "${BLUE}Team Kit コマンドのインストールを開始します${NC}"
if [ "$LOCAL_MODE" = true ]; then
    echo -e "${BLUE}モード: ローカル（${LOCAL_SOURCE_DIR}）${NC}"
else
    echo -e "${BLUE}リポジトリ: https://github.com/${REPO_OWNER}/${REPO_NAME}${NC}"
fi
echo -e "${BLUE}ターゲット: $TARGET_DIR/.claude/commands/teamkit/${NC}"
echo ""

# ファイルコピー関数（ローカルモード用）
copy_local_file() {
    local file_path="$1"
    local target_path="$2"
    local source_path="$LOCAL_SOURCE_DIR/$file_path"

    echo -n "  ${file_path} ... "

    if [ -f "$source_path" ]; then
        cp "$source_path" "$target_path"
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗ (ファイルが見つかりません: $source_path)${NC}"
        return 1
    fi
}

# ダウンロード関数（リモートモード用）
download_file() {
    local file_path="$1"
    local target_path="$2"
    local url="${BASE_URL}/.claude/commands/teamkit/${file_path}"

    echo -n "  ${file_path} ... "

    if curl -fsSL "$url" -o "$target_path" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# ファイル取得関数（モードに応じて切り替え）
get_file() {
    local file_path="$1"
    local target_path="$2"

    if [ "$LOCAL_MODE" = true ]; then
        copy_local_file "$file_path" "$target_path"
    else
        download_file "$file_path" "$target_path"
    fi
}

# コマンドファイルのリスト
COMMAND_FILES=(
    "apply-feedback.md"
    "check-status.md"
    "feedback.md"
    "generate-mock.md"
    "generate-screenflow.md"
    "generate-ui.md"
    "generate-usecase.md"
    "generate-workflow.md"
    "generate-manual.md"
    "generate-acceptance-test.md"
    "get-step-info.md"
    "add.md"
    "show-event.md"
    "update-status.md"
    "create-app.md"
    "design-app.md"
    "plan-app.md"
    "export-to-takt.md"
    "takt-init.md"
)

# 既存ファイルの上書き確認関数
should_overwrite() {
    local file_path="$1"
    if [ "$FORCE_OVERWRITE" = true ]; then
        return 0  # 上書きする
    fi

    # 対話的に確認
    echo -e "    ${YELLOW}警告: $file_path は既に存在します。上書きしますか？ (y/N)${NC}" >&2
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0  # 上書きする
    else
        return 1  # スキップする
    fi
}

# 廃止されたコマンドファイルの削除（アップグレード時の互換性対応）
DEPRECATED_FILES=(
    "create-feature.md"
    "generate-story.md"
    "update-feature.md"
    "check.md"
    "create-mock.md"
)

deprecated_found=false
for file in "${DEPRECATED_FILES[@]}"; do
    target_file="$TARGET_DIR/.claude/commands/teamkit/$file"
    if [ -f "$target_file" ]; then
        if [ "$deprecated_found" = false ]; then
            echo -e "${YELLOW}廃止されたコマンドファイルを削除中...${NC}"
            deprecated_found=true
        fi
        rm "$target_file"
        echo -e "  ${GREEN}✓${NC} $file を削除しました"
    fi
done

# skills に移動されたコマンドファイルの削除（commands → skills 移行対応）
MOVED_TO_SKILLS_FILES=(
    "app-init.md"
    "create.md"
    "generate.md"
)

moved_found=false
for file in "${MOVED_TO_SKILLS_FILES[@]}"; do
    target_file="$TARGET_DIR/.claude/commands/teamkit/$file"
    if [ -f "$target_file" ]; then
        if [ "$moved_found" = false ]; then
            echo -e "${YELLOW}skills に移動されたコマンドファイルを削除中...${NC}"
            moved_found=true
        fi
        rm "$target_file"
        echo -e "  ${GREEN}✓${NC} $file を削除しました（skills に移動済み）"
    fi
done

# .claude/commands/teamkit/ 以下の全ファイルを処理
echo -e "${YELLOW}ファイルをダウンロード中...${NC}"

# GitHubからダウンロード
for file in "${COMMAND_FILES[@]}"; do
    target_file="$TARGET_DIR/.claude/commands/teamkit/$file"
    target_dir="$(dirname "$target_file")"
    
    # ターゲットディレクトリが存在しない場合は作成
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    # ファイルが既に存在する場合
    if [ -f "$target_file" ]; then
        echo -e "${YELLOW}警告: $file は既に存在します${NC}"
        if should_overwrite "$target_file"; then
            get_file "$file" "$target_file"
            echo -e "    ${GREEN}✓ 上書きしました${NC}"
        else
            echo -e "    ${BLUE}スキップしました${NC}"
        fi
    else
        get_file "$file" "$target_file"
    fi
done

# スキルファイルのリスト（.claude/skills/teamkit/ に配置）
SKILL_FILES=(
    "manual-creator.md"
    "app-init.md"
    "create.md"
    "generate.md"
    "feedback-apply.md"
)

# スキルファイルのコピー関数（ローカルモード用）
copy_local_skill() {
    local file_path="$1"
    local target_path="$2"
    local source_path="$LOCAL_SKILLS_DIR/$file_path"

    echo -n "  ${file_path} ... "

    if [ -f "$source_path" ]; then
        cp "$source_path" "$target_path"
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗ (ファイルが見つかりません: $source_path)${NC}"
        return 1
    fi
}

# スキルファイルのダウンロード関数（リモートモード用）
download_skill() {
    local file_path="$1"
    local target_path="$2"
    local url="${BASE_URL}/.claude/skills/teamkit/${file_path}"

    echo -n "  ${file_path} ... "

    if curl -fsSL "$url" -o "$target_path" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# スキルファイル取得関数（モードに応じて切り替え）
get_skill_file() {
    local file_path="$1"
    local target_path="$2"

    if [ "$LOCAL_MODE" = true ]; then
        copy_local_skill "$file_path" "$target_path"
    else
        download_skill "$file_path" "$target_path"
    fi
}

# .claude/skills/teamkit/ 以下のスキルファイルを処理
echo -e "${YELLOW}スキルファイルをインストール中...${NC}"

for file in "${SKILL_FILES[@]}"; do
    target_file="$TARGET_DIR/.claude/skills/teamkit/$file"
    target_dir="$(dirname "$target_file")"

    # ターゲットディレクトリが存在しない場合は作成
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    # ファイルが既に存在する場合
    if [ -f "$target_file" ]; then
        echo -e "${YELLOW}警告: $file は既に存在します${NC}"
        if should_overwrite "$target_file"; then
            get_skill_file "$file" "$target_file"
            echo -e "    ${GREEN}✓ 上書きしました${NC}"
        else
            echo -e "    ${BLUE}スキップしました${NC}"
        fi
    else
        get_skill_file "$file" "$target_file"
    fi
done

# テーマファイルのリスト（.teamkit/themes/ に配置）
THEME_FILES=(
    "A4-Manual.css"
)

LOCAL_THEMES_DIR="$SCRIPT_DIR/.teamkit/themes"

# テーマファイルのコピー関数（ローカルモード用）
copy_local_theme() {
    local file_path="$1"
    local target_path="$2"
    local source_path="$LOCAL_THEMES_DIR/$file_path"

    echo -n "  ${file_path} ... "

    if [ -f "$source_path" ]; then
        cp "$source_path" "$target_path"
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗ (ファイルが見つかりません: $source_path)${NC}"
        return 1
    fi
}

# テーマファイルのダウンロード関数（リモートモード用）
download_theme() {
    local file_path="$1"
    local target_path="$2"
    local url="${BASE_URL}/.teamkit/themes/${file_path}"

    echo -n "  ${file_path} ... "

    if curl -fsSL "$url" -o "$target_path" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# テーマファイル取得関数（モードに応じて切り替え）
get_theme_file() {
    local file_path="$1"
    local target_path="$2"

    if [ "$LOCAL_MODE" = true ]; then
        copy_local_theme "$file_path" "$target_path"
    else
        download_theme "$file_path" "$target_path"
    fi
}

# .teamkit/themes/ 以下のテーマファイルを処理
echo -e "${YELLOW}テーマファイルをインストール中...${NC}"

for file in "${THEME_FILES[@]}"; do
    target_file="$TARGET_DIR/.teamkit/themes/$file"
    target_dir="$(dirname "$target_file")"

    # ターゲットディレクトリが存在しない場合は作成
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    # ファイルが既に存在する場合
    if [ -f "$target_file" ]; then
        echo -e "${YELLOW}警告: $file は既に存在します${NC}"
        if should_overwrite "$target_file"; then
            get_theme_file "$file" "$target_file"
            echo -e "    ${GREEN}✓ 上書きしました${NC}"
        else
            echo -e "    ${BLUE}スキップしました${NC}"
        fi
    else
        get_theme_file "$file" "$target_file"
    fi
done

echo ""

# CLAUDE.mdへの追記処理
echo -e "${YELLOW}CLAUDE.md にSKILLルールを追加中...${NC}"

CLAUDE_MD_PATH="$TARGET_DIR/CLAUDE.md"

# TeamKit用のセクション内容
read -r -d '' TEAMKIT_SECTION << 'SECTION_EOF' || true
<!-- TEAMKIT_SKILL_START -->
## TeamKit 自然言語ルーティング

ユーザーが日本語の自然言語で入力した場合、以下の判定ロジックに従って適切なコマンドを自動実行する。
スラッシュコマンドが明示的に指定された場合はそのコマンドをそのまま実行し、このルーティングは適用しない。

---

### specDir の自動設定ルール

- 会話中で一度 `specDir` を指定・特定した場合、その値を記憶して以降のコマンドで自動的に使用する
- 新しい `specDir` が明示的に指定された場合は、その値で上書きする
- `specDir` が不明な場合は `.teamkit/` 配下のディレクトリ一覧を確認し、ユーザーに選択を求める

---

### 判定フローチャート

```
ユーザーの自然言語入力
│
├─ [判定1] .teamkit/ が存在しない、または機能ディレクトリがない
│   → /teamkit:app-init <appName> を実行
│
├─ [判定2] フィードバック適用の指示か？
│   → /teamkit:apply-feedback <specDir> を実行
│
├─ [判定3] 新機能追加の指示か？（.teamkit/ に該当ディレクトリが存在しない）
│   → /teamkit:create <featureName> を実行（add + generate を連続実行）
│
├─ [判定4] 仕様生成または機能変更の指示か？
│   ├─ 対象機能の README.md を読み込み、ユーザーの入力内容と比較
│   │
│   ├─ README.md に記載のない新しい要件・変更を含む
│   │   → /teamkit:feedback <specDir> "<入力内容>" -p を実行
│   │
│   └─ 既存 README.md の範囲内（生成指示のみ）
│       → /teamkit:generate <specDir> を実行
│
├─ 上記のいずれにも該当しない場合
│   → 通常の会話として応答する
│
└─ 判定できない場合
    → ユーザーに意図を確認する
```

---

### 判定1: 初期セットアップ（最優先）

**条件**: `.teamkit/` ディレクトリが存在しない、または `.teamkit/` 配下に機能ディレクトリ（README.md を持つサブディレクトリ）が1つもない

**トリガー例**:
- 「勤怠管理アプリを作りたい」
- 「ECサイトの管理画面を作ろう」
- 「タスク管理ツールの要件をまとめたい」
- アプリの構想や要件に関する自由記述

**アクション**: `/teamkit:app-init <appName>` を実行
- `appName` はユーザーの入力からアプリケーション名を抽出する
- 抽出できない場合はユーザーに確認する

---

### 判定2: フィードバック適用

**トリガー例**:
- 「フィードバックを適用して」
- 「修正を反映して」
- 「変更を適用して」
- 「フィードバックを反映して」

**アクション**: `/teamkit:apply-feedback <specDir>` を実行

---

### 判定3: 新機能追加

**条件**: ユーザーの入力が新しい機能の追加を指示しており、`.teamkit/` 配下に該当するディレクトリが存在しない

**トリガー例**:
- 「在庫管理機能を追加して」（`.teamkit/inventory-management/` が存在しない）
- 「新しくレポート機能を作って」（`.teamkit/report/` が存在しない）

**アクション**: `/teamkit:create <featureName>` を実行（add + generate を連続実行）

---

### 判定4: 仕様生成 vs フィードバック（README.md 差分チェック）

**条件**: `.teamkit/` 配下に対象の機能ディレクトリが存在する

**判定手順**:
1. 対象の `specDir` を特定する（ユーザーの入力から機能名を抽出し、`.teamkit/` 配下のディレクトリ名と照合）
2. `<specDir>/README.md` を読み込む
3. ユーザーの入力内容と README.md の内容を比較する

| ユーザーの入力 | 判定結果 | 実行コマンド |
|---|---|---|
| 既存要件の範囲で「仕様を生成して」「生成して」等の生成指示 | 生成 | `/teamkit:generate <specDir>` |
| README.md にない新機能・変更・追加の記述を含む | フィードバック | `/teamkit:feedback <specDir> "<内容>" -p` |
| 既存仕様・モックへの修正を明示的に指示 | フィードバック | `/teamkit:feedback <specDir> "<内容>" -p` |

**生成と判定するトリガー例**:
- 「商品管理の仕様を生成して」
- 「勤怠管理を生成」
- 「attendanceの仕様を作って」

**フィードバックと判定するトリガー例**:
- 「商品管理に在庫アラート機能を追加して」
- 「注文管理の画面に検索機能を追加して」
- 「ダッシュボードのレイアウトを変更して」
- 「〇〇を修正して」「〇〇を直して」「〇〇に変更して」

---

### 自動ルーティング対象外コマンド

以下のコマンドは自然言語からの自動ルーティング対象外。使用するにはスラッシュコマンドを直接入力すること。

- `/teamkit:generate-workflow` - ワークフロー単体生成
- `/teamkit:generate-usecase` - ユースケース単体生成
- `/teamkit:generate-ui` - UI定義単体生成
- `/teamkit:generate-screenflow` - 画面遷移単体生成
- `/teamkit:generate-mock` - モックHTML単体生成
- `/teamkit:generate-manual` - マニュアル生成
- `/teamkit:generate-acceptance-test` - 受け入れテスト生成
- `/teamkit:show-event` - イベント表示
- `/teamkit:check-status` - ステータス確認
- `/teamkit:update-status` - ステータス更新
- `/teamkit:get-step-info` - ステップ情報取得
- `/teamkit:export-to-takt` - Taktエクスポート
- `/teamkit:takt-init` - Takt初期化
- `/teamkit:design-app` - アプリ設計
- `/teamkit:create-app` - アプリ作成
- `/teamkit:plan-app` - アプリ計画
<!-- TEAMKIT_SKILL_END -->
SECTION_EOF

# CLAUDE.mdが存在するかチェック
if [ -f "$CLAUDE_MD_PATH" ]; then
    # 既存のTeamKitセクションがあるかチェック
    if grep -q "<!-- TEAMKIT_SKILL_START -->" "$CLAUDE_MD_PATH"; then
        # 既存セクションを置換
        # 一時ファイルを使用して安全に置換
        TEMP_FILE=$(mktemp)
        awk '
            /<!-- TEAMKIT_SKILL_START -->/ { skip=1; next }
            /<!-- TEAMKIT_SKILL_END -->/ { skip=0; next }
            !skip { print }
        ' "$CLAUDE_MD_PATH" > "$TEMP_FILE"

        # TeamKitセクションを末尾に追加
        echo "" >> "$TEMP_FILE"
        echo "$TEAMKIT_SECTION" >> "$TEMP_FILE"

        mv "$TEMP_FILE" "$CLAUDE_MD_PATH"
        echo -e "  ${GREEN}✓ 既存のTeamKitセクションを更新しました${NC}"
    else
        # 新規セクションを追記
        echo "" >> "$CLAUDE_MD_PATH"
        echo "$TEAMKIT_SECTION" >> "$CLAUDE_MD_PATH"
        echo -e "  ${GREEN}✓ TeamKitセクションを追加しました${NC}"
    fi
else
    # CLAUDE.mdを新規作成
    echo "# Project Rules" > "$CLAUDE_MD_PATH"
    echo "" >> "$CLAUDE_MD_PATH"
    echo "$TEAMKIT_SECTION" >> "$CLAUDE_MD_PATH"
    echo -e "  ${GREEN}✓ CLAUDE.md を作成しました${NC}"
fi

echo ""
echo -e "${GREEN}完了しました！${NC}"
echo ""
echo -e "${BLUE}利用可能なSKILL（自然言語で自動実行）:${NC}"
echo "  - アプリの構想を話す → 初期セットアップ (app-init)"
echo "  - 「〇〇機能を追加して」→ 新機能追加 (create)"
echo "  - 「〇〇の仕様を生成して」→ 仕様生成 (generate)"
echo "  - 「〇〇を変更して」→ フィードバック登録 (feedback -p)"
echo "  - 「フィードバックを適用」→ フィードバック適用 (apply-feedback)"
echo ""
echo -e "${BLUE}スラッシュコマンド（手動実行）:${NC}"
echo "  /teamkit:feedback-apply, /teamkit:generate-workflow,"
echo "  /teamkit:generate-mock, /teamkit:check-status, etc."
