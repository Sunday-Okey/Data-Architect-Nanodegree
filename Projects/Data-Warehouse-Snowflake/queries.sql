-- Table: user
CREATE OR REPLACE TABLE user (
    user_id VARCHAR PRIMARY KEY,
    name VARCHAR,
    review_count INT,
    yelping_since DATE,
    useful INT,
    funny INT,
    cool INT,
    elite VARIANT,
    friends VARIANT,
    fans INT,
    average_stars DOUBLE,
    compliment_hot INT,
    compliment_more INT,
    compliment_profile INT,
    compliment_cute INT,
    compliment_list INT,
    compliment_note INT,
    compliment_plain INT,
    compliment_cool INT,
    compliment_funny INT,
    compliment_writer INT,
    complement_photos INT
);

-- Table: business
CREATE OR REPLACE TABLE business (
    business_id VARCHAR PRIMARY KEY,
    name VARCHAR,
    address VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code VARCHAR,
    latitude FLOAT,
    longitude FLOAT,
    stars DOUBLE,
    review_count INT,
    is_open INT,
    attributes VARIANT,
    hours VARIANT
);

-- Table: review
CREATE OR REPLACE TABLE review (
    review_id VARCHAR PRIMARY KEY,
    user_id VARCHAR,
    business_id VARCHAR,
    stars INT,
    useful BOOLEAN,
    funny BOOLEAN,
    cool BOOLEAN,
    text VARCHAR,
    date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user (user_id),
    FOREIGN KEY (business_id) REFERENCES business (business_id)
);

-- Table: tip
CREATE OR REPLACE TABLE tip (
    tip_id INT AUTOINCREMENT PRIMARY KEY,
    user_id VARCHAR,
    business_id VARCHAR,
    text VARCHAR,
    date DATE,
    compliment_count INT,
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (business_id) REFERENCES business(business_id)
);

-- Table: checkings
CREATE OR REPLACE TABLE checkin (
    business_id VARCHAR,
    date DATE,
    FOREIGN KEY (business_id) REFERENCES business(business_id)
);

-- Table: covid19
CREATE OR REPLACE TABLE covid (
    business_id VARCHAR PRIMARY KEY,
    highlights VARCHAR,
    delivery_or_takeout BOOLEAN,
    grubhub_enabled BOOLEAN,
    call_to_action_enabled BOOLEAN,
    request_a_quote_enabled BOOLEAN,
    covid_banner BOOLEAN,
    temporary_closed_until BOOLEAN,
    virtual_services_ofered BOOLEAN,
    FOREIGN KEY (business_id) REFERENCES business(business_id)
);

-- Table: temperature
CREATE OR REPLACE TABLE temperature (
    date DATE PRIMARY KEY,
    max FLOAT,
    min FLOAT,
    normal_max FLOAT,
    normal_min FLOAT
);

-- Table: precipitation
CREATE OR REPLACE TABLE precipitation (
    date DATE PRIMARY KEY,
    precipitation FLOAT,
    precipitation_normal FLOAT
);



INSERT INTO BUSINESS (
    business_id,
    name,
    address,
    city,
    state,
    postal_code,
    latitude,
    longitude,
    stars,
    review_count,
    is_open,
    attributes,
    hours
)
SELECT
    DISTINCT
    BUSINESSJSON:business_id::STRING AS business_id,
    BUSINESSJSON:name::STRING AS name,
    BUSINESSJSON:address::STRING AS address,
    BUSINESSJSON:city::STRING AS city,
    BUSINESSJSON:state::STRING AS state,
    BUSINESSJSON:postal_code::STRING AS postal_code,
    BUSINESSJSON:latitude::FLOAT AS latitude,
    BUSINESSJSON:longitude::FLOAT AS longitude,
    BUSINESSJSON:stars::INT AS stars,
    BUSINESSJSON:review_count::INTEGER AS review_count,
    BUSINESSJSON:is_open::INTEGER AS is_open,
    BUSINESSJSON:attributes::VARIANT AS attributes,
    BUSINESSJSON:hours::VARIANT AS hours
FROM UDACITYPROJECT.STAGING.BUSINESS;




