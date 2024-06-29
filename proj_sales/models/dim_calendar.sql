with recursive cte as (
select to_date('2021-01-01','yyyy-mm-dd') as fisc_dt
union
select (fisc_dt + interval '1 day')::date from cte where extract(year from fisc_dt)<=2030
)
select fisc_dt::date as fisc_dt, extract(year from fisc_dt)::int as fisc_yr, extract(month from fisc_dt)::int as fisc_pd, to_char(fisc_dt,'Month')::text as fisc_pd_nm, 'Q'||extract(quarter from fisc_dt)::int as fisc_qtr
from cte