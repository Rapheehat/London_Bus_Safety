-- EXPLORATORY DATA ANALYSIS

-- Q1. What are the most common types of incidents?
SELECT incident_event_type, COUNT(*) as incident_count
FROM incidents
GROUP BY incident_event_type
ORDER BY incident_count DESC;

-- Q2. Which routes have the highest number of incidents?
SELECT route, COUNT(*) as incident_count
FROM incidents
GROUP BY route
ORDER BY incident_count DESC
LIMIT 10;

-- Q3. How many incidents occurred each year?
SELECT year, COUNT(*) as incident_count
FROM incidents
GROUP BY year
ORDER BY year;

-- Q4. Which operator has the most incidents?
SELECT o.operator, COUNT(*) as incident_count
FROM incidents AS i
JOIN operators o ON i.operator_id = o.operator_id
GROUP BY o.operator
ORDER BY incident_count DESC;

-- Q5. How do incident rates vary between different operator groups?
SELECT o.group_name, COUNT(*) as incident_count
FROM incidents AS i
JOIN operators o ON i.operator_id = o.operator_id
GROUP BY o.group_name
ORDER BY incident_count DESC;

-- Q6. What is the distribution of incidents by victim category?
SELECT v.victim_category, COUNT(*) as victim_count
FROM incidents i
JOIN victims v ON i.victim_id = v.victim_id
GROUP BY v.victim_category
ORDER BY victim_count DESC;

-- Q7. What are the most common victim demographics (age and sex)?
SELECT v.victims_sex, v.victims_age, COUNT(*) AS victim_count
FROM incidents i
JOIN victims v ON i.victim_id = v.victim_id
GROUP BY v.victims_sex , v.victims_age
ORDER BY v.victims_sex;

-- Q8. Which boroughs have the highest number of incidents?
SELECT borough, COUNT(*) as incident_count
FROM incidents
GROUP BY borough
ORDER BY incident_count DESC
LIMIT 20;

-- Q9. Are there any bus garages that are associated with a higher number of incidents?
SELECT g.bus_garage, COUNT(*) as incident_count
FROM incidents i
JOIN bus_garages g ON i.bus_garage_id = g.bus_garage_id
GROUP BY g.bus_garage
ORDER BY incident_count DESC;

-- Q10. Is there a particular month of the year when incidents are more common?
SELECT MONTH(date_of_incident) as month, COUNT(*) as incident_count
FROM incidents
GROUP BY month
ORDER BY incident_count DESC;

-- Q11. What is the distribution of incidents based on injury result description?
SELECT injury_result_description, COUNT(*) as incident_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incidents), 1) as percentage
FROM incidents
GROUP BY injury_result_description
ORDER BY incident_count DESC;

-- Q12. How do incident rates vary between different times of the year (seasons)?
SELECT 
  CASE 
    WHEN MONTH(date_of_incident) IN (12, 1, 2) THEN 'Winter'
    WHEN MONTH(date_of_incident) IN (3, 4, 5) THEN 'Spring'
    WHEN MONTH(date_of_incident) IN (6, 7, 8) THEN 'Summer'
    WHEN MONTH(date_of_incident) IN (9, 10, 11) THEN 'Fall'
  END as season,
  COUNT(*) as incident_count
FROM incidents
GROUP BY season
ORDER BY incident_count DESC;

-- Q13. What is the age distribution of victims involved in incidents?
SELECT victims_age, COUNT(*) as victim_count
FROM victims v
JOIN incidents i ON v.victim_id = i.victim_id
GROUP BY victims_age
ORDER BY victim_count DESC;

-- Q14. What is the average number of incidents per route?
SELECT AVG(incident_count) as average_incidents_per_route
FROM (
  SELECT route, COUNT(*) as incident_count
  FROM incidents
  GROUP BY route
) as route_incidents;

-- Q15. Analyze the frequency of incidents involving multiple victims.
SELECT i.date_of_incident, o.operator, COUNT(*) AS victim_count
FROM incidents i
JOIN operators o ON o.operator_id = i.operator_id
GROUP BY i.date_of_incident, o.operator_id
HAVING victim_count > 1
ORDER BY victim_count DESC;
