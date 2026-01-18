-- ranking  the spending by member . 

SELECT 
    c.member_id,
    SUM(c.paid_amount) AS total_paid,
    ROW_NUMBER() OVER (ORDER BY SUM(c.paid_amount) DESC) AS spend_rank
FROM claims c

GROUP BY c.member_id
ORDER BY total_paid DESC
limit 10;






-- Claim Type Cost Breakdown with Ranking
SELECT 
    claim_type,
    COUNT(claim_id) AS number_of_claims,
    SUM(billed_amount) AS total_billed_amount,
    SUM(paid_amount) AS total_paid_amount,
    AVG(billed_amount) AS avg_billed_amount,
    AVG(paid_amount) AS avg_paid_amount,
    ROUND(SUM(paid_amount) * 100.0 / SUM(billed_amount), 2) AS payment_rate_percentage,
    RANK() OVER (ORDER BY SUM(paid_amount) DESC) AS cost_rank
FROM 
    claims
GROUP BY 
    claim_type
ORDER BY 
    total_paid_amount DESC;

-- Top 10 Most Expensive CPT Codes
SELECT 
    cpt_code,
    COUNT(claim_id) AS claim_count,
    SUM(billed_amount) AS total_billed_amount,
    SUM(paid_amount) AS total_paid_amount,
    ROUND(AVG(paid_amount), 2) AS avg_paid_per_claim,
    ROUND(SUM(paid_amount) * 100.0 / NULLIF(SUM(billed_amount), 0), 2) AS payment_rate_percentage
FROM 
    claims
WHERE 
    cpt_code IS NOT NULL
GROUP BY 
    cpt_code
ORDER BY 
    total_paid_amount DESC
LIMIT 10;




 -- Top 10 Most Expensive ICD Codes (Diagnoses)
SELECT 
    icd_code,
    COUNT(claim_id) AS claim_count,
    SUM(billed_amount) AS total_billed_amount,
    SUM(paid_amount) AS total_paid_amount,
    ROUND(AVG(paid_amount), 2) AS avg_paid_per_claim,
    ROUND(SUM(paid_amount) * 100.0 / NULLIF(SUM(billed_amount), 0), 2) AS payment_rate_percentage
FROM 
    claims
WHERE 
    icd_code IS NOT NULL
GROUP BY 
    icd_code
ORDER BY 
    total_paid_amount DESC
LIMIT 10;




-- Total Cost Per Member
SELECT 
    m.member_id,
    m.member_age,
    m.member_gender,
    m.plan_type,
    COUNT(c.claim_id) AS total_claims,
    SUM(c.billed_amount) AS total_billed,
    SUM(c.paid_amount) AS total_paid,
    ROUND(AVG(c.paid_amount), 2) AS avg_paid_per_claim,
    ROUND(SUM(c.paid_amount) / NULLIF(COUNT(c.claim_id), 0), 2) AS avg_cost_per_claim
FROM 
    members m
INNER JOIN 
    claims c ON m.member_id = c.member_id
GROUP BY 
    m.member_id, 
    m.member_age, 
    m.member_gender, 
    m.plan_type
ORDER BY 
    total_paid DESC
    limit 10 ;
    
    
    
    
