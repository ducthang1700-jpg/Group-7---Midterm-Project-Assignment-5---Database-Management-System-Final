-- ============================================================
-- Assignment 05 - Library Borrowing and Returning Management
-- File 1/4: schema.sql  (database, tables, keys and constraints)
-- Requires: MySQL 8.0.16 or later (CHECK constraints are enforced
--           only from this version onward)
-- Run order: schema.sql -> seed.sql -> queries.sql -> views.sql
-- ============================================================

-- Drop any previous copy so the script can be re-run on a fresh setup
DROP DATABASE IF EXISTS library_mini;
CREATE DATABASE library_mini
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE library_mini;

-- ------------------------------------------------------------
-- 1. categories: book categories
-- ------------------------------------------------------------
CREATE TABLE categories (
    category_id INT          NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    CONSTRAINT pk_categories PRIMARY KEY (category_id),
    -- Additional suggestion: category names must be unique
    CONSTRAINT uq_categories_name UNIQUE (name)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 2. copies: book copies (each copy belongs to exactly one category)
-- ------------------------------------------------------------
CREATE TABLE copies (
    copy_id     INT          NOT NULL AUTO_INCREMENT,
    title       VARCHAR(200) NOT NULL,
    author      VARCHAR(150) NOT NULL,
    barcode     VARCHAR(30)  NOT NULL,
    category_id INT          NOT NULL,
    CONSTRAINT pk_copies PRIMARY KEY (copy_id),
    CONSTRAINT uq_copies_barcode UNIQUE (barcode),
    CONSTRAINT fk_copies_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 3. readers: library members (dob and phone are optional because
--    the assignment only makes the name mandatory)
-- ------------------------------------------------------------
CREATE TABLE readers (
    reader_id INT          NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    dob       DATE         NULL,
    phone     VARCHAR(15)  NULL,
    CONSTRAINT pk_readers PRIMARY KEY (reader_id)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 4. loans: borrowing registrations (one reader + one book copy)
-- ------------------------------------------------------------
CREATE TABLE loans (
    loan_id   INT NOT NULL AUTO_INCREMENT,
    reader_id INT NOT NULL,
    copy_id   INT NOT NULL,
    loan_date DATE NOT NULL,
    status    ENUM('Pending', 'Active', 'Completed', 'Cancelled')
              NOT NULL DEFAULT 'Pending',
    due_date  DATE NOT NULL,
    CONSTRAINT pk_loans PRIMARY KEY (loan_id),
    CONSTRAINT fk_loans_reader FOREIGN KEY (reader_id)
        REFERENCES readers (reader_id),
    CONSTRAINT fk_loans_copy FOREIGN KEY (copy_id)
        REFERENCES copies (copy_id),
    -- due_date must not be earlier than loan_date (uses columns of the same table only)
    CONSTRAINT ck_loans_due_date CHECK (due_date >= loan_date)
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 5. return_records: return slips (at most one per loan)
--    fine_amount is the "confirmed incurred cost"
-- ------------------------------------------------------------
CREATE TABLE return_records (
    return_id      INT           NOT NULL AUTO_INCREMENT,
    loan_id        INT           NOT NULL,
    return_date    DATE          NOT NULL,
    condition_note VARCHAR(255)  NULL,
    fine_amount    DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT pk_return_records PRIMARY KEY (return_id),
    CONSTRAINT uq_return_records_loan UNIQUE (loan_id),
    CONSTRAINT fk_return_records_loan FOREIGN KEY (loan_id)
        REFERENCES loans (loan_id),
    CONSTRAINT ck_return_fine CHECK (fine_amount >= 0)
    -- Note: "return_date >= loan_date" requires comparing with the loans table.
    -- A CHECK constraint must not query another table, so this rule is
    -- verified by queries in seed.sql instead.
) ENGINE = InnoDB;

-- ------------------------------------------------------------
-- 6. payments: each row is one actual collection of money
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id   INT           NOT NULL AUTO_INCREMENT,
    loan_id      INT           NOT NULL,
    amount       DECIMAL(12,2) NOT NULL,
    payment_date DATE          NOT NULL,
    method       ENUM('Cash', 'BankTransfer', 'Card') NOT NULL,
    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    CONSTRAINT fk_payments_loan FOREIGN KEY (loan_id)
        REFERENCES loans (loan_id),
    CONSTRAINT ck_payments_amount CHECK (amount > 0)
) ENGINE = InnoDB;

-- ============================================================
-- Limits of this design (rules that the schema CANNOT enforce,
-- because they need data from other tables or from many rows;
-- they are verified by queries in seed.sql):
--   * Only loans with status = 'Completed' may have a return record,
--     and every Completed loan must have exactly one.
--   * return_date >= loan_date.
--   * Money may be collected only when a confirmed cost exists
--     (fine_amount > 0).
--   * The sum of payments.amount of a loan must not exceed fine_amount.
-- ============================================================
