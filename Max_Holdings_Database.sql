-- Creation of Database for the project 'Max_Holdings'
CREATE DATABASE Max_Holdings;
USE Max_Holdings;

-- =============================================================
-- SHOW ALL TABLE DATA
-- =============================================================
SELECT * FROM employee_info;
SELECT * FROM salary;
SELECT * FROM departments;
SELECT * FROM division;

SELECT * FROM employee_info_2;
-- =============================================================
-- Description of the tables
-- =============================================================
DESCRIBE employee_info;
DESCRIBE salary;
DESCRIBE departments;
DESCRIBE division;


-- =============================================================
-- Change data types of columns with wrong data type
-- (All text data types should be converted to VARCHAR)
-- =============================================================
-- EMPLOYEE_INFO TABLE
ALTER TABLE employee_info
MODIFY COLUMN First_Name VARCHAR(30),
MODIFY COLUMN Last_Name VARCHAR(30),
MODIFY COLUMN Gender VARCHAR(10),
MODIFY COLUMN Date_of_Birth DATE,
MODIFY COLUMN Join_Date DATE,
MODIFY COLUMN Role VARCHAR(100),
MODIFY COLUMN Email_address VARCHAR(50);

-- SALARY TABLE
ALTER TABLE salary
MODIFY COLUMN Designation VARCHAR(100),
MODIFY COLUMN Deduction_percentage DECIMAL(5, 2);

-- DEPARTMENTS TABLE
ALTER TABLE departments
MODIFY COLUMN Department VARCHAR(50),
MODIFY COLUMN Dept_Resumption_Time TIME,
MODIFY COLUMN Dept_Closing_Time TIME;

-- DIVISION TABLE
ALTER TABLE division
MODIFY COLUMN Division VARCHAR(50);


-- =============================================================
-- CREATE FULL VIEW FOR INSIGHTS & TO SHOW TABLE RELATIONSHIPS
-- =============================================================

CREATE VIEW raw_view AS
SELECT 	ID, First_Name, Last_Name, Gender, Date_of_Birth, Age, Join_Date, Role, 
		Designation, Tenure_in_org_in_months, Gross_Pay, Net_Pay, Deduction_percentage,
		Division,
		Department, HOD_ID, Dept_Resumption_Time, Dept_Closing_Time  
FROM employee_info e
JOIN salary s ON e.ID = s.EmpID
JOIN division v ON s.Division_ID = v.Division_ID 
JOIN departments d ON v.Dept_ID = d.Dept_ID;

SELECT * FROM raw_view;


-- =============================================================
-- HANDLE DUPLICATE RECORDS
-- =============================================================

-- _____________________________________________________________
-- Show employees with Duplicate records:
-- _____________________________________________________________

-- Employee_info Table
SELECT ID, First_Name, Last_Name, COUNT(ID) AS no_of_entries
FROM employee_info
GROUP BY ID, First_Name, Last_Name
HAVING COUNT(ID) > 1
ORDER BY 4 DESC;

-- Salary Table
SELECT EmpID, COUNT(EmpID) AS no_of_entries
FROM salary
GROUP BY EmpID
HAVING COUNT(EmpID) > 1;

-- Only Employee_info has duplicate records

-- _____________________________________________________________
-- Show duplicate entries in the order they appear in the table:
-- _____________________________________________________________

WITH Duplicate_emp AS (
						SELECT 	emp_unique_id, ID, First_Name, Last_Name, 
								ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) AS entry_no
						FROM employee_info)

SELECT * 
FROM Duplicate_emp WHERE entry_no >1
ORDER BY ID;

-- _____________________________________________________________
-- Add AUTO INCREMENT COLUMN TO Employee_info Table for Easy and Safe Deletion of Duplicate Records
-- This is to prevent total deletion of records that have the same ID
-- _____________________________________________________________

ALTER TABLE employee_info 
ADD COLUMN emp_unique_id INT AUTO_INCREMENT PRIMARY KEY;

-- _____________________________________________________________
-- Show duplicate entries with emp_unique_id:
-- _____________________________________________________________

WITH Duplicate_emp AS (
						SELECT 	emp_unique_id, ID, First_Name, Last_Name, 
								ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) AS entry_no
						FROM employee_info)

SELECT * 
FROM Duplicate_emp WHERE entry_no >1
ORDER BY ID;