-- Payment Ratio Analysis by Claim Type
SELECT 
    claim_type,
    COUNT(claim_id) AS total_claims,
    SUM(billed_amount) AS total_billed,
    SUM(paid_amount) AS total_paid,
    SUM(billed_amount - paid_amount) AS total_denied,
    
                                  -- Average paid ratio
    ROUND(AVG(paid_amount / NULLIF(billed_amount, 0)), 4) AS avg_paid_ratio,
    
                                   -- Aggregate paid ratio
    ROUND(SUM(paid_amount) / NULLIF(SUM(billed_amount), 0), 4) AS aggregate_paid_ratio,
    
                                       -- Min and Max ratios
    ROUND(MIN(paid_amount / NULLIF(billed_amount, 0)), 4) AS min_paid_ratio,
    ROUND(MAX(paid_amount / NULLIF(billed_amount, 0)), 4) AS max_paid_ratio,
    
                                       -- Fully denied claims
    COUNT(CASE WHEN paid_amount = 0 THEN 1 END) AS fully_denied_claims,
    ROUND(COUNT(CASE WHEN paid_amount = 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS denial_rate_percentage,
    
                                        -- Fully paid claims
    COUNT(CASE WHEN paid_amount = billed_amount THEN 1 END) AS fully_paid_claims,
    ROUND(COUNT(CASE WHEN paid_amount = billed_amount THEN 1 END) * 100.0 / COUNT(*), 2) AS full_payment_rate_percentage,
    
                                      -- Partial payment claims
    COUNT(CASE WHEN paid_amount > 0 AND paid_amount < billed_amount THEN 1 END) AS partial_payment_claims
FROM 
    claims
WHERE 
    billed_amount > 0
GROUP BY 
    claim_type
ORDER BY 
    avg_paid_ratio ASC;
    
    
    
       -- Payment Ratio Analysis by Provider (Top 20 by volume)
WITH provider_metrics AS (
    SELECT 
        provider_id,
        COUNT(claim_id) AS total_claims,
        SUM(billed_amount) AS total_billed,
        SUM(paid_amount) AS total_paid,
        SUM(billed_amount - paid_amount) AS total_denied,
        ROUND(AVG(paid_amount / NULLIF(billed_amount, 0)), 4) AS avg_paid_ratio,
        ROUND(SUM(paid_amount) / NULLIF(SUM(billed_amount), 0), 4) AS aggregate_paid_ratio,
        COUNT(CASE WHEN paid_amount = 0 THEN 1 END) AS fully_denied_claims,
        COUNT(CASE WHEN paid_amount = billed_amount THEN 1 END) AS fully_paid_claims
    FROM 
        claims
    WHERE 
        billed_amount > 0
    GROUP BY 
        provider_id
)
SELECT 
    provider_id,
    total_claims,
    total_billed,
    total_paid,
    total_denied,
    avg_paid_ratio,
    aggregate_paid_ratio,
    ROUND(fully_denied_claims * 100.0 / total_claims, 2) AS denial_rate_percentage,
    ROUND(fully_paid_claims * 100.0 / total_claims, 2) AS full_payment_rate_percentage,
    CASE 
        WHEN avg_paid_ratio < 0.70 THEN 'Low Payment (<70%)'
        WHEN avg_paid_ratio < 0.85 THEN 'Medium Payment (70-85%)'
        WHEN avg_paid_ratio < 0.95 THEN 'High Payment (85-95%)'
        ELSE 'Very High Payment (95%+)'
    END AS payment_category
FROM 
    provider_metrics
WHERE 
    total_claims >= 10  -- Minimum 10 claims for significance
ORDER BY 
    avg_paid_ratio ASC
LIMIT 10;


-- Payment Ratio Analysis by CPT Code (Top 30)
WITH cpt_metrics AS (
    SELECT 
        cpt_code,
        COUNT(claim_id) AS total_claims,
        SUM(billed_amount) AS total_billed,
        SUM(paid_amount) AS total_paid,
        SUM(billed_amount - paid_amount) AS total_denied,
        ROUND(AVG(paid_amount / NULLIF(billed_amount, 0)), 4) AS avg_paid_ratio,
        ROUND(SUM(paid_amount) / NULLIF(SUM(billed_amount), 0), 4) AS aggregate_paid_ratio,
        ROUND(STDDEV(paid_amount / NULLIF(billed_amount, 0)), 4) AS std_dev_ratio,
        COUNT(CASE WHEN paid_amount = 0 THEN 1 END) AS fully_denied_claims
    FROM 
        claims
    WHERE 
        billed_amount > 0
        AND cpt_code IS NOT NULL
    GROUP BY 
        cpt_code
)
SELECT 
    cpt_code,
    total_claims,
    total_billed,
    total_paid,
    total_denied,
    avg_paid_ratio,
    aggregate_paid_ratio,
    std_dev_ratio,
    ROUND(fully_denied_claims * 100.0 / total_claims, 2) AS denial_rate_percentage,
    CASE 
        WHEN avg_paid_ratio < 0.60 THEN 'Very Low (<60%)'
        WHEN avg_paid_ratio < 0.75 THEN 'Low (60-75%)'
        WHEN avg_paid_ratio < 0.90 THEN 'Medium (75-90%)'
        WHEN avg_paid_ratio < 0.98 THEN 'High (90-98%)'
        ELSE 'Very High (98%+)'
    END AS payment_category,
    RANK() OVER (ORDER BY avg_paid_ratio ASC) AS low_payment_rank,
    RANK() OVER (ORDER BY avg_paid_ratio DESC) AS high_payment_rank
FROM 
    cpt_metrics
WHERE 
    total_claims >= 5  -- Minimum 5 claims for significance
ORDER BY 
    avg_paid_ratio ASC
LIMIT 10;