INSERT INTO user
SELECT DISTINCT
    USERJSON:user_id::STRING AS user_id,
    USERJSON:name::STRING AS name,
    USERJSON:review_count::INTEGER AS review_count,
    TRY_TO_DATE(USERJSON:yelping_since::STRING) AS yelping_since,
    USERJSON:useful::INTEGER AS useful,
    USERJSON:funny::INTEGER AS funny,
    USERJSON:cool::INTEGER AS cool,
    USERJSON:elite::ARRAY AS elite,
    USERJSON:friends::ARRAY AS friends,
    USERJSON:fans::INTEGER AS fans,
    USERJSON:average_stars::FLOAT AS average_stars,
    USERJSON:compliment_hot::INTEGER AS compliment_hot,
    USERJSON:compliment_more::INTEGER AS compliment_more,
    USERJSON:compliment_profile::INTEGER AS compliment_profile,
    USERJSON:compliment_cute::INTEGER AS compliment_cute,
    USERJSON:compliment_list::INTEGER AS compliment_list,
    USERJSON:compliment_note::INTEGER AS compliment_note,
    USERJSON:compliment_plain::INTEGER AS compliment_plain,
    USERJSON:compliment_cool::INTEGER AS compliment_cool,
    USERJSON:compliment_funny::INTEGER AS compliment_funny,
    USERJSON:compliment_writer::INTEGER AS compliment_writer,
    USERJSON:compliment_photos::INTEGER AS compliment_photos
FROM UDACITYPROJECT.STAGING.user;


-- INSERT INTO reviews
INSERT INTO REVIEW
SELECT DISTINCT
    REVIEWJSON:review_id::VARCHAR AS review_id,
    REVIEWJSON:user_id::VARCHAR AS user_id,
    REVIEWJSON:business_id::VARCHAR AS business_id,
    REVIEWJSON:stars::INT AS stars,
    REVIEWJSON:useful::INT AS useful,  
    REVIEWJSON:funny::INT > 0 AS funny,    
    REVIEWJSON:cool::INT > 0 AS cool,      
    REVIEWJSON:text::TEXT AS text,
    TRY_TO_DATE(REVIEWJSON:date::STRING) AS date
FROM UDACITYPROJECT.STAGING.REVIEW;


INSERT INTO TIP (user_id, business_id, text, date, compliment_count)
SELECT DISTINCT
    TIPJSON:user_id::VARCHAR AS user_id,
    TIPJSON:business_id::VARCHAR AS business_id,
    TIPJSON:text::VARCHAR AS text,
    TIPJSON:date::DATE AS date,
    TIPJSON:compliment_count::INT AS compliment_count
FROM UDACITYPROJECT.STAGING.TIP;


INSERT INTO CHECKIN (business_id, date)
SELECT
    CHECKINJSON:business_id::VARCHAR AS business_id,
    TRY_TO_DATE(value::STRING) AS date
FROM UDACITYPROJECT.STAGING.CHECKIN,
LATERAL FLATTEN(INPUT => SPLIT(CHECKINJSON:date::STRING, ', ')) date_list;





INSERT INTO PRECIPITATION
SELECT *
FROM UDACITYPROJECT.STAGING.PRECIPITATION;


INSERT INTO COVID
SELECT COVIDJSON:business_id::VARCHAR AS business_id,
    COVIDJSON:highlights::VARCHAR AS highlights,
    COVIDJSON:delivery_or_takeout::INT > 0 AS delivery_or_takeout,
    COVIDJSON:grubhub_enabled::INT > 0 AS grubhub_enabled,
    COVIDJSON:call_to_action_enabled::INT > 0 AS call_to_action_enabled,
    COVIDJSON:request_a_quote_enabled::INT > 0 AS request_a_quote_enabled,
    COVIDJSON:covid_banner::INT > 0 AS covid_banner,
    COVIDJSON:temporary_closed_until::INT > 0 AS temporary_closed_until,
    COVIDJSON:virtual_services_ofered::INT > 0 AS virtual_services_ofered
FROM UDACITYPROJECT.STAGING.COVID;





-- Dimension table for businesses
CREATE OR REPLACE TABLE dim_business (
    business_id VARCHAR PRIMARY KEY,
    name VARCHAR,
    address VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code VARCHAR,
    latitude FLOAT,
    longitude FLOAT
);

-- Dimension table for temperature data
CREATE OR REPLACE TABLE dim_temperature (
    date DATE PRIMARY KEY,
    min FLOAT,
    max FLOAT,
    normal_min FLOAT,
    normal_max FLOAT
);

-- Dimension table for precipitation data
CREATE OR REPLACE TABLE dim_precipitation (
    date DATE PRIMARY KEY,
    precipitation FLOAT,
    precipitation_normal FLOAT
);

