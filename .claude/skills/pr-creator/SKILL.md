---
name: pr-creator
description: PRの作成と説明文の記載を行うスキル。ユーザーが「PRを作成して」「プルリクエストを作って」「create a PR」「make a pull request」と言った場合や、PR作成のワークフローについて話している場合に使用する。
---

# PR作成スキル

GitHub PRの作成と説明文の記載を行うスキル。

## テンプレート

`.github/PULL_REQUEST_TEMPLATE.md` を参照し、フォーマットに従って記載すること。

## ベースブランチの決定

- 引数で指定された場合: 引数のブランチを使用（例: `/pr-creator renewal/develop`）
- 引数なし: `renewal/develop` をデフォルトとして使用

## 手順

### 1. 事前確認

```bash
# 現在のブランチ名を取得
git branch --show-current

# 未コミットの変更がないか確認
git status

# ベースブランチからの差分コミットを取得
git log {base_branch}..HEAD --oneline

# 差分の内容を確認
git diff {base_branch}..HEAD --stat
```

### 2. push（未pushの場合）

リモートに未pushのコミットがある場合はpushを行う。

- スキル内でユーザーに許可を尋ねない（AskUserQuestion等での事前確認は不要）
    - 理由: `git push` は settings.json の permissions で Ask になっており、実行時に許可プロンプトが出る。スキル内で確認すると二度手間になるため

```bash
# ブランチ名は必ず明示する（カレントブランチの暗黙pushはしない）
git push origin {branch_name}
```

- すでにpush済み（リモートと差分なし）の場合はこのステップをスキップしてよい

### 3. テンプレートの確認

```bash
cat .github/PULL_REQUEST_TEMPLATE.md
```

### 4. PR作成

Assigneesには自分（PR作成者）を設定する（`--assignee "@me"`）。

```bash
# PRを作成（Assigneesに自分を設定）
gh pr create --base {base_branch} --assignee "@me" --title "タイトル" --body "$(cat <<'EOF'
## やったこと
- 変更内容1
- 変更内容2

## 動作確認
### API
- [ ] 確認項目

### Admin
- [ ] 確認項目

### その他
- [ ] 確認項目

## 備考
特記事項があれば記載
EOF
)"
```

### 5. CIテスト通過後、Copilotにレビュー依頼

PR作成後、CIの完了を待ち、テストがpassしたらGitHub Copilotにレビューを依頼する。

```bash
# CIの完了を待つ（全チェック成功で終了コード0、失敗があれば非0）
gh pr checks {pr_number} --watch --fail-fast

# CIがpassしたらCopilotにレビュー依頼
gh api repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers \
  -f "reviewers[]=copilot-pull-request-reviewer[bot]"
```

- 成功判定: レスポンスの `requested_reviewers` に `"login": "Copilot"` (type: Bot) が含まれていること
- CIが失敗した場合はレビュー依頼を行わず、失敗内容をユーザーに報告する
    - 理由: 落ちているコードにレビューを走らせても修正で差分が変わり、レビュー結果が無駄になるため
- CIの実行時間が長い場合は `gh pr checks {pr_number} --watch` をバックグラウンド実行し、完了通知を受けてからレビュー依頼を行う

### 6. Copilotレビュー完了の監視と結果報告

レビュー依頼を投げたらターンを終えず、完了監視をバックグラウンドで仕掛ける。ユーザーが結果を聞きに来なくても自動で報告できるようにするため。

```bash
# Copilotのレビューが付くまでポーリング（30秒間隔・最大30分）
# レビュー完了で終了コード0、タイムアウトで非0
for i in $(seq 1 60); do
  count=$(gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
    --jq '[.[] | select(.user.login == "copilot-pull-request-reviewer[bot]")] | length')
  if [ "$count" -gt 0 ]; then exit 0; fi
  sleep 30
done
exit 1
```

- 上記をバックグラウンド実行（run_in_background）し、完了通知を受けたらレビュー結果を確認して報告する
- 結果確認と報告内容:
    ```bash
    # レビュー本文（"generated no comments" なら指摘なし）
    gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --jq '.[] | {user: .user.login, body: .body}'
    # インラインコメント（指摘の実体はこちらに付く）
    gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --jq '.[] | {path: .path, line: .line, body: .body}'
    ```
    - 指摘なし: 「指摘なし」と報告
    - 指摘あり: 指摘の件数と内容（ファイル・行・要旨）を報告する。対応するかはユーザーの判断に委ねる
- タイムアウト（非0終了）の場合はその旨を報告し、ユーザーに手動確認を促す

### 7. PR説明文の更新（既存PRの場合）

```bash
# PR番号を取得
gh pr view --json number -q '.number'

# PR説明文を更新
gh api repos/{owner}/{repo}/pulls/{pr_number} \
  --method PATCH \
  -f body="$(cat <<'EOF'
## やったこと
...
EOF
)"
```

## 注意事項

- `gh pr edit`はGraphQL APIの制限でエラーになる場合があるため、説明文の更新には`gh api`を使用する
- 既存PRへのAssignee追加も同様に`gh pr edit --add-assignee`ではなくREST API（`gh api repos/{owner}/{repo}/issues/{pr_number}/assignees -f "assignees[]={login}"`）を使用する（新規作成時は`gh pr create --assignee "@me"`でよい）
- Copilotへのレビュー依頼も`gh pr edit --add-reviewer`ではなくREST API（`gh api`）を使用する。レビュアー名は`copilot-pull-request-reviewer[bot]`を指定する（`Copilot`ではAPIが解決できない）
- コミットメッセージのプレフィックス（add:, fix:, refactor:など）を維持する
- 動作確認方法はAPI・Admin・その他に分類する
