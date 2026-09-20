with source as (
    select * from {{ source('raw_production', 'production_billofmaterials') }}
),

renamed as (
    select
        -- Chaves
        cast(BillOfMaterialsID as int)      as bill_of_materials_id,
        cast(ProductAssemblyID as int)      as assembly_product_id, -- Produto pai montado (nulo se for raiz)
        cast(ComponentID as int)            as component_product_id, -- Componente/peça filha

        -- Hierarquia e medidas
        cast(BOMLevel as int)               as bom_level,
        cast(PerAssemblyQty as decimal(18, 4)) as per_assembly_quantity,
        cast(UnitMeasureCode as string)     as unit_measure_code,

        -- Vigência da estrutura
        cast(StartDate as date)             as start_date,
        cast(EndDate as date)               as end_date,
        case 
            when EndDate is null then true 
            else false 
        end                                 as is_current_bom,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;