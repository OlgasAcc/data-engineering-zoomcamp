{{ config(materialized="table") }}

with
    filtered_trips as (
        select
            service_type,
            extract(year from pickup_datetime) as year,
            extract(month from pickup_datetime) as month,
            fare_amount
        from `terraform-demo-452019.demo_dataset.fact_trips`
        where
            fare_amount > 0
            and trip_distance > 0
            and payment_type_description in ('Cash', 'Credit Card')
            and extract(year from pickup_datetime) between 2010 and 2025
    ),
    ranked_fares as (
        select
            service_type,
            year,
            month,
            fare_amount,
            ntile(100) over (
                partition by service_type, year, month order by fare_amount
            ) as percentile
        from filtered_trips
    )
select
    service_type,
    year,
    month,
    max(case when percentile <= 97 then fare_amount end) as p97,
    max(case when percentile <= 95 then fare_amount end) as p95,
    max(case when percentile <= 90 then fare_amount end) as p90
from ranked_fares
where year = 2020 and month = 4
group by service_type, year, month
