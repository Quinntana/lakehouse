{{ config(materialized='view', schema='staging') }}

with source as (

    select *
    from iceberg.flink.iceberg_customers

),

renamed as (

    select
        id as customer_id,
        first_name,
        last_name,
        lower(trim(email)) as email
    from source

)

select * from renamed

