---
description: このセッションで起動したサブエージェントの一覧と使用モデルを表示する
allowed-tools: Bash
---

# Session Agents

現在のセッション内で起動されたサブエージェントの情報（種類・説明・実際に使われたモデル・トークン使用量）を表示してください。

## 手順

1. 現在のセッションIDを特定する。システムプロンプトに記載されている scratchpad ディレクトリのパスが
   `.../<プロジェクトスラッグ>/<セッションID>/scratchpad` という形式になっているので、そこからセッションIDとプロジェクトスラッグを取り出す。

2. 以下のスクリプトの `<PROJECT_SLUG>` と `<SESSION_ID>` を置き換えて実行する:

```bash
dir=~/.claude/projects/<PROJECT_SLUG>/<SESSION_ID>/subagents
if [ ! -d "$dir" ] || ! ls "$dir"/agent-*.jsonl >/dev/null 2>&1; then
  echo "このセッションで起動されたサブエージェントはありません"
else
  for jsonl in "$dir"/agent-*.jsonl; do
    id=$(basename "$jsonl" .jsonl)
    meta="$dir/$id.meta.json"
    echo "=== $id ==="
    [ -f "$meta" ] && cat "$meta" && echo
    model=$(grep -o '"model":"[^"]*"' "$jsonl" | sed 's/"model":"//;s/"//' | sort -u | paste -sd, -)
    tokens=$(grep -o '"output_tokens":[0-9]*' "$jsonl" | awk -F: '{s+=$2} END {print s}')
    echo "model: ${model:-unknown}"
    echo "output_tokens: ${tokens:-0}"
    echo
  done
fi
```

3. 結果を以下の列を持つmarkdownテーブルに整形して表示する:
   - **Agent ID**（`agent-` プレフィックスは省略可）
   - **Type**（meta.json の `agentType`）
   - **Description**（meta.json の `description`）
   - **Model**（実際に使われたモデルID。複数あればすべて）
   - **Output Tokens**

## 注意

- transcript の JSONL フォーマットは Claude Code の内部仕様であり、バージョンによって変わる可能性がある。パースに失敗した場合はその旨を伝えること。
- サブエージェントが1つもない場合は「このセッションで起動されたサブエージェントはありません」とだけ伝えること。
