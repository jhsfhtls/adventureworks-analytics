with source as (
    select * from {{ source('raw_production', 'production_document') }}
),

renamed as (
    select
        -- Chaves e nós hierárquicos
        cast(DocumentNode as string)        as document_node,
        cast(DocumentLevel as int)          as document_level,
        cast(rowguid as string)             as row_guid,

        -- Metadados do arquivo
        cast(Title as string)               as document_title,
        cast(Owner as int)                  as owner_employee_id,
        cast(FolderFlag as boolean)         as is_folder,
        cast(FileName as string)            as file_name,
        cast(FileExtension as string)       as file_extension,
        cast(Revision as string)            as revision_number,
        cast(ChangeNumber as int)           as change_number,
        cast(Status as int)                 as document_status_code, -- 1 = Pending approval, 2 = Approved, 3 = Obsolete
        cast(DocumentSummary as string)     as document_summary,
        cast(Document as string)            as document_binary_content,

        -- Auditoria (armazenado como string no raw)
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;