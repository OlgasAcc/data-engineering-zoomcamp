-- models/core/dim_fhv_trips.sql
{{ config(materialized='table') }}

-- models/core/dim_fhv_trips.sql
{{ config(materialized='table') }}

SELECT 
    sft.dispatching_base_num,
    sft.pickup_datetime,
    sft.dropoff_datetime,
    sft.pickup_location_id,
    sft.dropoff_location_id,
    sft.year,
    sft.month,
    dz1.zone AS pickup_zone,
    dz2.zone AS dropoff_zone
FROM `terraform-demo-452019.demo_dataset.staging_fhv_trips` sft
LEFT JOIN `terraform-demo-452019.demo_dataset.dim_zones` dz1 
    ON sft.pickup_location_id = dz1.locationid  -- Corrected column name
LEFT JOIN `terraform-demo-452019.demo_dataset.dim_zones` dz2 
    ON sft.dropoff_location_id = dz2.locationid  -- Corrected column name

