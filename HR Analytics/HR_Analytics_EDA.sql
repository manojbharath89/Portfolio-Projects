USE meriskill;

SELECT Age
FROM `hremployeeattrition`;

-- Checking for NULL values
SELECT COUNT(*) AS 'Null_Values'
FROM `hremployeeattrition`
WHERE Age IS NULL OR Attrition IS NULL OR BusinessTravel IS NULL 
OR DailyRate IS NULL OR Department IS NULL OR DistanceFromHome IS NULL 
OR Education IS NULL OR EducationField IS NULL OR EmployeeCount IS NULL 
OR EmployeeNumber IS NULL OR EnvironmentSatisfaction IS NULL 
OR Gender IS NULL OR HourlyRate IS NULL OR JobInvolvement IS NULL 
OR JobLevel IS NULL OR JobRole IS NULL OR JobSatisfaction IS NULL 
OR MaritalStatus IS NULL OR MonthlyIncome IS NULL OR MonthlyRate IS NULL 
OR NumCompaniesWorked IS NULL OR Over18 IS NULL 
OR OverTime IS NULL OR PercentSalaryHike IS NULL 
OR PerformanceRating IS NULL OR RelationshipSatisfaction IS NULL 
OR StandardHours IS NULL OR StockOptionLevel IS NULL 
OR TotalWorkingYears IS NULL OR TrainingTimesLastYear IS NULL 
OR WorkLifeBalance IS NULL OR YearsAtCompany IS NULL 
OR YearsInCurrentRole IS NULL OR YearsSinceLastPromotion IS NULL 
OR YearsWithCurrManager IS NULL;
/* There are no null values in the dataset, so we can proceed with our analysis */

-- Finding the total number of employees who have left the company and their respective attrition rate
SELECT Attrition, COUNT(*) as `Number of Employees`, (COUNT(*)/(SELECT COUNT(*) FROM `hremployeeattrition`))*100 AS `Attrition Rate`
FROM `hremployeeattrition`
WHERE Attrition='Yes'
GROUP BY Attrition;

-- Finding the average monthly income for employees based on their education level
SELECT Education, AVG(MonthlyIncome) as `Average Monthly Income`
FROM `hremployeeattrition`
GROUP BY Education;

-- Finding the Top 5 job roles with the highest attrition rate
SELECT JobRole, COUNT(*) as `Number of Employees`, (COUNT(*)/(SELECT COUNT(*) FROM `hremployeeattrition`))*100 AS `Attrition Rate`
FROM `hremployeeattrition`
WHERE Attrition = 'Yes'
GROUP BY JobRole
ORDER BY `Attrition Rate` DESC
LIMIT 5;
/* Laboratory Technician job role with 62 employees have highest attrition rate of 4.22 approximately. */

-- Finding the average age of employees who have been promoted in the last 2 years
SELECT AVG(Age) as `Average Age`
FROM `hremployeeattrition`
WHERE YearsSinceLastPromotion <= 2;

-- Finding the departments with the highest average monthly income
SELECT Department, AVG(MonthlyIncome) as `Average Monthly Income`
FROM `hremployeeattrition`
GROUP BY Department
ORDER BY `Average Monthly Income` DESC;
/* Sales is the department, which has highest average monthly income. */

-- Finding the average age of the employees
SELECT AVG(Age) AS 'Average_Age'
FROM `hremployeeattrition`;
/* The average age of the employees in this dataset is approximately 37 years old. */

-- Checking the attrition rate
SELECT (COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) / COUNT(*)) * 100 AS 'Attrition_Rate' 
FROM `hremployeeattrition`;
/* The attrition rate of the employees is approximately 16%. */

-- Finding the average daily rate for each department
SELECT Department, AVG(DailyRate) AS 'Average_Daily_Rate'
FROM `hremployeeattrition`
GROUP BY Department;
/* We can see that the average daily rate is similar across all departments. */

-- Finding the education level of the employees with the highest monthly income
SELECT Education, MAX(MonthlyIncome) AS 'Max_Monthly_Income'
FROM `hremployeeattrition`
GROUP BY Education
ORDER BY Max_Monthly_Income DESC
LIMIT 1;
/* The employees with the highest monthly income have an education level of 4. */

-- Identifying the Top 5 job roles with the highest job satisfaction
SELECT JobRole, AVG(JobSatisfaction) AS 'Average_Job_Satisfaction'
FROM `hremployeeattrition`
GROUP BY JobRole
ORDER BY Average_Job_Satisfaction DESC
LIMIT 5;
/* We can see that healthcare representatives, research scientists
and sales executives have the highest job satisfaction among all job roles. */

-- Comparing the average monthly income of employees, who have overtime work and those who do not
SELECT OverTime, AVG(MonthlyIncome) AS 'Average_Monthly_Income'
FROM `hremployeeattrition`
GROUP BY OverTime;
/* Employees who have overtime work tend to have a higher average monthly income
compared to those who do not have overtime work. */

-- Examining the average distance from home for employees in each department
SELECT Department, AVG(DistanceFromHome) AS 'Average_Distance'
FROM `hremployeeattrition`
GROUP BY Department;

-- Comparing the job levels of employees who have overtime work and those who do not
SELECT OverTime, AVG(JobLevel) AS 'Average_Job_Level'
FROM `hremployeeattrition`
GROUP BY OverTime;
/* Employees who have overtime work tend to have a slightly higher average job level
compared to those who do not have overtime work */

-- Finding the correlation between age and total working years
SELECT (AVG(Age * TotalWorkingYears) - AVG(Age) * AVG(TotalWorkingYears)) /
        (SQRT(AVG(Age * Age) - AVG(Age) * AVG(Age)) *
         SQRT(AVG(TotalWorkingYears * TotalWorkingYears) - AVG(TotalWorkingYears) * AVG(TotalWorkingYears))) AS correlation_coefficient
FROM `hremployeeattrition`;
/* There is a moderate positive correlation between age and total working years,
meaning that as an employee's age increases, their total working years also tend to increase. */

/*
Data-driven Valuable Insights from the HR_Employee_Attrition Data:
==================================================================

*****************************************************************************************************************************

In conclusion, the key insights from this EDA are as follows:

- Laboratory Technician job role with 62 employees have highest attrition rate of 4.22 approximately.

- The average age of employees is approximately 37 years old.

- The attrition rate in this dataset is approximately 16%.

- The average daily rate is similar across all departments.

- The employees with the highest monthly income have an education level of 4.

- Healthcare representatives, research scientists and sales executives have the highest job satisfaction among all job roles.

- Employees who have overtime work tend to have a higher average monthly income and job level.

- There is a moderate positive correlation between age and total working years.

******************************************************************************************************************************
*/