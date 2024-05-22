This document contains all the SQL queries used to extract data from the Data Center.

## STAGE:

### Stage 1: Facility 

```
SELECT tag_id_long as tag_id, release_date as date, 'facility' AS stage, 'hatch' AS origin, fork_length_mm, 'tag' AS action, species  
FROM HATCH_TAG
```

### Stage 2: Downstream

The juvinille salmons that from hatchary- maybe there are tagging events between hatchery and detection, not yet considered yet.

All hatchery origin fish in downstream
```
SELECT tagid as tag_id, DATE(datetime) as date, 'downstream' as stage, 'hatch' as origin, HATCH_TAG.fork_length_mm, 'detect' as action,
      HATCH_TAG.species 
FROM downstream_detections  
INNER JOIN HATCH_TAG ON downstream_detections.tagid = HATCH_TAG.tag_id_long
```

All wild origin fish in downstream 
```
SELECT tagid as tag_id, DATE(datetime) as date, 'downstream' as stage, 'wild' as origin, field.fork_length_mm, tag_status as action, field.species 
FROM downstream_detections
INNER JOIN field ON downstream_detections.tagid = field.tag_id_long 
WHERE tagid NOT IN (
  SELECT DISTINCT tag_id_long
  FROM hatch_tag
  INNER JOIN downstream_detections ON hatch_tag.tag_id_long = downstream_detections.tagid)
```
### Stage 3: Estuary

```
SELECT tag_id_long, date, 'estuary' AS stage, wild_or_hatchery AS origin, fork_length_mm, tag_status AS action, species
FROM field 
WHERE river_or_estuary='estuary'
```

### Stage 4: Microtroll

All hatchry origin fish from microtroll
```
SELECT DISTINCT microtroll.tag_id_long as tag_id, date, 'microtroll' as stage, 'hatch' as origin,
        microtroll.fork_length_mm, 
        'detect' as action, microtroll.species
FROM microtroll 
INNER JOIN hatch_tag ON microtroll.tag_id_long = hatch_tag.tag_id_long
WHERE microtroll.tag_id_long IS NOT NULL
```

All wild origin fish from microtroll
```
SELECT DISTINCT microtroll.tag_id_long as tag_id, date, 'microtroll' as stage, 'wild' as origin,
        microtroll.fork_length_mm, 
        microtroll.tag_status as action, microtroll.species
FROM microtroll 
WHERE tag_id_long NOT IN (
    SELECT DISTINCT microtroll.tag_id_long
    FROM microtroll 
    INNER JOIN hatch_tag ON microtroll.tag_id_long = hatch_tag.tag_id_long
    )
```
### Stage 5: Return
