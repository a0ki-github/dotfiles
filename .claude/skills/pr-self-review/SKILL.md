---
name: pr-self-review
description: 自分のPRに、セッション中に検討した設計判断・考慮点をセルフレビューコメント（インラインコメント）として残すスキル。ユーザーが「セルフレビューして」「セルフレビューコメント残して」「検討したことをPRにコメントして」「設計判断を記録して」と言った場合に使用する。
---

# PRセルフレビュースキル

自分のPRに、実装・執筆時に検討した設計判断をインラインコメントとして残す。レビュアーの理解を助け、判断の記録を残すことが目的。

## コメントの書き方（最重要）

レビュアーに見えている情報（PRの差分）を基準に書く。セッション内のやり取りや推敲の履歴はレビュアーには見えていない。

- 「変更前」として参照してよいのは、PRの差分に表示されているものだけ
    - 既存記述を更新するPR: 変更前は差分に見えているので、「〜から変えた理由」という書き方が正しい
    - 新規作成のPR: セッション中の推敲でボツにした案はレビュアーに見えないので、「〜から変えた理由」ではなく「A ではなく B にした理由」と単体で読める対比で書く
        - NG: 「追従手順を fetch → merge から PR 状態の分岐に変えた理由」
        - OK: 「追従手順を『fetch で差分確認 → merge』ではなく『PR 状態で分岐』にした理由」
- 内容は判断の根拠になったものを書く: トレードオフ、検討して捨てた案とその理由、前提にした運用・制約
- diffを読めば分かること（何をしたか）は書かない。diffから読み取れないこと(なぜそうしたか)だけを書く

## 手順

### 1. 対象の確認

```bash
# PR番号と、コメント対象のコミットがPRに含まれているか確認
gh pr view {pr_number} --json commits --jq '.commits[] | .oid[0:7] + " " + .messageHeadline'

# コメントを付ける行番号の特定（PRのHEAD時点の内容で確認する）
git show {head_sha}:{path} | cat -n
```

### 2. レビューJSONの作成

日本語・複数行本文のエスケープ事故を防ぐため、インラインで組み立てず一時ファイル（scratchpad）にJSONを書いて `--input` で渡す。

```json
{
  "commit_id": "{PRのHEADのフルSHA}",
  "event": "COMMENT",
  "body": "セルフレビュー: 設計時に考慮した点をインラインコメントに残します。",
  "comments": [
    {
      "path": "path/to/file",
      "line": 10,
      "side": "RIGHT",
      "body": "**◯◯ではなく△△にした理由**\n\n- ..."
    }
  ]
}
```

### 3. 投稿

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --input {json_path} --jq '{id: .id, state: .state, url: .html_url}'
```

- `gh pr review` はインラインコメントを付けられないため `gh api` を使用する
- 投稿後、レビューの見出し・内容を要約してユーザーに報告する

## 投稿済みコメントの修正

```bash
# コメントIDの特定（レビューIDで絞り込む）
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '.[] | select(.pull_request_review_id == {review_id}) | {id: .id, path: .path, line: .line}'

# 本文の更新（bodyのみのJSONを一時ファイルに書いて渡す）
gh api repos/{owner}/{repo}/pulls/comments/{comment_id} --method PATCH --input {json_path}
```
