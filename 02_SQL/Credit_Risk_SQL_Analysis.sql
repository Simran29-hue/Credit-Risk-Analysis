/*===========================================================
 Project: Credit Risk Analysis Dashboard

 Description:
 This script performs data type validation and standardization
 for the Credit Risk dataset before importing it into Power BI.

 Author: Simran Singh
 Tools: SQL Server

===========================================================*/

--==========================================
-- View Complete Dataset
--========================================== 
SELECT * FROM credit_risk


/* ==========================================
   Check Column Names and Data Types
   ========================================== */
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'credit_risk';


/* ==========================================
   Convert Numeric Columns to Decimal
   (For accurate calculations and reporting)
   ========================================== */
ALTER TABLE credit_risk
ALTER COLUMN loan_int_rate DECIMAL (5,2);

ALTER TABLE credit_risk
ALTER COLUMN loan_percent_income DECIMAL (5,2);

/* ==========================================
   Verify Updated Data Types
   ========================================== */
SELECT
COLUMN_NAME,
DATA_TYPE,
CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='credit_risk';


/* ==========================================
   Standardize Character Columns
   ========================================== */

-- Loan Grade (A-G)
ALTER TABLE credit_risk
ALTER COLUMN loan_grade char (1)

-- Customer Income Category
ALTER TABLE credit_risk
ALTER COLUMN income_flag VARCHAR(20);

-- Customer Age Category
ALTER TABLE credit_risk
ALTER COLUMN age_flag VARCHAR(20);

-- Risk Classification
ALTER TABLE credit_risk
ALTER COLUMN risk_category VARCHAR(20);

-- Income Band
ALTER TABLE credit_risk
ALTER COLUMN income_band VARCHAR(20);

-- Debt Burden Category
ALTER TABLE credit_risk
ALTER COLUMN debt_burden VARCHAR(20);

-- Default Status Label
ALTER TABLE credit_risk
ALTER COLUMN default_label VARCHAR(20);

-- Repeat Defaulter Status
ALTER TABLE credit_risk
ALTER COLUMN repeat_defaulter VARCHAR(20);

/* ==========================================
   Convert Binary Columns to Integer
   (0 = No, 1 = Yes)
   ========================================== */
ALTER TABLE credit_risk
ALTER COLUMN loan_status INT;

ALTER TABLE credit_risk
ALTER COLUMN cb_person_default_on_file INT;

/*===========================================================
 Business Analysis Queries

 The queries below are used to explore the credit risk dataset
 and answer different business questions. The results helped
 identify customer behavior, loan trends, and default patterns
 for the Power BI dashboard.

===========================================================*/

--=========================================================
-- 1. How many total loan application are in the dataset?
--=========================================================
SELECT COUNT(*) AS Total_Applications
From credit_risk;

--===========================================
-- 2. How many customers have defaulted?
--===========================================
SELECT COUNT(*) AS Total_Defaulters
From credit_risk
WHERE loan_status = 1

--============================================
-- 3. Show all details of customers who took loans for MEDICAL purpose
--============================================
SELECT * FROM credit_risk;

SELECT 
person_age,
person_income,
loan_amnt,
loan_intent,
loan_grade,
loan_status
FROM credit_risk
WHERE loan_intent = 'MEDICAL'
ORDER BY loan_amnt DESC;

--==============================================
-- 4. Show top 10 largest loan amounts taken
--==============================================
SELECT TOP 10
person_age,
person_income,
loan_amnt,
loan_grade,
loan_intent,
default_label
FROM credit_risk
ORDER BY loan_amnt DESC

--================================================
-- 5. How many customers have a previous default history?
--================================================
SELECT 
cb_person_default_on_file AS Previous_default,
count(*) as total_customers
FROM credit_risk
WHERE cb_person_default_on_file = 1
Group BY cb_person_default_on_file

