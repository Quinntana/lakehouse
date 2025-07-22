{{ config(materialized='table', schema='flink') }}

with customers as (

    select *
    from {{ ref('stg_customers') }}

),

final as (

    select
        customer_id as id,
        concat(first_name, ' ', last_name) as full_name,
        email
    from customers

)

select * from final
