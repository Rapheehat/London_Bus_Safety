-- Data Cleaning

-- Highighting the particular project to be used
USE bus_incidents;

-- Inspect the data
SELECT * 
FROM tfl_bus_safety;

-- Create a copy of the table
CREATE TABLE temp_incidents LIKE tfl_bus_safety;

INSERT INTO temp_incidents
SELECT * 
FROM tfl_bus_safety;

-- Add a temporary unique identifier
ALTER TABLE temp_incidents ADD COLUMN unique_id INT AUTO_INCREMENT PRIMARY KEY;

-- Remove duplicates
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY year, date_of_incident, route, operator, group_name, bus_garage, borough, 
                            injury_result_description, incident_event_type, victim_category, victims_sex, victims_age
           ) AS row_num
    FROM temp_incidents
)
DELETE FROM temp_incidents
WHERE unique_id IN (
    SELECT unique_id
    FROM cte
    WHERE row_num > 1
);

-- Delete the duplicates
WITH cte AS (
    SELECT unique_id,
           ROW_NUMBER() OVER (
               PARTITION BY year, date_of_incident, route, operator, group_name, bus_garage, borough, 
                            injury_result_description, incident_event_type, victim_category, victims_sex, victims_age
               ORDER BY (SELECT NULL)  -- Can be replaced with a specific column if order matters
           ) AS row_num
    FROM temp_incidents
)
DELETE FROM temp_incidents
WHERE unique_id IN (
    SELECT unique_id
    FROM cte
    WHERE row_num > 1
);

-- Remove temporary unique Id
ALTER TABLE temp_incidents DROP COLUMN unique_id;

-- Confirm that duplicates have been deleted
SELECT *
FROM temp_incidents;

-- Change type for date_of_incident and route
ALTER TABLE temp_incidents MODIFY COLUMN date_of_incident DATE;
ALTER TABLE temp_incidents MODIFY COLUMN route VARCHAR(10);

-- Creating Tables
CREATE TABLE operators (
  operator_id INT AUTO_INCREMENT PRIMARY KEY,
  operator TEXT,
  group_name TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE bus_garages (
  bus_garage_id INT AUTO_INCREMENT PRIMARY KEY,
  bus_garage TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE victims (
  victim_id INT AUTO_INCREMENT PRIMARY KEY,
  victim_category TEXT,
  victims_sex TEXT,
  victims_age TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE incidents (
  incident_id INT AUTO_INCREMENT PRIMARY KEY,
  year INT DEFAULT NULL,
  date_of_incident DATE DEFAULT NULL,
  route VARCHAR(10) DEFAULT NULL,
  borough TEXT,
  injury_result_description TEXT,
  incident_event_type TEXT,
  operator_id INT,
  bus_garage_id INT,
  victim_id INT,
  FOREIGN KEY (operator_id) REFERENCES operators(operator_id),
  FOREIGN KEY (bus_garage_id) REFERENCES bus_garages(bus_garage_id),
  FOREIGN KEY (victim_id) REFERENCES victims(victim_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populate each table
-- Operators Table
INSERT INTO operators (operator, group_name)
SELECT DISTINCT operator, group_name FROM temp_incidents;

-- Bus Garages Table
INSERT INTO bus_garages (bus_garage)
SELECT DISTINCT bus_garage FROM temp_incidents;

-- Victims Table
INSERT INTO victims (victim_category, victims_sex, victims_age)
SELECT DISTINCT victim_category, victims_sex, victims_age FROM temp_incidents;

-- Incidents Table
INSERT INTO incidents (year, date_of_incident, route, borough, injury_result_description, incident_event_type, operator_id, bus_garage_id, victim_id)
SELECT
    t.year,
    t.date_of_incident,
    t.route,
    t.borough,
    t.injury_result_description,
    t.incident_event_type,
    o.operator_id,
    g.bus_garage_id,
    v.victim_id
FROM
    temp_incidents t
JOIN operators o ON t.operator = o.operator AND t.group_name = o.group_name
JOIN bus_garages g ON t.bus_garage = g.bus_garage
JOIN victims v ON t.victim_category = v.victim_category AND t.victims_sex = v.victims_sex AND t.victims_age = v.victims_age;

-- Verify the contents of the tables
SELECT * FROM operators;
SELECT * FROM bus_garages;
SELECT * FROM victims;
SELECT * FROM incidents;

-- drop temp_incidents table
DROP TABLE temp_incidents;


















