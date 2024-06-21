The following are the quesries needed for each problem:

1. For each species in each system, list the numbers of hatchery and wild tags going out and the timing of those detections (to be able to compare hatchery and wild outmigrations).

```SQL
WITH hatchTagCount AS (
  SELECT COUNT(*) AS count, system, species, date_time_release::DATE, tag_id_long, 'hatchery' AS origin
  FROM hatch_tag
  GROUP BY system, species, date_time_release, tag_id_long
), fieldCount AS (
  SELECT COUNT(*) AS count, watershed, species, date, tag_id_long, 'field' AS origin
  FROM field 
  WHERE tag_status = 'tag'
  AND clip_status = 'unclip'
  GROUP BY watershed, species, date, tag_id_long
), locationDetection AS (
  SELECT *, detections.datetime::DATE AS date
  FROM detections 
  LEFT JOIN location ON detections.location = location.location_code
  WHERE location.subloc = 'ds'
), hatchTagDetectionList AS (
  SELECT hatch_tag.tag_id_long, hatchTagCount.species, hatchTagCount.system, hatchTagCount.date_time_release, hatchTagCount.origin, locationDetection.date AS detection_date
  FROM hatch_tag 
  LEFT JOIN locationDetection ON hatch_tag.tag_id_long = locationDetection.tag_id
  LEFT JOIN hatchTagCount ON hatch_tag.tag_id_long = hatchTagCount.tag_id_long
  WHERE hatchTagCount.date_time_release IS NOT NULL AND locationDetection.date IS NOT NULL
), fieldDetectionList AS (
  SELECT field.tag_id_long, locationDetection.datetime, field.watershed, fieldCount.species, field.date, fieldCount.origin, locationDetection.date AS detection_date
  FROM field 
  LEFT JOIN locationDetection ON field.tag_id_long = locationDetection.tagid
  LEFT JOIN fieldCount ON field.tag_id_long = fieldCount.tag_id_long
  WHERE field.tag_status = 'tag' AND field.clip_status = 'unclip' AND field.date IS NOT NULL
), fieldComplete AS (
  SELECT fieldDetectionList.tag_id_long, 
    fieldDetectionList.watershed AS "system/watershed",
    fieldDetectionList.species,
    fieldDetectionList.origin,
    ROUND(EXTRACT(EPOCH FROM (fieldDetectionList.datetime - fieldDetectionList.date)) / 86400, 3) AS diff_date
  FROM fieldDetectionList
), hatchComplete AS (
  SELECT hatchTagDetectionList.tag_id_long, 
    hatchTagDetectionList.system AS "system/watershed",
    hatchTagDetectionList.species,
    hatchTagDetectionList.origin,
    ROUND(EXTRACT(EPOCH FROM (hatchTagDetectionList.detection_date - hatchTagDetectionList.date_time_release)) / 86400, 3) AS diff_date
  FROM hatchTagDetectionList
)
```

2. For each stage (i.e. hatchery/river, estuary, microtroll, adult), what are the number of tags deployed to date or over a specific time frame?

```
SELECT CASE 
            WHEN h.stage IS NULL THEN 'Hatchery'
            ELSE h.stage
            END,
         'hatchery' as tag_status,
         COUNT(DISTINCT(h.tag_id_long)) AS tag_count
FROM ods.hatch_tag_tagging_date h
WHERE h.tag_id_long IS NOT NULL
AND tagging_date > '2021-01-01'
GROUP BY h.stage

UNION ALL

SELECT 'Field' as stage,
        CASE 
                    WHEN f.tag_status = 'no tag' THEN 'notag'
                    ELSE f.tag_status END  AS tag_status,
         COUNT(DISTINCT(f.tag_id_long)) AS tag_count
         
FROM field f
WHERE f.tag_id_long IS NOT NULL
AND f.tag_status NOT IN ('recap', 'mort', 'reject')
AND date > '2021-01-01'
GROUP BY f.tag_status

UNION ALL

SELECT 'Microtroll' as stage,
         m.tag_status,
         COUNT(DISTINCT(m.tag_id_long)) AS tag_count
         
FROM microtroll m
WHERE m.tag_id_long IS NOT NULL
AND m.tag_status NOT IN ('recap', 'mort', 'reject')
AND date > '2021-01-01'
GROUP BY m.tag_status
```

3. For each system/watershed, list all tags deployed that were subsequently redetected on the lowest mainstem array or in the estuary immediately after outmigration (to look at freshwater survival rather than overall survival and adult returns).

