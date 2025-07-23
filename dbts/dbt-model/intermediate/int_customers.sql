{{ config(materialized='table', schema='intermediate') }}

with staged as (
    select *
    from {{ ref('stg_customers') }}
),

transformed as (
    select
        customer_id,
        first_name,
        last_name,
        email,
        concat(first_name, '-', last_name) as name_key
    from staged
)

select * from transformed