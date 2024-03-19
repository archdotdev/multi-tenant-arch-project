{{
    config(
        enabled=False
    )
}}
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

)
select
    "Custom_Field__c",
    "Another_Field__c"
from source
