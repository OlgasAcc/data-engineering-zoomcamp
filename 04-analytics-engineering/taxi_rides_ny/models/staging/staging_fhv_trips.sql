{{ config(materialized="view") }}

-- models/staging/staging_fhv_trips.sql
{{ config(materialized='table') }}

SELECT 
    dispatching_base_num,
    pickup_datetime,
    dropoff_datetime,
    PULocationID AS pickup_location_id,  -- Rename column
    DOLocationID AS dropoff_location_id, -- Rename column
    EXTRACT(YEAR FROM pickup_datetime) AS year, 
    EXTRACT(MONTH FROM pickup_datetime) AS month
FROM `terraform-demo-452019.demo_dataset.fhv_tripdata`
WHERE dispatching_base_num IS NOT NULL
