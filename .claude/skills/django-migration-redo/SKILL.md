---
name: migration-redo
description: 最新のマイグレーションをロールバック→削除→再生成→適用するスキル。ユーザーが「マイグレーションやり直して」「マイグレーション作り直して」「migration redo」のような指示をした場合に使用してください。
---

# マイグレーションやり直しスキル

ローカル環境で最新のマイグレーションをロールバックし、削除・再生成・適用を行う。モデルの軽微な修正で新しいマイグレーションファイルを増やしたくない場合に使う。

## 引数

アプリ名を引数として受け取る。

- 使用例: `/migration-redo old_system_account`
- `$ARGUMENTS` にアプリ名が渡される

引数が空の場合はユーザーにアプリ名を確認してから進める。

## 前提条件

- 対象のマイグレーションがローカル環境のみに適用されていること
- 他の環境（staging, production等）に反映済みのマイグレーションには絶対に使わないこと

## 作業手順

### 1. 最新のマイグレーションファイルを特定

`apps/{app_name}/migrations/` 内のファイルを確認し、最新のマイグレーションファイル（番号が最も大きいもの）を特定する。`__init__.py` は除外する。

### 2. ロールバック

最新の1つ前のマイグレーション番号を特定し、そこまでロールバックする。

- 1つ前のマイグレーションがある場合:
  ```bash
  docker compose exec web python manage.py migrate {app_name} {一つ前の番号}
  ```
- 最新が `0001_initial.py` の場合（1つ前がない）:
  ```bash
  docker compose exec web python manage.py migrate {app_name} zero
  ```

### 3. マイグレーションファイルを削除

手順1で特定した最新のマイグレーションファイルを削除する。

### 4. makemigrations 実行

```bash
docker compose exec web python manage.py makemigrations {app_name}
```

### 5. migrate 実行

```bash
docker compose exec web python manage.py migrate {app_name}
```

## ユーザーへの報告

完了後、以下を報告する:
- ロールバックしたマイグレーション名
- 新しく生成されたマイグレーション名
