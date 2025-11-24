# Payment Intelligence Pipeline (SQL → Tableau)
**Transforming raw appointment logs into governed financial and operational KPIs.**

<img width="2598" height="1558" alt="Monthly Financial Performance (1)" src="https://github.com/user-attachments/assets/45967515-5db7-4053-933e-ad93a4bc9ef6" />

---

## 📌 Executive Summary
Built a pipeline that standardizes revenue recognition and cancellation analysis for high-volume service businesses (salon/spa/SaaS-style).

This project focuses on two problems:
1) **Revenue imputation:** The bookings log has $0 deposits. I wrote SQL to estimate prices by service type (e.g., Balayage vs Haircut).  
2) **Scenario modeling:** Added a Tableau What-If to show the dollar impact of cutting cancellations by 1–5 percentage points.

Result: Found a ~25% cancellation spike in Q4 and a ~$122/month recovery opportunity per location from a modest retention lift.

---

## 🛠 Technical Stack
- **SQL (SQLite):** CTEs, window functions, price imputation, QC flags  
- **Tableau:** parameters, dual-axis views, scenario slider, red/green MoM bars

---

## 1) Data Engineering Layer (SQL)
*File: `sql/monthly_KPI's1.sql`*

The SQL turns row-level bookings into a monthly finance table you can audit.

**What it does**
- **Price imputation:** `CASE` logic assigns prices when deposits are $0.00  
- **Safe MoM growth:** uses `MAX(prev_gpv, 150)` to avoid base-effect spikes  
- **Prescriptive metric:** `delta_gpv_1pp` = GPV gain from a 1-point drop in cancellations  
- **QC check:** ensures `cancelled_appointments ≤ scheduled_appointments`

---

## 2) Visualization & Strategy Layer (Tableau)
**Live Dashboard:** https://public.tableau.com/app/profile/akram.mohammed3381/viz/MonthlyFinancialPerformanceRevenueVsChurnRisk/Dashboard1

### Dashboard 1 — Revenue vs Cancellation Risk
- GPV (bars) vs Cancellation Rate % (line) on a dual axis  
- Mid-summer revenue peaks line up with higher cancellations (15–25%)

### Dashboard 2 — Growth & Scenario Modeling
- What-If slider for a 1–5% cancellation cut  
- `[Revenue Opportunity $]` updates in real time  
- MoM bars turn red/green for quick trend scans

---

## 3) Key Findings
- **Q4 risk:** August revenue (~$3.4k) is followed by **~25% cancellations in November** → likely staffing/scheduling strain  
- **Revenue lift:** A 5-point cancellation reduction adds **~$122/month** per location  
- **Seasonality:** Normal softening into Q4; the cancel spike is larger than seasonality alone

---

## 4) Screenshots

**Revenue vs Cancellation Risk (detail)**  
<img width="1636" height="1480" alt="Monthly  Revenue % Churn Risk (1)" src="https://github.com/user-attachments/assets/85b9f86c-83c5-4021-b335-086fc27e9002" />

**MoM Growth (detail)**  
<img width="1476" height="1480" alt="MOM growth" src="https://github.com/user-attachments/assets/8aaa4e88-c42c-4027-9b2a-bcc109a056cb" />

---
## 📚 Data Dictionary

<img width="799" height="178" alt="Screenshot 2025-11-23 at 19 33 13" src="https://github.com/user-attachments/assets/3d5efec1-bf0b-4f00-8626-76cb56b970e2" />
			
"Owner: Akram Mohammed
SLA: Source → SQL table by 6:00 AM PT monthly
Notes: IDs salted/hashed; datetimes shifted for privacy."

---

## 📏 KPI Definitions
	•	GPV (Gross Payment Volume): Sum of realized service revenue for completed/checkout visits
	•	Cancellation Rate: (cancelled + no_show) / (completed + checkout + cancelled + no_show)
	•	Safe MoM Growth: (GPV_t − GPV_(t-1)) / MAX(GPV_(t-1), 150)
	•	1-pp Cancel Elasticity: GPV gain from a 1-point drop in cancellations
	•	delta_gpv_1pp = (scheduled_cnt * 1%) * avg_ticket
	•	Platform revenue: delta_gpv_1pp * 2.75% (configurable)

---

## 🧪 Assumptions & Limits
	•	Price imputation is service-based and meant for demo; replace with POS payments for production.
	•	Safe MoM floor uses $150; adjust per business.
	•	Single-location example; multi-location rollups add location_id.

---

## 📂 Repository Structure
```text
data/
  appointments_anonymized.csv   # Raw data (salted/hashed)

sql/
  monthly_KPI's1.sql            # Cleaning + metrics logic

screenshots/
  revenue_vs_churn.png
  mom_growth.png
  executive_dashboard.png

README.md

---

## 🔗 Data Source

Dataset: Hair Salon Appointments (Anonymous) via Kaggle.
