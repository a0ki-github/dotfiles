---
name: review-pr
description: レビュアーとしてGitHub PRを深掘り調査し、指摘・疑問をPendingレビューコメントとして残すスキル。ユーザーが「PR#NNNのレビュアーとして相談」「PR#NNNをレビューして」「レビュアーに指定された」と言った場合、レビュー中のPRについて質問・調査依頼をした場合、「Pendingコメントして」「指摘をコメントに残して」と言った場合に必ず使用する。PR番号やPR URLに言及してレビュー観点の相談をしている場合も、明示的に「レビュー」と言われなくても使用する。
---

# review-pr: レビュアーとしてのPR深掘りとPendingコメント

レビュアーに指定されたPRについて、ユーザーと対話しながら調査し、指示された指摘だけをPendingレビューコメントとして投稿するワークフロー。

## 基本フロー

このスキルは通常、PR番号を引数として起動される（例: 「PR#951のレビュアーとして相談」）。フローは**ユーザー主導**で進む:

1. **PR把握**: Step 1を実行してPRを把握し、概要を報告する。**ここで止まる**。頼まれていない指摘の洗い出しや深掘りはしない
2. **質問対応**: ユーザーが随時質問してくる。質問された内容だけをStep 2の技法で調査し、ソース付きで回答する（Step 3）。聞かれていない補足は不要（追加で知りたければユーザーが聞いてくる）
3. **投稿**: ユーザーが「コメントして」と指摘を指定したら、それをPendingコメントとして投稿する（Step 4）
4. **提出はユーザー**: Pendingレビューの最終提出（submit）はユーザーがGitHub UIで手動で行う。**こちらからは絶対にsubmitしない**。Approve / Request Changes の判断もユーザーのもの

例外: 「PR全体をレビューして」「指摘を洗い出して」と明示的に任された場合のみ、概要把握→深掘り→指摘候補の重要度付き報告まで自律的に行う（それでも投稿は指示待ち）。

## Step 1: PR概要の把握

起動されたらまず以下を実行し、以降の調査の土台を作る:

```bash
gh pr view <N> --json title,body,author,baseRefName,headRefName,state,additions,deletions,changedFiles,url
gh pr diff <N> --name-only
# 既存レビュー・コメントの確認（他レビュアーやbotとの指摘重複を避けるため）
gh pr view <N> --json reviews,comments
# diff全体をscratchpadに保存しておくと以降のawk/grepが速い
gh pr diff <N> > <scratchpad>/pr<N>.diff
```

概要をユーザーに1度だけ要約して伝える（作者、base、規模、目的、既存レビュー状況）。報告したらユーザーの質問を待つ。「相談内容をどうぞ」のような促しは1行で十分。

## Step 2: 深掘り調査の技法

調査は「PR説明の主張を鵜呑みにせず、実測で検証する」が原則。よく使う技法:

### PRブランチの実体をgrepする

ローカルのcheckoutはbase側であることが多く、**変更後のコードの残存参照はローカルgrepでは検証できない**。必ずPRブランチをfetchして調べる:

```bash
git fetch origin <headRefName> --quiet   # FETCH_HEADに入る
git grep -n "<pattern>" FETCH_HEAD -- 'apps/...'
git show FETCH_HEAD:path/to/file.py
```

**ユーザーの作業ツリーは変更しない**。PRブランチのcheckoutやローカルマージは、ユーザーが編集中のファイルを巻き込む恐れがあるためレビュー調査では行わない。FETCH_HEAD（またはorigin/<branch>）への参照だけで調査は完結できる。マージ後の状態検証（migration衝突等）が必要な場合は、両ブランチのファイル一覧・依存関係を突き合わせて静的に判定するか、git worktreeでの分離を検討する。

### 同名シンボルの誤検知を排除する

削除されたフィールド・メソッドと同名のものが別クラスに存在することは多い。grepのヒットだけで「残存参照あり」と判断せず、**どのクラス/モデルへの参照かを特定してから**判断する:

```bash
# 行→所属クラスの対応を取る
awk '/^class /{cls=$2} /<pattern>/{print NR": ["cls"] "$0}' file.py
```

