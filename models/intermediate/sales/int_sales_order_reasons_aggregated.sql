with header_reasons as (
    select * from {{ ref('stg_sales__sales_order_header_sales_reason') }}
),

reasons as (
    select * from {{ ref('stg_sales__sales_reason') }}
),

aggregated as (
    select
        hr.sales_order_id,
        -- Agrupa os motivos em uma string delimitada por vírgula compatível com Databricks SQL
        concat_ws(', ', collect_set(r.sales_reason_name)) as sales_reasons_list,
        concat_ws(', ', collect_set(r.sales_reason_type)) as sales_reason_types_list,
        count(distinct r.sales_reason_id)                 as total_reasons_count
    from header_reasons hr
    inner join reasons r
        on hr.sales_reason_id = r.sales_reason_id
    group by hr.sales_order_id
)

select * from aggregated