-- Fact table for business reviews and interactions
CREATE OR REPLACE TABLE fact (
    review_id VARCHAR,
    user_id VARCHAR,
    business_id VARCHAR,
    review_count INT,
    date DATE,
    stars INT,
    useful BOOLEAN,
    funny BOOLEAN,
    cool BOOLEAN,
    FOREIGN KEY (business_id) REFERENCES dim_business(business_id),
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (date) REFERENCES dim_temperature(date),
    FOREIGN KEY (date) REFERENCES dim_precipitation(date)
);

CREATE OR REPLACE TABLE dim_user (
    user_id VARCHAR PRIMARY KEY,
    name VARCHAR,
    yelping_since DATE
);



INSERT INTO dim_user
SELECT user_id, name, TRY_TO_DATE(yelping_since) AS yelping_since
FROM UDACITYPROJECT.ODS.USER;



INSERT INTO dim_temperature
SELECT *
FROM UDACITYPROJECT.ODS.TEMPERATURE;

INSERT INTO dim_precipitation
SELECT *
FROM UDACITYPROJECT.ODS.PRECIPITATION;


INSERT INTO DIM_BUSINESS
SELECT business_id,
    name,
    address,
    city,
    state,
    postal_code,
    latitude,
    longitude
FROM UDACITYPROJECT.ODS.BUSINESS;

-- INSERT INTO FACT
INSERT INTO fact
SELECT
    r.review_id,
    u.user_id,
    r.business_id,
    u.review_count,
    TO_DATE(r.date) AS date,
    r.stars,
    r.useful,
    r.funny,
    r.cool
FROM UDACITYPROJECT.ODS.REVIEW AS r
JOIN UDACITYPROJECT.ODS.USER AS u
    ON r.user_id = u.user_id;


-- INTEGRATION QUERY
SELECT
    r.review_id,
    r.stars,
    r.date,
    t.min,
    t.max,
    t.normal_min,
    t.normal_max,
    p.precipitation,
    p.precipitation_normal
FROM review AS r
LEFT JOIN temperature AS t
    ON r.date = t.date
LEFT JOIN precipitation AS p
    ON r.date = p.date;


-- FINAL REPORTING QUERY
SELECT
    f.date,
    db.name,
    AVG(f.stars) AS average_stars,
    dt.min,
    dt.max,
    dt.precipitation,
    dt.precipitation_normal,
    db.city,
    db.state
FROM fact AS f
LEFT JOIN dim_business AS db
    ON f.business_id = db.business_id
LEFT JOIN dim_temperature AS dt
    ON f.date = dt.date
LEFT JOIN dim_precipitation AS dp
    ON f.date = dp.date
GROUP BY
    f.date,
    db.name,
    dt.min,
    dt.max,
    dp.precipitation,
    dp.precipitation_normal,
    db.city,
    db.state
ORDER BY f.date DESC;


put "file:///Users/Sunday Okechukwu/Downloads/temps.csv" @my_csv_stage auto_compress=true;

put 'file:///Users/Sunday Okechukwu/Downloads/precipitations.csv' @my_csv_stage auto_compress=true;


copy into "precipitation" from @my_csv_stage/precipitations.csv.gz file_format=mycsvformat on_error='skip_file';
copy into "temperature" from @my_csv_stage/temps.csv.gz file_format=mycsvformat on_error='skip_file';


-- INSERT INTO dim_temperature
-- SELECT TO_DATE(date, 'YYYYMMDD') as date, to_double(min_val) min_val, to_double(max_val) max_val, to_double(normal_min) normal_min, to_double(normal_max) normal_max
-- FROM UDACITYPROJECT.staging.temperature

-- drop table "temperature";
-- drop table "precipitation";

create or replace table dim_temperature (
  date DATE, min_val DOUBLE, max_val DOUBLE, normal_min DOUBLE, 
  normal_max DOUBLE);


--   create or replace table precipitation (
--   date STRING, precipitation STRING, precipitation_normal STRING);

-- copy into precipitation from @my_csv_stage/precipitations.csv.gz file_format=mycsvformat on_error='skip_file';
-- copy into temperature from @my_csv_stage/temps.csv.gz file_format=mycsvformat on_error='skip_file';


create or replace table "temperature" (
  "date" STRING, "min" STRING, "max" STRING, "normal_min" STRING, 
  "normal_max" STRING);


  create or replace table "precipitation" (
  "date" STRING, "precipitation" STRING, "precipitation_normal" STRING);


  create or replace table dim_precipitation (
  date DATE, precipitation STRING, precipitation_normal STRING);

copy into precipitation from @my_csv_stage/precipitations.csv.gz file_format=mycsvformat on_error='skip_file';


insert into dim_precipitation
select  date, precipitation, precipitation_normal
from udacityproject.ods.precipitation