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

```SQL
SELECT stage,
      COUNT(DISTINCT(tag_id_long))
FROM hatch_tag 
WHERE stage IS NOT NULL
AND date_time_release BETWEEN '2018-01-01' -- Change this for initial date
                          AND '2024-01-01' -- Change this for after date
GROUP BY stage
```

3. For each system/watershed, list all tags deployed that were subsequently redetected on the lowest mainstem array or in the estuary immediately after outmigration (to look at freshwater survival rather than overall survival and adult returns).

```
```

4. For each species in each system/watershed, create a summary of total tags deployed in each period (i.e. hatchery, river, estuary, microtroll - note assignment to stock/system for estuary and microtroll data will be limited to what genetics data we have available), total recaptured tags within each period, and #s of detections both on the outward migration to sea, and the return migration as adults. The goal being to have a summary of all the tags we’ve put out, and how many of them were subsequently redetected to give us our sample sizes for our survival models.

```
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
