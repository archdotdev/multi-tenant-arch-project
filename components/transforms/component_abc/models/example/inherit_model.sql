select 'Base Value!'

{% set child = adapter.get_relation(
    database=this.database,
    schema=this.schema,
    identifier='inherit_model__child') %}
{% if child %}

union all

select *
from {{ child }}
{% endif %}


