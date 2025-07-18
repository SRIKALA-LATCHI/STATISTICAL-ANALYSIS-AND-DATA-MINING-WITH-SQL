-- Drop tables if they already exist
DROP TABLE IF EXISTS AnalysisLogs;
DROP TABLE IF EXISTS Dataset;
DROP TABLE IF EXISTS Users;

-- Create Dataset Table
CREATE TABLE Dataset (
    record_id INT PRIMARY KEY,
    category VARCHAR(50),
    value FLOAT,
    timestamp TIMESTAMP,
    label VARCHAR(50)
);

-- Create Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(50),
    role VARCHAR(20) -- Analyst or Admin
);

-- Create AnalysisLogs Table
CREATE TABLE AnalysisLogs (
    log_id INT PRIMARY KEY,
    user_id INT,
    operation TEXT,
    log_time TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Insert Sample Data into Dataset
INSERT INTO Dataset (record_id, category, value, timestamp, label) VALUES
(1, 'Sales', 1200.5, '2025-03-15 10:00:00', 'High'),
(2, 'Sales', 300.0,  '2025-03-15 10:05:00', 'Low');

-- Insert Sample Data into Users
INSERT INTO Users (user_id, name, role) VALUES
(1, 'Asha', 'Analyst'),
(2, 'Vikram', 'Admin');

-- Insert Sample Data into AnalysisLogs
INSERT INTO AnalysisLogs (log_id, user_id, operation, log_time) VALUES
(1, 1, 'Average Value Computation', '2025-04-01 08:30:00');

-- ========================
-- SQL FUNCTIONS & ANALYSIS
-- ========================

-- 1. Compute average, median, stddev
-- (1a) Average value
SELECT category, AVG(value) AS average_value
FROM Dataset
GROUP BY category;

-- (1b) Median (approx using percentile_cont)
-- NOTE: Use only if supported by DBMS like PostgreSQL or Oracle
-- Otherwise skip or simulate manually
-- Example for PostgreSQL:
-- SELECT category, percentile_cont(0.5) WITHIN GROUP (ORDER BY value) AS median_value
-- FROM Dataset GROUP BY category;

-- (1c) Standard deviation
SELECT category, STDDEV(value) AS std_dev
FROM Dataset
GROUP BY category;

-- 2. Category-wise summaries
SELECT category,
       COUNT(*) AS total_records,
       MIN(value) AS min_value,
       MAX(value) AS max_value,
       AVG(value) AS avg_value
FROM Dataset
GROUP BY category;

-- 3. Outlier Detection (simple threshold based)
SELECT * FROM Dataset
WHERE value > 1000 OR value < 100;

-- ========================
-- VIEWS
-- ========================

-- 4. Summary view by category
CREATE OR REPLACE VIEW category_summary AS
SELECT category, COUNT(*) AS count, AVG(value) AS avg_value
FROM Dataset
GROUP BY category;

-- 5. Recent operations log
CREATE OR REPLACE VIEW recent_logs AS
SELECT L.log_id, U.name AS user_name, L.operation, L.log_time
FROM AnalysisLogs L
JOIN Users U ON L.user_id = U.user_id
ORDER BY L.log_time DESC;

-- 6. Trendline analysis over time
CREATE OR REPLACE VIEW trendline AS
SELECT category, DATE(timestamp) AS date, AVG(value) AS daily_avg
FROM Dataset
GROUP BY category, DATE(timestamp)
ORDER BY date;

-- ========================
-- NESTED QUERIES
-- ========================

-- 7. Top 5 highest values by category
SELECT *
FROM Dataset D1
WHERE 5 > (
    SELECT COUNT(*) FROM Dataset D2
    WHERE D2.category = D1.category AND D2.value > D1.value
)
ORDER BY category, value DESC;

-- 8. Compare mean values between categories
SELECT category, AVG(value) AS avg_value
FROM Dataset
GROUP BY category;

-- 9. Frequent labels per category
SELECT category, label, COUNT(*) AS count
FROM Dataset
GROUP BY category, label
ORDER BY category, count DESC;

-- ========================
-- JOIN-BASED QUERIES
-- ========================

-- 10. Log of analysis with user details
SELECT L.log_id, U.name AS user_name, U.role, L.operation, L.log_time
FROM AnalysisLogs L
JOIN Users U ON L.user_id = U.user_id;

-- 11. Daily activity of analysts
SELECT U.name, DATE(L.log_time) AS log_date, COUNT(*) AS activity_count
FROM Users U
JOIN AnalysisLogs L ON U.user_id = L.user_id
WHERE U.role = 'Analyst'
GROUP BY U.name, DATE(L.log_time);

-- 12. Category vs label distribution
SELECT category, label, COUNT(*) AS count
FROM Dataset
GROUP BY category, label
ORDER BY category, count DESC;