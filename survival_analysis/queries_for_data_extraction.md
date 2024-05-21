This document contains all the SQL queries used to extract data from the Data Center.

## STAGE:

### Stage 1: Facility 

```
SELECT tag_id_long, tagging_date, 'facility' AS stage, 'hatch' AS origin, fork_length_mm, species  
FROM HATCH_TAG
```

### Stage 2: Downstream

The juvinille salmons that from hatchary- maybe there are tagging events between hatchery and detection, not yet considered yet. 

```
SELECT tagid, datetime, 'downstream' as stage, 'hatch' as origin, HATCH_TAG.fork_length_mm, HATCH_TAG.species 
FROM detections 
INNER JOIN HATCH_TAG ON DETECTIONS.tagid = HATCH_TAG.tag_id_long  
WHERE location IN (
  SELECT DISTINCT d.location 
  FROM detections d
  JOIN location l ON d.location = l.location_code
  WHERE l.site_description = 'Mainstem Array'
    AND l.subloc = 'ds'
)
AND DATE(DETECTIONS.datetime) - DATE(HATCH_TAG.tagging_date) < 100;
```
### Stage 3: Estuary


### Stage 4: Microtroll

All hatchry origin fish from microtroll
```
SELECT DISTINCT microtroll.tag_id_long, date, 'microtroll' as stage, 'hatch' as origin,
        microtroll.fork_length_mm, 
        microtroll.clip_status as action, microtroll.species
FROM microtroll 
INNER JOIN hatch_tag ON microtroll.tag_id_long = hatch_tag.tag_id_long
WHERE microtroll.tag_id_long IS NOT NULL
```

All wild origin fish from microtroll
```
SELECT DISTINCT microtroll.tag_id_long, date, 'microtroll' as stage, 'wild' as origin,
        microtroll.fork_length_mm, 
        microtroll.clip_status as action, microtroll.species
FROM microtroll 
WHERE tag_id_long NOT IN (
    SELECT DISTINCT microtroll.tag_id_long
    FROM microtroll 
    INNER JOIN hatch_tag ON microtroll.tag_id_long = hatch_tag.tag_id_long
    WHERE microtroll.tag_id_long IS NOT NULL
)
```
### Stage 5: Return
