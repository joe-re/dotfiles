# herdr 操作メモ

[herdr](https://herdr.dev) は AI コーディングエージェント向けのターミナルワークスペースマネージャ。
tmux のように prefix キーからの操作で workspace / tab / pane を管理する。

## この dotfiles での構成

- **インストール**: nix（`nix/flake.nix` の `herdr` input → `nix/home.nix` の `herdrPkg`）
- **設定ファイル**: `config/herdr/config.toml` → `~/.config/herdr/config.toml` に symlink
  - herdr はログ・ソケット・セッション状態を `~/.config/herdr/` に書き込むため、ディレクトリごとではなく `config.toml` のみを symlink している
- **prefix キー**: `Ctrl+t`（デフォルトの `Ctrl+b` から変更）
- **zsh 連携**: `config/zsh/zshrc` の preexec フックで、herdr の pane 内で `claude` / `codex` を起動すると pane 名がカレントディレクトリ名に自動リネームされる

## 基本操作

すべて **prefix（`Ctrl+t`）を押してから** 次のキーを押す。

### 全般

| キー | 操作 |
|---|---|
| `Ctrl+t` `?` | ヘルプ表示 |
| `Ctrl+t` `s` | 設定画面 |
| `Ctrl+t` `q` | デタッチ |
| `Ctrl+t` `Shift+r` | config.toml のリロード |
| `Ctrl+t` `g` | goto（ナビゲートモード） |
| `Ctrl+t` `b` | サイドバーの表示切り替え |
| `Ctrl+t` `o` | 通知対象を開く |

### Workspace

| キー | 操作 |
|---|---|
| `Ctrl+t` `w` | workspace ピッカー |
| `Ctrl+t` `Shift+n` | 新規 workspace |
| `Ctrl+t` `Shift+g` | 新規 git worktree |
| `Ctrl+t` `Shift+w` | workspace リネーム |
| `Ctrl+t` `Shift+d` | workspace を閉じる |

### Tab

| キー | 操作 |
|---|---|
| `Ctrl+t` `c` | 新規 tab |
| `Ctrl+t` `n` / `p` | 次 / 前の tab |
| `Ctrl+t` `1..9` | tab 番号で切り替え |
| `Ctrl+t` `Shift+t` | tab リネーム |
| `Ctrl+t` `Shift+x` | tab を閉じる |

### Pane

| キー | 操作 |
|---|---|
| `Ctrl+t` `v` | 縦分割 |
| `Ctrl+t` `-` | 横分割 |
| `Ctrl+t` `h` / `j` / `k` / `l` | pane フォーカス移動（vim 風） |
| `Ctrl+t` `Tab` / `Shift+Tab` | pane を順番に切り替え |
| `Ctrl+t` `z` | pane のズーム（全画面切り替え） |
| `Ctrl+t` `r` | リサイズモード |
| `Ctrl+t` `x` | pane を閉じる |
| `Ctrl+t` `Shift+p` | pane リネーム |
| `Ctrl+t` `e` | スクロールバックをエディタで開く |

### カスタムバインド（config.toml で定義）

| キー | 操作 |
|---|---|
| `Ctrl+t` `Shift+b` | pane を新しい tab に切り出してフォーカス（tmux の break-pane 相当） |

## よく使う CLI コマンド

```bash
herdr                        # 永続セッションを起動 or アタッチ
herdr --session <name>       # 名前付きセッションを使用
herdr --remote <ssh-target>  # SSH 経由でリモートの herdr サーバにアタッチ
herdr status                 # クライアント / サーバの状態表示
herdr update                 # 最新版に更新
herdr server stop            # サーバ停止
herdr server reload-config   # config.toml をリロード
herdr config reset-keys      # カスタムキーバインドをリセット（バックアップあり）
```

### ソケット API 系（スクリプトから操作する用）

```bash
herdr workspace <subcommand>    # workspace 操作
herdr tab <subcommand>          # tab 操作
herdr pane <subcommand>         # pane 操作（rename など）
herdr agent <subcommand>        # agent / terminal 操作
herdr worktree <subcommand>     # git worktree 操作
herdr notification <subcommand> # 通知操作
herdr wait <subcommand>         # 条件待ち（ブロッキング）
```

herdr が管理する pane 内では `$HERDR_PANE_ID` / `$HERDR_ACTIVE_PANE_ID` / `$HERDR_BIN_PATH`
などの環境変数が使える。zshrc の pane 自動リネームはこれを利用している:

```zsh
herdr pane rename "$HERDR_PANE_ID" "${PWD:t}"
```

## その他

- ログ: `~/.config/herdr/herdr.log`（`herdr-client.log` / `herdr-server.log` もあり）
- デフォルト設定の全体像: `herdr --default-config`
- このメモは herdr 0.7.1 時点の内容
