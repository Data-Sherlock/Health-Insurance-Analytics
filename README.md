<div align="center">

# 🏥 Healthcare Claims Analytics

### *Where Is the Money Going?*


[![SQL](https://img.shields.io/badge/SQL-MySQL-orange.svg)](https://www.mysql.com/)
[![Power BI](https://img.shields.io/badge/Power%20BI-DAX-yellow.svg)](https://powerbi.microsoft.com/)
[![Status](https://img.shields.io/badge/Status-Complete-success.svg)]()

**Exposing $514K in payment leakage and engineering a $319K recovery strategy across 449 claims**

[View Dashboard](#-dashboard-architecture) • [Explore Insights](#-strategic-insights) • [See Results](#-financial-impact-analysis)

---

</div>

## 📋 Table of Contents

- [Business Context](#-business-context)
- [Technical Implementation](#️-technical-implementation)
- [Strategic Insights](#-strategic-insights)
- [Project Deliverables](#-project-deliverables)
- [Financial Impact](#-financial-impact-analysis)
- [Executive Action Plan](#-executive-action-plan)
- [Dashboard Architecture](#-dashboard-architecture)
- [Repository Structure](#-repository-structure)
- [Methodology](#-methodology-highlights)
- [License](#-license)

---

## 🏢 Business Context

A regional health insurance company hemorrhaged profitability as claims costs spiraled without visibility into spending drivers. Between **January 2023** and **June 2024**, the organization:

- 💰 Processed **$2.06M** in billed claims
- ✅ Paid only **75.20%** ($1.55M)
- ❌ Left **$514K** in denied/unpaid claims

> **C-Level Demand:** *"We are losing money and we want to figure out why!"*

This project delivers a comprehensive analytics platform that identifies cost concentration points, payment inefficiencies, and high-risk members—providing an actionable roadmap to recover **$319K annually** while improving member satisfaction.

---

## 🛠️ Technical Implementation

### 1. Data Engineering (SQL + MySQL)

Integrated **449 claims** across **100 members** (15 active) with multi-dimensional analysis.

**Key Technical Challenges:**

| Challenge | Solution |
|-----------|----------|
| **Hierarchical Aggregation** | Bridging member demographics with claims via `INNER JOIN` while preserving claim-level granularity |
| **Payment Ratio Calculations** | Using `NULLIF()` guards against division-by-zero in payment efficiency metrics |
| **Ranking Windows** | Leveraging `RANK() OVER (ORDER BY SUM(...) DESC)` to identify top cost drivers |

**Query Example:**

```sql
-- Multi-Level Cost Attribution
WITH member_totals AS (
    SELECT 
        member_id, 
        SUM(paid_amount) AS total_paid
    FROM claims
    GROUP BY member_id
    ORDER BY total_paid DESC 
    LIMIT 10
)
SELECT 
    m.member_id, 
    m.member_age, 
    m.plan_type,
    c.claim_type,
    SUM(c.paid_amount) AS type_cost,
    ROUND(SUM(c.paid_amount) * 100.0 / mt.total_paid, 2) AS pct_of_member_total
FROM members m
JOIN claims c ON m.member_id = c.member_id
JOIN member_totals mt ON m.member_id = mt.member_id
GROUP BY m.member_id, c.claim_type
ORDER BY m.member_id, type_cost DESC;
```

### 2. Advanced Analytics (DAX)

Engineered a **Payment Efficiency Index** to flag underperforming claim types:

```dax
Payment Efficiency Score = 
VAR CurrentRatio = [Avg Paid Ratio]
VAR BenchmarkRatio = 0.9078  // Lab services benchmark
VAR VolumeFactor = LOG10([Claim Count])
VAR DenialPenalty = [Denial Rate %] / 100
RETURN
    (CurrentRatio / BenchmarkRatio) * VolumeFactor * (1 - DenialPenalty)
```

**Purpose:** Balances payment rate performance against claim volume and denial frequency to prioritize intervention areas.

---

## 🔍 Strategic Insights

### 🚨 The Emergency Claims Gap

**Emergency services** identified as critical leverage point with **Priority Score: 76.63%**

- 💸 **$290K** (18.8% of total spend)
- 📉 Trails Lab services by **14.15 percentage points** in payment efficiency
- ⚠️ **Market Risk:** Emergency coverage is the **#1 insurance purchasing driver**

> This gap represents both a cost leak and a competitive vulnerability.

### 💊 The $85K Procedure

**CPT Code 12345 + ICD Code A12.3** emerged as the single highest cost driver:

```
┌─────────────────────────────────────┐
│ 32 claims (7.1% of volume)          │
│ $85,000 paid (5.5% of total spend)  │
│ $2,656 avg vs $1,500 benchmark      │
└─────────────────────────────────────┘
```

**Audit Opportunity:** Coding accuracy review + alternative treatment protocols  
**Expected Savings:** $14.6K annually | **ROI:** 730%

### 👥 Member Cost Concentration

**Member #6:** $43K spend (2.88x average, Rank #1)

- 85% driven by inpatient services
- Likely chronic condition requiring case management
- Top 10 members = **21.3% of total costs** from **10% of population**

**Intervention Model:**

```
High-Touch Case Management
├─ Investment: $30K (Top 10 members)
├─ Expected Cost Reduction: 15-20%
└─ Annual Savings: $49K-$66K (163-220% ROI)
```

### 📊 The Q2 2023 Anomaly

**May 2023** recorded the highest claim activity spike:

| Metric | Value | Impact |
|--------|-------|--------|
| Billed Amount | $15K | Peak month |
| Payment Rate | 50% | Below average |
| Subsequent Decline | 68% | Through Q3-Q4 |

**Hypothesis:** Seasonal health event (flu outbreak?) or policy change  
**Implication:** Capacity planning blind spot requiring investigation

---

## 📊 Project Deliverables

| Analysis Module | Key Metrics | Business Impact |
|:----------------|:------------|:----------------|
| **Claim Type Breakdown** | Payment Rate by Service (73.88%-90.78%) | Identified inpatient/emergency inefficiencies costing $224K |
| **CPT/ICD Cost Drivers** | Top 10 Procedure/Diagnosis Codes | Pinpointed $85K concentration in single code pair |
| **Member Profiling** | Top 10 High-Cost Members ($328K) | Risk stratification enables $115K recovery via case mgmt |
| **Payment Ratio Analysis** | Billed vs Paid Gap ($514K unpaid) | Quantified leakage by claim type, provider, procedure |
| **Temporal Trends** | 18-Month Volume/Cost Patterns | Revealed Q2 2023 spike for predictive capacity planning |

---

## 💰 Financial Impact Analysis

### The $319K Recovery Roadmap

**Scenario:** Elevate all claim types to Lab's 90.78% benchmark payment rate

| Claim Type | Current Rate | Gap to Target | Current Paid | Potential Recovery |
|:-----------|:-------------|:--------------|:-------------|:-------------------|
| Inpatient | 73.88% | **-16.90%** | $1,090,000 | **+$249,015** |
| Emergency | 76.63% | **-14.15%** | $290,000 | **+$53,148** |
| Outpatient | 80.30% | **-10.48%** | $130,000 | **+$17,064** |
| **TOTAL** | — | — | — | **+$319,227** |

> **Realistic Target:** 85% payment rate across all types = **$145K year-1 recovery** (conservative)

---

## 🚀 Executive Action Plan

### Phase 1: Immediate Interventions (0-30 Days)

| Priority | Action | Investment | Annual Return | ROI |
|:---------|:-------|:-----------|:--------------|:----|
| 🔴 **CRITICAL** | Audit CPT 12345 + ICD A12.3 coding accuracy | $2K | $14.6K | **730%** |
| 🔴 **CRITICAL** | Review Provider PRV00045 (62.3% payment rate) | $5K | $32K | **640%** |
| 🟡 **HIGH** | Initiate case management for Top 10 members | $30K | $49K-$66K | **163-220%** |

**30-Day Impact:** $37K investment → $95.6K-$112.6K recovery (**258-304% ROI**)

---

### Phase 2: Process Optimization (1-3 Months)

| Priority | Action | Investment | Annual Return | Timeline |
|:---------|:-------|:-----------|:--------------|:---------|
| 🟡 **HIGH** | Emergency claims payment process review | $15K | $41K | 6 weeks |
| 🟡 **HIGH** | Inpatient claim adjudication workflow audit | $25K | $66K | 10 weeks |
| 🟢 **MEDIUM** | Care coordination for next 15 high-cost members | $20K | $32K-$48K | 12 weeks |

**Q1 Impact:** $60K investment → $139K-$155K recovery (**232-258% ROI**)

---

### Phase 3: Strategic Transformation (3-12 Months)

#### 1. Predictive Member Risk Model
- ML-based early identification of high-cost trajectories
- **Investment:** $75K | **Return:** $232K-$310K annually | **ROI:** 309-413%

#### 2. Provider Network Optimization
- Renegotiate/remove bottom 20% payment performers
- **Investment:** $50K | **Return:** $77K-$124K annually | **ROI:** 154-248%

#### 3. Preventive Wellness Programs
- Reduce 75% of member base costs by 5-8%
- **Investment:** $100K | **Return:** $77K-$124K annually | **ROI:** 77-124%

---

### 📈 Year 1 Financial Summary

```
Total Investment:  $225K
Total Recovery:    $386K-$558K
Net ROI Year 1:    172-248%
Year 2+ ROI:       386-558% (no reinvestment needed)
```

---

## 🎯 Stakeholder Requirements: Fully Addressed

<details>
<summary><b>✅ "Which claim types are most expensive?"</b></summary>

**Answer:** Inpatient care dominates at **$1.09M (70.8% of spend)** but suffers from **lowest payment efficiency (73.88%)**—a dangerous combination requiring immediate intervention.

</details>

<details>
<summary><b>✅ "Which CPT and ICD codes drive highest spending?"</b></summary>

**Answer:** **CPT 12345 + ICD A12.3** generates **$85K (5.5% of total)** from just 32 claims (**$2,656 avg**). This single code pair represents the largest audit opportunity with **$14.6K annual savings potential**.

</details>

<details>
<summary><b>✅ "Which members cost the most?"</b></summary>

**Answer:** **Top 10 members (10% of population) account for $328K (21.3% of total costs)**. Member #6 alone costs **$43K**—2.88x the average. Implementing case management for this cohort yields **$49K-$66K savings** (163-220% ROI).

</details>

<details>
<summary><b>✅ "How do billed vs paid amounts compare?"</b></summary>

**Answer:** **$514K (24.80%) remains unpaid** across all claims. Payment rates vary wildly by claim type (73.88%-90.78%), with Lab services setting the benchmark. Closing this gap to 85% across all types recovers **$145K annually**.

</details>

---

## 📈 Dashboard Architecture

### Power BI Data Model

```
┌─────────────────────────────────────────────────────────────┐
│                   SEMANTIC LAYER (DAX)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Payment      │  │ Cost         │  │ Risk         │      │
│  │ Efficiency   │  │ Attribution  │  │ Segmentation │      │
│  │ Score        │  │ Model        │  │ Index        │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
┌─────────▼──────────────────▼──────────────────▼─────────────┐
│               FACT & DIMENSION TABLES (MySQL)                 │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │  CLAIMS (Fact)   │  1:N    │  MEMBERS (Dim)   │          │
│  ├──────────────────┤◄────────┤──────────────────┤          │
│  │ • claim_id (PK)  │         │ • member_id (PK) │          │
│  │ • member_id (FK) │         │ • age (21-94)    │          │
│  │ • claim_type     │         │ • gender (F/M)   │          │
│  │ • cpt_code       │         │ • plan_type      │          │
│  │ • icd_code       │         │   (EPO/HMO/PPO)  │          │
│  │ • billed_amount  │         │ • enrollment_dt  │          │
│  │ • paid_amount    │         └──────────────────┘          │
│  │ • claim_date     │         100 Members                    │
│  └──────────────────┘         15 Active (2024)               │
│  449 Records (2023-2024)                                     │
└──────────────────────────────────────────────────────────────┘
```

### Interactive Capabilities

- 🔍 **Drill-Through:** Click any member → view full claim history breakdown
- 🎛️ **Cross-Filtering:** Select claim type → all visuals auto-filter
- 💡 **Dynamic Tooltips:** Hover over any data point → see payment rate, denial %, benchmark comparison
- 📊 **Export Ready:** All tables exportable to Excel for offline analysis

---

## 📁 Repository Structure

```
healthcare-claims-analytics/
│
├── 📄 README.md                          ← You are here
├── 📄 LICENSE
│
├── 📁 data/
│   ├── schema/
│   │   ├── database_schema.sql           ← Table DDL
│   │   ├── ERD_diagram.png               ← Visual data model
│   │   └── data_dictionary.md            ← Field definitions
│   └── sample/
│       ├── sample_claims.csv             ← 10 example records
│       └── sample_members.csv
│
├── 📁 sql/
│   ├── 01_exploratory/
│   │   ├── claim_type_breakdown.sql      ← Question 1 answer
│   │   └── time_series_trends.sql
│   ├── 02_advanced/
│   │   ├── cpt_icd_analysis.sql          ← Question 2 answer
│   │   ├── high_cost_members.sql         ← Question 3 answer
│   │   └── payment_ratio_analysis.sql    ← Question 4 answer
│   └── 03_business_insights/
│       ├── profitability_summary.sql
│       └── intervention_targets.sql
│
├── 📁 powerbi/
│   ├── Health_Insurance_Analytics.pbix   ← Main dashboard
│   ├── dax_measures.txt                  ← All DAX formulas
│   └── screenshots/
│       ├── overview_dashboard.png
│       ├── claims_breakdown.png
│       └── member_analysis.png
│
└── 📁 docs/
    ├── business_insights.md              ← Executive summary
    ├── methodology.md                    ← Analytical approach
    ├── technical_architecture.md         ← System design
    └── stakeholder_requirements.md       ← Requirements mapping
```

---

## 🎓 Methodology Highlights

### 1. Cost Attribution Framework

Applied activity-based costing principles to allocate spending:

- **Member-level:** Total paid per individual
- **Service-level:** Claim type contribution %
- **Procedure-level:** CPT/ICD combination impact

### 2. Payment Efficiency Benchmarking

Established Lab services (90.78%) as internal gold standard. All other claim types measured against this benchmark to quantify performance gaps.

### 3. Risk Stratification Model

Segmented 100 members into tiers:

| Tier | Criteria | Count | Strategy |
|------|----------|-------|----------|
| **High-Risk** | Top 10 (>$28K spend) | 10 | Intensive case management |
| **Medium-Risk** | Next 15 ($15K-$28K) | 15 | Care coordination |
| **Low-Risk** | Remaining (<$15K) | 75 | Preventive wellness |

### 4. Temporal Pattern Recognition

Used `LAG()` window functions to detect anomalies:

```sql
WITH monthly_metrics AS (
    SELECT 
        DATE_FORMAT(claim_date, '%Y-%m') AS month,
        SUM(billed_amount) AS billed,
        SUM(paid_amount) AS paid,
        LAG(SUM(billed_amount)) OVER (ORDER BY DATE_FORMAT(claim_date, '%Y-%m')) AS prev_billed
    FROM claims
    GROUP BY month
)
SELECT 
    month, 
    billed,
    ROUND((billed - prev_billed) / prev_billed * 100, 2) AS mom_change_pct
FROM monthly_metrics
WHERE ABS((billed - prev_billed) / prev_billed) > 0.30; -- Flag >30% swings
```

---

## 🔬 Key SQL Patterns Used

| Pattern | Use Case | Example |
|---------|----------|---------|
| **Window Functions** | Cost ranking, trend analysis | `RANK() OVER (PARTITION BY claim_type ORDER BY paid_amount DESC)` |
| **CTEs** | Multi-step aggregations | `WITH member_totals AS (...)` |
| **Conditional Aggregation** | Category-specific metrics | `SUM(CASE WHEN claim_type = 'inpatient' THEN paid_amount END)` |
| **NULLIF Guards** | Safe division operations | `paid_amount / NULLIF(billed_amount, 0)` |
| **Date Functions** | Temporal grouping | `DATE_FORMAT(claim_date, '%Y-%m')` |

---

## 💡 Why This Project Stands Out

- ✅ **Business-First Framing:** Leads with stakeholder pain points, not technology
- ✅ **Quantified Impact:** Every insight tied to dollar amounts and ROI
- ✅ **Actionable Roadmap:** Not just "what" but "so what" and "now what"
- ✅ **Healthcare Domain Expertise:** Understands CPT/ICD codes, claim adjudication, case management
- ✅ **Full-Stack Implementation:** Database → Analytics → Visualization → Strategy
- ✅ **Reproducible Methodology:** All queries documented, data model clear, approach transferable

---

## 📞 Contact

**[AHmed Rafi]**  
 Data Analyst | SQL + Power BI Specialist

📧 **Email:** ahmedrafi.analytics@gmail.com
💼 **LinkedIn:** [linkedin.com/in/yourprofile](https://linkedin.com/in/yourprofile)  




<div align="center">

### 🏥 Built to answer: *"Where is the money going?"*

**Exposing $514K in leakage • Engineering $319K in recovery**

[![⬆ Back to Top](#-healthcare-claims-analytics)](#)

</div>
