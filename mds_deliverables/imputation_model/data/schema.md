# `Raw_data`

`field_genetic_species.csv` and `sql_field_imputation_data.csv` have the following schema:
| Column Name          | Data Type |
|-----------------------|-----------|
| date                  | date      |
| watershed             | string    |
| river                 | string    |
| site                  | string    |
| method                | string    |
| local                 | string    |
| water_temp_start      | float     |
| fork_length_mm        | int       |
| annotated_species     | string    |
| confirmed_species     | string    |
| tag_id_long           | float     |

`microtroll_train.csv` and `microtroll_test` have the following schema:
| Column Name        | Data Type |
|---------------------|-----------|
| tag_id_long         | float     |
| river               | string    |
| year                | int       |
| date                | date      |
| stock               | string    |
| pfma                | int       |
| latregion           | string    |
| fork_length_mm      | float     |
| annotated_species   | string    |
| confirmed_species   | string    |

# `Result`

| Column Name       | Data Type |
|--------------------|-----------|
| tag_id_long        | float     |
| species            | string    |
| predicted_label    | string    |
| confidence         | float     |
