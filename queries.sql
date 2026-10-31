-- ============================================================
-- Assignment 05 - Library Borrowing and Returning Management
-- File 3/4: queries.sql  (10 independent queries)
-- Convention: date ranges use half-open intervals [from, to) so no
-- data is missed.
--   January 2025 : loan_date >= '2025-01-01' AND < '2025-02-01'
--   Q1 2025      : loan_date >= '2025-01-01' AND < '2025-04-01'
--   Year 2025    : loan_date >= '2025-01-01' AND < '2026-01-01'
--   (loan_date is used for loans; payment_date is used for payments)
-- "Confirmed cost" = return_records.fine_amount
-- ============================================================
USE library_mini;

-- ------------------------------------------------------------
-- Query 1. Completed loans in January 2025, with the reader,
--          the book copy and loan_date.
-- Expected: loan 1 (reader 1), loan 5 (reader 2), loan 2 (reader 1)
-- ------------------------------------------------------------
SELECT l.loan_id,
       r.reader_id, r.full_name,
       c.copy_id,   c.title,
       l.loan_date
FROM loans l
JOIN readers r ON r.reader_id = l.reader_id
JOIN copies  c ON c.copy_id   = l.copy_id
WHERE l.status = 'Completed'
  AND l.loan_date >= '2025-01-01' AND l.loan_date < '2025-02-01'
ORDER BY l.loan_date, l.loan_id;

-- ------------------------------------------------------------
-- Query 2. Number of loans per category in Q1/2025 (all statuses),
--          including categories with 0 loans.
-- LEFT JOIN, with the date condition placed in ON (not in WHERE;
-- otherwise categories with 0 loans would be filtered out).
-- Expected: 1 Literature=2 | 2 Natural Sciences=2 (loan 4 + loan 16 on 2025-03-31) |
--           3 IT=4 | 4 History=1 (loan 17 on 2025-04-01 is NOT in Q1) | 5 Children's Books=0
-- ------------------------------------------------------------
SELECT g.category_id,
       g.name,
       COUNT(l.loan_id) AS total_loans
FROM categories g
LEFT JOIN copies c ON c.category_id = g.category_id
LEFT JOIN loans  l ON l.copy_id = c.copy_id
                  AND l.loan_date >= '2025-01-01' AND l.loan_date < '2025-04-01'
GROUP BY g.category_id, g.name
ORDER BY g.category_id;

-- ------------------------------------------------------------
-- Query 3. Readers with at least one loan that has no return record,
--          excluding Cancelled loans; each reader appears once.
-- EXISTS / NOT EXISTS is used, so rows are never duplicated.
-- Expected: reader 3 (loan 11), reader 7 (loan 12), reader 9 (loan 15)
-- ------------------------------------------------------------
SELECT r.reader_id, r.full_name
FROM readers r
WHERE EXISTS (
    SELECT 1
    FROM loans l
    WHERE l.reader_id = r.reader_id
      AND l.status <> 'Cancelled'
      AND NOT EXISTS (SELECT 1 FROM return_records rr WHERE rr.loan_id = l.loan_id)
)
ORDER BY r.reader_id;

