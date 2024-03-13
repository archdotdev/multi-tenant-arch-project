
-- Use the `ref` function to select from other models

select *
from {{ ref('component_abc_table') }}
where id = 1
