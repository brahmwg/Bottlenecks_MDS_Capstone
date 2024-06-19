Extracting truth data (for training):
Taking all fishes that have been confirmed by the lab
```
SELECT fg.date, fg.watershed, 
        fg.river, fg.site, 
        fg.method, fg.local, 
        fg.water_temp_start, 
        fg.fork_length_mm, fg.species as annoted_species, species_id.species as confirmed_species, fg.tag_id_long
FROM field_genetics fg 
INNER JOIN species_id ON species_id.indiv = fg.indiv
WHERE species_id.species = 'coho' OR species_id.species = 'chinook'OR species_id.species = 'steelhead'
```

Extracting data to impute (to predict on):
all fishes that have never been sent to the lab
```
WITH table_1 AS(
SELECT fg.date, fg.watershed, 
        fg.river, fg.site, 
        fg.method, fg.local, 
        fg.water_temp_start, 
        fg.fork_length_mm, fg.species as annoted_species, species_id.species as confirmed_species, fg.tag_id_long
FROM field_genetics fg 
INNER JOIN species_id ON species_id.indiv = fg.indiv
WHERE species_id.species = 'coho' OR species_id.species = 'chinook'OR species_id.species = 'steelhead')

SELECT tag_id_long, date, watershed, river, site, method, local, fork_length_mm, species
FROM field A
WHERE NOT EXISTS (SELECT 1 FROM table_1 B WHERE B.tag_id_long = A.tag_id_long)
```

Extracting truth table for microtroll
```
select tag_id_long, river, year, date, stock, pfma, latregion, fork_length_mm, species as annotated_species, species_id as confirmed_species
from all_tagging 
where source = 'microtroll' and species_id IN ('chinook', 'coho', 'none') and stock IS NOT NULL
```

Extracting microtroll data to predict for:
```
select tag_id_long, river, year, date, stock, stock_group, pfma, latregion, fork_length_mm, species as annotated_species, species_id as confirmed_species
from all_tagging 
where source = 'microtroll' and species_id IS NULL and stock is not null
```