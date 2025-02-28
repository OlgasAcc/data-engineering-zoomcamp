{{ config(materialized="table") }}

WITH trip_durations AS (
    SELECT
        dispatching_base_num,
        pickup_datetime,
        dropoff_datetime,
        pickup_location_id,
        dropoff_location_id,
        year,
        month,
        pickup_zone,
        dropoff_zone,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) AS trip_duration
    FROM
        {{ ref('dim_fhv_trips') }}
),
p90_trip_durations AS (
    SELECT
        year,
        month,
        pickup_location_id,
        dropoff_location_id,
        pickup_zone,
        dropoff_zone,
        APPROX_QUANTILES(trip_duration, 100)[OFFSET(90)] AS p90_trip_duration
    FROM
        trip_durations
    GROUP BY
        year, month, pickup_location_id, dropoff_location_id, pickup_zone, dropoff_zone
),
filtered_trips AS (
    SELECT
        p90.year,
        p90.month,
        p90.pickup_location_id,
        p90.dropoff_location_id,
        p90.pickup_zone,
        p90.dropoff_zone,
        p90.p90_trip_duration
    FROM
        p90_trip_durations p90
    WHERE
        p90.year = 2019
        AND p90.month = 11
        AND p90.pickup_zone IN ('Newark Airport', 'SoHo', 'Yorkville East')
),
ranked_trips AS (
    SELECT
        year,
        month,
        pickup_location_id,
        pickup_zone,
        dropoff_zone,
        p90_trip_duration,
        ROW_NUMBER() OVER (PARTITION BY pickup_zone ORDER BY p90_trip_duration DESC) AS rank
    FROM
        filtered_trips
)
SELECT
    pickup_zone,
    dropoff_zone,
    p90_trip_duration
FROM
    ranked_trips
WHERE
    rank = 2
ORDER BY pickup_zone