-- ============================================================
-- Assignment 05 - Library Borrowing and Returning Management
-- File 4/4: views.sql  (3 VIEWs, covering the whole time range)
-- ============================================================
USE library_mini;

-- ------------------------------------------------------------
-- v_detail: one row per loan registration.
-- LEFT JOIN return_records keeps loans without a return record
-- (their fee is NULL). return_records.loan_id is UNIQUE, so the
-- join never duplicates a loan row.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_detail AS
SELECT l.loan_id,
       l.loan_date,
       l.status,
       r.reader_id,
       r.full_name   AS reader_name,
       c.copy_id,
       c.title       AS book_title,
       g.category_id,
       g.name        AS category_name,
       rr.fine_amount AS fee_amount
FROM loans l
JOIN readers r    ON r.reader_id   = l.reader_id
JOIN copies  c    ON c.copy_id     = l.copy_id
JOIN categories g ON g.category_id = c.category_id
LEFT JOIN return_records rr ON rr.loan_id = l.loan_id;

-- ------------------------------------------------------------
-- v_group_summary: one row per category (categories with no loans
-- are kept). Totals that do not occur are shown as 0 (COALESCE).
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_group_summary AS
SELECT g.category_id,
       g.name AS category_name,
       COUNT(l.loan_id) AS total_loans,
       COALESCE(SUM(CASE WHEN l.status = 'Completed' THEN 1 ELSE 0 END), 0) AS completed_loans,
       COALESCE(SUM(CASE WHEN l.status = 'Cancelled' THEN 1 ELSE 0 END), 0) AS cancelled_loans,
       COALESCE(SUM(rr.fine_amount), 0) AS total_fee
FROM categories g
LEFT JOIN copies c          ON c.category_id = g.category_id
LEFT JOIN loans l           ON l.copy_id = c.copy_id
LEFT JOIN return_records rr ON rr.loan_id = l.loan_id
GROUP BY g.category_id, g.name;

-- ------------------------------------------------------------
-- v_debt: one row per reader.
-- Costs and payments are aggregated SEPARATELY per reader and only
-- then joined, so a cost is never counted twice when a loan has
-- several payments.
-- Debt = total confirmed cost - total money actually collected.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_debt AS
SELECT r.reader_id,
       r.full_name AS reader_name,
       COALESCE(f.total_fee, 0)  AS total_fee,
       COALESCE(p.total_paid, 0) AS total_paid,
       COALESCE(f.total_fee, 0) - COALESCE(p.total_paid, 0) AS balance_due
FROM readers r
LEFT JOIN (
    SELECT l.reader_id, SUM(rr.fine_amount) AS total_fee
    FROM loans l
    JOIN return_records rr ON rr.loan_id = l.loan_id
    GROUP BY l.reader_id
) f ON f.reader_id = r.reader_id
LEFT JOIN (
    SELECT l.reader_id, SUM(pm.amount) AS total_paid
    FROM loans l
    JOIN payments pm ON pm.loan_id = l.loan_id
    GROUP BY l.reader_id
) p ON p.reader_id = r.reader_id;

-- ============================================================
-- Queries to verify the VIEWs
-- ============================================================

-- v_detail: must have 21 rows (same as loans); loans without a return record have fee_amount = NULL
SELECT * FROM v_detail ORDER BY loan_id;
SELECT (SELECT COUNT(*) FROM v_detail) AS view_rows,
       (SELECT COUNT(*) FROM loans)    AS loan_rows;

-- v_group_summary: 5 rows; Children's Books has 1 loan (loan 9, in 2024) and fee 0
-- Expected total_fee: Literature 35000 | Natural Sciences 30000 | IT 37000 | History 8000 | Children's Books 0
SELECT * FROM v_group_summary ORDER BY category_id;
-- The category fee totals must equal the total fine_amount of the table (no double counting)
SELECT (SELECT SUM(total_fee) FROM v_group_summary)   AS sum_in_view,
       (SELECT SUM(fine_amount) FROM return_records) AS sum_in_table;

-- v_debt: 11 rows; debt of reader 3 = 4000, reader 5 = 10000, everyone else = 0
-- (expected totals: cost 110000, paid 96000)
SELECT * FROM v_debt ORDER BY reader_id;
-- Total cost / total paid in the view must match the base tables
SELECT (SELECT SUM(total_fee)  FROM v_debt) AS fee_in_view,
       (SELECT SUM(fine_amount) FROM return_records) AS fee_in_table,
       (SELECT SUM(total_paid) FROM v_debt) AS paid_in_view,
       (SELECT SUM(amount) FROM payments)   AS paid_in_table;
