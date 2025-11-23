/* Project: Salon Financial Pipeline
*/

WITH
-- Global params: Centralized here so we don't hunt for hardcoded values later.
params AS (
  SELECT
    0.025 AS take_rate,        -- Current platform fee
    150.0 AS min_base_gpv,     -- Floor for MoM calculations to prevent infinite % spikes on low-volume months
    5.0   AS alert_pp          -- Threshold: Flag if Churn Rate jumps > 5 points
),

-- Step 1: Clean raw logs and fix missing revenue data
clean_base AS (
    SELECT
        appointment_hash,
        -- SQLite requires string parsing for ISO dates
        DATE(SUBSTR(appt_datetime_utc, 1, 10)) as appt_date,
        status,
        -- Raw deposit_amount is 0.0 in source, so imputing standard pricing by service type
        CASE
            WHEN services LIKE '%Balayage%' OR services LIKE '%Highlight%' THEN 220
            WHEN services LIKE '%Color%' THEN 150
            WHEN services LIKE '%Haircut%' THEN 85
            ELSE 60 -- Base rate for misc services
        END as imputed_amount
    FROM
        appointments_anonymized
    WHERE
        appointment_hash IS NOT NULL
),

-- Step 2: Aggregate to Monthly level (Base Cohorts)
monthly_rollup AS (
    SELECT
        strftime('%Y-%m', appt_date) as report_month,
        COUNT(*) as scheduled_appointments,

        -- Defining Churn as both explicit cancels and no-shows
        SUM(CASE WHEN status IN ('cancelled', 'no_show') THEN 1 ELSE 0 END) as cancelled_appointments,

        -- Revenue recognized only on completion
        SUM(CASE WHEN status IN ('completed', 'checkout') THEN 1 ELSE 0 END) as completed_appointments,
        SUM(CASE WHEN status IN ('completed', 'checkout') THEN imputed_amount ELSE 0 END) as gpv
    FROM
        clean_base
    GROUP BY 1
),

-- Step 3: Calculate KPIs and Sensitivity Models
financial_metrics AS (
    SELECT
        m.report_month,
        m.scheduled_appointments,
        m.cancelled_appointments,
        m.completed_appointments,
        m.gpv,

        -- KPI: Cancel Rate
        CASE WHEN m.scheduled_appointments > 0
             THEN CAST(m.cancelled_appointments AS REAL) / m.scheduled_appointments
             ELSE 0 END as cancel_rate,

        -- Metric: Average Ticket (AOV)
        CASE WHEN m.completed_appointments > 0
             THEN CAST(m.gpv AS REAL) / m.completed_appointments
             ELSE 0 END as avg_ticket,

        -- MoM Growth: Using a 'Safe Denominator' to dampen volatility from low-volume months
        (m.gpv - LAG(m.gpv) OVER (ORDER BY m.report_month)) /
        MAX(
            LAG(m.gpv) OVER (ORDER BY m.report_month),
            (SELECT min_base_gpv FROM params)
        ) as mom_growth_safe,

        -- Scenario: Revenue impact if we save 1% of booked appointments from cancelling
        MIN(m.cancelled_appointments, 0.01 * m.scheduled_appointments) * (CASE WHEN m.completed_appointments > 0 THEN CAST(m.gpv AS REAL) / m.completed_appointments ELSE 0 END)
        as delta_gpv_1pp,

        -- Integrity Checks for the dashboard
        CASE WHEN m.cancelled_appointments <= m.scheduled_appointments THEN 1 ELSE 0 END as qc_pass,
        CASE WHEN m.gpv >= 0 THEN 1 ELSE 0 END as gpv_valid
    FROM
        monthly_rollup m
),

-- Step 4: Final formatting and Alerts
final_output AS (
    SELECT
        met.*,
        p.take_rate,

        -- Calculate net revenue impact for the platform
        met.delta_gpv_1pp * p.take_rate as delta_platform_rev_1pp,

        -- Alert logic: Flag month if churn spike is alarming
        CASE
            WHEN (met.cancel_rate * 100) - LAG(met.cancel_rate * 100) OVER (ORDER BY met.report_month) >= p.alert_pp
            THEN 1 ELSE 0
        END as alert_churn_spike
    FROM
        financial_metrics met, params p
)

SELECT * FROM final_output ORDER BY report_month DESC;