{{ config(materialized="table") }}

select
    sft.dispatching_base_num,
    sft.pickup_datetime,
    sft.dropoff_datetime,
    sft.pickup_location_id,
    sft.dropoff_location_id,
    sft.year,
    sft.month,
    dz1.zone as pickup_zone,
    dz2.zone as dropoff_zone
from `terraform-demo-452019.demo_dataset.staging_fhv_trips` sft
left join
    `terraform-demo-452019.demo_dataset.dim_zones` dz1
    on sft.pickup_location_id = dz1.locationid
left join
    `terraform-demo-452019.demo_dataset.dim_zones` dz2
    on sft.dropoff_location_id = dz2.locationid
