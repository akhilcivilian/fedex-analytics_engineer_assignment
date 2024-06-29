with cte as (
	select distinct
	md5(coalesce("ship-postal-code"::text,'UNKNOWN') || coalesce("ship-city"::text,'UNKNOWN')) as hash_key,
	coalesce("ship-postal-code"::text,'UNKNOWN') as postal_cd,
	upper("ship-city")::text as city,
	upper("ship-state")::text as state,
	upper("ship-country")::text as country_cd,
	case length("Date") 
		when 8 then to_date("Date",'mm-dd-yy') 
		when 10 then to_date("Date",'dd-mm-yyyy') 
		end as valid_from
	from {{ref('amazon_sales_report')}}
)
, cte_hash_key as (
	select *, row_number() over(partition by hash_key order by valid_from desc) as rid
	from cte
)
, cte_correct_names as (
    select 
        hash_key,
        postal_cd,
        case when city IN ('BANGALORE','BENAGLURU') THEN 'BENGALURU' else city end as city,
        case when "state" = 'PB' then 'PUNJAB'
        when "state" = 'PONDICHERRY' then 'PUDUCHERRY'
        when "state" IN ('RAJSHTHAN','RAJSTHAN','RJ') then 'RAJASTHAN'
        else "state" end as "state",
        country_cd,
        valid_from
    from cte_hash_key 
    where rid=1
)
select * from cte_correct_names