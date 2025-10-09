![campaign-creators-gMsnXqILjp4-unsplash](https://github.com/user-attachments/assets/68af6507-8efb-449c-9a8a-8bd95e3da6e8)


# 👥 HR Workforce Analysis with SQL & Power BI

![Power BI](https://img.shields.io/badge/PowerBI-Dashboard-F2C811?logo=powerbi&logoColor=black)
![MySQL](https://img.shields.io/badge/Database-MySQL-blue?logo=mysql&logoColor=white)
![MySQL Connector](https://img.shields.io/badge/MySQL-Connector-4479A1?logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/Project-Complete-brightgreen)

This project presents an **HR Analytics solution** for a company (**Max_Holdings**) using **MySQL** for data transformation and **Power BI** for visualization and reporting.  
It provides insights into **employee demographics, payroll, recruitment trends, workforce structure, and HR recommendations**.

---

## 📂 Project Structure

```
HR_Analysis/
│── data/
│    └── online CSV extracts of raw HR tables (employee_info, salary, departments, division)
│── sql_scripts/
│    └── Max_Holdings_Database.sql         # SQL cleaning & preprocessing steps
│── Max_Holdings_Analysis.pbix             # Power BI dashboard file
│── Max_Holdings_BI.pdf                    # Exported report (preview of dashboards)
│── README.md                              # Project documentation
```

---

## 🗄️ Data & SQL Transformation

- **Database:** `Max_Holdings`
- **Tables:** `employee_info`, `salary`, `departments`, `division`
- **Cleaning Steps (in MySQL):**
  - Fixed datatypes for text, date, and numeric fields  
  - Created a **full relational view (`raw_view`)** joining all tables  
  - Removed duplicate employee records using window function & CTE `ROW_NUMBER()`  
  - Replaced missing/invalid values (e.g., recalculated ages using audit date)  
  - Corrected formatting issues (string trims, proper case for names, gender standardization)  
  - Validated payroll consistency (Net Pay = Gross Pay - Deduction)
 
``` sql
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
```

👉 See `Max_Holdings_Database.sql` for full SQL workflow.

---

## 📊 Power BI Dashboard

The Power BI report contains **5 Pages**:

1. **Exploratory Data Analysis (EDA)**  
   - KPI Cards: Total Employees, Avg Age, Avg Tenure, Avg Salaries, Deduction %  
   - Age & Gender Distribution (histogram + donut chart)  
   - Department/Role counts with slicers  
   - Recruitment Trends (yearly hires, heatmap by month/year)  

2. **Demographics Dashboard**  
   - Workforce distribution by Age, Gender, Department, Role  
   - Highlights of diversity, tenure, and hiring patterns  

3. **Payroll & Salary Analysis**  
   - Net Monthly Salary Distribution  
   - Gender Pay Equity (gross vs net comparisons)  
   - Salary by Department & Role  
   - Tenure vs Salary correlation  

4. **Tabular Summaries**  
   - Organizational Structure (Dept → Division → Role → Employee counts)  
   - Workforce vs Work Duration & Salary tables  
   - Employee details (Top vs Least Earners)  

5. **Insights & Recommendations**  
   - Key findings on demographics, recruitment, pay disparities, workload, and data quality issues  
   - **Business Recommendations** for gender equity, succession planning, fair compensation, retention, and workload balancing  

📄 **Preview:** See `Max_Holdings_BI.pdf` for dashboard snapshots.  
👉 **[Max_Holdings_BI.pdf](https://github.com/user-attachments/files/22704288/Max_Holdings_BI.pdf)**


![Max_Holdings_BI](https://github.com/user-attachments/assets/8f4cfee7-8214-49d7-900f-05082d8af75a)

---

## 📈 Key Insights

- Workforce is **young** (68% between ages 26–35), but leadership roles show higher ages (50+).  
- **Gender imbalance**: 72% Male vs 28% Female.  
- **Recruitment trend:** Hiring peaked in 2017–2019; none after Jan 2020 (COVID impact).  
- **Pay disparities** exist across departments and roles — Legal earns 4x Finance.  
- **Top earners** often have short tenure (<1 year), raising fairness concerns.  
- **High deductions** (70–80%) observed for senior roles, possibly due to stock/benefits structure.  
- Data quality issues: unrealistic salary records for some roles.  

---

## 🚀 How to Run

### 1. SQL Preprocessing  
Run the script:  
```sql
source sql_scripts/hr_cleaning_transformations.sql;
```

### 2. Connect Power BI to MySQL  
- Install MySQL Connector  
- Connect Power BI to `Max_Holdings` database  
- Import tables & views (use `raw_view`)  

### 3. Open Dashboard  
- Load `HR_Analysis.pbix` in Power BI Desktop  
- Or view `HR_Report.pdf` for a static preview  

---

## 📌 Future Improvements

- Automate updates with a **live MySQL–Power BI connection**  
- Add **HR forecasting models** (attrition prediction, salary projections)  
- Deploy interactive **Power BI Service dashboards** with scheduled refresh  
- Integrate with **Python (Pandas + Seaborn)** for deeper EDA before visualization  

---

## 🏆 Author

**Your Name**  
_Data Analyst & Data Scientist_  
[LinkedIn](https://www.linkedin.com/) | [Portfolio](https://yourportfolio.com) | [GitHub](https://github.com/yourusername)
