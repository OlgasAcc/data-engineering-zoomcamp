{{ config(materialized="table") }}

with
    trip_durations as (
        select
            dispatching_base_num,
            pickup_datetime,
            dropoff_datetime,
            pickup_location_id,
            dropoff_location_id,
            year,
            month,
            pickup_zone,
            dropoff_zone,
            timestamp_diff(dropoff_datetime, pickup_datetime, second) as trip_duration
        from {{ ref("dim_fhv_trips") }}
    ),
    p90_trip_durations as (
        select
            year,
            month,
            pickup_location_id,
            dropoff_location_id,
            pickup_zone,
            dropoff_zone,
            approx_quantiles(trip_duration, 100)[offset(90)] as p90_trip_duration
        from trip_durations
        group by
            year,
            month,
            pickup_location_id,
            dropoff_location_id,
            pickup_zone,
            dropoff_zone
    ),
    filtered_trips as (
        select
            p90.year,
            p90.month,
            p90.pickup_location_id,
            p90.dropoff_location_id,
            p90.pickup_zone,
            p90.dropoff_zone,
            p90.p90_trip_duration
        from p90_trip_durations p90
        where
            p90.year = 2019
            and p90.month = 11
            and p90.pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East')
    ),
    ranked_trips as (
        select
            year,
            month,
            pickup_location_id,
            pickup_zone,
            dropoff_zone,
            p90_trip_duration,
            row_number() over (
                partition by pickup_zone order by p90_trip_duration desc
            ) as rank
        from filtered_trips
    )
select pickup_zone, dropoff_zone, p90_trip_duration
from ranked_trips
where rank = 2
order by pickup_zone
