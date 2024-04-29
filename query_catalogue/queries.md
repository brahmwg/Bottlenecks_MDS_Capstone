The following are the quesries needed for each problem:

1. For each species in each system, list the numbers of hatchery and wild tags going out and the timing of those detections (to be able to compare hatchery and wild outmigrations).

```
```

2. For each stage (i.e. hatchery/river, estuary, microtroll, adult), what are the number of tags deployed to date or over a specific time frame?

```
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
