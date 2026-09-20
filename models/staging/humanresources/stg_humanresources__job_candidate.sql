with source as (
    select * from {{ source('raw_humanresources', 'humanresources_jobcandidate') }}
),

renamed as (
    select
        -- Chaves
        cast(JobCandidateID as int)         as job_candidate_id,
        cast(BusinessEntityID as int)       as business_entity_id, -- Pode ser nulo se não contratado

        -- Currículo / Documentação
        cast(Resume as string)              as resume_xml,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;