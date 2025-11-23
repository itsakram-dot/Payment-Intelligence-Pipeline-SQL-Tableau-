# Payment Intelligence Pipeline (SQL → Tableau)
**Transforming raw appointment logs into governed Financial & Operational KPIs.**

<img width="2598" height="1558" alt="Monthly Financial Performance" src="https://github.com/user-attachments/assets/228838e6-2372-4680-80f2-245be1b90822" />


## 📌 Executive Summary
Built an end-to-end financial reporting pipeline that standardizes revenue recognition and churn analysis for high-volume service businesses (SaaS/Salon/Spa).

Unlike standard "dashboarding" projects, this pipeline solves two specific data engineering challenges often found in fintech:
1.  **Revenue Imputation:** The source system (bookings log) contained incomplete transaction values ($0 deposits). I engineered a SQL logic layer to impute revenue based on service mix (e.g., Balayage vs. Haircut pricing).
2.  **Scenario Modeling:** Finance stakeholders need more than historical charts. I built an interactive "What-If" model in Tableau to quantify the revenue impact of reducing churn by 1-5%.

**Business Impact:** Identified a ~25% churn spike in Q4 and modeled a **projected revenue recovery opportunity** of ~$122/month (per single salon location) via retention intervention.

## 🛠 Technical Stack
* **SQL (SQLite):** CTEs, Window Functions, Data Imputation, QC/Audit Flags.
* **Tableau:** Parameters, Computed Sets, Dual-Axis Visualization, Red/Green Conditional Logic.

---

## 1. Data Engineering Layer (SQL)
*File: `sql/monthly_kpis.sql`*

Raw appointment logs are noisy and often lack financial context. I wrote a comprehensive SQL pipeline to transform row-level booking data into an auditable monthly finance table.

**Key Engineering Features:**
* **Revenue Imputation:** `CASE` logic to assign estimated transaction values to services where raw deposit data was missing ($0.00).
* **Safe MoM Growth:** Implemented a "Safe Denominator" logic (`MAX(prev_month, $150)`) to prevent artificial 400%+ growth spikes during low-volume months.
* **Prescriptive Metrics:** Calculated `delta_gpv_1pp` (Dollar value of 1 percentage point of churn) directly in SQL to power downstream scenario modeling.
* **Audit Flags:** Automated QC columns (`qc_integrity_pass`) to verify that `cancelled_appointments <= scheduled_appointments`.

---

## 2. Visualization & Strategy Layer (Tableau)
*Live Dashboard: [View on Tableau Public](https://public.tableau.com/app/profile/akram.mohammed3381/viz/MonthlyFinancialPerformanceRevenueVsChurnRisk/Dashboard1)*

### Dashboard 1: Revenue vs. Churn Risk
* **Dual-Axis Visualization:** Correlates Gross Payment Volume (GPV) against Cancellation Rate % to spot operational failures.
* **Insight:** Validated a correlation where capacity constraints (mid-summer peak) led to a subsequent 15-25% spike in cancellations.

### Dashboard 2: Growth & Scenario Modeling
* **Interactive Slider:** "What-If" parameter allowing executives to toggle a 1-5% churn reduction.
* **Dynamic Calculation:** Real-time computation of `[Revenue Opportunity $]`, proving the financial ROI of retention campaigns.
* **Red/Green Logic:** Conditional formatting on MoM Growth bars to instantly flag negative revenue trends.

---

## 3. Key Findings
* **Q4 Risk Detected:** While August hit a revenue peak ($3.4k), **November saw a massive Churn spike to ~25%**, signaling operational/staffing friction.
* **Revenue Opportunity:** The scenario model identified that a conservative 5% reduction in churn would recover **~$122 in immediate monthly revenue** (per location).
* **Seasonality:** MoM revenue softened heading into Q4, consistent with industry trends, but the disproportionate churn spike indicates a service-level issue rather than just demand softening.

---

## 4. Screenshots

**Revenue vs. Churn Risk (Detail)**
<img width="1636" height="1480" alt="Monthly  Revenue % Churn Risk" src="https://github.com/user-attachments/assets/a7a28832-39db-4689-9f81-16da637adec7" />

**MoM Growth & Red/Green Logic (Detail)**
<img width="1476" height="1480" alt="MOM growth" src="https://github.com/user-attachments/assets/c439e963-4700-42ab-a7e4-e0db153fa6bf" />

---

## 📂 Repository Structure

```text
data/
  appointments_anonymized.csv  # Raw data (salted/hashed)

sql/
  monthly_KPI's1.sql             # The cleaning & metrics logic

screenshots/
  revenue_vs_churn.png
  mom_growth.png
  executive_dashboard.png

README.md

🔗 Data Source
Dataset: Hair Salon Appointments (Anonymous) via Kaggle.

Note: IDs are salted/hashed and datetimes shifted for privacy.