--================================
-- 6. What is the overall default rate across all loans?
--================================
select 
count(*) as Total_Loans,
sum(loan_status) as Total_Defaulter,
count(*) - sum(loan_status) as Total_Non_Defaulter,
CAST (sum(loan_status) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Default_Rate_Pct
from credit_risk

--=================================
-- 7. Which loan grade has the highest default rate?
--=================================
SELECT 
loan_grade,
count(*) as Total_Loans,
sum(loan_status) as Defaulter,
cast (sum(loan_status)*100.0 / count(*) as DECIMAL(5,2)) AS Default_Rate_Pct
FROM credit_risk
GROUP BY loan_grade
ORDER BY Default_Rate_Pct DESC;

--===================================
-- 8. Which loan purpose has the most defaults?
--===================================
SELECT 
loan_intent,
count(*) as Total_Loans,
sum(loan_status) as Defaulter,
cast (sum(loan_status)*100.0 / count(*) as DECIMAL(5,2)) AS Default_Rate_Pct
FROM credit_risk
GROUP BY loan_intent
ORDER BY Default_Rate_Pct DESC;

--=========================================
-- 9. Does home ownership affect deafault rate? (Are renters riskier than homeowners?)
--=========================================
SELECT 
person_home_ownership,
count(*) as Total_Loans,
sum(loan_status) as Defaulter,
cast (sum(loan_status)*100.0 / count(*) as DECIMAL(5,2)) AS Default_Rate_Pct
FROM credit_risk
GROUP BY person_home_ownership
ORDER BY Default_Rate_Pct DESC;

--============================================
-- 10. What is the average loan amount and interest rate for defaulters vs non-defaulters? (Do defaulters borrow more or pay higher interest?)
--============================================
SELECT * FROM credit_risk
SELECT 
default_label,
COUNT(*) AS Total_Customers,
CAST(AVG(loan_amnt) AS DECIMAL (10,2)) AS Avg_loan_amount,
CAST(AVG(loan_int_rate) AS DECIMAL (10,2)) AS Avg_Intereset_Rate,
CAST(AVG(person_income) AS DECIMAL (10,2)) AS Avg_Income
FROM credit_risk
Group by default_label
ORDER BY Avg_loan_amount DESC;

--=============================================
-- 11. Which income band has the highest default rate? (Should low income applicants face stricter checks?)
--=============================================
SELECT
income_band,
COUNT(*) AS Total_loans,
SUM(loan_status) as Defaulters,
CAST(SUM(loan_status)*100.0 / COUNT(*) AS DECIMAL (5,2)) AS Default_prct_rate
FROM credit_risk
Group By income_band
order by Default_prct_rate DESC;

--==============================================
-- 12. How does debt burden relate to defaults? (Is high debt burden a strong predictor of default?)
--==============================================
SELECT
debt_burden,
COUNT(*) AS Total_loans,
SUM(loan_status) as Defaulters,
CAST(SUM(loan_status)*100.0 / COUNT(*) AS DECIMAL (5,2)) AS Default_prct_rate
FROM credit_risk
Group By debt_burden
order by Default_prct_rate DESC;

--================================================
-- 13.  Which age group defaults the most? (Is age a risk factor for loan default?)
--================================================
SELECT
	CASE
		WHEN person_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN person_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN person_age BETWEEN 36 AND 45 THEN '36-45'
		WHEN person_age BETWEEN 46 AND 60 THEN '46-60'
		ELSE '60+'
	END AS Age_Group,
COUNT(*) AS Total_loans,
SUM(loan_status) as Defaulters,
CAST(SUM(loan_status)*100.0 / COUNT(*) AS DECIMAL (5,2)) AS Default_prct_rate
FROM credit_risk
GROUP BY  
	CASE
		WHEN person_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN person_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN person_age BETWEEN 36 AND 45 THEN '36-45'
		WHEN person_age BETWEEN 46 AND 60 THEN '46-60'
		ELSE '60+'
	END
ORDER BY Default_prct_rate DESC;

--======================================
-- 14. Which loan grade + intent combination is riskiest? 
--======================================
SELECT 
loan_grade,
loan_intent,
COUNT(*) AS Total_loans,
SUM(loan_status) as Defaulters,
CAST(SUM(loan_status)*100.0 / COUNT(*) AS DECIMAL (5,2)) AS Default_prct_rate
FROM credit_risk
Group By loan_grade,loan_intent
HAVING COUNT(*)>50
ORDER BY Default_prct_rate DESC

--=====================================
-- 15. How many repeat defaulters exist and what is their profile?
--=====================================
SELECT 
repeat_defaulter,
COUNT(*) AS Total_Count,
CAST(AVG(loan_amnt) AS DECIMAL (10,2)) AS Avg_loan_amount,
CAST(AVG(loan_int_rate) AS DECIMAL (10,2)) AS Avg_Intereset_Rate,
CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk) AS DECIMAL(5,2)) AS Pct_of_Total
FROM credit_risk 
Group by repeat_defaulter
Order By Total_Count DESC;

--==================================
-- 16. Which loan grade is the riskiest — ranked by default rate?
--==================================
SELECT 
loan_grade,
COUNT(*) AS Toal_Loans,
SUM(loan_status) as Defaulter,
Cast(SUM(loan_status) * 100.0/COUNT(*) as DECIMAL(5,2)) AS Default_prct_rate,
RANK() OVER(ORDER BY SUM(loan_status) * 100.0/COUNT(*) DESC) AS Risk_Rate
FROM credit_risk
Group By loan_grade
Order by Risk_Rate;

--====================================
-- 17. How much does interest rate jump between each loan grade?
--====================================
SELECT 
loan_grade,
CAST(AVG(loan_int_rate) AS DECIMAL (5,2)) AS AVG_INT_RATE,
LAG (CAST(AVG(loan_int_rate) AS DECIMAL (5,2))) OVER (ORDER BY loan_grade) as Prev_Grade_Rate,
CAST(AVG(loan_int_rate) AS DECIMAL (5,2)) - LAG (CAST(AVG(loan_int_rate) AS DECIMAL (5,2))) OVER (ORDER BY loan_grade) AS Rate_jump
FROM credit_risk
Group By loan_grade
order by loan_grade

