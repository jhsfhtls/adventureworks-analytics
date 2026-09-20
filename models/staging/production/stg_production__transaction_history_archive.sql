with source as (
    select * from {{ source('raw_production', 'production_transactionhistoryarchive') }}
),

renamed as (
    select
        -- Chaves e referências de ordens arquivadas
        cast(TransactionID as int)              as transaction_id,
        cast(ProductID as int)                  as product_id,
        cast(ReferenceOrderID as int)          as reference_order_id,
        cast(ReferenceOrderLineID as int)      as reference_order_line_id,

        -- Tipo e datas da movimentação
        cast(TransactionDate as date)           as transaction_date,
        cast(TransactionType as string)         as transaction_type_code, -- 'W' = Work Order, 'S' = Sales Order, 'P' = Purchase Order

        -- Métricas
        cast(Quantity as int)                   as quantity,
        cast(ActualCost as decimal(18, 4))      as actual_cost,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;