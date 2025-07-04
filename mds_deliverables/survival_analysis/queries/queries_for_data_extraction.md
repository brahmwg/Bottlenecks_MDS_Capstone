This document contains all the SQL queries used to extract data from the Data Center.

## STAGE:

### Stage 1: Facility

Save the query below as `hatchery.csv`.

```SQL         
SELECT tag_id_long as tag_id, release_date as date, 'facility' AS stage, 'hatch' AS origin, fork_length_mm, 'tag' AS action, species  
FROM HATCH_TAG
```

### Stage 2: Downstream

The juvinille salmons that from hatchary- maybe there are tagging events between hatchery and detection, not yet considered yet.

All hatchery origin fish in downstream Save the query below as `downstream_hatch.csv`.

```SQL         
SELECT tagid as tag_id, DATE(datetime) as date, 'downstream' as stage, 'hatch' as origin, HATCH_TAG.avg_fork_length, 'detect' as action,
      HATCH_TAG.species 
FROM downstream_detections  
INNER JOIN HATCH_TAG ON downstream_detections.tagid = HATCH_TAG.tag_id_long
```

All wild origin fish in downstream Save the query below as `downstream_wild.csv`.

```SQL        
SELECT tagid as tag_id, DATE(datetime) as date, 'downstream' as stage, 'wild' as origin, field.fork_length_mm, tag_status as action, field.species 
FROM downstream_detections
INNER JOIN field ON downstream_detections.tagid = field.tag_id_long 
WHERE tagid NOT IN (
  SELECT DISTINCT tag_id_long
  FROM hatch_tag
  INNER JOIN downstream_detections ON hatch_tag.tag_id_long = downstream_detections.tagid)
```

### Stage 3: Estuary

Save the query below as `estuary.csv`.

```SQL         
SELECT tag_id_long AS tag_id, date, 'estuary' AS stage, wild_or_hatchery AS origin, fork_length_mm, tag_status AS action, species
FROM field 
WHERE river_or_estuary='estuary'
```

### Stage 4: Microtroll

All hatchry origin fish from microtroll Save the query below as `microtroll_hatch.csv`.

```SQL         
SELECT DISTINCT microtroll.tag_id_long as tag_id, date, 'microtroll' as stage, 'hatch' as origin,
        microtroll.fork_length_mm, 
        'detect' as action, microtroll.species
FROM microtroll 
INNER JOIN hatch_tag ON microtroll.tag_id_long = hatch_tag.tag_id_long
WHERE microtroll.tag_id_long IS NOT NULL
```

All wild origin fish from microtroll Save the query below as `microtroll_wild.csv`.

```SQL         
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

Exclude those who were encountered in the first detection to make sure is return. Save the query below as `return.csv`.

```SQL         
SELECT o.tag_id_long AS tag_id, 
      earliest_detection_date as date, 
      'return' as stage,
      o.source AS origin,
      COALESCE(a.fork_length_mm, h.avg_fork_length::double precision) AS fork_length_mm,
      'detect' AS action,
      o.species
FROM outmigrant_and_return3 o
LEFT JOIN all_tagging a ON o.tag_id_long = a.tag_id_long
LEFT JOIN hatch_tag h ON o.tag_id_long = h.tag_id_long
```
