---
name: release-diff
description: 最後に本番リリースしたコミットと最新のデフォルトブランチの差分（GitHub比較URL）を確認するスキル。ユーザーが「本番リリースとの差分を確認して」「前回リリースからの差分が欲しい」「release diff」「未リリースの変更を確認して」のような指示をした場合に使用してください。
---

# 本番リリース差分確認スキル

GitHub Actionsで本番リリースしているリポジトリで、最後に成功した本番デプロイのコミットと最新のデフォルトブランチとの差分をGitHubの比較URLとして提示する。

## 引数

本番デプロイ用ワークフローのファイル名を任意の引数として受け取る。

- 使用例: `/release-diff deploy-to-prod.yml`
- `$ARGUMENTS` にワークフローファイル名が渡される

引数が空の場合は後述の手順でワークフローを自動検出する。

## 作業手順

### 1. リポジトリとデフォルトブランチを特定

```bash
gh repo view --json nameWithOwner,defaultBranchRef --jq '{repo: .nameWithOwner, branch: .defaultBranchRef.name}'
```

### 2. 本番デプロイ用ワークフローを特定

引数でワークフローファイル名が指定されていればそれを使う。

指定がない場合は `.github/workflows/` 内のファイル一覧から、名前に `prod` / `production` / `release` を含むものを探す。

- 候補が1つならそれを使う
- 候補が複数、または見つからない場合は、各ワークフローの `name` と `on` を確認したうえでユーザーに確認する

### 3. 最後に成功した本番デプロイのコミットを取得

```bash
gh run list --workflow={ワークフローファイル名} --status=success --limit 1 --json headSha,createdAt --jq '.[0]'
```

成功した実行が1件もない場合はその旨を報告して終了する。

### 4. リモートのデフォルトブランチの最新コミットを取得

```bash
git ls-remote origin {デフォルトブランチ}
```

ローカルではなくリモートの最新コミットと比較すること。

### 5. 差分の確認

手順3と手順4のコミットSHAを比較する。

- 同一の場合: 差分なし（本番は最新）と報告する
- 異なる場合: 差分に含まれるコミットの概要を確認する
  ```bash
  git fetch origin {デフォルトブランチ}
  git log --oneline {デプロイ済みSHA}..origin/{デフォルトブランチ}
  ```

### 6. 差分をPR単位に整理

差分がある場合、コミット一覧からPR番号を抽出し、PR単位の概要を作る。

- マージコミット形式: `Merge pull request #NNN from {ブランチ名}`
- squashマージ形式: コミットサブジェクト末尾の `(#NNN)`

抽出したPR番号ごとにタイトルを取得する:

```bash
gh pr view {PR番号} --json number,title --jq '"#\(.number) \(.title)"'
```

どのPRにも紐づかないコミット（デフォルトブランチへの直接pushなど）があれば、PRに含まれない差分として扱う。

## ユーザーへの報告

以下を報告する:

- 最後の本番リリースの日時とコミットSHA
  - 日時はJSTに変換して報告する（`gh run list` の `createdAt` はUTC）。例: `2026-07-30T04:35:19Z` → `2026-07-30 13:35 JST`
- 差分の有無
- GitHubの比較URL: `https://github.com/{owner}/{repo}/compare/{デプロイ済みSHA}...{デフォルトブランチ}`
- 差分がある場合:
  - PR単位の概要（PR件数と、各PRの番号・タイトル・変更内容の1行要約）
  - PRに紐づかない直接pushコミットがあればその旨
  - 含まれるコミットの件数と一覧（`git log --oneline` の結果）