-- _____________________________________________________________
-- Delete duplicate entries:
-- _____________________________________________________________

WITH Duplicate_emp AS (
						SELECT 	emp_unique_id,
								ROW_NUMBER() OVER (PARTITION BY ID ORDER BY emp_unique_id) AS entry_no
						FROM employee_info)
                        
DELETE FROM employee_info
WHERE emp_unique_id IN (
						SELECT emp_unique_id 
                        FROM Duplicate_emp WHERE entry_no > 1)
;

-- _____________________________________________________________
-- Confirm Total No. of Records after removal of duplicates:
-- _____________________________________________________________
SELECT COUNT(*)
FROM employee_info;

ALTER TABLE employee_info
DROP COLUMN emp_unique_id;


-- =============================================================
-- HANDLE NULL & MISSING VALUES
-- =============================================================


-- NULL Value Check in Employee_info Table:

SELECT COUNT(*) AS Null_Records 
FROM Employee_info 
WHERE ID IS NULL OR Date_of_Birth IS NULL OR Age IS NULL OR Join_Date IS NULL OR Role IS NULL;


-- NULL Value Check in salary Table:

SELECT COUNT(*) 
FROM Salary 
WHERE EmpID IS NULL OR Division_ID IS NULL OR Tenure_in_org_in_months IS NULL 
OR Gross_Pay IS NULL OR Net_Pay IS NULL OR Deduction IS NULL;

-- _____________________________________________________________
-- Missing Value Check (Zero Age is not valid, so it is regarded as missing value):

SELECT * FROM Employee_info 
WHERE Age = 0;



-- =============================================================
-- REPLACEMENT OF MISSING VALUES
-- =============================================================

-- _____________________________________________________________
-- We have to first find the period the records ended
-- _____________________________________________________________
WITH audit_interval AS (
						SELECT 	ID, Join_Date, 
								DATE_ADD(Join_Date, INTERVAL Tenure_in_org_in_months MONTH) AS End_date
						FROM employee_info e
						JOIN salary s
						ON e.ID = s.EmpID)

SELECT MAX(End_date) AS Audit_Date from audit_interval;


-- Assumed End date = 2020/07/15


-- _____________________________________________________________
-- Calculate Age For Employees with missing values
-- We deduct Date_of_Birth from Audit_Date
-- _____________________________________________________________

UPDATE employee_info
SET age = TIMESTAMPDIFF(YEAR, Date_of_Birth, '2020/07/15')
WHERE age = 0;


-- =============================================================
-- CHECKING FOR ERRORS AND INCONSISTENCIES
-- =============================================================

-- Confirm if Net salary = Gross salary - Deduction (within margin of error):

SELECT * FROM salary
WHERE Gross_Pay - Deduction != Net_Pay;

-- _____________________________________________________________

-- Confirm any significant difference between calculated deduction and original salary table deduction
-- Check in ascending & descending order of difference:

SELECT 	EmpID, Tenure_in_org_in_months, Gross_Pay,  
		Deduction_percentage,
		Deduction, 
		ROUND(Gross_Pay * Deduction_percentage/100) AS calculated_deduction,
		Deduction - ROUND(Gross_Pay * Deduction_percentage/100) AS difference,
		Net_Pay
FROM salary;


-- =========================================================
-- CLEANING RECORDS WITH STRING FUNCTIONS
-- =========================================================

-- Replace dots with space in Role column of employee_info table:

UPDATE employee_info
SET Role = REPLACE(Role, '.', ' ');
-- _____________________________________________________________

-- Trim out white spaces in First_Name & Last_Name columns of employee_info table:

UPDATE employee_info
SET First_Name = TRIM(First_Name),
Last_Name = TRIM(Last_Name);
-- _____________________________________________________________

-- Change First_Name & Last_Name to proper form:

UPDATE employee_info
SET First_Name = CONCAT(UPPER(SUBSTRING(First_Name, 1, 1)),LOWER(SUBSTRING(First_Name, 2))),
Last_Name = CONCAT(UPPER(SUBSTRING(Last_Name, 1, 1)),LOWER(SUBSTRING(Last_Name, 2)));

-- _____________________________________________________________

-- Standardize the Gender values (F for Female, M for Male):

UPDATE employee_info
SET Gender =
			CASE WHEN Gender = 'F' THEN 'Female'
								ELSE 'Male'
            END;

-- ================================================================