# Django API数算出スクリプト
# 実行方法: docker compose exec -T {webサービス名} python manage.py shell < ~/.claude/skills/django-api-count/scripts/count_apis.py
# 稼働中DjangoのURLリゾルバから全エンドポイントを実測し、以下を出力する
#   1. DRF API（/api/ 配下）のURL・メソッド一覧と集計
#   2. カスタムAdminビュー（自作アプリ定義）のURL・ソース位置一覧（メソッドは目視判定用）
#   3. カウント外（ライブラリ自動生成・その他）の件数
import inspect

from django.urls import get_resolver
from django.urls.resolvers import URLResolver

HTTP_METHODS = ("get", "post", "put", "patch", "delete")
# 自作アプリのモジュールプレフィックス（プロジェクト構成に応じて調整）
APP_MODULE_PREFIX = "apps."
# エンドユーザー向けではない /api/ 配下のエンドポイント（別掲する。プロジェクトに応じて調整）
NON_ENDUSER_API = ("api/health-check/", "api/notification/push")


def collect(resolver, prefix=""):
    for p in resolver.url_patterns:
        if isinstance(p, URLResolver):
            yield from collect(p, prefix + str(p.pattern))
        else:
            yield prefix + str(p.pattern), p.callback


def methods_for(cb):
    """クラスベースビューの許可メソッドを返す（HEAD/OPTIONS除外）。関数ビューはNone"""
    cls = getattr(cb, "view_class", None) or getattr(cb, "cls", None)
    if cls is not None:
        return [
            m
            for m in HTTP_METHODS
            if m in getattr(cls, "http_method_names", HTTP_METHODS) and hasattr(cls, m)
        ]
    actions = getattr(cb, "actions", None)
    if actions:
        return [m for m in actions if m in HTTP_METHODS]
    return None


def source_of(cb):
    try:
        f = inspect.unwrap(cb)
        return f"{inspect.getsourcefile(f)}:{inspect.getsourcelines(f)[1]}"
    except Exception:
        return "?"


rows = list(collect(get_resolver()))

# 1. DRF API
print("==== 1. DRF API (/api/) ====")
drf_url_count = 0
drf_method_count = 0
undetectable = []
for url, cb in sorted(rows, key=lambda r: r[0]):
    if not url.startswith("api/"):
        continue
    ms = methods_for(cb)
    if ms is None:
        undetectable.append((url, source_of(cb)))
        continue
    mark = "  <- エンドユーザー向け外（別掲）" if url in NON_ENDUSER_API else ""
    print(f"{url}\t{ms}{mark}")
    drf_url_count += 1
    drf_method_count += len(ms)
excluded_methods = sum(
    len(methods_for(cb) or [])
    for url, cb in rows
    if url in NON_ENDUSER_API
)
print(f"[集計] URL: {drf_url_count} / メソッド: {drf_method_count}")
print(f"[集計] うち別掲分（{', '.join(NON_ENDUSER_API)}）: {excluded_methods} メソッド")
print(f"[集計] エンドユーザー向けDRF API: {drf_method_count - excluded_methods} メソッド")
if undetectable:
    print("[警告] メソッド機械判定不可のDRFビュー（目視判定が必要）:")
    for url, src in undetectable:
        print(f"  {url}\t{src}")

# 2. カスタムAdminビュー
print()
print("==== 2. カスタムAdminビュー (admin/ 配下で自作アプリ定義) ====")
print("以下は関数ビューが多くメソッドの機械判定ができないため、ソースを目視判定すること")
custom_admin_count = 0
lib_admin_count = 0
for url, cb in sorted(rows, key=lambda r: r[0]):
    if not (url.startswith("admin/") or url.startswith("_nested_admin/")):
        continue
    if not cb.__module__.startswith(APP_MODULE_PREFIX):
        lib_admin_count += 1
        continue
    custom_admin_count += 1
    ms = methods_for(cb)
    name = getattr(cb, "__name__", cb.__class__.__name__)
    print(f"{url}\t{ms if ms is not None else '要目視判定'}\t{cb.__module__}.{name}\t{source_of(cb)}")
print(f"[集計] カスタムAdmin URL: {custom_admin_count}")

# 3. カウント外
print()
print("==== 3. カウント外 ====")
print(f"ライブラリ自動生成のAdmin URL（Django Admin / import_export / nested_admin等）: {lib_admin_count}")
for url, cb in sorted(rows, key=lambda r: r[0]):
    if not url.startswith(("api/", "admin/", "_nested_admin/")):
        print(f"その他URL（local限定等）: {url}\t{cb.__module__}")
