---
name: appstore-release
description: FlutterアプリのアップデートをApp Store審査に提出する（バージョン更新→ビルド→アップロード→ASCで新バージョン作成→審査提出）。「リリースして」「アップデートを審査に出して」「新バージョンを提出して」等の依頼で使用。
---

# App Storeアップデートリリース（Flutter iOS）

公開済みアプリのアップデートを審査提出するまでの手順。初回リリースのセットアップ（契約・IAP作成・メタデータ・スクリーンショット等）は完了済みであることが前提。

## 手順

### 1. バージョン番号を上げる

`pubspec.yaml` の `version: x.y.z+n` を更新する。
- マーケティングバージョン（x.y.z）：機能追加ならminor、修正ならpatchを上げる
- ビルド番号（+n）：**必ず前回より大きくする**（同じだとRedundant Binary Uploadで拒否）

### 2. ビルド＆アップロード

`testflight-upload` スキルの手順に従う。要点：
- `flutter build ipa --release` が「Your team has no devices」で失敗する場合は、**未署名アーカイブ→エクスポート時にクラウド配信署名**の方式を使う：
  ```bash
  flutter build ios --release --no-codesign
  cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release \
    -destination 'generic/platform=iOS' archive -archivePath ../build/ios/archive/Runner.xcarchive \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
  xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive \
    -exportOptionsPlist <destination:upload入りのplist> -allowProvisioningUpdates
  ```
- 出力はログファイルへリダイレクト（パイプ禁止）、タイムアウト長め
- アップロード後、ASCでの処理完了は数分〜30分。内部テスターに自動配信される

### 3. App Store Connectで新バージョンを作成

App Store Connect → アプリ → 配信タブ：
1. 左サイドバー「iOSアプリ」横の「**＋**」から新バージョンを作成（バージョン番号は pubspec の x.y.z と揃える）
2. 「**このバージョンの新機能**」（What's New）を記入 — 変更点をユーザー向けの言葉で
3. スクリーンショット・概要などは前バージョンから引き継がれる（UIが大きく変わった時だけ更新）

ブラウザ操作の注意（Claude in Chrome使用時）:
- ASCのファイルアップロードは input[type=file] が隠れている。JSで可視化してから `file_upload` ツールを使う
- スクリーンショット規格：6.5インチ = 1284×2778px（iPhone 14 Plusシミュレータで `xcrun simctl io <udid> screenshot` がぴったり）

### 4. ビルドを紐付けて審査へ提出

1. 新バージョンページの「ビルド」→「ビルドを追加」→ アップロードした新ビルドを選択
2. 「**審査用に追加**」→ 提出物の下書きに追加
3. 下書きパネルの「**審査へ提出**」をクリック
4. 「提出されました」表示を確認。ステータスが「審査待ち」になる

### 5. 提出後

- 審査は通常24〜48時間。結果はメールで届く
- リリース方法は「自動リリース」設定なら承認後そのまま公開される
- コード変更をコミット（バージョン番号変更を含める）

## 過去の設定値（オフライン食材辞典の場合の参考）

- バンドルID: jp.bulltech.foodDictionary / Team: 854H7T45RQ / ASC App ID: 6796736903
- 配信: 148カ国（EU27カ国除外 = DSAトレーダー申告回避のため。EU追加時はトレーダー申告が必要）
- IAP: premium_unlock（非消耗型・¥300）。IAPの変更・追加時は審査に同時提出が必要
- サポートURL: https://a0ki-github.github.io/offline-food-dictionary-support/

## トラブルシューティング

- 「審査用に追加できません」→ 不足項目が赤枠で表示される。指示に従い設定（初回は「コンテンツの配信権」が未設定だった）
- ビルドが選択肢に出ない → ASC処理中。数分〜30分待つ。輸出コンプライアンスはInfo.plistで自動回答済み
- スクリーンショット撮り直しが必要な場合 → iPhone 14 Plusシミュレータ（1284×2778）で撮影。シミュレータのUI操作はAppleScriptの `System Events click at {x,y}` が確実。日本語入力はsimctl pbcopy→長押しペーストで
