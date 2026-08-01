---
name: testflight-upload
description: FlutterアプリのiOSビルドをTestFlight（App Store Connect）へコマンドラインでアップロードする。「TestFlightにアップロードして」「新しいビルドを上げて」等の依頼で使用。
---

# TestFlightアップロード（Flutter iOS）

FlutterプロジェクトのiOSビルドを署名付きでビルドし、App Store Connectへ直接アップロードする手順。
Xcode GUIやTransporterは不要。認証はXcodeのAccountsにサインイン済みのApple IDセッションを利用する（パスワード・APIキー不要）。

## 前提条件（初回のみ確認）

1. Apple Developer Program（有料）に加入済みであること。無料のPersonal TeamではApp Store用プロファイルを作成できない。
2. Xcode → Settings → Accounts に該当Apple IDでサインイン済みであること。
3. バンドルIDが `com.example.*` のままなら変更が必要（`ios/Runner.xcodeproj/project.pbxproj` の `PRODUCT_BUNDLE_IDENTIFIER` を全置換。RunnerTests側も含め複数箇所ある）。
4. App Store Connectに該当バンドルIDのAppレコードが作成済みであること（未作成ならユーザーに作成を依頼）。
5. `ios/Runner/Info.plist` に `ITSAppUsesNonExemptEncryption` = `false` があると、アップロード後の輸出コンプライアンス質問をスキップできる（標準的なHTTPS暗号化のみ使用の場合）。

## 手順

### 1. ビルド番号をインクリメント

`pubspec.yaml` の `version: x.y.z+n` を確認し、`n` を前回アップロードより大きくする（例: `0.1.0+1` → `0.1.0+2`）。
同じバージョン＋ビルド番号を再アップロードすると「Redundant Binary Upload」(code 90189) で拒否される。

### 2. アップロード用ExportOptionsを用意

スクラッチパッドに `ExportOptionsUpload.plist` を作成する（teamIDはプロジェクトの `project.pbxproj` 内 `DEVELOPMENT_TEAM` の値を使う）:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>destination</key>
	<string>upload</string>
	<key>teamID</key>
	<string>TEAM_ID_HERE</string>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
```

`destination: upload` がポイント。これで `-exportArchive` がIPAをローカルに書き出す代わりにApp Store Connectへ直接アップロードする。

### 3. アーカイブを作成

プロジェクトルートで:

```bash
flutter build ipa --release
```

成果物: `build/ios/archive/Runner.xcarchive`
（ローカルエクスポート用に `ios/ExportOptions.plist` がある場合、IPAも作られるが以降は使わない）

### 4. アップロード実行

```bash
xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist <ExportOptionsUpload.plistのパス> \
  -allowProvisioningUpdates \
  > <スクラッチパッド>/upload.log 2>&1
```

**重要な注意点:**
- 出力は必ずログファイルにリダイレクトする。`| grep | head` などのパイプを挟むと、headがパイプを閉じた時のSIGPIPEでアップロードが途中終了する恐れがある（実際に発生した事故あり）。
- アップロードは数分かかる。Bashのtimeoutを長め（600000ms）に設定するか、`run_in_background: true` で実行する。
- `-allowProvisioningUpdates` により、バンドルID登録・Distribution証明書・プロファイルが自動作成される。

### 5. 結果確認

ログファイルで判定:
- `EXPORT SUCCEEDED` または `Upload succeeded` → 成功
- `Redundant Binary Upload` (code 90189) → 同じビルド番号が既にアップロード済み（＝以前のアップロードは成功している）。ビルド番号を上げて手順1からやり直し
- `No signing certificate` / `does not have permission` → Xcodeのアカウントセッション切れ、またはDeveloper Program未加入。ユーザーにXcodeでのサインイン状態を確認してもらう

### 6. アップロード後の案内

成功したらユーザーに伝える:
1. App Store Connect側の処理完了メールを待つ（5〜30分）
2. App Store Connect → TestFlightタブでビルドが「テスト可能」になればテスター配信できる
3. 初回のみ: 内部テストグループ作成＋テスター追加、iPhoneのTestFlightアプリから招待を受けてインストール

## トラブルシューティング

- キーチェーンのスキャン（`security dump-keychain` 等）は行わない。署名エラーの調査はログとXcode画面のユーザー確認で行う。
- Developer Program加入直後は反映に時間がかかる。「Welcome to the Apple Developer Program」メールの到着が有効化の目印。
- Xcodeのチームキャッシュ確認: `defaults read com.apple.dt.Xcode IDEProvisioningTeams`