```
WITH 
    HATCH_TAG_FIELD AS (
        SELECT DISTINCT
            HATCH_TAG.tag_id_long,
            HATCH_TAG.system,
            DATE(HATCH_TAG.date_time_release) AS tag_date,       
            DATE(FIELD.date) AS encounter_date                  
        FROM HATCH_TAG 
        INNER JOIN FIELD ON HATCH_TAG.tag_id_long = FIELD.tag_id_long
        LEFT JOIN LOCATION AS LOCATION1 ON LOWER(HATCH_TAG.system) = LOWER(LOCATION1.watershed)
        LEFT JOIN LOCATION AS LOCATION2 ON LOWER(FIELD.site) = LOWER(LOCATION2.site_description)
        WHERE FIELD.tag_status = 'recap'
          AND LOCATION2.location_code IN ('3c', '3d', '3e', '3f', '2d', '41', '7e')
          AND LOCATION1.watershed = LOCATION2.watershed
          AND DATE(FIELD.date) - DATE(HATCH_TAG.date_time_release) > 100
    ),
    HATCH_TAG_DETECTIONS AS (
        SELECT DISTINCT
            HATCH_TAG.tag_id_long,
            HATCH_TAG.system,
            DATE(HATCH_TAG.date_time_release) AS tag_date,       
            DATE(DETECTIONS.datetime) AS encounter_date        
        FROM HATCH_TAG 
        INNER JOIN DETECTIONS ON HATCH_TAG.tag_id_long = DETECTIONS.tagid
        LEFT JOIN LOCATION AS LOCATION1 ON LOWER(HATCH_TAG.system) = LOWER(LOCATION1.watershed)
        LEFT JOIN LOCATION AS LOCATION2 ON LOWER(DETECTIONS.location) = LOWER(LOCATION2.location_code)
        WHERE HATCH_TAG.tag_id_long NOT IN (SELECT tag_id_long FROM HATCH_TAG_FIELD)
          AND LOCATION2.subloc = 'ds'
          AND DATE(DETECTIONS.datetime) - DATE(HATCH_TAG.date_time_release) > 100
    ),
    FIELD_FIELD_DETECTIONS AS (
        SELECT DISTINCT
            FIELD1.tag_id_long,
            LOCATION1.watershed AS system,
            DATE(FIELD1.date) AS tag_date,                      
            DATE(FIELD2.date) AS encounter_date                 
        FROM FIELD FIELD1
        INNER JOIN FIELD FIELD2 ON FIELD1.tag_id_long = FIELD2.tag_id_long
        LEFT JOIN LOCATION AS LOCATION1 ON LOWER(FIELD1.site) = LOWER(LOCATION1.site_description)
        LEFT JOIN LOCATION AS LOCATION2 ON LOWER(FIELD2.site) = LOWER(LOCATION2.site_description)
        WHERE FIELD1.tag_id_long NOT IN (SELECT tag_id_long FROM HATCH_TAG_FIELD)
          AND FIELD1.tag_id_long NOT IN (SELECT tag_id_long FROM HATCH_TAG_DETECTIONS)
          AND FIELD1.tag_status = 'tag'
          AND FIELD2.tag_status = 'recap'
          AND DATE(FIELD2.date) - DATE(FIELD1.date) > 100
          AND (
            (LOCATION1.location_code = '39' AND LOCATION2.location_code IN ('3c', '3d', '3f'))
            OR (LOCATION1.location_code IN ('2c', '2f', '2e') AND LOCATION2.location_code = '2d')
            OR (LOCATION1.location_code IN ('43', '42') AND LOCATION2.location_code = '41')
            OR (LOCATION1.location_code IN ('79', '78', '7f') AND LOCATION2.location_code = '7e')
          )
    ),
    FIELD_DETECTIONS AS (
        SELECT DISTINCT
            FIELD.tag_id_long,
            FIELD.watershed AS system,
            DATE(FIELD.date) AS tag_date,                      
            DATE(DETECTIONS.datetime) AS encounter_date        
        FROM FIELD 
        INNER JOIN DETECTIONS ON FIELD.tag_id_long = DETECTIONS.tagid
        LEFT JOIN LOCATION ON LOWER(DETECTIONS.location) = LOWER(LOCATION.location_code)
        WHERE FIELD.tag_id_long NOT IN (SELECT tag_id_long FROM HATCH_TAG_FIELD)
          AND FIELD.tag_id_long NOT IN (SELECT tag_id_long FROM HATCH_TAG_DETECTIONS)
          AND FIELD.tag_id_long NOT IN (SELECT tag_id_long FROM FIELD_FIELD_DETECTIONS)
          AND FIELD.tag_status = 'tag'
          AND DATE(DETECTIONS.datetime) - DATE(FIELD.date) > 100
          AND LOCATION.subloc = 'ds'
    )
SELECT tag_id_long, system, tag_date, encounter_date FROM HATCH_TAG_FIELD
UNION
SELECT tag_id_long, system, tag_date, encounter_date FROM HATCH_TAG_DETECTIONS
UNION
SELECT tag_id_long, system, tag_date, encounter_date FROM FIELD_FIELD_DETECTIONS
UNION
SELECT tag_id_long, system, tag_date, encounter_date FROM FIELD_DETECTIONS;

```

