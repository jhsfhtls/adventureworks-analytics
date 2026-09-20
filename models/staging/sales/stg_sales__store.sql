with source as (
    select * from {{ source('raw_sales', 'sales_store') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)           as store_business_entity_id,
        cast(SalesPersonID as int)              as assigned_sales_person_id,
        cast(rowguid as string)                 as row_guid,

        -- Dados da loja/revenda (B2B)
        cast(Name as string)                    as store_name,
        cast(Demographics as string)            as demographics_xml,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;