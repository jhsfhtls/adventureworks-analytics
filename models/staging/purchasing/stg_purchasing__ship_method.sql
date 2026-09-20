with source as (
    select * from {{ source('raw_purchasing', 'purchasing_shipmethod') }}
),

renamed as (
    select
        -- Chaves
        cast(ShipMethodID as int)               as ship_method_id,
        cast(rowguid as string)                 as row_guid,

        -- Dados da transportadora/modalidade
        cast(Name as string)                    as ship_method_name, -- Ex: 'XR - COURIER', 'OVERNIGHT J-FAST'
        cast(ShipBase as decimal(18, 4))        as base_shipping_fee,
        cast(ShipRate as decimal(18, 4))        as shipping_rate_per_pound,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;