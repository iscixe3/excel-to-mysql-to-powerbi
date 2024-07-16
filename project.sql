CREATE DATABASE hr;

USE hr;

SELECT * FROM hr_data;

ALTER TABLE hr_data
RENAME COLUMN ï»¿id TO id;

SELECT birthdate FROM hr_data
WHERE birthdate LIKE '%-%';

UPDATE hr_data
SET birthdate = CONCAT(LEFT(birthdate, 6),'19',RIGHT(birthdate,2))
WHERE birthdate LIKE '%-__';

UPDATE hr_data
SET termdate = 
NULLIF(termdate, TRIM(termdate)=' ');

SELECT hire_date FROM hr_data
WHERE hire_date LIKE '%-%';

UPDATE hr_data
SET hire_date = CONCAT(LEFT(hire_date, 6),'20',RIGHT(hire_date,2))
WHERE hire_date LIKE '%-__';

SELECT termdate
FROM hr_data
WHERE termdate IS NOT NULL
ORDER BY termdate DESC;

UPDATE hr_data
SET termdate = str_to_date(LEFT(termdate,19), '%Y-%m-%d %H:%i:%s')
WHERE termdate IS NOT NULL;

ALTER TABLE hr_data
MODIFY COLUMN termdate
DATE;

UPDATE hr_data
SET birthdate = REPLACE(birthdate, '/', '-');


UPDATE hr_data
SET birthdate = str_to_date(birthdate, '%m-%d-%Y');

ALTER TABLE hr_data
MODIFY COLUMN birthdate
DATE;

SELECT birthdate FROM hr_data;

UPDATE hr_data
SET hire_date = REPLACE(hire_date, '/', '-');

UPDATE hr_data
SET hire_date = str_to_date(hire_date, '%m-%d-%Y');

ALTER TABLE hr_data
MODIFY COLUMN hire_date
DATE;

-- create a new column "age"
ALTER TABLE hr_data
ADD age varchar(50); 

-- populate new colum with age
UPDATE hr_data
SET age = FLOOR(DATEDIFF(CURRENT_DATE, birthdate) / 365);

SELECT * FROM hr_data;

-- QUESTIONS TO ANSWER FROM THE DATA



-- 1) What's the age distribution in the company?
-- age distribution  

WITH cte as (
SELECT age,
	CASE
		WHEN age >= 21 AND age <= 30 THEN '21-30'
        WHEN age >= 31 AND age <= 40 THEN '31-40'
        WHEN age >= 41 AND age <= 50 THEN '41-50'
        ELSE '51+'
        END as age_range
FROM hr_data
WHERE termdate is NULL)
SELECT age_range, count(age_range) as total_count
FROM cte
GROUP BY age_range;

-- age group by gender

WITH cte as (
SELECT age,
	CASE
		WHEN age >= 21 AND age <= 30 THEN '21-30'
        WHEN age >= 31 AND age <= 40 THEN '31-40'
        WHEN age >= 41 AND age <= 50 THEN '41-50'
        ELSE '51+'
        END as age_range, gender
FROM hr_data
WHERE termdate is NULL)
SELECT age_range, gender, count(*) as total_count
FROM cte
GROUP BY age_range, gender
ORDER BY gender, total_count DESC;

-- 2) What's the gender breakdown in the company?

SELECT gender, count(*) count
FROM hr_data
WHERE termdate is NULL
GROUP BY gender;

-- 3) How does gender vary across departments and job titles?
--  departments

SELECT  department, gender, count(*) count
FROM hr_data
WHERE termdate is NULL
GROUP BY department,gender
ORDER BY department, count DESC;

-- job title

SELECT  department, jobtitle, gender, count(*) count
FROM hr_data
WHERE termdate is NULL
GROUP BY department,jobtitle,gender
ORDER BY department,jobtitle, count DESC;

-- 4) What's the race distribution in the company?

SELECT race, count(*) count
FROM hr_data
WHERE termdate is NULL
GROUP BY race
ORDER BY count DESC;

-- 5) What's the average length of employment in the company?

SELECT AVG(timestampdiff(YEAR, hire_date, termdate)) average_length FROM hr_data
WHERE termdate <= curdate() ;

-- 6) Which department has the highest turnover rate?
-- get total count
-- get terminated count
-- terminated count/total count

WITH CTE AS(
SELECT department, count(*) as department_count,
SUM(CASE
	WHEN
		termdate <= curdate()
        THEN  1 ELSE 0
        END) AS term_count
    FROM hr_data
    GROUP BY department)
SELECT department, department_count, term_count, ROUND(((term_count / department_count) * 100),2) as turnover_rate 
FROM cte
ORDER BY turnover_rate DESC;
  

-- 7) What is the tenure distribution for each department?

SELECT department, AVG(timestampdiff(YEAR, hire_date, termdate)) average_length
FROM hr_data
WHERE termdate  <= curdate() 
GROUP BY department
ORDER BY average_length DESC;

-- 8) How many employees work remotely for each department?
-- employee count per location
SELECT location, count(*) as count_of_employee
FROM hr_data
WHERE termdate IS NULL
GROUP BY location
ORDER BY count_of_employee DESC;

-- remote employee count per department
SELECT department, count(*) as total_remote_employee FROM hr_data
WHERE location = 'remote' AND termdate IS NULL
GROUP BY department
ORDER BY total_remote_employee DESC;

-- 9) What's the distribution of employees across different states?

SELECT location_state, count(*) AS count from hr_data
WHERE termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 10) How are job titles distributed in the company?

SELECT jobtitle, count(*) AS count FROM hr_data
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;

-- 11) How have employee hire counts varied over time?
-- calcute hires
-- calcute terminations
-- (hires-termination)/hires = percent hire change

WITH cte AS (
SELECT YEAR(hire_date) AS hire_year ,count(*) AS hires, SUM(CASE
	WHEN
		termdate <= curdate()
        THEN  1 ELSE 0
        END) AS term_count
 FROM hr_data
 GROUP BY hire_year)
 SELECT *, 
 (hires-term_count)/hires *100 AS percent_hire_change
 FROM cte
 ORDER BY hire_year;
