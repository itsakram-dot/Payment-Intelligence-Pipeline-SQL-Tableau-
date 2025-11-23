# Payment Intelligence Pipeline (SQL → Tableau)
Transforming raw salon appointment logs into board-ready financial KPIs.

![yyfdyv3db](https://github.com/user-attachments/assets/ccc5f381-e226-4a0a-80ca-b64a3b7fc713)

## Overview
This project simulates a real financial-reporting workflow for service-based businesses (salons, spas, gyms) by transforming raw appointment data into trusted executive KPIs. It mirrors the type of analytics used inside SaaS and payments platforms like Mindbody, Fresha, and similar operational-finance systems.

Using SQL and Tableau, I engineered a pipeline that models:
- GPV (Gross Payment Volume)
- Cancellation Risk / Churn Signals
- Month-over-Month Revenue Growth
- Active Customer Base
- Operational risk insights

## Data Source

**Dataset:** Hair Salon Appointments (Anonymous)  
**Source:** https://www.kaggle.com/datasets/calebhwhite/hair-salon-appointments-anonymous  

- Customer & provider IDs salted  
- Appointment & charge IDs hashed  
- Datetimes shifted per-client  
- Card expiration coarsened  

## Technical Stack
- SQL (SQLite) — data modeling, CTEs, window functions  
- Tableau Online — executive visualization and KPI dashboard  

---

## 1. Data Modeling Layer (SQL)

The raw appointment log was cleaned and transformed into monthly financial metrics using:

**✔ CTEs**  
For readability and modular transformations.

**✔ Window Functions**  
To calculate:
- Previous month GPV  
- MoM revenue growth  
- Churn indicators 

Full SQL available in: montly_KPI's.sql

---

## 2. Visualization Layer (Tableau)

### Dashboard 1 — Revenue vs. Churn Risk
- GPV (bars, left axis)  
- Cancellation Rate % (line, right axis)  
- Dual-axis analysis  
- Color-coded risk segments  

### Dashboard 2 — MoM Revenue Growth
- Quick Table Calculation (Percent Difference)  
- Green = Positive Growth  
- Red = Negative Growth  
- Highlights seasonal/operational performance dips  

---

## 3. Key Insights Identified

✔ GPV peaked in midsummer, aligning with typical salon/spa seasonality.  
✔ As revenue peaked, cancellation risk increased ~15%, signaling capacity or scheduling pressures.  
✔ MoM revenue softened heading into Q4, a predictable seasonal decline.  
✔ Booking channels and service types showed clear retention patterns.  

---

## 4. Screenshots
<img width="1636" height="1480" alt="Monthly  Revenue % Churn Risk (1)" src="https://github.com/user-attachments/assets/6fff4abd-7208-4ee2-b4f1-9b5dc870416e" />
<img width="1476" height="1480" alt="MOM growth" src="https://github.com/user-attachments/assets/db6a088b-726e-438a-9ac3-431754c7d448" />
<img width="2598" height="1538" alt="Monthly Financial Performance" src="https://github.com/user-attachments/assets/196056b4-fe54-443c-8fa1-2e20796c369b" />

**Tableau Public link:**  
https://public.tableau.com/app/profile/akram.mohammed3381/viz/MonthlyFinancialPerformanceRevenueVsChurnRisk/Dashboard1

---

## 5. Repository Structure

```text
data/
  appointments_anonymized.csv

sql/
  monthly_KPI's.sql

tableau/
  public_link.txt  (contains the Tableau Public URL)

screenshots/
  revenue_vs_churn.png
  mom_growth.png
  executive_dashboard.png

README.md
