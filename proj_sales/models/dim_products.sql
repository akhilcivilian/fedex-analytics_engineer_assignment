select distinct
md5(coalesce("SKU"::text,'UNKNOWN') || coalesce("ASIN"::text,'UNKNOWN')) as hash_key,
coalesce("SKU"::text,'UNKNOWN') as prod_id,
upper("Style")::text as style_nm,
upper("Category")::text as category_nm,
upper("Size")::text as size_cd,
coalesce("ASIN"::text,'UNKNOWN') as asin_id
from {{ref('amazon_sales_report')}}