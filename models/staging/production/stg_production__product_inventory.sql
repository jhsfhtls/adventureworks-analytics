with source as (
    select * from {{ source('raw_production', 'production_productinventory') }}
),

renamed as (
    select
        -- Chaves compostas
        cast(ProductID as int)              as product_id,
        cast(LocationID as int)             as location_id,
        cast(rowguid as string)             as row_guid,

        -- Localização física no armazém/estoque
        cast(Shelf as string)               as shelf_code, -- Ex: 'A', 'B', 'N/A'
        cast(Bin as int)                    as bin_number,

        -- Saldo em estoque
        cast(Quantity as int)               as stock_quantity,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;