--=====================================
-- 18. What is the default rate across Low, Medium and High risk tiers?
--=====================================
WITH RiskSegments AS (
	SELECT *,
		CASE 
			WHEN loan_grade in ('E','F','G') THEN 'High_Risk'
			WHEN loan_grade in ('C','D') THEN 'Medium_Risk'
			ELSE 'Low_Risk'
		END AS Risk_tier
	FROM credit_risk
)
SELECT 
Risk_tier,
COUNT(*) AS Total_loans,
SUM(loan_status) AS Defaulters,
CAST(SUM(loan_status) * 100.0/ COUNT(*) AS DECIMAL (5,2)) AS Default_prct_rate,
CAST(AVG(loan_amnt) as decimal(10,2)) as AVG_loan_amnt
FROM RiskSegments
GROUP BY Risk_tier
ORDER BY Default_prct_rate DESC

--===================================
--19. Within each loan purpose, which grade defaults the most?
--===================================
SELECT DISTINCT
loan_intent,
loan_grade,
COUNT(*) OVER (PARTITION BY loan_intent,loan_grade) AS Total_loans,
SUM(loan_status) OVER (PARTITION BY loan_intent,loan_grade) AS Defaults,
CAST(SUM(loan_status) OVER (PARTITION BY loan_intent,loan_grade) * 100.0 / 
                       COUNT(*) OVER (PARTITION BY loan_intent,loan_grade) AS Decimal (5,2)) AS Default_pct_rate
FROM credit_risk 
order by loan_intent,Default_pct_rate DESC;

--==================================
-- 20. Which loan purposes have a higher than average default rate?
--==================================
SELECT
loan_intent,
count(*) AS Total_loans,
SUM(loan_status) AS Defaults,
Cast(SUM(loan_status)*100.0/count(*) AS DECIMAL(5,2)) AS Default_prct_rate
FROM credit_risk
Group By loan_intent
HAVING Cast(SUM(loan_status)*100.0/count(*) AS DECIMAL(5,2)) > 
       (select Cast(SUM(loan_status)*100.0/count(*) AS DECIMAL(5,2)) 
	          FROM credit_risk)
order by Default_prct_rate DESC;

--=======================================
-- 21. What is the bank's recommendation for each loan grade?
--=======================================
WITH GradeRisk AS (
SELECT 
loan_grade,
COUNT(*) AS Total_loans,
SUM(loan_status) AS Defaults,
CAST(SUM(loan_status)*100.0/COUNT(*) AS DECIMAL(5,2)) AS Default_prct_rate
FROM credit_risk
Group By loan_grade
),
GradeRanked as (
   SELECT * , 
      Rank() OVER (ORDER BY Default_prct_rate DESC) AS Risk_Rank,
	  CASE
	  WHEN Default_prct_rate >= 30 THEN 'Avoid'
	  WHEN Default_prct_rate >= 15 THEN 'Cautions'
	  ELSE 'Acceptable'
	  END AS Bank_Recommendation
   From GradeRisk
)
SELECT * FROM GradeRanked
ORDER BY Risk_Rank;

--===============================
-- 22. Which income band has the highest default volume vs highest default rate?
--===============================
SELECT
income_band,
COUNT(*) AS Total_Loans,
SUM(loan_status) AS Defaults,
CAST(SUM(loan_status) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Default_Rate_Pct,
RANK() OVER (ORDER BY SUM(loan_status) DESC) AS Rank_By_Volume,
DENSE_RANK() OVER (ORDER BY SUM(loan_status) * 100.0 / COUNT(*) DESC) AS DenseRank_By_Rate
FROM credit_risk
GROUP BY income_band
ORDER BY Rank_By_Volume;

--==================================
-- 23. Divide all customers into 4 risk quartiles based on interest rate
--==================================
SELECT
person_age,
person_income,
loan_amnt,
loan_int_rate,
loan_status,
NTILE(4) OVER (ORDER BY loan_int_rate DESC) AS Risk_Quartile
FROM credit_risk
ORDER BY Risk_Quartile, loan_int_rate DESC;

--================================
-- 24. Who are the top 10 highest risk individual loan accounts?
--================================
WITH RankedLoans AS (
    SELECT
      person_age,
      person_income,
      loan_grade,
      loan_amnt,
      loan_int_rate,
      loan_percent_income,
      repeat_defaulter,
      loan_status,
      ROW_NUMBER() OVER (ORDER BY loan_int_rate DESC, loan_amnt DESC) AS Row_Num
    FROM credit_risk
    WHERE loan_status = 1
)
SELECT * FROM RankedLoans
WHERE Row_Num <= 10;