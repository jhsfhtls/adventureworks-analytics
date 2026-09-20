with source as (
    select * from {{ source('raw_sales', 'sales_salesorderdetail') }}
),

renamed as (
    select
        -- Chaves
        cast(SalesOrderID as int)               as sales_order_id,
        cast(SalesOrderDetailID as int)         as sales_order_detail_id,
        cast(ProductID as int)                  as product_id,
        cast(SpecialOfferID as int)             as special_offer_id,
        cast(rowguid as string)                 as row_guid,

        -- Rastreamento e volumes
        cast(CarrierTrackingNumber as string)   as carrier_tracking_number,
        cast(OrderQty as int)                   as order_quantity,

        -- Preços, descontos e total da linha
        cast(UnitPrice as decimal(18, 4))       as unit_price,
        cast(UnitPriceDiscount as decimal(18, 4)) as unit_price_discount,
        cast(LineTotal as decimal(18, 4))       as line_total_amount,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;