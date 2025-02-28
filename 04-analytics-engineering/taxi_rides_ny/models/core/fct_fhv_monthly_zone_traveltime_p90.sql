{{ config(materialized="table") }}

with
    trip_durations as (
        select
            pickup_zone,
            dropoff_zone,
            timestamp_diff(dropoff_datetime, pickup_datetime, second) as trip_duration
        from `terraform-demo-452019.demo_dataset.dim_fhv_trips`
        where
            year = 2019
            and month = 11
            and pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East')
    ),

    p90_trip_durations as (
        select
            pickup_zone,
            dropoff_zone,
            approx_quantiles(trip_duration, 100)[offset(90)] as p90_trip_duration
        from trip_durations
        group by pickup_zone, dropoff_zone
    ),

    ranked_trips as (
        select
            pickup_zone,
            dropoff_zone,
            p90_trip_duration,
            rank() over (
                partition by pickup_zone order by p90_trip_duration desc
            ) as rank
        from p90_trip_durations
    )

select pickup_zone, dropoff_zone, p90_trip_duration
from ranked_trips
where rank = 2
order by pickup_zone
