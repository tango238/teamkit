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
echo -e "${BLUE}リポジトリ: https://github.com/${REPO_OWNER}/${REPO_NAME}${NC}"
echo -e "${BLUE}ターゲット: $TARGET_DIR/.claude/commands/teamkit/${NC}"
echo ""

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

# コマンドファイルのリスト
COMMAND_FILES=(
    "apply-feedback.md"
    "check-status.md"
    "check.md"
    "clean.md"
    "create-feature.md"
    "create-mock.md"
    "feedback.md"
    "generate-log.md"
    "generate-mock.md"
    "generate-screenflow.md"
    "generate-story.md"
    "generate-ui.md"
    "generate-usecase.md"
    "get-step-info.md"
    "update-feature.md"
    "update-status.md"
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
            download_file "$file" "$target_file"
            echo -e "    ${GREEN}✓ 上書きしました${NC}"
        else
            echo -e "    ${BLUE}スキップしました${NC}"
        fi
    else
        download_file "$file" "$target_file"
    fi
done

echo ""
echo -e "${GREEN}完了しました！${NC}"
