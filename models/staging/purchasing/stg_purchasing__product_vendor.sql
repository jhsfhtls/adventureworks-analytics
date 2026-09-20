with source as (
    select * from {{ source('raw_purchasing', 'purchasing_productvendor') }}
),

renamed as (
    select
        -- Chaves compostas
        cast(ProductID as int)                  as product_id,
        cast(BusinessEntityID as int)           as vendor_business_entity_id,

        -- Parâmetros de fornecimento e lead time
        cast(AverageLeadTime as int)            as average_lead_time_days,
        cast(StandardPrice as decimal(18, 4))   as standard_purchase_price,
        cast(LastReceiptCost as decimal(18, 4)) as last_receipt_cost,
        cast(LastReceiptDate as date)           as last_receipt_date,

        -- Lotes de pedido
        cast(MinOrderQty as int)                as min_order_quantity,
        cast(MaxOrderQty as int)                as max_order_quantity,
        cast(OnOrderQty as int)                 as on_order_quantity,
        cast(UnitMeasureCode as string)         as unit_measure_code,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;