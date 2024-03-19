{{
    config(
        enabled=False
    )
}}
-- depends_on: {{ ref('stg_salesforce__Contact_custom') }}
with source as (
    -- Simulate fake Salesforce source data
    select
        'foo' as "Default",
        'custom' as "Custom_Field__c",
        'another' as "Another_Field__c",
        '2024-01-01' as "_sdc_extracted_at",
        '2024-01-01' as "_sdc_received_at",
        '2024-01-01' as "_sdc_batched_at",
        '2024-01-01' as "_sdc_deleted_at",
        '2024-01-01' as "_sdc_sequence",
        '2024-01-01' as "_sdc_table_version",
        '2024-01-01' as "_sdc_sync_started_at"
    union all

    select
        'foo' as "Default",
        'custom' as "Custom_Field__c",
        'another' as "Another_Field__c",
        '2024-01-02' as "_sdc_extracted_at",
        '2024-01-02' as "_sdc_received_at",
        '2024-01-02' as "_sdc_batched_at",
        '2024-01-02' as "_sdc_deleted_at",
        '2024-01-02' as "_sdc_sequence",
        '2024-01-02' as "_sdc_table_version",
        '2024-01-02' as "_sdc_sync_started_at"

), renamed as (

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
