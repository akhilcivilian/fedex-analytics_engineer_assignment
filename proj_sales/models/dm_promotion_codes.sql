select 
    order_id,
    transaction_date,
    prod_hash_key,
    address_hash_key,
    fulfillment_entity_nm,
    sales_channel,
    b2b_flag,
    unnest(regexp_split_to_array(concatenated_promo_id,',')) as promo_code
from {{ref("fct_orders")}}
where promo_flag = true