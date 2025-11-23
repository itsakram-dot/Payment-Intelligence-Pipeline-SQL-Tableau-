/* Project: Salon Finance Pipeline
   Author: Akram Mohammed
   Compatibility: SQLite (DataGrip Default)
*/
WITH Cleaned_Data AS (
    SELECT
        appointment_hash,
        client_pid,
        status,
        -- Transformation 1: Date Parsing (Extract YYYY-MM-DD)
        DATE(SUBSTR(appt_datetime_utc, 1, 10)) as appt_date,

        -- Transformation 2: Impute Revenue
        CASE
            WHEN services LIKE '%Balayage%' OR services LIKE '%Highlight%' THEN 220
            WHEN services LIKE '%Color%' THEN 150
            WHEN services LIKE '%Haircut%' THEN 85
            ELSE 60 -- Base rate
        END as estimated_revenue
    FROM
        appointments_anonymized
    WHERE
        appointment_hash IS NOT NULL
),

Monthly_Aggregates AS (
    SELECT
        -- Transformation 3: Group by Month
        strftime('%Y-%m', appt_date) as report_month,

        -- KPI 1: GPV (Gross Payment Volume)
        SUM(CASE WHEN status IN ('completed', 'checkout') THEN estimated_revenue ELSE 0 END) as GPV,

        -- KPI 2: Utilization (Total Bookings)
        COUNT(DISTINCT appointment_hash) as total_bookings,

        -- KPI 3: Churn Risk (Cancellation Rate)
        ROUND(
            CAST(SUM(CASE WHEN status IN ('cancelled', 'no_show') THEN 1 ELSE 0 END) AS REAL) /
            NULLIF(COUNT(*), 0) * 100,
        2) as cancellation_rate_pct,

        -- KPI 4: Active Client Base
        COUNT(DISTINCT client_pid) as active_clients
    FROM
        Cleaned_Data
    GROUP BY
        1
),

Growth_Analysis AS (
    SELECT
        report_month,
        GPV,
        total_bookings,
        cancellation_rate_pct,
        -- Window Function: Calculate Month-over-Month Revenue Growth
        LAG(GPV) OVER (ORDER BY report_month) as prev_month_gpv,
        ROUND(
            (GPV - LAG(GPV) OVER (ORDER BY report_month)) /
            NULLIF(LAG(GPV) OVER (ORDER BY report_month), 0) * 100,
        2) as gpv_growth_mom
    FROM
        Monthly_Aggregates
)

SELECT * FROM Growth_Analysis
ORDER BY report_month DESC;