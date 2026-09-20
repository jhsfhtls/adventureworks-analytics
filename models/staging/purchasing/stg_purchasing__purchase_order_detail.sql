with source as (
    select * from {{ source('raw_purchasing', 'purchasing_purchaseorderdetail') }}
),

renamed as (
    select
        -- Chaves
        cast(PurchaseOrderID as int)            as purchase_order_id,
        cast(PurchaseOrderDetailID as int)      as purchase_order_detail_id,
        cast(ProductID as int)                  as product_id,

        -- Prazos
        cast(DueDate as date)                   as due_date,

        -- Quantidades e conferência física
        cast(OrderQty as int)                   as order_quantity,
        cast(ReceivedQty as decimal(10, 2))     as received_quantity,
        cast(RejectedQty as decimal(10, 2))     as rejected_quantity,
        cast(StockedQty as decimal(10, 2))      as stocked_quantity,

        -- Valores financeiros
        cast(UnitPrice as decimal(18, 4))       as unit_price,
        cast(LineTotal as decimal(18, 4))       as line_total,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;