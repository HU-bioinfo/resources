#!/bin/bash

# VSIXファイルを直接ダウンロードしてCursorにインストールするスクリプト
# 使用方法: ./install-vsix.sh <VSIX_URL>

# カラーコードの定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘルプ関数
show_help() {
    echo -e "${BLUE}VSIXファイルをダウンロードしてCursorにインストールするスクリプト${NC}"
    echo ""
    echo "使用方法:"
    echo "  $0 <VSIX_URL>"
    echo ""
    echo "例:"
    echo "  $0 https://example.com/extension.vsix"
    echo "  $0 https://github.com/user/repo/releases/download/v1.0.0/extension.vsix"
    echo ""
    echo "オプション:"
    echo "  -h, --help    このヘルプを表示"
    echo ""
}

# エラーハンドリング関数
error_exit() {
    echo -e "${RED}エラー: $1${NC}" >&2
    exit 1
}

# 成功メッセージ関数
success_msg() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 警告メッセージ関数
warning_msg() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 情報メッセージ関数
info_msg() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# 依存関係のチェック
check_dependencies() {
    info_msg "依存関係をチェックしています..."
    
    # curlの確認
    if ! command -v curl &> /dev/null; then
        error_exit "curlコマンドが見つかりません。インストールしてください。"
    fi
    
    # Cursorの確認
    if ! command -v cursor &> /dev/null; then
        error_exit "Cursorコマンドが見つかりません。Cursorがインストールされていることを確認してください。"
    fi
    
    success_msg "すべての依存関係が確認できました"
}

# URLの妥当性チェック
validate_url() {
    local url="$1"
    
    # URLの基本的な形式チェック
    if [[ ! "$url" =~ ^https?:// ]]; then
        error_exit "無効なURL形式です。http://またはhttps://で始まるURLを指定してください。"
    fi
    
    # VSIXファイルの拡張子チェック
    if [[ ! "$url" =~ \.vsix$ ]]; then
        warning_msg "URLが.vsixで終わっていません。本当にVSIXファイルですか？"
        read -p "続行しますか？ (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error_exit "処理を中断しました。"
        fi
    fi
}

# 一時ディレクトリの作成
create_temp_dir() {
    TEMP_DIR=$(mktemp -d)
    if [[ ! -d "$TEMP_DIR" ]]; then
        error_exit "一時ディレクトリの作成に失敗しました。"
    fi
    info_msg "一時ディレクトリを作成しました: $TEMP_DIR"
}

# クリーンアップ関数
cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        info_msg "一時ファイルをクリーンアップしています..."
        rm -rf "$TEMP_DIR"
        success_msg "クリーンアップが完了しました"
    fi
}

# SIGINTとSIGTERMをトラップしてクリーンアップを実行
trap cleanup EXIT INT TERM

# ファイルのダウンロード
download_vsix() {
    local url="$1"
    local filename=$(basename "$url")
    
    # ファイル名が空の場合のフォールバック
    if [[ -z "$filename" || "$filename" == "/" ]]; then
        filename="extension.vsix"
    fi
    
    VSIX_PATH="$TEMP_DIR/$filename"
    
    info_msg "VSIXファイルをダウンロードしています..."
    info_msg "URL: $url"
    info_msg "保存先: $VSIX_PATH"
    
    # curlでダウンロード（プログレスバー付き）
    if curl -L --fail --show-error --progress-bar "$url" -o "$VSIX_PATH"; then
        success_msg "ダウンロードが完了しました"
    else
        error_exit "ダウンロードに失敗しました。URLを確認してください。"
    fi
    
    # ファイルサイズの確認
    if [[ ! -s "$VSIX_PATH" ]]; then
        error_exit "ダウンロードしたファイルが空です。"
    fi
    
    local file_size=$(du -h "$VSIX_PATH" | cut -f1)
    info_msg "ダウンロードしたファイルサイズ: $file_size"
}

# Cursorへのインストール
install_to_cursor() {
    local vsix_path="$1"
    
    info_msg "CursorにVSIXファイルをインストールしています..."
    info_msg "ファイル: $vsix_path"
    
    if cursor --install-extension "$vsix_path"; then
        success_msg "インストールが完了しました！"
    else
        error_exit "インストールに失敗しました。"
    fi
}

# メイン処理
main() {
    # 引数の確認
    if [[ $# -eq 0 ]]; then
        show_help
        error_exit "VSIXファイルのURLを指定してください。"
    fi
    
    # ヘルプの表示
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    local vsix_url="$1"
    
    echo -e "${BLUE}=== VSIX インストーラー ===${NC}"
    echo "VSIXファイルをダウンロードしてCursorにインストールします"
    echo ""
    
    # 各ステップの実行
    check_dependencies
    validate_url "$vsix_url"
    create_temp_dir
    download_vsix "$vsix_url"
    install_to_cursor "$VSIX_PATH"
    
    echo ""
    echo -e "${GREEN}=== インストール完了 ===${NC}"
    success_msg "VSIXファイルのインストールが正常に完了しました！"
    info_msg "Cursorを再起動することをお勧めします。"
}

# スクリプト実行
main "$@" 