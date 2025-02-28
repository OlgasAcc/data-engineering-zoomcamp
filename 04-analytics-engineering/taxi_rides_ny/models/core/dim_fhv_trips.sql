{{ config(materialized="table") }}

with
    mapped_trips as (
        select
            sft.dispatching_base_num,
            sft.pickup_datetime,
            sft.dropoff_datetime,
            sft.pickup_location_id,
            sft.dropoff_location_id,
            sft.year,
            sft.month,
            coalesce(dz1.zone, 'Unknown') as pickup_zone,
            coalesce(dz2.zone, 'Unknown') as dropoff_zone
        from `terraform-demo-452019.demo_dataset.staging_fhv_trips` sft
        left join
            `terraform-demo-452019.demo_dataset.dim_zones` dz1
            on safe_cast(sft.pickup_location_id as string)
            = safe_cast(dz1.locationid as string)
        left join
            `terraform-demo-452019.demo_dataset.dim_zones` dz2
            on safe_cast(sft.dropoff_location_id as string)
            = safe_cast(dz2.locationid as string)
    )

select *
from mapped_trips
