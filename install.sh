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

# ソースディレクトリ（このスクリプトからの相対パス）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/.claude/commands/teamkit"

# リモート実行かローカル実行かを判定
# 1. stdinがパイプかどうか（curlの場合）
# 2. BASH_SOURCE[0]がファイルとして存在しない
# 3. ソースディレクトリが存在しない
REMOTE_MODE=false

# stdinがパイプ（curlでパイプされている）かチェック
if [ -p /dev/stdin ] || [ ! -t 0 ]; then
    REMOTE_MODE=true
# BASH_SOURCE[0]がファイルとして存在しないか、/dev/fd/*で始まる場合
elif [ ! -f "${BASH_SOURCE[0]}" ] 2>/dev/null || echo "${BASH_SOURCE[0]}" | grep -q "^/dev/fd/"; then
    REMOTE_MODE=true
# ソースディレクトリが存在しない場合
elif [ ! -d "$SOURCE_DIR" ]; then
    REMOTE_MODE=true
fi

if [ "$REMOTE_MODE" = true ]; then
    echo -e "${BLUE}リモートモードで実行します（GitHubからダウンロード）${NC}"
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


if [ "$REMOTE_MODE" = true ]; then
    echo -e "${BLUE}Team Kit コマンドのインストールを開始します${NC}"
    echo -e "${BLUE}リポジトリ: https://github.com/${REPO_OWNER}/${REPO_NAME}${NC}"
    echo -e "${BLUE}ターゲット: $TARGET_DIR/.claude/commands/teamkit/${NC}"
else
    echo -e "${BLUE}.claude/commands/teamkit ファイルのコピーを開始します${NC}"
    echo -e "${BLUE}ソース: $SOURCE_DIR${NC}"
    echo -e "${BLUE}ターゲット: $TARGET_DIR/.claude/commands/teamkit/${NC}"
fi
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

# ファイルコピー関数
copy_file() {
    local source_file="$1"
    local filename="$(basename "$source_file")"
    local target_file="$TARGET_DIR/.claude/commands/teamkit/$filename"
    local target_dir_path="$(dirname "$target_file")"

    echo -n "  ${filename} ... "

    # ターゲットディレクトリが存在しない場合は作成
    if [ ! -d "$target_dir_path" ]; then
        mkdir -p "$target_dir_path"
    fi

    # ファイルが既に存在する場合
    if [ -f "$target_file" ]; then
        echo -e "${YELLOW}警告: ファイルが既に存在します${NC}"
        if should_overwrite "$target_file"; then
            cp "$source_file" "$target_file"
            echo -e "    ${GREEN}✓ 上書きしました${NC}"
            return 0
        else
            echo -e "    ${BLUE}スキップしました${NC}"
            return 0
        fi
    else
        cp "$source_file" "$target_file"
        echo -e "${GREEN}✓${NC}"
        return 0
    fi
}

# .claude/commands/teamkit/ 以下の全ファイルを処理
echo -e "${YELLOW}ファイルを処理中...${NC}"

if [ "$REMOTE_MODE" = true ]; then
    # リモートモード: GitHubからダウンロード
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
else
    # ローカルモード: ファイルコピー
    find "$SOURCE_DIR" -type f | while read -r source_file; do
        copy_file "$source_file"
    done
fi

echo ""
echo -e "${GREEN}完了しました！${NC}"
