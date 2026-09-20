with source as (
    select * from {{ source('raw_production', 'production_product') }}
),

renamed as (
    select
        -- Chaves e identificadores
        cast(ProductID as int)                  as product_id,
        cast(ProductSubcategoryID as int)       as product_subcategory_id,
        cast(ProductModelID as int)             as product_model_id,
        cast(ProductNumber as string)           as product_number,
        cast(rowguid as string)                 as row_guid,

        -- Descrição básica e classificação
        cast(Name as string)                    as product_name,
        cast(MakeFlag as boolean)               as is_manufactured_in_house, -- true = fabricado, false = comprado pronto
        cast(FinishedGoodsFlag as boolean)      as is_finished_goods,        -- true = comercializável
        cast(Color as string)                   as color_name,
        cast(ProductLine as string)             as product_line_code,        -- 'R' (Road), 'M' (Mountain), 'T' (Touring), 'S' (Standard)
        cast(Class as string)                   as class_code,               -- 'H' (High), 'M' (Medium), 'L' (Low)
        cast(Style as string)                   as style_code,               -- 'W' (Women's), 'M' (Men's), 'U' (Universal)

        -- Estoque e parâmetros de produção
        cast(SafetyStockLevel as int)           as safety_stock_level,
        cast(ReorderPoint as int)               as reorder_point_level,
        cast(DaysToManufacture as int)          as days_to_manufacture,

        -- Preços e custos
        cast(StandardCost as decimal(18, 4))    as standard_cost,
        cast(ListPrice as decimal(18, 4))       as list_price,

        -- Dimensões e pesos
        cast(Size as string)                    as size,
        cast(SizeUnitMeasureCode as string)     as size_unit_measure_code,
        cast(Weight as decimal(10, 2))          as weight,
        cast(WeightUnitMeasureCode as string)   as weight_unit_measure_code,

        -- Ciclo de vida do produto
        cast(SellStartDate as date)             as sell_start_date,
        cast(SellEndDate as date)               as sell_end_date,
        cast(DiscontinuedDate as date)          as discontinued_date,
        case 
            when SellEndDate is null or SellEndDate > current_date() then true 
            else false 
        end                                     as is_currently_sold,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;