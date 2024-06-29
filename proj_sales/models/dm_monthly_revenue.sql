select 
	c.fisc_yr,
	c.fisc_pd,
	o.prod_hash_key,
	p.category_nm,
	o.sales_channel,
	o.address_hash_key,
	a.city,
	a.state,
	o.b2b_flag,
	o.promo_flag,
	sum(net_sales_value) as total_revenue,
	sum(net_quantity) as total_quantity_sold,
	sum(gross_sales_value)-sum(net_sales_value) as total_return_amount,
	sum(gross_quantity)-sum(net_quantity) as total_return_quantity
from {{ref("fct_orders")}} as o
left join {{ref("dim_products")}} p on o.prod_hash_key = p.hash_key
left join {{ref("dim_addresses")}} a on o.address_hash_key = a.hash_key 
left join {{ref("dim_calendar")}} c on o.transaction_date = c.fisc_dt 
group by 
	c.fisc_yr,
	c.fisc_pd,
	o.prod_hash_key,
	p.category_nm,
	o.sales_channel,
	o.address_hash_key,
	a.city,
	a.state,
	o.b2b_flag,
	o.promo_flag