### CI・型チェックで検出されない領域を重点的に見る

テストが通っていても安全とは言えない領域こそレビュアーの価値が出る:

- **テンプレート**（Djangoテンプレート等）: 存在しない属性は黙って空表示になり、エラーもテスト失敗も起きない
- 文字列参照（`.values("field")`、`select_related("field")`、設定ファイル内の名前）
- fixture / seed データ、管理コマンド、ドキュメント

### base側との比較で影響を判定する

削除・変更されるものについて、base側で「誰が書き込んでいたか / 誰が読んでいたか」をgrepし、データ消失や挙動変化のリスクを判定する:

```bash
git grep -n "<pattern>" origin/<baseRefName> -- 'path/'
```

削除対象に現行コードが書き込んでいた場合、PR説明の「影響なし」が不正確な可能性がある。代替フィールドの有無（重複カラムか、情報が失われるか）まで確認する。

### DBマイグレーションの安全性

- 依存チェーンが直列か、番号がbase側と衝突しないか（`git ls-tree` で両ブランチのmigrationファイル一覧を比較）
- カラム・テーブル削除はデータ的に不可逆。書き込み元の有無とバックアップの必要性を確認
- ローリングデプロイ時の旧コード×新スキーマの混在ウィンドウ

## Step 3: 報告

- **結果には必ずソースを付ける**（`file:line`、実行したコマンドと実測結果）。確認できなかったことは「未確認」と明示する
- 指摘には重要度タグを付ける: 【要修正】【要確認】【運用確認】など
- 「問題なし」と確認できた項目も根拠付きで報告する（何を確認済みかが分かることで、ユーザーが残りの確認範囲を判断できる）
- お世辞や過剰な補足は不要。指摘は遠慮なく

## Step 4: Pendingコメントの投稿（指示された場合のみ）

ユーザーが投稿対象として承認した指摘だけを投稿する。勝手に指摘を追加しない。

### 事前確認

```bash
# 既存のPENDINGレビューがあると新規POSTが失敗する
gh api repos/<owner>/<repo>/pulls/<N>/reviews --jq '.[] | select(.state=="PENDING") | {id, user: .user.login}'
```

既存PENDINGレビューがある場合は**そこで必ず停止し、状況（レビューID・コメント件数）を報告して指示を仰ぐ**。GraphQL `addPullRequestReviewThread` による既存PENDINGへの追記は技術的には可能だが、既存PENDINGはユーザーが編集中の未提出レビューであり、勝手に追記するとその内容を汚染する。追記はユーザーが明示的に「追記して」と指示した場合のみ行う。

### アンカー行の確定

インラインコメントは**diffに含まれるファイル・行にしか置けない**。diff外のファイルへの指摘（例: 変更されていないテンプレートの残存参照）は、その原因となったdiff内の行（例: フィールドを削除しているmigrationの行）にアンカーする。

行番号は推測せず実測で確定する:

```bash
git show FETCH_HEAD:path/to/file.py | cat -n
```

### 投稿

`event` を指定せずPOSTするとPENDING状態のレビューになる。JSONはファイルに書いて `--input` で渡す:

```bash
cat > <scratchpad>/review.json <<'EOF'
{
  "commit_id": "<head SHA (git rev-parse FETCH_HEAD)>",
  "comments": [
    {"path": "...", "line": <行番号>, "side": "RIGHT", "body": "【要修正】..."}
  ]
}
EOF
gh api repos/<owner>/<repo>/pulls/<N>/reviews --method POST \
  --input <scratchpad>/review.json --jq '{id, state}'
```

コメント本文は日本語で、「何が起きるか（根拠）」と「どうすべきか（提案）」をセットで書く。会話中で使った略称や番号（指摘1〜3等）は本文に持ち込まず、それ単体で読めるようにする。

### 投稿後の報告

- レビューID・stateを報告する
- **PENDINGレビューは本人にしか見えない**こと、GitHub UIの「Files changed → Review changes」で確認・編集してSubmitするのはユーザーであることを伝える
