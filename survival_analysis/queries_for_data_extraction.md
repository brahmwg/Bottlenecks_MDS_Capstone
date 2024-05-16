This document contains all the SQL queries used to extract data from the Data Center.

## STAGE:

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