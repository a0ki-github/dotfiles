# Flutterアプリ共通規約（portfolio/flutter配下）

個人開発のFlutterアプリ（日本向け）に共通で適用するコーディング規約。
アプリ固有の設計方針（課金モデル・オフライン方針など）は各プロジェクトのCLAUDE.mdに書く。

## プロジェクト構成

- `lib/` 直下にフラットに置く（小規模アプリ前提。階層化は必要になってから）
- ファイル名は snake_case。役割をサフィックスで表す:
  - 画面: `xxx_screen.dart`（例: `search_screen.dart`）
  - 部品: `xxx_tile.dart` / `xxx_sheet.dart` など Widget種別のサフィックス
  - サービス: `xxx_service.dart`（例: `premium_service.dart`）
  - データ定義: `xxx_data.dart`、モデル: 単数形（例: `food_item.dart`）
- import順: Flutter/外部パッケージ → 空行 → 相対import

## 命名・コード

- 公開定数は `k` プレフィックス（例: `kPremiumProductId`）
- enumの分岐は switch式を使う
- Widgetはできる限り `const` コンストラクタ + `StatelessWidget`。状態が必要な時だけStateful
- lintは `flutter_lints` に従う（`flutter analyze` をクリーンに保つ）

## コメント

- 日本語で書く
- 「何をしているか」ではなく「なぜそうするか・制約」を書く
- 公開クラス・定数には `///` ドキュメントコメントを付ける

## 状態管理

- 外部の状態管理パッケージは使わない
- サービスは `ChangeNotifier` + シングルトン（`static final instance`）パターン
- UIからは `ListenableBuilder(listenable: XxxService.instance, ...)` で購読

## ビルド・ネイティブアセット

- アイコン・スプラッシュ等のネイティブアセットを変更したら、再ビルド前に必ず `flutter clean && flutter pub get` を実行する（キャッシュで古いアセットが残る事故が過去に複数回発生）
- ネイティブ層の挙動（キャッシュ・ビルドモード差）に関わる作業は、試行錯誤の前にまず仕組みを説明してから最小手順で変更する
- デバッグ用の `Future.delayed` 等の意図的な遅延をコミットに残さない（スプラッシュに3秒の遅延が本番ビルドに混入した事故あり）

## ゲート付き状態のテスト容易性

- 課金・エンタイトルメント等のゲート付き状態には、`kDebugMode` 限定のデバッグトグルを最初から実装する（実購入なしでUIを確認できるようにする。例: `debugSetPremium`）

## UIテキスト・ローカライズ

- 日本向けアプリのため、UIテキストは日本語を直書きしてよい（i18n基盤は入れない）
- ただし `Info.plist` に `CFBundleLocalizations` = `ja` を必ず宣言する
  （App Storeの言語表記が「EN」になるのを防ぐ。食材辞典1.0.0での教訓）

## セキュリティ

前提: サーバーレス・アカウントレス構成のため、サーバー側の脆弱性（IDOR・認証・インジェクション等）は対象外。
クライアントアプリとして守るのは以下。

- **シークレットをコード・リポジトリに置かない**: Dartのバイナリからは文字列を抽出できるため、APIキー・秘密鍵の埋め込みは漏洩と同義。特にAndroid署名鍵（`key.properties` / `*.jks`）の漏洩はアプリ乗っ取りに直結するので、gitignore必須＋`~/keystores/` で管理
- **shared_preferences は平文**（root化/脱獄端末では読み書き可能）。プレミアムフラグ程度は許容するが（買い切り数百円のアプリで検証サーバーを立てるのは割に合わない）、トークン等の本当の秘密情報は `flutter_secure_storage`（Keychain/Keystore）を使う
- **依存パッケージを最小限に保つ**（サプライチェーンリスク）。追加する時はverified publisher（`flutter.dev` / `dart.dev` 等）か利用実績の多いものに限る
- **デバッグ用コードは `kDebugMode` でガードする**（リリースビルドではコンパイル時に除去される。`if (kDebugMode)` 以外の自前フラグで代用しない）
- 将来ネットワーク機能を追加する場合:
  - HTTPS必須（iOS ATS / Androidのデフォルトの平文拒否を無効化しない）
  - 開発中の証明書エラーを `badCertificateCallback` で握りつぶすコードを本番に残さない
  - WebView・`url_launcher` に渡すURLを外部入力から組み立てない。WebViewのJavaScriptは必要な時だけ有効化

## リリース設定（新規プロジェクト作成時にやること）

- バンドルID / applicationId: `jp.bulltech.<appName>`（iOSはcamelCase、Androidはsnake_case）
  - `com.example.*` のまま初回ビルドに進まない
- `Info.plist` に `ITSAppUsesNonExemptEncryption` = `false`（輸出コンプライアンス自動回答）
- 対応デバイス（iPhone専用にするか）はアプリごとに判断し、iPhone専用なら `TARGETED_DEVICE_FAMILY = 1`
- Android署名: `key.properties` + `~/keystores/` の鍵を使う（gitignore必須）
- バージョンは `x.y.z+n`。ストア提出のたびに `n` を必ずインクリメント
- リリース手順はスキルを使う: `/testflight-upload`（配布）、`/appstore-first-release`（新規）、`/appstore-release`（更新）
- ストア提出の作業を始める前に、前提条件の監査を先に行う（アカウント登録・本人確認・契約・署名・実機要件など）。
  特に「ユーザー本人にしかできない・完了まで日数がかかる」外部ブロッカーを最初に洗い出して先行着手してもらう
  （例: Apple Developer加入、Google Playの本人確認・Android実機確認は数日かかる）

## Git

- コミットメッセージは `add:` / `fix:` / `release:` などのプレフィックス + 日本語
- コミット・プッシュはユーザーの指示があってから行う
- コミット・PR作成の前に `git status` と差分を確認し、**今のタスクに関係するファイルだけ**が含まれることを確認する
  （無関係な画像・アセットがPRに混入した事故あり）。コミットは小さくスコープを絞る
