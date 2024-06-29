{% test amount_not_negative(model) %}

select *  
from {{ model }} 
where coalesce("Amount",0) < 0

{% endtest %}

