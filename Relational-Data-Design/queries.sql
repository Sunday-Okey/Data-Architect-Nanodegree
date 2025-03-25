DROP TABLE IF EXISTS "salaries" CASCADE;

DROP TABLE IF EXISTS "education_levels" CASCADE;

DROP TABLE IF EXISTS "employees" CASCADE;

DROP TABLE IF EXISTS "cities" CASCADE;

DROP TABLE IF EXISTS "states" CASCADE;

DROP TABLE IF EXISTS "addresses" CASCADE;

DROP TABLE IF EXISTS "regions" CASCADE;

DROP TABLE IF EXISTS "jobs" CASCADE;

DROP TABLE IF EXISTS "departments" CASCADE;

DROP TABLE IF EXISTS "employee_records" CASCADE;

-- DATA DEFINITION LANGUAGE (DDL)

-- SALARIES TABLE

CREATE TABLE IF NOT EXISTS "salaries" (
    "salary_id" SERIAL PRIMARY KEY,
    "salary" INTEGER
);

-- EDUCATION LEVEL TABLE 
CREATE TABLE IF NOT EXISTS "education_levels" (
    "edu_lvl_id" SERIAL PRIMARY KEY,
    "edu_lvl" VARCHAR(100)
);


-- DEPARTMENT TABLE
CREATE TABLE IF NOT EXISTS "departments" (
    "dept_id" SERIAL PRIMARY KEY,
    "dept_nm" VARCHAR(100)
    );


-- JOB TITLE TABLE
CREATE TABLE IF NOT EXISTS "jobs" (
    "job_id" SERIAL PRIMARY KEY,
    "job" VARCHAR(100)
);


-- REGION TABLE
CREATE TABLE IF NOT EXISTS "regions" (
    "region_id" SERIAL PRIMARY KEY,
    "region_nm" VARCHAR(50)
);


-- STATE TABLE 
CREATE TABLE IF NOT EXISTS "states" (
    "state_id" SERIAL PRIMARY KEY,
    "state" VARCHAR(50),
    "region_id" INTEGER REFERENCES "regions"
);


-- CITY TABLE
CREATE TABLE IF NOT EXISTS "cities" (
    "city_id" SERIAL PRIMARY KEY,
    "city" VARCHAR(50),
    "state_id" INTEGER REFERENCES "states"
);


-- ADDRESS TABLE 
CREATE TABLE IF NOT EXISTS "addresses" (
    "address_id" SERIAL PRIMARY KEY,
    "address" VARCHAR(100),
    "city_id" INTEGER REFERENCES "cities"
);


-- EMPLOYEE TABLE
CREATE TABLE IF NOT EXISTS "employees" (
    "emp_id" VARCHAR(8) PRIMARY KEY,
    "emp_nm" VARCHAR(100),
    "email" VARCHAR(100),
    "edu_lvl_id" INTEGER REFERENCES "education_levels"
);


-- EMPLOYEE RECORDS TABLE
CREATE TABLE IF NOT EXISTS "employee_records" (
    
    "emp_id" VARCHAR(8) REFERENCES "employees",
    "hire_date" DATE,
    "start_date" DATE,
    "end_date" DATE,
    "manager_id" VARCHAR(8) REFERENCES "employees",
    "salary_id" INTEGER REFERENCES "salaries", 
    "dept_id"INTEGER REFERENCES "departments",
    "job_id" INTEGER REFERENCES "jobs",
    "address_id" INTEGER REFERENCES "addresses",
    CONSTRAINT "emp_hist_pk" PRIMARY KEY ("emp_id", "start_date")
);


-- DATA MANIPULATION LANGUAGE (DML)


-- Insert into SALARIES table
INSERT INTO salaries (salary)
SELECT DISTINCT salary
FROM proj_stg;

-- Insert into EDUCATION_LEVELS table
INSERT INTO education_levels (edu_lvl)
SELECT DISTINCT education_lvl
FROM proj_stg;

