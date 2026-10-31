-- ============================================================
-- Assignment 05 - Library Borrowing and Returning Management
-- File 2/4: seed.sql  (sample data + data verification queries)
-- Run after schema.sql. All data is fictional, not real personal data.
-- ============================================================
USE library_mini;

-- ------------------------------------------------------------
-- 1. categories (5)
--    Category 5 (Children's Books) has no loan in Q1/2025
-- ------------------------------------------------------------
INSERT INTO categories (category_id, name) VALUES
(1, 'Literature'),
(2, 'Natural Sciences'),
(3, 'Information Technology'),
(4, 'History'),
(5, 'Children''s Books');

-- ------------------------------------------------------------
-- 2. copies (7)
--    copy 6: only loaned in 2024      -> no loan in 2025
--    copy 7: never loaned
-- ------------------------------------------------------------
INSERT INTO copies (copy_id, title, author, barcode, category_id) VALUES
(1, 'Selected Short Stories',          'Nguyen Minh Anh', 'BC-0001', 1),
(2, 'Database Fundamentals',           'Tran Quoc Bao',   'BC-0002', 3),
(3, 'Introduction to Python',          'Le Thu Ha',       'BC-0003', 3),
(4, 'General Physics',                 'Pham Gia Huy',    'BC-0004', 2),
(5, 'Modern History of Vietnam',       'Do Thanh Tung',   'BC-0005', 4),
(6, 'Illustrated Children''s Stories', 'Vu Ngoc Lan',     'BC-0006', 5),
(7, 'General Chemistry',               'Hoang Duc Long',  'BC-0007', 2);

-- ------------------------------------------------------------
-- 3. readers (11)
--    readers 1 and 6 share the same name, to show why queries must
--    return an identifier next to the name
--    reader 10: has no loan at all
--    reader 11: exactly 3 Completed loans in 2025 (not > 3), plus Completed
--               loans on boundary dates; ties with reader 4 on total cost
-- ------------------------------------------------------------
INSERT INTO readers (reader_id, full_name, dob, phone) VALUES
(1,  'Nguyen Van An',  '2000-03-15', '0900000001'),
(2,  'Tran Thi Binh',  '1999-07-22', '0900000002'),
(3,  'Le Hoang Cuong', '2001-11-05', '0900000003'),
(4,  'Pham Thu Dung',  '2002-01-30', '0900000004'),
(5,  'Hoang Minh Duc', '1998-09-12', '0900000005'),
(6,  'Nguyen Van An',  '2003-05-18', '0900000006'),
(7,  'Do Thi Ha',      '2000-12-02', '0900000007'),
(8,  'Bui Quang Huy',  '1997-04-27', '0900000008'),
(9,  'Vu Thanh Lan',   '2001-08-09', '0900000009'),
(10, 'Ngo Gia Khanh',  '2004-06-14', '0900000010'),
(11, 'Dang Quoc Khanh', '1996-10-03', '0900000011');

-- ------------------------------------------------------------
-- 4. loans (21): 15 Completed, 2 Pending, 1 Active, 3 Cancelled
--    Completed: 1-10, 16-20 | Pending: 11, 15 | Active: 12 | Cancelled: 13, 14, 21
--    Loans 16-21 are extra test data (boundary dates, exactly-3 case, rate 25%):
--      16: 2025-03-31 (last day of Q1)        17: 2025-04-01 (first day after Q1)
--      18: 2025-12-31 (last day of 2025)      19: 2026-01-01 (first day after 2025)
--      20: 2024-12-31 (last day before 2025)  21: Cancelled loan of copy 5 in 2025
-- ------------------------------------------------------------
INSERT INTO loans (loan_id, reader_id, copy_id, loan_date, status, due_date) VALUES
-- Reader 1 has 4 Completed loans in 2025 (loans 1-4)
(1,  1, 2, '2025-01-05', 'Completed', '2025-01-19'),
(2,  1, 3, '2025-01-20', 'Completed', '2025-02-03'),
(3,  1, 2, '2025-02-12', 'Completed', '2025-02-26'),
(4,  1, 4, '2025-03-10', 'Completed', '2025-03-24'),
-- January 2025
(5,  2, 1, '2025-01-15', 'Completed', '2025-01-29'),
-- In 2025 but outside Q1
(6,  3, 5, '2025-04-02', 'Completed', '2025-04-16'),
(7,  4, 3, '2025-06-10', 'Completed', '2025-06-24'),
-- Outside 2025
(8,  2, 2, '2024-11-05', 'Completed', '2024-11-19'),
(9,  6, 6, '2024-12-01', 'Completed', '2024-12-15'),
(10, 5, 1, '2026-01-08', 'Completed', '2026-01-22'),
-- No return record yet / cancelled
(11, 3, 3, '2025-02-20', 'Pending',   '2025-03-06'),
(12, 7, 5, '2025-03-15', 'Active',    '2025-03-29'),
(13, 2, 1, '2025-01-25', 'Cancelled', '2025-02-08'),
(14, 8, 2, '2025-05-05', 'Cancelled', '2025-05-19'),
(15, 9, 1, '2025-09-10', 'Pending',   '2025-09-24'),
-- Extra test data (reader 11 has exactly 3 Completed loans in 2025: loans 16, 17, 18)
(16, 11, 4, '2025-03-31', 'Completed', '2025-04-14'),
(17, 11, 5, '2025-04-01', 'Completed', '2025-04-15'),
(18, 11, 4, '2025-12-31', 'Completed', '2026-01-14'),
(19, 11, 5, '2026-01-01', 'Completed', '2026-01-15'),
(20, 11, 4, '2024-12-31', 'Completed', '2025-01-14'),
(21, 9,  5, '2025-08-20', 'Cancelled', '2025-09-03');

-- ------------------------------------------------------------
-- 5. return_records (15) - only for Completed loans (1-10, 16-20)
--    fine_amount = 0 is valid (loans 1, 3, 9, 17, 18, 19, 20)
-- ------------------------------------------------------------
INSERT INTO return_records (return_id, loan_id, return_date, condition_note, fine_amount) VALUES
(1,  1,  '2025-01-18', 'Good condition',            0),
(2,  2,  '2025-02-10', 'Returned 7 days late',      15000),
(3,  3,  '2025-02-25', 'Good condition',            0),
(4,  4,  '2025-03-30', 'Returned late, torn cover', 20000),
(5,  5,  '2025-01-28', 'Some pages yellowed',       5000),
(6,  6,  '2025-04-20', 'Returned 4 days late',      8000),
(7,  7,  '2025-06-24', 'Last page stained',         10000),
(8,  8,  '2024-11-25', 'Returned 6 days late',      12000),
(9,  9,  '2024-12-14', 'Good condition',            0),
(10, 10, '2026-01-20', 'Table of contents missing', 30000),
(11, 16, '2025-04-12', 'Water damaged cover',      10000),
(12, 17, '2025-04-10', 'Good condition',            0),
(13, 18, '2026-01-10', 'Good condition',            0),
(14, 19, '2026-01-14', 'Good condition',            0),
(15, 20, '2025-01-10', 'Good condition',            0);

-- ------------------------------------------------------------
-- 6. payments (11) - only for loans with a confirmed cost > 0
--    Loan 16 (reader 11): fully paid, makes reader 11 tie with reader 4 on total cost (10,000)
--    Loans 2, 4, 10: paid in several installments (loans 2 and 4 fully paid)
--    Loan 6: 4,000 still owed | Loan 10: 10,000 still owed
--    Reader 5 only paid in 2026 -> total paid in 2025 = 0
-- ------------------------------------------------------------
INSERT INTO payments (payment_id, loan_id, amount, payment_date, method) VALUES
(1,  2,  10000, '2025-02-10', 'Cash'),
(2,  2,  5000,  '2025-02-15', 'BankTransfer'),
(3,  4,  12000, '2025-03-30', 'Card'),
(4,  5,  5000,  '2025-01-28', 'Cash'),
(5,  6,  4000,  '2025-04-20', 'Cash'),
(6,  7,  10000, '2025-06-24', 'BankTransfer'),
(7,  8,  12000, '2024-11-25', 'Cash'),
(8,  10, 10000, '2026-01-20', 'Card'),
(9,  10, 10000, '2026-02-05', 'Cash'),
(10, 4,  8000,  '2025-04-05', 'Cash'),
(11, 16, 10000, '2025-04-12', 'BankTransfer');

-- ============================================================
-- DATA VERIFICATION
-- Each result row: check_id | description | actual value | valid range | PASS/FAIL
-- ============================================================

-- A. Minimum number of records
SELECT check_id, description, actual_value, min_ok, max_ok,
       IF(actual_value BETWEEN min_ok AND max_ok, 'PASS', 'FAIL') AS result
FROM (
    SELECT 'A01' AS check_id, 'categories >= 5'     AS description, (SELECT COUNT(*) FROM categories)     AS actual_value, 5  AS min_ok, 999999 AS max_ok
    UNION ALL SELECT 'A02', 'copies >= 6',          (SELECT COUNT(*) FROM copies),         6,  999999
    UNION ALL SELECT 'A03', 'readers >= 10',        (SELECT COUNT(*) FROM readers),        10, 999999
    UNION ALL SELECT 'A04', 'loans >= 12',          (SELECT COUNT(*) FROM loans),          12, 999999
    UNION ALL SELECT 'A05', 'return_records >= 10', (SELECT COUNT(*) FROM return_records), 10, 999999
    UNION ALL SELECT 'A06', 'payments >= 10',       (SELECT COUNT(*) FROM payments),       10, 999999
) t;

-- B. Referential integrity (expect 0 orphan rows) and cross-table business rules
SELECT check_id, description, actual_value, min_ok, max_ok,
       IF(actual_value BETWEEN min_ok AND max_ok, 'PASS', 'FAIL') AS result
FROM (
    SELECT 'B01' AS check_id, 'copies referencing a missing category' AS description,
           (SELECT COUNT(*) FROM copies c LEFT JOIN categories g ON g.category_id = c.category_id
             WHERE g.category_id IS NULL) AS actual_value, 0 AS min_ok, 0 AS max_ok
    UNION ALL SELECT 'B02', 'loans referencing a missing reader',
           (SELECT COUNT(*) FROM loans l LEFT JOIN readers r ON r.reader_id = l.reader_id
             WHERE r.reader_id IS NULL), 0, 0
    UNION ALL SELECT 'B03', 'loans referencing a missing copy',
           (SELECT COUNT(*) FROM loans l LEFT JOIN copies c ON c.copy_id = l.copy_id
             WHERE c.copy_id IS NULL), 0, 0
    UNION ALL SELECT 'B04', 'return_records referencing a missing loan',
           (SELECT COUNT(*) FROM return_records rr LEFT JOIN loans l ON l.loan_id = rr.loan_id
             WHERE l.loan_id IS NULL), 0, 0
    UNION ALL SELECT 'B05', 'payments referencing a missing loan',
           (SELECT COUNT(*) FROM payments p LEFT JOIN loans l ON l.loan_id = p.loan_id
             WHERE l.loan_id IS NULL), 0, 0
    UNION ALL SELECT 'B06', 'Completed loans without exactly 1 return record',
           (SELECT COUNT(*) FROM loans l
             WHERE l.status = 'Completed'
               AND (SELECT COUNT(*) FROM return_records rr WHERE rr.loan_id = l.loan_id) <> 1), 0, 0
    UNION ALL SELECT 'B07', 'return records belonging to a loan that is NOT Completed',
           (SELECT COUNT(*) FROM return_records rr JOIN loans l ON l.loan_id = rr.loan_id
             WHERE l.status <> 'Completed'), 0, 0
    UNION ALL SELECT 'B08', 'return_date earlier than loan_date',
           (SELECT COUNT(*) FROM return_records rr JOIN loans l ON l.loan_id = rr.loan_id
             WHERE rr.return_date < l.loan_date), 0, 0
    UNION ALL SELECT 'B09', 'due_date earlier than loan_date',
           (SELECT COUNT(*) FROM loans WHERE due_date < loan_date), 0, 0
    UNION ALL SELECT 'B10', 'negative fine_amount',
           (SELECT COUNT(*) FROM return_records WHERE fine_amount < 0), 0, 0
    UNION ALL SELECT 'B11', 'payments with amount <= 0',
           (SELECT COUNT(*) FROM payments WHERE amount <= 0), 0, 0
    UNION ALL SELECT 'B12', 'payments collected without a confirmed cost (> 0)',
           (SELECT COUNT(*) FROM payments p
             WHERE NOT EXISTS (SELECT 1 FROM return_records rr
                                WHERE rr.loan_id = p.loan_id AND rr.fine_amount > 0)), 0, 0
    UNION ALL SELECT 'B13', 'loans whose total collected exceeds the confirmed cost',
           (SELECT COUNT(*)
              FROM (SELECT loan_id, SUM(amount) AS paid FROM payments GROUP BY loan_id) pp
              JOIN return_records rr ON rr.loan_id = pp.loan_id
             WHERE pp.paid > rr.fine_amount), 0, 0
    UNION ALL SELECT 'B14', 'payment_date earlier than return_date (extra check)',
           (SELECT COUNT(*) FROM payments p JOIN return_records rr ON rr.loan_id = p.loan_id
             WHERE p.payment_date < rr.return_date), 0, 0
) t;

-- C. Special data scenarios required by the assignment (expect >= 1)
SELECT check_id, description, actual_value, min_ok, max_ok,
       IF(actual_value BETWEEN min_ok AND max_ok, 'PASS', 'FAIL') AS result
FROM (
    SELECT 'C01' AS check_id, 'Completed loans in January 2025' AS description,
           (SELECT COUNT(*) FROM loans WHERE status = 'Completed'
               AND loan_date >= '2025-01-01' AND loan_date < '2025-02-01') AS actual_value, 1 AS min_ok, 999999 AS max_ok
    UNION ALL SELECT 'C02', 'loans in Feb-Mar 2025 (rest of Q1)',
           (SELECT COUNT(*) FROM loans WHERE loan_date >= '2025-02-01' AND loan_date < '2025-04-01'), 1, 999999
    UNION ALL SELECT 'C03', 'loans in 2025 but outside Q1',
           (SELECT COUNT(*) FROM loans WHERE loan_date >= '2025-04-01' AND loan_date < '2026-01-01'), 1, 999999
    UNION ALL SELECT 'C04', 'loans outside 2025',
           (SELECT COUNT(*) FROM loans WHERE loan_date < '2025-01-01' OR loan_date >= '2026-01-01'), 1, 999999
    UNION ALL SELECT 'C05', 'distinct statuses (all 4 required)',
           (SELECT COUNT(DISTINCT status) FROM loans), 4, 4
    UNION ALL SELECT 'C06', 'readers with > 3 Completed loans in 2025',
           (SELECT COUNT(*) FROM (SELECT reader_id FROM loans
                                   WHERE status = 'Completed'
                                     AND loan_date >= '2025-01-01' AND loan_date < '2026-01-01'
                                   GROUP BY reader_id HAVING COUNT(*) > 3) x), 1, 999999
    UNION ALL SELECT 'C07', 'readers with loans but no payment at all',
           (SELECT COUNT(*) FROM readers r
             WHERE EXISTS (SELECT 1 FROM loans l WHERE l.reader_id = r.reader_id)
               AND NOT EXISTS (SELECT 1 FROM loans l JOIN payments p ON p.loan_id = l.loan_id
                                WHERE l.reader_id = r.reader_id)), 1, 999999
    UNION ALL SELECT 'C08', 'loans paid in 2 or more installments',
           (SELECT COUNT(*) FROM (SELECT loan_id FROM payments GROUP BY loan_id HAVING COUNT(*) >= 2) x), 1, 999999
    UNION ALL SELECT 'C09', 'loans with an outstanding debt (cost > total collected)',
           (SELECT COUNT(*) FROM return_records rr
             WHERE rr.fine_amount > (SELECT COALESCE(SUM(p.amount), 0) FROM payments p
                                      WHERE p.loan_id = rr.loan_id)), 1, 999999
    UNION ALL SELECT 'C10', 'readers with no loan at all',
           (SELECT COUNT(*) FROM readers r
             WHERE NOT EXISTS (SELECT 1 FROM loans l WHERE l.reader_id = r.reader_id)), 1, 999999
    UNION ALL SELECT 'C11', 'categories with no loan in Q1/2025',
           (SELECT COUNT(*) FROM categories g
             WHERE NOT EXISTS (SELECT 1 FROM copies c JOIN loans l ON l.copy_id = c.copy_id
                                WHERE c.category_id = g.category_id
                                  AND l.loan_date >= '2025-01-01' AND l.loan_date < '2025-04-01')), 1, 999999
    UNION ALL SELECT 'C12', 'copies with no loan in 2025',
           (SELECT COUNT(*) FROM copies c
             WHERE NOT EXISTS (SELECT 1 FROM loans l
                                WHERE l.copy_id = c.copy_id
                                  AND l.loan_date >= '2025-01-01' AND l.loan_date < '2026-01-01')), 1, 999999
) t;

-- D. Extra scenarios added to make mistakes in queries visible (not required by the assignment)
SELECT check_id, description, actual_value, min_ok, max_ok,
       IF(actual_value BETWEEN min_ok AND max_ok, 'PASS', 'FAIL') AS result
FROM (
    SELECT 'D01' AS check_id, 'readers with exactly 3 Completed loans in 2025 (tests > 3 vs >= 3)' AS description,
           (SELECT COUNT(*) FROM (SELECT reader_id FROM loans
                                   WHERE status = 'Completed'
                                     AND loan_date >= '2025-01-01' AND loan_date < '2026-01-01'
                                   GROUP BY reader_id HAVING COUNT(*) = 3) x) AS actual_value, 1 AS min_ok, 999999 AS max_ok
    UNION ALL SELECT 'D02', 'readers with more Completed loans overall than in 2025 (tests the year filter)',
           (SELECT COUNT(*) FROM readers r
             WHERE (SELECT COUNT(*) FROM loans l WHERE l.reader_id = r.reader_id AND l.status = 'Completed')
                 > (SELECT COUNT(*) FROM loans l WHERE l.reader_id = r.reader_id AND l.status = 'Completed'
                       AND l.loan_date >= '2025-01-01' AND l.loan_date < '2026-01-01')), 1, 999999
    UNION ALL SELECT 'D03', 'boundary dates present (2025-03-31, 2025-04-01, 2025-12-31, 2026-01-01; all 4 required)',
           (SELECT COUNT(DISTINCT loan_date) FROM loans
             WHERE loan_date IN ('2025-03-31', '2025-04-01', '2025-12-31', '2026-01-01')), 4, 4
    UNION ALL SELECT 'D04', 'pairs of readers with the same positive total cost (tests the id tie-break in query 8)',
           (SELECT COUNT(*) FROM (SELECT l.reader_id, SUM(rr.fine_amount) AS t
                                    FROM loans l JOIN return_records rr ON rr.loan_id = l.loan_id
                                   GROUP BY l.reader_id HAVING SUM(rr.fine_amount) > 0) a
                    JOIN (SELECT l.reader_id, SUM(rr.fine_amount) AS t
                            FROM loans l JOIN return_records rr ON rr.loan_id = l.loan_id
                           GROUP BY l.reader_id HAVING SUM(rr.fine_amount) > 0) b
                      ON a.t = b.t AND a.reader_id < b.reader_id), 1, 999999
    UNION ALL SELECT 'D05', 'copies in a 3-way tie for a top-3 place (tests the copy_id tie-break in query 5)',
           (SELECT COUNT(*) FROM (SELECT copy_id FROM loans
                                   WHERE status = 'Completed'
                                     AND loan_date >= '2025-01-01' AND loan_date < '2026-01-01'
                                   GROUP BY copy_id HAVING COUNT(*) = 2) x), 3, 999999
) t;

-- ------------------------------------------------------------
-- Illustrations of INSERT statements that violate constraints
-- (kept in comments so that this file still runs end to end).
-- Remove the comment marks of ONE statement at a time to try it;
-- each one must raise an error.
-- ------------------------------------------------------------
-- (1) duplicate barcode -> UNIQUE error:
-- INSERT INTO copies (title, author, barcode, category_id) VALUES ('Duplicate barcode book', 'X', 'BC-0001', 1);
-- (2) due_date earlier than loan_date -> CHECK error:
-- INSERT INTO loans (reader_id, copy_id, loan_date, status, due_date) VALUES (1, 1, '2025-05-10', 'Pending', '2025-05-01');
-- (3) invalid status -> ENUM error:
-- INSERT INTO loans (reader_id, copy_id, loan_date, status, due_date) VALUES (1, 1, '2025-05-10', 'Lost', '2025-05-20');
-- (4) two return records for the same loan -> UNIQUE (loan_id) error:
-- INSERT INTO return_records (loan_id, return_date, condition_note, fine_amount) VALUES (1, '2025-01-19', 'Duplicate', 0);
-- (5) negative fine_amount -> CHECK error:
-- INSERT INTO return_records (loan_id, return_date, condition_note, fine_amount) VALUES (11, '2025-03-01', 'Invalid', -1);
-- (6) amount = 0 -> CHECK error:
-- INSERT INTO payments (loan_id, amount, payment_date, method) VALUES (2, 0, '2025-02-20', 'Cash');
-- (7) invalid payment method -> ENUM error:
-- INSERT INTO payments (loan_id, amount, payment_date, method) VALUES (2, 1000, '2025-02-20', 'Cheque');
-- (8) non-existent foreign key -> FOREIGN KEY error:
-- INSERT INTO loans (reader_id, copy_id, loan_date, status, due_date) VALUES (999, 1, '2025-05-10', 'Pending', '2025-05-20');
-- (9) The cases below are NOT blocked by the schema (detect them with checks B06-B13 above):
--     collecting money for a loan with no confirmed cost, total collected above the cost,
--     a return record for a Pending loan, return_date earlier than loan_date.
