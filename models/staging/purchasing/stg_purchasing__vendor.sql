with source as (
    select * from {{ source('raw_purchasing', 'purchasing_vendor') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)           as vendor_business_entity_id,

        -- Identificação do fornecedor
        cast(AccountNumber as string)           as vendor_account_number,
        cast(Name as string)                    as vendor_name,
        cast(CreditRating as int)               as credit_rating, -- Escala de classificação de crédito de 1 a 5
        cast(PreferredVendorStatus as boolean)  as is_preferred_vendor,
        cast(ActiveFlag as boolean)             as is_active,
        cast(PurchasingWebServiceURL as string) as purchasing_web_service_url,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;