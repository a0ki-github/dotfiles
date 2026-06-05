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

### 前提

- リモートへのpushはユーザーが済ませている。push操作は行わないこと。

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

### 2. テンプレートの確認

```bash
cat .github/PULL_REQUEST_TEMPLATE.md
```

### 3. PR作成

```bash
# PRを作成
gh pr create --base {base_branch} --title "タイトル" --body "$(cat <<'EOF'
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

### 4. PR説明文の更新（既存PRの場合）

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
- コミットメッセージのプレフィックス（add:, fix:, refactor:など）を維持する
- 動作確認方法はAPI・Admin・その他に分類する
