
-- Use the `ref` function to select from other models

select *
from {{ ref('component_abc_table') }}
union all

select *
from {{ ref('component_def_table') }}
