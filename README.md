# VSIX インストーラー

リモートからVSIXファイルを直接ダウンロードして、CursorエディターにインストールするためのBashスクリプトです。

## 特徴

- リモートURLからVSIXファイルを自動ダウンロード
- Cursorへの自動インストール
- エラーハンドリングとバリデーション
- カラー出力による見やすいメッセージ
- 一時ファイルの自動クリーンアップ

## 必要な環境

- Linux/macOS/WSL
- Bash シェル
- `curl` コマンド
- `cursor` コマンド（Cursor エディターのCLI）

## 使用方法

### 基本的な使用方法

```bash
./install-vsix.sh <VSIX_URL>
```

### 例

```bash
# GitHub Releasesからダウンロード
./install-vsix.sh https://github.com/user/repo/releases/download/v1.0.0/extension.vsix

# 直接ダウンロードURL
./install-vsix.sh https://example.com/path/to/extension.vsix
```

### ヘルプの表示

```bash
./install-vsix.sh --help
# または
./install-vsix.sh -h
```

## 処理の流れ

1. **依存関係チェック**: `curl`と`cursor`コマンドの存在確認
2. **URL検証**: URLの形式とVSIXファイルの拡張子確認
3. **一時ディレクトリ作成**: ダウンロード用の安全な一時領域
4. **ファイルダウンロード**: curlを使用したプログレスバー付きダウンロード
5. **Cursorインストール**: VSIXファイルのCursorへのインストール
6. **クリーンアップ**: 一時ファイルの削除

## エラーハンドリング

- 不正なURL形式の検出
- ダウンロード失敗の処理
- インストール失敗の処理
- シグナル処理による安全な終了
- 一時ファイルの確実なクリーンアップ

## セキュリティ

- 一時ディレクトリは安全に作成・削除
- ダウンロードはSSL/TLS接続で実行
- ファイルサイズの検証

## トラブルシューティング

### `cursor`コマンドが見つからない場合

Cursorエディターが正しくインストールされていることを確認してください。

```bash
which cursor
```

### `curl`コマンドが見つからない場合

curlをインストールしてください：

```bash
# Ubuntu/Debian
sudo apt install curl

# CentOS/RHEL
sudo yum install curl

# macOS
brew install curl
```

### ダウンロードが失敗する場合

- URLが正しいことを確認
- ネットワーク接続を確認
- ファイアウォール設定を確認

## ライセンス

このスクリプトはMITライセンスの下で公開されています。 