-- Insert into REGIONS table
INSERT INTO regions (region_nm)
SELECT DISTINCT location
FROM proj_stg;

-- Insert into DEPARTMENTS table
INSERT INTO departments (dept_nm)
SELECT DISTINCT department_nm
FROM proj_stg;

-- Insert into JOBS table
INSERT INTO jobs (job)
SELECT DISTINCT job_title
FROM proj_stg;


-- Insert into STATES table
INSERT INTO states (state, region_id)
SELECT DISTINCT 
    p.state, 
    r.region_id
FROM 
    proj_stg p
JOIN 
    regions r ON p.location = r.region_nm;

-- Insert into CITIES table
INSERT INTO cities (city, state_id)
SELECT DISTINCT 
    p.city, 
    s.state_id
FROM 
    proj_stg p
JOIN 
    states s ON p.state = s.state;

-- Insert into ADDRESSES table
INSERT INTO addresses (address, city_id)
SELECT DISTINCT 
    p.address, 
    c.city_id
FROM 
    proj_stg p
JOIN 
    cities c ON p.city = c.city;

-- Insert into EMPLOYEES table
INSERT INTO employees (emp_id, emp_nm, email, edu_lvl_id)
SELECT DISTINCT 
    p.emp_id, 
    p.emp_nm, 
    p.email, 
    e.edu_lvl_id
FROM 
    proj_stg p
JOIN 
    education_levels e ON p.education_lvl = e.edu_lvl;

-- Insert into EMPLOYEE_RECORDS table
INSERT INTO employee_records (
    emp_id, 
    start_date, 
    hire_date, 
    end_date, 
    manager_id, 
    salary_id, 
    dept_id, 
    job_id, 
    address_id
)
SELECT DISTINCT 
    e.emp_id, 
    p.start_dt, 
    p.hire_dt, 
    p.end_dt, 
    m.emp_id, 
    s.salary_id, 
    d.dept_id, 
    j.job_id, 
    a.address_id
FROM 
    proj_stg p 
JOIN 
    jobs j ON j.job = p.job_title 
JOIN 
    employees e ON e.emp_id = p.emp_id
LEFT JOIN 
    employees m ON p.manager = m.emp_nm
LEFT JOIN 
    departments d ON p.department_nm = d.dept_nm
LEFT JOIN 
    addresses a ON p.address = a.address
LEFT JOIN 
    salaries s ON s.salary = p.salary;

-- Question 1: Return a list of employees with Job Titles and Department Names

SELECT emp_nm employees, job AS job_title, dept_nm department
FROM employees
JOIN employee_records USING(emp_id)
JOIN jobs USING (job_id)
JOIN departments USING (dept_id)
LIMIT 5;

-- Question 2: Insert Web Programmer as a new job title

INSERT INTO jobs ("job")
VALUES ('Web Programmer');

-- Question 3: Correct the job title from web programmer to web developer

UPDATE jobs 
SET "job" = 'Web Developer'
WHERE "job" = 'Web Programmer';

-- Question 4: Delete the job title Web Developer from the database

DELETE FROM jobs
WHERE job = 'Web Developer';

-- Question 5: How many employees are in each department?


SELECT dept_nm, COUNT(*) no_of_employees
FROM employees
JOIN employee_records USING(emp_id)
JOIN departments USING (dept_id)
GROUP BY 1;

/* Question 6: Write a query that returns current and past jobs
(include employee name, job title, department, manager name, start and
end date for position) for employee Toni Lembeck. */


WITH employee_data AS (
    SELECT
        er.emp_id,
        e.emp_nm,
        j.job,
        d.dept_nm,
        er.manager_id,
        er.start_date,
        er.end_date
    FROM employee_records er
    INNER JOIN employees e 
        ON er.emp_id = e.emp_id
    INNER JOIN departments d 
        ON er.dept_id = d.dept_id
    INNER JOIN jobs j 
        ON er.job_id = j.job_id
)

