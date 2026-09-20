with source as (
    select * from {{ source('raw_purchasing', 'purchasing_purchaseorderheader') }}
),

renamed as (
    select
        -- Chaves e participantes
        cast(PurchaseOrderID as int)            as purchase_order_id,
        cast(VendorID as int)                   as vendor_business_entity_id,
        cast(EmployeeID as int)                 as buyer_employee_id,
        cast(ShipMethodID as int)               as ship_method_id,

        -- Controle e status
        cast(RevisionNumber as int)             as revision_number,
        cast(Status as int)                     as order_status_code, -- 1 = Pending, 2 = Approved, 3 = Rejected, 4 = Complete

        -- Datas
        cast(OrderDate as date)                 as order_date,
        cast(ShipDate as date)                  as ship_date,

        -- Valores consolidados
        cast(SubTotal as decimal(18, 4))        as subtotal_amount,
        cast(TaxAmt as decimal(18, 4))          as tax_amount,
        cast(Freight as decimal(18, 4))         as freight_amount,
        cast(TotalDue as decimal(18, 4))        as total_due_amount,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;