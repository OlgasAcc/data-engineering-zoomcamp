{{ config(materialized="table") }}

with
    base_trips as (
        select
            pickup_datetime,
            total_amount,
            service_type,  -- 'green' or 'yellow'
            extract(year from pickup_datetime) as year,
            extract(quarter from pickup_datetime) as quarter,
            concat(
                extract(year from pickup_datetime),
                '/Q',
                extract(quarter from pickup_datetime)
            ) as year_quarter
        from {{ ref("fact_trips") }}
    ),

    quarterly_revenue as (
        select
            year,
            quarter,
            year_quarter,
            service_type,
            sum(total_amount) as quarterly_revenue
        from base_trips
        group by year, quarter, year_quarter, service_type
    ),

    quarterly_yoy_growth as (
        select
            q1.year,
            q1.quarter,
            q1.year_quarter,
            q1.service_type,
            q1.quarterly_revenue,
            q0.quarterly_revenue as prev_year_revenue,
            round(
                (q1.quarterly_revenue - q0.quarterly_revenue)
                / q0.quarterly_revenue
                * 100,
                2
            ) as yoy_growth
        from quarterly_revenue q1
        left join
            quarterly_revenue q0
            on q1.service_type = q0.service_type
            and q1.quarter = q0.quarter
            and q1.year = q0.year + 1  -- Compare with previous year
    )

select *
from quarterly_yoy_growth
order by service_type, year_quarter
