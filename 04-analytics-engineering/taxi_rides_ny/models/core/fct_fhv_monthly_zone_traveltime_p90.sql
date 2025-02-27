-- models/fact/fct_fhv_monthly_zone_traveltime_p90.sql
{{ config(materialized="table") }}

WITH trip_durations AS (
    SELECT 
        year,
        month,
        pickup_location_id,
        dropoff_location_id,
        pickup_zone,
        dropoff_zone,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) AS trip_duration
    FROM `terraform-demo-452019.demo_dataset.dim_fhv_trips`
    WHERE year = 2019 
      AND month = 11
      AND pickup_zone IN ('Newark Airport', 'SoHo', 'Yorkville East')
      AND dropoff_location_id IS NOT NULL
),
p90_trip_duration AS (
    SELECT 
        year,
        month,
        pickup_location_id,
        dropoff_location_id,
        pickup_zone,
        dropoff_zone,
        PERCENTILE_CONT(trip_duration, 0.90) AS p90_trip_duration 
    FROM trip_durations
    GROUP BY year, month, pickup_location_id, dropoff_location_id, pickup_zone, dropoff_zone
),
ranked_trips AS (
    SELECT 
        pickup_zone,
        dropoff_zone,
        SAFE_CAST(p90_trip_duration AS FLOAT64) AS p90_trip_duration, 
        RANK() OVER (PARTITION BY pickup_zone ORDER BY SAFE_CAST(p90_trip_duration AS FLOAT64) DESC) AS rank
    FROM p90_trip_duration
)
SELECT pickup_zone, dropoff_zone, p90_trip_duration
FROM ranked_trips
WHERE rank = 2