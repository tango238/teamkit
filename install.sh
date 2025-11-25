#!/bin/bash
set -e

# カラー出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ソースディレクトリ（このスクリプトからの相対パス）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/.claude/commands/tk"

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
    echo "  ./install.sh <ターゲットディレクトリのパス>"
    echo ""
    echo "オプション:"
    echo "  --yes, -y, --force, -f  既存ファイルを確認せずに上書き"
    echo ""
    echo "例:"
    echo "  ./install.sh /path/to/target-project"
    echo "  ./install.sh --yes /path/to/target-project"
    exit 1
fi

# ソースディレクトリの存在確認
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}エラー: ソースディレクトリが存在しません: $SOURCE_DIR${NC}"
    exit 1
fi

# ターゲットディレクトリの存在確認
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}エラー: ターゲットディレクトリが存在しません: $TARGET_DIR${NC}"
    exit 1
fi

# 絶対パスに変換
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo -e "${BLUE}.claude/commands/tk ファイルのコピーを開始します${NC}"
echo -e "${BLUE}ソース: $SOURCE_DIR${NC}"
echo -e "${BLUE}ターゲット: $TARGET_DIR${NC}"
echo ""

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
    local relative_path="${source_file#$SOURCE_DIR/}"
    local target_file="$TARGET_DIR/$relative_path"
    local target_dir_path="$(dirname "$target_file")"

    echo -n "  ${relative_path} ... "

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

# .claude/commands/tk 以下の全ファイルを処理
echo -e "${YELLOW}ファイルをコピー中...${NC}"
find "$SOURCE_DIR" -type f | while read -r source_file; do
    copy_file "$source_file"
done

echo ""
echo -e "${GREEN}完了しました！${NC}"
