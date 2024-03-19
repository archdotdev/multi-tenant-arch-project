-- depends_on: {{ ref('stg_salesforce__Contact_custom') }}
with renamed as (

    select
        "Default" as default_value,
        {% if model_exists('stg_salesforce__Contact_custom', graph.nodes) %}
            {% for column in adapter.get_columns_in_relation(ref('stg_salesforce__Contact_custom')) %}
                {{ column.quoted }},
            {% endfor %}
        {% endif %}
        "_sdc_extracted_at",
        "_sdc_received_at",
        "_sdc_batched_at",
        "_sdc_deleted_at",
        "_sdc_sequence",
        "_sdc_table_version",
        "_sdc_sync_started_at"

    from source

)

select * from renamed