SELECT
    e.emp_nm AS employee,
    e.job AS job_title,
    e.dept_nm AS department,
    m.emp_nm AS manager,
    e.start_date,
    e.end_date
FROM employee_data e
INNER JOIN employee_data m 
    ON e.manager_id = m.emp_id
WHERE e.emp_nm = 'Toni Lembeck'
ORDER BY e.start_date DESC;



/*Create a view that returns all employee attributes; results should 
resemble initial Excel file */

DROP VIEW IF EXISTS emp;

CREATE VIEW emp AS (
WITH employee_data AS (
    SELECT
        er.emp_id,
        e.emp_nm,
		e.email,
        j.job,
        d.dept_nm,
        er.manager_id,
        er.start_date,
        er.end_date,
		er.hire_date,
		edu_lvl,
		salary,
		address,
		region_nm,
		state,
		city
    FROM  employees e
    INNER JOIN employee_records er
        ON er.emp_id = e.emp_id
    INNER JOIN departments d 
        ON er.dept_id = d.dept_id
    INNER JOIN jobs j 
        ON er.job_id = j.job_id
    INNER JOIN education_levels 
        USING(edu_lvl_id)
    INNER JOIN salaries 
        USING(salary_id)
    INNER JOIN addresses
        USING(address_id)
	INNER JOIN cities 
        USING(city_id)
    INNER JOIN states 
        USING(state_id)
	 INNER JOIN regions 
        USING(region_id)
)

SELECT
	e1.emp_id,
    e1.emp_nm,
	e1.email,
	e1.hire_date AS hire_dt,
    e1.job AS job_title,
	e1.salary,
    e1.dept_nm AS department_nm,
    m.emp_nm AS manager,
    e1.start_date AS start_dt,
    e1.end_date AS end_dt,
	e1.region_nm location,
	e1.address,
	e1.city,
	e1.state,
	e1.edu_lvl AS education_level
FROM employee_data e1
LEFT JOIN employee_data m 
    ON e1.manager_id = m.emp_id
);

SELECT * FROM emp;


/* Create a stored procedure with parameters that returns current and past jobs
(include employee name, job title, department, manager name,
start and end date for position) when given an employee name. */


DROP FUNCTION IF EXISTS GetEmployeeJobHistory(VARCHAR);

CREATE OR REPLACE FUNCTION GetEmployeeJobHistory(employee_name VARCHAR(100))
RETURNS TABLE (
    employee VARCHAR(100),
    job_title VARCHAR,
    department VARCHAR,
    manager VARCHAR(100),
    start_date DATE,
    end_date DATE
)
AS $$
BEGIN
    RETURN QUERY 
    WITH employee_data AS (
        SELECT
            er.emp_id,
            e.emp_nm,
            j.job,
            d.dept_nm,
            er.manager_id,
            er.start_date,
            er.end_date
        FROM employee_records er
        JOIN employees e ON er.emp_id = e.emp_id
        JOIN departments d ON er.dept_id = d.dept_id
        JOIN jobs j ON er.job_id = j.job_id
    )
    SELECT
        e.emp_nm AS employee,
        e.job AS job_title,
        e.dept_nm AS department,
        m.emp_nm AS manager,
        e.start_date,
        e.end_date
    FROM employee_data e
    INNER JOIN employee_data m ON e.manager_id = m.emp_id
    WHERE e.emp_nm = employee_name
    ORDER BY e.start_date DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM GetEmployeeJobHistory('Toni Lembeck');




-- Implement user security on the restricted salary attribute.

-- Step 1: Create the non-management user
CREATE USER NoMgr WITH PASSWORD 'password';

-- Step 2: Grant access to all tables in the public schema
GRANT CONNECT ON DATABASE project TO NoMgr;
GRANT USAGE ON SCHEMA public TO NoMgr;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO NoMgr;

-- Step 3: Revoke access to the salaries table in the public schema
REVOKE ALL ON TABLE public.salaries FROM NoMgr;
-- GRANT SELECT ON TABLE public.salaries TO NoMgr;





