
-- =============================
-- Query 1: Top 5 Assignments by Total Donation Amount and Donor Type
-- =============================

-- Step 1: Create a CTE (Common Table Expression) to calculate total donation amount
WITH donation_details AS (
    SELECT
        d.assignment_id,
        -- Sum the donation amounts per assignment and donor type, rounded to 2 decimal places
        ROUND(SUM(d.amount), 2) AS rounded_total_donation_amount,
        dn.donor_type
    FROM
        donations d
    -- Join with donors table to get the donor type
    JOIN donors dn ON d.donor_id = dn.donor_id
    -- Grouping by assignment and donor type to get unique totals
    GROUP BY
        d.assignment_id, dn.donor_type
)

-- Step 2: Join with the assignments table to add assignment name and region
SELECT
    a.assignment_name,
    a.region,
    dd.rounded_total_donation_amount,
    dd.donor_type
FROM
    assignments a
-- Join with the previously defined donation_details CTE
JOIN
    donation_details dd ON a.assignment_id = dd.assignment_id
-- Order results by donation amount in descending order
ORDER BY
    dd.rounded_total_donation_amount DESC
-- Limit results to top 5
LIMIT 5;



-- =============================
-- Query 2: Top Assignment per Region by Impact Score (only if donations were made)
-- =============================

-- Step 1: Count the number of donations per assignment
WITH donation_counts AS (
    SELECT
        assignment_id,
        COUNT(donation_id) AS num_total_donations
    FROM
        donations
    GROUP BY
        assignment_id
),

-- Step 2: Join with assignments and assign a rank per region by impact_score
ranked_assignments AS (
    SELECT
        a.assignment_name,
        a.region,
        a.impact_score,
        dc.num_total_donations,
        -- Assign rank per region based on descending impact score
        ROW_NUMBER() OVER (PARTITION BY a.region ORDER BY a.impact_score DESC) AS rank_in_region
    FROM
        assignments a
    -- Join with donation_counts to ensure assignment received donations
    JOIN
        donation_counts dc ON a.assignment_id = dc.assignment_id
    -- Only include assignments that received at least one donation
    WHERE
        dc.num_total_donations > 0
)

-- Step 3: Select only the top-ranked assignment per region
SELECT
    assignment_name,
    region,
    impact_score,
    num_total_donations
FROM
    ranked_assignments
-- Only the assignment ranked #1 per region is included
WHERE
    rank_in_region = 1
-- Sort final output alphabetically by region
ORDER BY
    region ASC;
