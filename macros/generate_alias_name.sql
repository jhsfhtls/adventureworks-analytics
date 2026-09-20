{% macro generate_alias_name(custom_alias_name=none, node=none) -%}
    {%- if custom_alias_name is not none -%}
        {{ custom_alias_name | trim }}
    {%- elif node is not none -%}
        {%- set clean_name = node.name -%}
        {%- if clean_name.startswith('stg_') -%}
            {%- set clean_name = clean_name[4:] -%}
        {%- elif clean_name.startswith('int_') -%}
            {%- set clean_name = clean_name[4:] -%}
        {%- elif clean_name.startswith('dim_') -%}
            {%- set clean_name = clean_name[4:] -%}
        {%- elif clean_name.startswith('fct_') -%}
            {%- set clean_name = clean_name[4:] -%}
        {%- elif clean_name.startswith('fato_') -%}
            {%- set clean_name = clean_name[5:] -%}
        {%- endif -%}
        {{ clean_name | replace('__', '_') | trim }}
    {%- else -%}
        {{ '' }}
    {%- endif -%}
{%- endmacro %}