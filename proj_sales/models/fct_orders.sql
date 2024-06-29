with cte_distinct_rows as (
	select distinct "Order ID", "Date", "Status", "Fulfilment", "Sales Channel ", "ship-service-level", "Style", "SKU", "Category", "Size", "ASIN", "Courier Status", "Qty", "currency", "Amount", "ship-city", "ship-state", "ship-postal-code", "ship-country", "promotion-ids", "B2B", "fulfilled-by" 
	from {{ref('amazon_sales_report')}}
)
, cte_dedup_1 as (
	select *, row_number() over(partition by "Order ID", "SKU", "ASIN" order by "Qty" desc) as row_id
	from cte_distinct_rows 
)
, cte_dedup_2 as (
	select *
	from cte_dedup_1 
	where row_id=1
)
, cte_orders as (
select 
	"Order ID"::text as order_id,
	row_number() over(partition by "Order ID" order by "SKU") as order_line_nbr,
	case length("Date") 
		when 8 then to_date("Date",'mm-dd-yy') 
		when 10 then to_date("Date",'dd-mm-yyyy') 
		end as transaction_date,
	md5("Order ID" || "SKU" || "ASIN") as hash_key,
	md5(coalesce("SKU"::text,'UNKNOWN') || coalesce("ASIN"::text,'UNKNOWN')) as prod_hash_key,
	md5(coalesce("ship-postal-code"::text,'UNKNOWN') || coalesce("ship-city"::text,'UNKNOWN')) as address_hash_key,
	case position('-' in "Status") 
		when 0 then trim("Status") 
		else trim(substring("Status",1,position('-' in "Status")-1)) 
		end as order_status,
	case position('-' in "Status")
		when 0 then null
		else trim(substring("Status",position('-' in "Status")+1,length("Status")))
		end as order_status_remarks,
	"Courier Status"::text as shipment_status,
	"Sales Channel "::text as sales_channel,
	"Fulfilment"::text as fulfillment_group_nm,
	coalesce("fulfilled-by","Fulfilment")::text as fulfillment_entity_nm,
	"ship-service-level"::text as shipment_service_level,
	coalesce("Qty",0)::float as gross_quantity,
	coalesce("Amount",0)::decimal(20,2) as gross_sales_value,
	coalesce("currency",'UNKNOWN')::text as currency_cd,
	"promotion-ids"::text as concatenated_promo_id,
	"B2B"::bool as b2b_flag,
	case 
		when "promotion-ids" is null then false 
		else true 
		end as promo_flag
from cte_dedup_2
)
, cte_return_orders as (
	select *, 
		case 
			when order_status_remarks in ('Lost in Transit','Returning to Seller','Rejected by Buyer','Returned to Seller','Damaged') then true
			else false
			end as return_flag
	from cte_orders
)
select *, 
	case 
		when return_flag = true then 0
		else gross_quantity
		end as net_quantity,	
	case 
		when return_flag = true then 0
		else gross_sales_value
		end as net_sales_value
from cte_return_orders