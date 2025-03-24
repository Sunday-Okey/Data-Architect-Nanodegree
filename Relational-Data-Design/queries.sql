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

