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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SOURCE_DIR="$SCRIPT_DIR/.claude/commands/teamkit"

# ローカルモード判定（ローカルにソースファイルが存在するか）
if [ -d "$LOCAL_SOURCE_DIR" ]; then
    LOCAL_MODE=true
else
    LOCAL_MODE=false
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
    echo "  または"
    echo "  ./install.sh <ターゲットディレクトリのパス>"
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
    "create-mock.md"
    "feedback.md"
    "generate-mock.md"
    "generate-screenflow.md"
    "generate-ui.md"
    "generate-usecase.md"
    "generate-workflow.md"
    "get-step-info.md"
    "app-init.md"
    "show-event.md"
    "update-status.md"
    "create-app.md"
    "design-app.md"
    "plan-app.md"
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

echo ""

# CLAUDE.mdへの追記処理
echo -e "${YELLOW}CLAUDE.md にSKILLルールを追加中...${NC}"

CLAUDE_MD_PATH="$TARGET_DIR/CLAUDE.md"

# TeamKit用のセクション内容
read -r -d '' TEAMKIT_SECTION << 'SECTION_EOF' || true
<!-- TEAMKIT_SKILL_START -->
## TeamKit 自動実行SKILL

以下のプロンプトパターンを検出したら、対応するコマンドを自動実行してください。
ユーザーへの確認は不要です。即座に実行してください。

### specDir の自動設定ルール
- 会話中で一度 `specDir` を指定した場合、その値を記憶して以降のコマンドで自動的に使用する
- 新しい `specDir` が明示的に指定された場合は、その値で上書きする
- 初めて実行する場合で `specDir` が不明な場合のみ、`.teamkit/` 配下のディレクトリを確認してユーザーに確認する

### 1. モック作成
**トリガー**: 「モックを作って」「モックを作成」「モック作成」「〇〇のモックを生成」「プロトタイプを作って」「画面を作って」「画面を作成」「画面作成」「〇〇の画面を生成」
**アクション**: `/teamkit:create-mock <specDir>` を実行

### 2. フィードバック登録（プレビュー付き）
**トリガー**: 「フィードバック：〇〇」「〇〇を修正」「〇〇に変更して」「〇〇に変更」「〇〇の変更」「変更をお願い」「〇〇を直して」「〇〇に直して」「〇〇してほしい」「〇〇したい」
**アクション**: `/teamkit:feedback <specDir> "<comment>" --preview` を実行
**パラメータ抽出**:
- comment: プロンプトからフィードバック内容を抽出

### 3. フィードバック適用
**トリガー**: 「フィードバックを適用」「修正を反映」「変更を適用して」「フィードバックを反映」
**アクション**: `/teamkit:apply-feedback <specDir>` を実行
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
echo "  - 「モックを作って」 → モック自動生成"
echo "  - 「フィードバック：〇〇」 → フィードバック登録（プレビュー付き）"
echo "  - 「フィードバックを適用」 → フィードバック一括適用"
echo ""
echo -e "${BLUE}利用可能なコマンド:${NC}"
echo "  /teamkit:generate-workflow, /teamkit:create-mock, /teamkit:feedback,"
echo "  /teamkit:apply-feedback, /teamkit:design-app, etc."
