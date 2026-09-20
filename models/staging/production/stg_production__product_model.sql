with source as (
    select * from {{ source('raw_production', 'production_productmodel') }}
),

renamed as (
    select
        -- Usa try_cast para tolerar linhas corrompidas da ingestão do CSV
        try_cast(ProductModelID as int)     as product_model_id,
        cast(rowguid as string)             as row_guid,

        -- Atributos do modelo
        cast(Name as string)                as product_model_name,
        cast(CatalogDescription as string)  as catalog_description_xml,
        cast(Instructions as string)        as manufacturing_instructions_xml,

        -- Auditoria
        try_cast(ModifiedDate as timestamp) as modified_at
    from source
    -- Filtra e descarta as linhas quebradas que não possuem um ID numérico válido
    where try_cast(ProductModelID as int) is not null
)

select * from renamed