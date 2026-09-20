with source as (
    select * from {{ source('raw_sales', 'sales_customer') }}
),

renamed as (
    select
        -- Chaves
        cast(CustomerID as int)                 as customer_id,
        cast(PersonID as int)                   as person_id,   -- Preenchido para clientes B2C (físicos)
        cast(StoreID as int)                    as store_id,    -- Preenchido para revendas/lojas B2B
        cast(TerritoryID as int)                as territory_id,
        cast(rowguid as string)                 as row_guid,

        -- Identificação da conta
        cast(AccountNumber as string)           as customer_account_number,
        case 
            when StoreID is not null then 'Store (B2B)'
            else 'Individual (B2C)'
        end                                     as customer_type,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;