-- ------------------------------------------------------------
-- Query 4. Average incurred cost per Completed loan for each category,
--          over all time; only categories that have incurred a cost.
-- "Has incurred a cost" = the category's total fine_amount > 0 (HAVING).
-- The average is still computed over ALL Completed loans of the
-- category, including loans whose fine is 0.
-- A category whose fines are all 0 (e.g. Children's Books) is excluded.
-- Expected: 1=17500.00 | 2=7500.00 | 3=7400.00 | 4=2666.67
--           (Children's Books is not shown)
-- ------------------------------------------------------------
SELECT g.category_id,
       g.name,
       COUNT(*)                       AS completed_loans,
       ROUND(AVG(rr.fine_amount), 2)  AS avg_fine
FROM categories g
JOIN copies c          ON c.category_id = g.category_id
JOIN loans  l          ON l.copy_id = c.copy_id AND l.status = 'Completed'
JOIN return_records rr ON rr.loan_id = l.loan_id
GROUP BY g.category_id, g.name
HAVING SUM(rr.fine_amount) > 0
ORDER BY g.category_id;

-- ------------------------------------------------------------
-- Query 5. Top 3 copies with the most Completed loans in 2025;
--          ties are broken by copy_id ascending; only copies that
--          have loans are listed.
-- Expected: copy 4 (3 loans), copy 2 (2 loans), copy 3 (2 loans)
--           (copy 5 also has 2 loans but loses the tie on copy_id)
-- ------------------------------------------------------------
SELECT c.copy_id,
       c.title,
       COUNT(*) AS completed_loans
FROM copies c
JOIN loans l ON l.copy_id = c.copy_id
WHERE l.status = 'Completed'
  AND l.loan_date >= '2025-01-01' AND l.loan_date < '2026-01-01'
GROUP BY c.copy_id, c.title
ORDER BY completed_loans DESC, c.copy_id ASC
LIMIT 3;

-- ------------------------------------------------------------
-- Query 6. Total amount each reader paid in 2025 (by payment_date);
--          readers who have not paid show 0.
-- The year condition is placed in ON so every reader is kept.
-- Each payment appears only once, so SUM is never double counted.
-- Expected: 1=35000 | 2=5000 | 3=4000 | 4=10000 | 5=0 (paid in 2026) | 6..10=0 | 11=10000
-- ------------------------------------------------------------
SELECT r.reader_id,
       r.full_name,
       COALESCE(SUM(p.amount), 0) AS total_paid_2025
FROM readers r
LEFT JOIN loans l    ON l.reader_id = r.reader_id
LEFT JOIN payments p ON p.loan_id = l.loan_id
                    AND p.payment_date >= '2025-01-01' AND p.payment_date < '2026-01-01'
GROUP BY r.reader_id, r.full_name
ORDER BY r.reader_id;

-- ------------------------------------------------------------
-- Query 7. Readers with no payment record at all (whole data set),
--          including readers who have no loans.
-- Expected: readers 6, 7, 8, 9, 10
-- ------------------------------------------------------------
SELECT r.reader_id, r.full_name
FROM readers r
WHERE NOT EXISTS (
    SELECT 1
    FROM loans l
    JOIN payments p ON p.loan_id = l.loan_id
    WHERE l.reader_id = r.reader_id
)
ORDER BY r.reader_id;

-- ------------------------------------------------------------
-- Query 8. All readers ordered by total confirmed cost, descending
--          (regardless of payment); ties are broken by id ascending.
-- Costs are aggregated per reader BEFORE joining, so payments are not
-- needed and nothing is double counted.
-- Expected: 1=35000, 5=30000, 2=17000, 4=10000, 11=10000 (tie, id ascending),
--           3=8000, then 6,7,8,9,10 = 0
-- ------------------------------------------------------------
SELECT r.reader_id,
       r.full_name,
       COALESCE(f.total_fee, 0) AS total_fee
FROM readers r
LEFT JOIN (
    SELECT l.reader_id, SUM(rr.fine_amount) AS total_fee
    FROM loans l
    JOIN return_records rr ON rr.loan_id = l.loan_id
    GROUP BY l.reader_id
) f ON f.reader_id = r.reader_id
ORDER BY total_fee DESC, r.reader_id ASC;

-- ------------------------------------------------------------
-- Query 9. Cancellation rate of each copy in 2025:
--          Cancelled loans / all loans in the year * 100, rounded to
--          2 decimals; NULL if the total is 0.
-- Expected: copy 1=33.33 | 2=33.33 | 3=0.00 | 4=0.00 (3 loans) | 5=25.00 (4 loans, 1 cancelled) |
--           6=NULL | 7=NULL
-- ------------------------------------------------------------
SELECT c.copy_id,
       c.title,
       COUNT(l.loan_id) AS total_loans_2025,
       SUM(CASE WHEN l.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_loans,
       CASE WHEN COUNT(l.loan_id) = 0 THEN NULL
            ELSE ROUND(SUM(CASE WHEN l.status = 'Cancelled' THEN 1 ELSE 0 END)
                       * 100 / COUNT(l.loan_id), 2)
       END AS cancel_rate_pct
FROM copies c
LEFT JOIN loans l ON l.copy_id = c.copy_id
                 AND l.loan_date >= '2025-01-01' AND l.loan_date < '2026-01-01'
GROUP BY c.copy_id, c.title
ORDER BY c.copy_id;

-- ------------------------------------------------------------
-- Query 10. Readers with MORE THAN 3 Completed loans in 2025, with
--           the count, sorted by count descending.
-- Expected: reader 1 (4 loans). Reader 11 has exactly 3 Completed loans in 2025
--           (plus 2 outside 2025), so it must NOT appear.
-- ------------------------------------------------------------
SELECT r.reader_id,
       r.full_name,
       COUNT(*) AS completed_loans
FROM readers r
JOIN loans l ON l.reader_id = r.reader_id
WHERE l.status = 'Completed'
  AND l.loan_date >= '2025-01-01' AND l.loan_date < '2026-01-01'
GROUP BY r.reader_id, r.full_name
HAVING COUNT(*) > 3
ORDER BY completed_loans DESC, r.reader_id;