4. For each species in each system/watershed, create a summary of total tags deployed in each period (i.e. hatchery, river, estuary, microtroll - note assignment to stock/system for estuary and microtroll data will be limited to what genetics data we have available), total recaptured tags within each period, and #s of detections both on the outward migration to sea, and the return migration as adults. The goal being to have a summary of all the tags we’ve put out, and how many of them were subsequently redetected to give us our sample sizes for our survival models.

```
SELECT species,
       COALESCE(stage, 'Hatchery'),
       COUNT(DISTINCT(tag_id_long)) AS tags,
       0 AS recaps
FROM ods.hatch_tag_tagging_date h
WHERE h.tag_id_long IS NOT NULL
AND tagging_date > '2021-01-01'
GROUP BY species,
         stage
         
UNION ALL

SELECT m.species,
       'Microtroll' AS stage,
       SUM(CASE WHEN m.tag_status = 'tag' THEN 1 ELSE 0 END) as tags,
       SUM(CASE WHEN m.tag_status = 'recap' THEN 1 ELSE 0 END) as recaps
FROM microtroll m
WHERE m.tag_id_long IS NOT NULL
      AND m.species IS NOT NULL
AND date > '2021-01-01'
GROUP BY m.species

         
UNION ALL

SELECT f.species,
       'Field' AS stage,
       SUM(CASE WHEN f.tag_status = 'tag' THEN 1 ELSE 0 END) as tags,
       SUM(CASE WHEN f.tag_status = 'recap' THEN 1 ELSE 0 END) as recaps
FROM field f
WHERE f.tag_id_long IS NOT NULL
      AND f.species IS NOT NULL
AND f.date > '2021-01-01'
GROUP BY f.species
```

5. For each species in each system/watershed, list the fork lengths of the fish tagged and identify which of those fish were detected as returning adults (compare size structure of initial and returning cohorts).

```SQL
WITH table_1 AS (
  SELECT field.tag_id_long, field.watershed, field.species, field.fork_length_mm, field.date, det.last_date
  FROM field 
  INNER JOIN (
    SELECT DISTINCT d.tagid, MAX(DATE(d.datetime)) OVER (PARTITION BY d.tagid) AS last_date
    FROM detections d
  ) det ON field.tag_id_long = det.tagid
)

SELECT *, last_date - date AS no_of_days
FROM table_1
WHERE last_date - date > 100
ORDER BY no_of_days DESC
```

6. For each system each year, look up what proportion of the total tags out were detected on seal haul outs or in heron rookeries (to be able to easily pull out predator data and calculate predation rates).

```SQL
WITH predator_counts AS (
    SELECT EXTRACT(YEAR FROM predator.date) AS year,
           SUM(CASE WHEN predator.predator = 'heron' THEN 1 ELSE 0 END) AS heron_count,
           SUM(CASE WHEN predator.predator = 'sea houl' THEN 1 ELSE 0 END) AS sea_houl_count,
           location.site_name AS location
    FROM predator
    JOIN location ON predator.location_name = location.site_name
    GROUP BY year, location.site_name
), 
hatch_tag_count AS (
  SELECT h.outmigration_y, h.system, COUNT(h.tag_id_long) AS tag_count
  FROM hatch_tag h
  LEFT JOIN field f ON h.tag_id_long = f.tag_id_long
  LEFT JOIN microtroll m ON h.tag_id_long = m.tag_id_long
  GROUP BY h.outmigration_y, h.system
)

SELECT year, heron_count, sea_houl_count
FROM predator_counts
JOIN hatch_tag_count ON predator_counts.location = hatch_tag_count.system
WHERE year > 2020;
```

7. A query to produce a data frame that could be used for overwinter survival analysis for Chinook

```
```

8. The “Stage specific survival” Query

```
```

9. Origin (Hatchery vs wild)

```
```
