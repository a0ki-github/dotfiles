---
name: appstore-first-release
description: 新しいFlutterアプリをApp Storeに初めてリリースするためのフルセットアップ（Appレコード作成〜メタデータ〜スクリーンショット〜審査提出）。「新しいアプリをリリースしたい」「初回リリースの準備をして」等の依頼で使用。アップデートの提出はappstore-releaseを使う。
---

# App Store初回リリース（Flutter iOS）

新規アプリをApp Storeに初めて出すまでの全手順。アカウントレベルの設定（Apple Developer Program加入、有料アプリ契約、銀行口座、W-8BEN、Small Business Program）は完了済みの前提（Team: 854H7T45RQ / 15hoursweek@gmail.com）。

## 事前にユーザーに確認すること

1. バンドルID（例: jp.bulltech.xxxx — com.example.*は不可）
2. App Store上のアプリ名・サブタイトル（30字以内）
3. 価格（無料か有料か）と課金プロダクトの有無・価格
4. iPhone専用にするか（TARGETED_DEVICE_FAMILY = 1。iPad対応ならiPad用スクショも必要）
5. カテゴリ

## 手順

### 1. プロジェクト設定

- `project.pbxproj`: PRODUCT_BUNDLE_IDENTIFIER を全置換（RunnerTests含む）、DEVELOPMENT_TEAM = 854H7T45RQ、必要なら TARGETED_DEVICE_FAMILY = 1
- `Info.plist`: `ITSAppUsesNonExemptEncryption` = false を追加（輸出コンプライアンス自動回答）
- `pubspec.yaml`: version を 1.0.0+1 に

### 2. Appレコード作成（ユーザー操作 or ブラウザ操作）

App Store Connect → アプリ →「＋」→ 新規App。バンドルIDは初回アップロード後に自動登録される（-allowProvisioningUpdates）ため、先にビルド&アップロード（testflight-uploadスキル）してからでもよい。SKUは英数字の任意ID。

### 3. ビルド＆アップロード

`testflight-upload` スキルに従う（署名エラー時は未署名アーカイブ方式）。

### 4. 課金プロダクト（IAPがある場合）

アプリ →「収益化」→「アプリ内購入」→ 作成:
- 種類（非消耗型など）、参照名、製品ID（**コードの定数と完全一致**・変更不可）
- 価格（基準国=日本でティア選択）、ローカリゼーション（表示名・説明）、配信可否（全地域）
- 審査用スクリーンショット（ペイウォール画面。シミュレータで撮影可）
- **最初のIAPはアプリバージョンと同時に審査提出が必要**

### 5. サポートページ＆プライバシーポリシー（必須URL）

GitHub Pagesで作成（メインリポジトリがprivateなら別の公開リポジトリを作る）:
- サポートページ: 連絡先メール、FAQ（復元方法など）
- プライバシーポリシー: データ収集なし・IAPはApple決済・第三者提供なし等
- 例: https://a0ki-github.github.io/offline-food-dictionary-support/

### 6. スクリーンショット（3〜5枚）

iPhone 14 Plusシミュレータで撮影（1284×2778px = 6.5インチ枠にそのまま使える）:
```bash
xcrun simctl create "iPhone 14 Plus (SS)" com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus
xcrun simctl boot <udid>
flutter build ios --simulator && xcrun simctl install <udid> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <udid> <bundleId>
xcrun simctl io <udid> screenshot shot.png
```
- シミュレータ操作はAppleScript `System Events click at {x,y}` が確実（cliclickは不安定）
- 日本語入力は `simctl pbcopy` でクリップボード→長押し→Paste
- 座標変換: ウィンドウ位置+ベゼルオフセット(約27.5, 82.5)+デバイスpt×0.80
- macOSの画面収録許可ダイアログが出たら許可せず、Simulatorウィンドウを移動して回避
- 撮影後はシミュレータを削除

### 7. App Store Connectメタデータ（ブラウザ操作で代行可能）

バージョンページ: スクリーンショット（隠れinput[type=file]をJSで可視化してfile_uploadツール）、概要、プロモーションテキスト、キーワード（100字）、サポートURL、著作権、バージョン表記
アプリ情報: サブタイトル、カテゴリ、**年齢制限アンケート**（7ステップ・食材辞典系は全て「なし/いいえ」で4+）、**コンテンツの配信権**（サードパーティコンテンツなし）
アプリのプライバシー: プライバシーポリシーURL、データ収集アンケート（収集なし）→ **公開ボタン**
価格および配信状況: 価格（無料=¥0）、**配信国**（EU除外なら「特定の国」で全選択→EU27カ国を外す。EU配信するならDSAトレーダー申告が必要=住所公開）
App Review情報: サインイン不要のチェック、連絡先（氏名・電話・メール）、審査員向けメモ（オフライン動作・IAPの説明など）
リリース方法: 自動/手動

### 8. 審査へ提出

1. IAPページ「審査用に追加」（IAPがある場合）
2. バージョンページ「審査用に追加」→ 提出物の下書き（既存の下書きに追加）
3. 下書きパネル「審査へ提出」→「提出されました」確認
4. 不足項目があれば赤枠で表示されるので対処して再試行

### 9. 提出後

- 審査24〜48時間、結果はメール
- コード変更（バンドルID・バージョン等）をコミット
- 承認後: Small Business Programが有効なら手数料15%

## 免責的な注意

- DSAトレーダーステータス「配信予定なし」を選んだ場合、EU27カ国には配信できない（後から変更可）
- 電話番号・住所などの個人情報入力、契約への同意はユーザー本人に確認・実行してもらう
