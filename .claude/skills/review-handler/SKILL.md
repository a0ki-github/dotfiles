---
name: review-handler
description: PRレビューの指摘確認・対応を行うスキル。
---

# レビュー対応スキル

PRレビューの指摘を確認・対応するスキル。

## 手順

### 1. レビューコメントの取得

```bash
# PR番号を取得
gh pr view --json number -q '.number'

# レビューコメントを取得
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments

# レビュー全体を取得（承認/変更要求含む）
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews
```

### 2. 対応が必要なコメントの特定

authorが未返信のコメントは要対応とみなす。

### 3. 指摘内容の分類

各コメントを以下に分類:

| 分類 | 対応 |
|------|------|
| バグ・エラーリスク | 修正必須 |
| セキュリティ上の問題 | 修正必須 |
| コード品質改善 | 検討の上対応 |
| スタイル・命名 | プロジェクト規約に従い判断 |
| 自動生成ファイル | 対応不要 |

### 4. 対応方針の決定

各指摘に対して:
1. 該当ファイルを読み込み、コンテキストを確認
2. 修正が必要かどうか判断
3. 必要な場合は修正を実施

### 5. テスト実行

修正後は必ずテストを実行:
```bash
docker compose exec web pytest -v apps/{app_name}/tests/
```

### 6. レビューへの返信

修正対応した場合は、どのコミットで対応したかを埋め込みリンクで返信:

```bash
# 最新コミットの情報を取得
git log -1 --format="%H %s"

# リポジトリURLを取得
gh repo view --json url -q '.url'

# コメントに返信（埋め込みリンク形式）
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  --method POST \
  -f body="修正しました [{commit_message}]({repo_url}/commit/{commit_sha})"
```

返信例: `修正しました [fix: Noneチェックを追加](https://github.com/owner/repo/commit/abc1234)`

## 注意事項

- 修正前に必ず該当コードを読んでコンテキストを理解する
- 機械的に修正せず、プロジェクトの規約・パターンを考慮する
- 修正後は必ずテストを実行して動作確認する
