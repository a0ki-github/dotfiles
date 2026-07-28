---
name: django-api-count
description: DjangoプロジェクトのAPI数（DRF API / カスタムAdmin API別、HTTPメソッド別）を稼働中アプリのURLリゾルバから実測して算出するスキル。脆弱性診断のスコープ算出などに使う。ユーザーが「API数を算出して」「エンドポイント数を数えて」「脆弱性診断用のAPI一覧が欲しい」「APIの規模を教えて」のように言った場合に必ず使用する。grep等の静的カウントで代用しないこと。
---

# Django API数算出

稼働中DjangoのURLリゾルバから全エンドポイントを実測し、「DRF API」と「カスタムAdmin API」に分けてメソッド別のAPI数を算出する。

## カウント基準（脆弱性診断スコープの考え方）

- **URLが同じでもHTTPメソッドが違えば別カウント**（GET: api/A と POST: api/A は2）。HEAD/OPTIONSは数えない
- 診断対象の基準は「URLの由来」ではなく **「自作コードが実行される面か」**
    - **DRF API**: `/api/` 配下の全エンドポイント。ただし監視用・内部トリガー用などエンドユーザー向けでないもの（例: health-check、Push通知トリガー）は別掲する
    - **カスタムAdmin API**: `/admin/` 配下のうち、ビュー定義元モジュールが自作アプリ（`apps.*` 等）のもの。**Django Admin標準URLの実装オーバーライド（change_view / delete_view / login差し替え等）も含める**。オーバーライドにも独自ロジックが入り脆弱性が生まれ得るため
    - **カウント外**: ライブラリ実装のまま自動生成されるURL（Django Admin本体・django-import-export・nested_admin）、local環境限定URL（schema/ docs/ 等）。件数のみ報告する

## 手順

### 1. 実測スクリプトの実行

コンテナが起動していることを確認し（起動方法はプロジェクトの規約に従う。invase-app-backendではメインツリー `./mac up`、worktree `./mac-wt up`）、以下を実行する:

```bash
docker compose exec -T web python manage.py shell < ~/.claude/skills/django-api-count/scripts/count_apis.py
```

- `web` はDjangoが動くサービス名。プロジェクトに応じて読み替える
- スクリプト冒頭の定数（`APP_MODULE_PREFIX`、`NON_ENDUSER_API`）はプロジェクトに応じて調整する。デフォルトはinvase-app-backend向け

出力は3セクション:
1. **DRF API一覧と集計** — メソッドはクラスの `http_method_names` と実装済みハンドラから機械判定済み。この数字をそのまま使える
2. **カスタムAdminビュー一覧**（URL・ソース位置付き） — 関数ビューはメソッド機械判定不可のため次の手順で目視判定する
3. **カウント外の件数**

### 2. カスタムAdminビューのメソッド目視判定

セクション2の各ビューについて、ソース位置（file:line）を開いてメソッド数を判定する。まず対象ファイル群を `grep -n "require_POST\|require_GET\|require_http_methods\|request.method"` すると効率的。

| 実装パターン | 判定 |
|---|---|
| `@require_POST` デコレータ | POSTのみ = 1 |
| `if request.method != "POST":` でエラー/リダイレクト | POSTのみ = 1 |
| `if request.method == "POST":` で処理、else側でGET画面（フォーム等）を表示 | GET+POST = 2 |
| `if request.method == "POST":` で処理、else側は無処理でリダイレクトのみ | POSTのみ = 1（GETは機能を持たないため） |
| メソッド分岐なし（ダウンロード・プレビュー・JSON返却系） | GETのみ = 1 |
| Django Admin標準のchange/delete画面のオーバーライド | GET+POST = 2（標準実装が表示+送信の両対応） |
| `['get']` 等が機械判定済みで表示されているもの | その値を使う |

`== "POST"` 分岐はelse側の挙動（画面表示かリダイレクトか）で1か2が分かれるため、必ずelse側まで読むこと。

### 3. 報告

以下のフォーマットで報告する:

```markdown
| 区分 | API数（メソッド別） | URL数 |
|---|---|---|
| DRF API（/api/ 配下） | N | n |
| カスタムAdmin API | M | m |
| **合計** | **N+M** | **n+m** |
```

あわせて必ず記載するもの:
- 各区分の定義とカウント外の範囲（上記「カウント基準」を要約）
- カスタムAdminのアプリ別内訳（URL数・メソッド数・備考）
- 別掲分（health-check等）の扱い
- 算出方法の要約（URLリゾルバ実測 + 目視判定、静的解析ではないこと）
- 注意点: URL単位のカウントに載らない自作コード（標準Admin URL上のカスタムactions・import/export設定・`get_queryset` 等のフックのオーバーライド）があるため、診断スコープは「ライブラリ自動生成URLは対象外、ただし自作コードを含むAdmin画面は対象」のような表現を推奨する

## 過去の算出結果（invase-app-backendの基準値）

2026-07-22時点: DRF API 103メソッド（95 URL、別掲2メソッド除く）、カスタムAdmin 77メソッド（63 URL）。大きく乖離した場合はURL構成の変化かカウント基準のブレを疑うこと。
