
-- Use the `ref` function to select from other models

select *
from {{ ref('component_def_table') }}
where id = 2
