The following are the quesries needed for each problem:

1. For each species in each system, list the numbers of hatchery and wild tags going out and the timing of those detections (to be able to compare hatchery and wild outmigrations).

```
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

```
```

6. For each system each year, look up what proportion of the total tags out were detected on seal haul outs or in heron rookeries (to be able to easily pull out predator data and calculate predation rates).

```
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
