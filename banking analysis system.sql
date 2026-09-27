

-- ============================================================
-- Banking Customer Transaction Analytics
-- SQL Analysis Project
-- ============================================================

CREATE DATABASE banking_analysis;

USE banking_analysis;

-- ============================================================
-- DATABASE VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_accounts
FROM accounts;

SELECT COUNT(*) AS total_transactions
FROM transactions;

SELECT COUNT(*) AS total_loans
FROM loans;


-- ============================================================
-- CUSTOMER & ACCOUNT ANALYSIS
-- ============================================================

-- 1. Customer Account Details

SELECT
    c.customer_id,
    c.customer_name,
    a.account_id,
    a.account_type,
    a.balance
FROM customers AS c
INNER JOIN accounts AS a
    ON c.customer_id = a.customer_id;


-- 2. Customer-wise Total Account Balance

SELECT
    c.customer_id,
    c.customer_name,
    SUM(a.balance) AS total_balance
FROM customers AS c
INNER JOIN accounts AS a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;


-- 3. Top 10 Customers by Total Account Balance

SELECT
    c.customer_id,
    c.customer_name,
    SUM(a.balance) AS total_balance
FROM customers AS c
INNER JOIN accounts AS a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_balance DESC
LIMIT 10;


-- 4. Customers with Total Account Balance > ₹5,00,000

SELECT
    c.customer_id,
    c.customer_name,
    SUM(a.balance) AS total_balance
FROM customers AS c
INNER JOIN accounts AS a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING total_balance > 500000;


-- 5. Customers Having More Than One Account

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(a.account_id) AS account_count
FROM customers AS c
INNER JOIN accounts AS a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING account_count > 1;


-- ============================================================
-- TRANSACTION ANALYSIS
-- ============================================================

-- 6. Customer-wise Transaction Count and Total Amount

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_transaction_amount
FROM customers AS c
INNER JOIN accounts AS a
    ON c.customer_id = a.customer_id
INNER JOIN transactions AS t
    ON a.account_id = t.account_id
GROUP BY
    c.customer_id,
    c.customer_name;


-- 7. Top 10 Customers by Transaction Amount

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_transaction_amount
FROM customers AS c
INNER JOIN accounts AS a
    ON c.customer_id = a.customer_id
INNER JOIN transactions AS t
    ON a.account_id = t.account_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_transaction_amount DESC
LIMIT 10;


-- ============================================================
-- LOAN ANALYSIS
-- ============================================================

-- 8. Customer-wise Loan Analysis

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(l.loan_id) AS loan_count,
    SUM(l.loan_amount) AS total_loan_amount
FROM customers AS c
INNER JOIN loans AS l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;


-- 9. Customer-wise and Loan Type-wise Average Loan

SELECT
    c.customer_id,
    c.customer_name,
    l.loan_type,
    AVG(l.loan_amount) AS avg_loan_amount
FROM customers AS c
INNER JOIN loans AS l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.customer_name,
    l.loan_type;


-- 10. Loan Default Analysis

SELECT
    loan_type,
    COUNT(loan_id) AS default_loan_count
FROM loans
WHERE loan_status = 'Default'
GROUP BY loan_type;


-- 11. Loan Amount by Loan Status

SELECT
    loan_status,
    COUNT(loan_id) AS total_loan_count,
    SUM(loan_amount) AS total_loan_amount
FROM loans
GROUP BY loan_status;


-- ============================================================
-- CTE ANALYSIS
-- ============================================================

-- 12. Top 10 Customers by Total Balance Using CTE

WITH customer_balance AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(a.balance) AS total_balance
    FROM customers AS c
    INNER JOIN accounts AS a
        ON c.customer_id = a.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_balance
FROM customer_balance
ORDER BY total_balance DESC
LIMIT 10;


-- 13. Top 10 Customers by Transaction Amount Using CTE

WITH total_transaction_amount AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(t.amount) AS total_amount
    FROM customers AS c
    INNER JOIN accounts AS a
        ON c.customer_id = a.customer_id
    INNER JOIN transactions AS t
        ON a.account_id = t.account_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_amount
FROM total_transaction_amount
ORDER BY total_amount DESC
LIMIT 10;


-- ============================================================
-- WINDOW FUNCTION ANALYSIS
-- ============================================================

-- 14. Rank Loans Using ROW_NUMBER()

SELECT
    loan_id,
    customer_id,
    loan_type,
    loan_amount,
    row_num
FROM (
    SELECT
        loan_id,
        customer_id,
        loan_type,
        loan_amount,
        ROW_NUMBER() OVER (
            PARTITION BY loan_type
            ORDER BY loan_amount DESC
        ) AS row_num
    FROM loans
) AS ranked_loans;


-- 15. Rank Loans Using RANK()

SELECT
    loan_id,
    customer_id,
    loan_type,
    loan_amount,
    loan_rank
FROM (
    SELECT
        loan_id,
        customer_id,
        loan_type,
        loan_amount,
        RANK() OVER (
            PARTITION BY loan_type
            ORDER BY loan_amount DESC
        ) AS loan_rank
    FROM loans
) AS ranked_loans;


-- 16. Rank Loans Using DENSE_RANK()

SELECT
    loan_id,
    customer_id,
    loan_type,
    loan_amount,
    loan_rank
FROM (
    SELECT
        loan_id,
        customer_id,
        loan_type,
        loan_amount,
        DENSE_RANK() OVER (
            PARTITION BY loan_type
            ORDER BY loan_amount DESC
        ) AS loan_rank
    FROM loans
) AS ranked_loans;


-- 17. Compare Loan Amount with Previous Loan Using LAG()

SELECT
    loan_id,
    customer_id,
    loan_type,
    loan_amount,
    previous_loan_amount
FROM (
    SELECT
        loan_id,
        customer_id,
        loan_type,
        loan_amount,
        LAG(loan_amount) OVER (
            PARTITION BY loan_type
            ORDER BY loan_amount DESC
        ) AS previous_loan_amount
    FROM loans
) AS loan_analysis;


-- 18. Compare Loan Amount with Next Loan Using LEAD()

SELECT
    loan_id,
    customer_id,
    loan_type,
    loan_amount,
    next_loan_amount
FROM (
    SELECT
        loan_id,
        customer_id,
        loan_type,
        loan_amount,
        LEAD(loan_amount) OVER (
            PARTITION BY loan_type
            ORDER BY loan_amount DESC
        ) AS next_loan_amount
    FROM loans
) AS loan_analysis;


-- 19. Top 3 Highest-Value Loans by Loan Type
-- Using CTE + RANK()

WITH ranked_loans AS (
    SELECT
        loan_id,
        customer_id,
        loan_type,
        loan_amount,
        RANK() OVER (
            PARTITION BY loan_type
            ORDER BY loan_amount DESC
        ) AS loan_rank
    FROM loans
)
SELECT
    loan_id,
    customer_id,
    loan_type,
    loan_amount,
    loan_rank
FROM ranked_loans
WHERE loan_rank <= 3
ORDER BY
    loan_type,
    loan_rank;