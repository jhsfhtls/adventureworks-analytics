with source as (
    select * from {{ source('raw_production', 'production_productlistpricehistory') }}
),

renamed as (
    select
        -- Chaves
        cast(ProductID as int)              as product_id,

        -- Período de vigência do preço de tabela
        cast(StartDate as date)             as start_date,
        cast(EndDate as date)               as end_date,
        case 
            when EndDate is null then true 
            else false 
        end                                 as is_current_price,

        -- Valor
        cast(ListPrice as decimal(18, 4))   as list_price,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;