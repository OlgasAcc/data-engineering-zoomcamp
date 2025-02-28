{{ config(materialized="table") }}

select
    dispatching_base_num,
    pickup_datetime,
    dropoff_datetime,
    cast(pulocationid as int64) as pickup_location_id,
    cast(dolocationid as int64) as dropoff_location_id,
    extract(year from pickup_datetime) as year,
    extract(month from pickup_datetime) as month
from `terraform-demo-452019.demo_dataset.fhv_tripdata`
where
    dispatching_base_num is not null
    and pulocationid is not null
    and dolocationid is not null
