
# 💸 Donation & Assignment Analysis – Donor Trends & Regional Insights

This project explores how donation behaviors and regional dynamics influence assignment performance. Using SQL queries, we extract the top-funded initiatives, analyze donor types, and determine the highest-impact assignments per region based on engagement.

---

## 📌 Project Objectives

- Identify the **top 5 assignments** that received the **highest donation amounts**, segmented by donor type  
- Highlight the **most impactful assignment per region** based on `impact_score`, only including those with **actual donation activity**  
- Leverage **window functions** to perform intra-region ranking  

---

## 📁 Data Source

Relational database tables representing donation and assignment ecosystems:

- `assignments`: Assignment metadata including name, region, and impact score  
- `donations`: Individual donation records with donor reference and assignment target  
- `donors`: Donor profile including donor type (`individual`, `corporate`, etc.)  

---

## 🔍 Key Features & SQL Queries

### 💰 1. Top-Funded Assignments  
**Query Name**: `highest_donation_assignments`

- Aggregates total donation amount per `assignment_id` and `donor_type`  
- Uses a **CTE** to group and round total donation values  
- Joins with `assignments` to retrieve `assignment_name` and `region`  
- Sorted by total donation descending  
- **Limits results to top 5 records**

```sql
WITH donation_details AS (
    SELECT
        d.assignment_id,
        ROUND(SUM(d.amount), 2) AS rounded_total_donation_amount,
        dn.donor_type
    FROM
        donations d
    JOIN donors dn ON d.donor_id = dn.donor_id
    GROUP BY
        d.assignment_id, dn.donor_type
)
SELECT
    a.assignment_name,
    a.region,
    dd.rounded_total_donation_amount,
    dd.donor_type
FROM
    assignments a
JOIN
    donation_details dd ON a.assignment_id = dd.assignment_id
ORDER BY
    dd.rounded_total_donation_amount DESC
LIMIT 5;
```

---

### 🌍 2. Top Assignments per Region by Impact  
**Query Name**: `top_regional_assignments`

- Filters to assignments that have received **at least one donation**  
- Uses a **CTE** to count total donations per assignment  
- Applies a **window function** (`ROW_NUMBER`) to rank assignments **within each region** by `impact_score`  
- Returns only the **top-ranked (rank = 1)** assignment per region  
- Ordered alphabetically by region

```sql
WITH donation_counts AS (
    SELECT
        assignment_id,
        COUNT(donation_id) AS num_total_donations
    FROM
        donations
    GROUP BY
        assignment_id
),
ranked_assignments AS (
    SELECT
        a.assignment_name,
        a.region,
        a.impact_score,
        dc.num_total_donations,
        ROW_NUMBER() OVER (PARTITION BY a.region ORDER BY a.impact_score DESC) AS rank_in_region
    FROM
        assignments a
    JOIN
        donation_counts dc ON a.assignment_id = dc.assignment_id
    WHERE
        dc.num_total_donations > 0
)
SELECT
    assignment_name,
    region,
    impact_score,
    num_total_donations
FROM
    ranked_assignments
WHERE
    rank_in_region = 1
ORDER BY
    region ASC;
```

---

## 📊 Sample Insights

- 💸 **Top-funded assignments** show a strong skew toward specific donor types (e.g., corporate donors funding high-visibility projects)  
- 🌍 In each region, **only the assignment with the highest impact score and real donations** is highlighted  
- 🔍 Enables nonprofits to **target high-impact regions** and **understand donor behavior**  

---

## 💻 Tech Stack

- **SQL** (PostgreSQL / MySQL) – Core analytics, joins, aggregations, and window functions  
- **Database Tables** – Assumes clean, normalized tables: `donations`, `donors`, `assignments`  
- **Optional Dashboards** – Power BI, Metabase, or Tableau for visualization  

---

## 🧠 Why This Project?

Understanding the distribution and impact of donations is crucial for optimizing fundraising strategies and operational focus. This analysis simulates nonprofit data intelligence to:

- Highlight where **funding is most effective**  
- Tailor **donor engagement** strategies by type and region  
- Inform future **assignment planning and prioritization**

