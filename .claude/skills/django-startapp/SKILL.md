---
name: django-startapp
description: Djangoの新規アプリを「apps/配下に置く」プロジェクト規約に沿って作成するスキル。startapp→apps/へ移動→apps.pyのname修正→INSTALLED_APPS追加→不要ファイル削除までを一括で行う。ユーザーが「{アプリ名}でアプリ作って」「Djangoアプリ追加して」「startappして」「新しいアプリを作りたい」のようにDjangoアプリの新規作成を求めた場合に使用する。アプリ名だけ渡されてコマンドが明示されていなくても、Djangoプロジェクト（manage.py / apps/ ディレクトリが存在）での「アプリ作成」文脈なら積極的に使うこと。
---

# django-startapp

Djangoの新規アプリを、このプロジェクトの規約に沿って作成する。素の `startapp` はアプリをプロジェクトルートに置き、`INSTALLED_APPS` への登録も手動になる。このスキルはアプリを `apps/` 配下に集約し、登録・後片付けまで一気通貫で行う。

## 入力

アプリ名を1つ受け取る（例: `blog`）。以降このドキュメントでは `{name}` と表記する。`{Name}` はパスカルケース（`blog` → `Blog`）を指す。

## 前提の確認

実行前に次を確認する。揃っていなければユーザーに知らせる。

- カレントが `manage.py` のあるプロジェクトルートであること。
- `apps/` ディレクトリが存在すること。無い場合は `mkdir apps` で作ってよい（このスキルの規約上 `apps/` への集約が前提のため、作成は「指示の実現に必要な作業」に含まれる）。
- 設定ファイルは `core/settings/base.py` を想定。もし無ければ `INSTALLED_APPS` を定義しているファイルを探して読み替える。

## 手順

### 1. アプリを生成して apps/ へ移動

```bash
python manage.py startapp {name}
mv {name} apps/
```

`startapp` はルートに `{name}/` を生成するので、`apps/` 配下へ移動する。

### 2. apps.py を修正

`apps/{name}/apps.py` を次の2点に整える。

- `name` 属性を apps配下のドットパスに書き換える。これをしないと Django がアプリを `apps.{name}` として解決できない。
- `default_auto_field = "django.db.models.BigAutoField"` を設定する。`startapp` の生成結果に無ければ追記し、別の値になっていればこの値にする。

```python
class {Name}Config(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"   # ← 無ければ追記
    name = "apps.{name}"                                   # ← "{name}" から "apps.{name}" に変更
```

クラス名（`{Name}Config`）は `startapp` の生成結果のまま触らない。

### 3. INSTALLED_APPS に登録

`core/settings/base.py` の `INSTALLED_APPS` に `"apps.{name}"` を追加する。既存の自作アプリ群と並べる位置に入れる（サードパーティ・Django組み込みと混ぜない）。

```python
INSTALLED_APPS = [
    # ...
    "apps.{name}",
]
```

### 4. 使わないファイルを削除

このプロジェクトでは `tests.py` と `views.py` を使わないため削除する。`startapp` 直後のこれらは未追跡ファイルなので `git clean` で消す。**対象を必ずパスで明示**し、他の未追跡ファイルを巻き込まないこと（`apps/{name}/` のようなディレクトリ単位指定はアプリごと消えるため使わない）。

```bash
git clean -f apps/{name}/tests.py apps/{name}/views.py
```

## 完了報告

実行後、次を簡潔に伝える。

- 生成したアプリのパス（`apps/{name}/`）
- `INSTALLED_APPS` に追加した行
- 削除したファイル（`tests.py`, `views.py`）

## 例

**入力:** `blog でアプリ作って`

**実行内容:**
```bash
python manage.py startapp blog
mv blog apps/
# apps/blog/apps.py の name を "apps.blog" に編集
# core/settings/base.py の INSTALLED_APPS に "apps.blog" を追加
git clean -f apps/blog/tests.py apps/blog/views.py
```
