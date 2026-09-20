with source as (
    select * from {{ source('raw_sales', 'sales_salesorderheader') }}
),

renamed as (
    select
        -- Chaves e identificadores
        cast(SalesOrderID as int)               as sales_order_id,
        cast(CustomerID as int)                 as customer_id,
        cast(SalesPersonID as int)              as sales_person_id,
        cast(TerritoryID as int)                as territory_id,
        cast(BillToAddressID as int)            as bill_to_address_id,
        cast(ShipToAddressID as int)            as ship_to_address_id,
        cast(ShipMethodID as int)               as ship_method_id,
        cast(CreditCardID as int)               as credit_card_id,
        cast(CurrencyRateID as int)             as currency_rate_id,
        cast(rowguid as string)                 as row_guid,

        -- Números de controle e status
        cast(SalesOrderNumber as string)        as sales_order_number,
        cast(PurchaseOrderNumber as string)     as customer_po_number,
        cast(AccountNumber as string)           as customer_account_number,
        cast(CreditCardApprovalCode as string)  as credit_card_approval_code,
        cast(RevisionNumber as int)             as revision_number,
        cast(Status as int)                     as order_status_code, -- 1=InProcess, 2=Approved, 3=Backordered, 4=Rejected, 5=Shipped, 6=Cancelled
        cast(OnlineOrderFlag as boolean)        as is_online_order,

        -- Datas
        cast(OrderDate as date)                 as order_date,
        cast(DueDate as date)                   as due_date,
        cast(ShipDate as date)                  as ship_date,

        -- Valores financeiros
        cast(SubTotal as decimal(18, 4))        as subtotal_amount,
        cast(TaxAmt as decimal(18, 4))          as tax_amount,
        cast(Freight as decimal(18, 4))         as freight_amount,
        cast(TotalDue as decimal(18, 4))        as total_due_amount,

        -- Comentários e auditoria
        cast(Comment as string)                 as order_comment,
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;