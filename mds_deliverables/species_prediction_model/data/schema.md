# Following are the schemas for the files in the `/data` folder:
## `det.json`

| Column Name           | Data Type   |
|-----------------------|-------------|
| species               | string      |
| eye_size              | string      |
| snout_shape           | string      |
| parr_marks            | string      |
| parr_marks_length     | string      |
| spotting_density      | string      |
| fin_type              | string      |
| parr_marks_spacing    | string      |
| spotting_characteristic| string      |

## `field.csv`

| Column Name       | Data Type |
|--------------------|-----------|
| watershed          | string    |
| river              | string    |
| site               | string    |
| method             | string    |
| local              | string    |
| water_temp_start   | float     |
| fork_length_mm     | int       |
| species            | string    |

## `new_field.csv`

| Column Name       | Data Type |
|--------------------|-----------|
| tag_id_long        | float     |
| watershed          | string    |
| river              | string    |
| site               | string    |
| method             | string    |
| local              | string    |
| water_temp_start   | float     |
| fork_length_mm     | float     |
| species            | string    |


## `predictions`

| Column Name       | Data Type |
|--------------------|-----------|
| tag_id_long        | float     |
| prediction_1       | string    |
| prediction_2       | string    |
| prediction_3       | string    |
| prediction         | string    |


