# `Raw`
For the `cowichan_historic.csv` file, the data has the following structure: 
| Column Name | Data Type |
| --- | --- | 
| date | `object` |
| species | `object` |
| count | `int64` |

For the `data_salmon2.csv` file, the data has the following structure: 
| Column Name | Data Type |
| --- | --- | 
| date | `object` |
| watershed | `object` |
| site | `object` |
| species | `object` |
| count | `int64` |

For the `flow_2023.csv` file, the data has the following structure: 
| Column Name | Data Type |
| --- | --- | 
| STATION_NUMBER | `object` |
| YEAR | `int64` |
| MONTH | `int64` |
| FLOW1 - FLOW31 | `float64` |

For the `level_2023.csv` file, the data has the following structure: 
| Column Name | Data Type |
| --- | --- | 
| STATION_NUMBER | `object` |
| YEAR | `int64` |
| MONTH | `int64` |
| LEVEL1 - LEVEL31 | `float64` |

For the `northcochiwan_daily_temp.csv` file, the data has the following structure: 
| Column Name | Data Type |
| --- | --- | 
| UTC_DATE | `object` |
| RELATIVE_HUMIDITY | `float64` |
| WIND_SPEED | `float64` |
| TEMP | `float64` |
| WINDCHILL | `float64` |
| DEW_POINT_TEMP | `float64` |

For the `salmon_concat.csv` file, the data has the following structure: 
| Column Name | Data Type |
| --- | --- | 
| date | `object` |
| count | `int64` |
| 70.2 | `object` |
| cow bay | `object` |
| mainstem fence | `object` |
| skutz | `object` |
| vimy pool | `object` |
| ck | `bool` |
| co | `bool` |


# `Preprocessed`
For the `preprocessed_ck.csv` file, the data has the following structure: 

| Column Name | Data Type |
| --- | --- | 
| date | `object` |
| month | `int64` |
| year | `object` |
| Temp | `float64` |
| Flow | `float64` |
| Level | `float64` |
| count | `float64` |
| october_Flow | `float64` |
| november_Flow | `float64` |
| december_Temp | `float64` |
| january_Temp | `float64` |
| february_Temp | `float64` |
| october_Level | `float64` |
| november_Level | `float64` |
| rolling_Temp_mean_15 | `float64` |
| rolling_Temp_mean_10 | `float64` |
| rolling_Temp_mean_5 | `float64` |
| rolling_Temp_std_15 | `float64` |
| rolling_Temp_std_10 | `float64` |
| rolling_Temp_std_5 | `float64` |
| rolling_Flow_mean_15 | `float64` |
| rolling_Flow_mean_10 | `float64` |
| rolling_Flow_mean_5 | `float64` |
| rolling_Flow_std_15 | `float64` |
| rolling_Flow_std_10 | `float64` |
| rolling_Flow_std_5 | `float64` |
| rolling_Level_mean_15 | `float64` |
| rolling_Level_mean_10 | `float64` |
| rolling_Level_mean_5 | `float64` |
| rolling_Level_std_15 | `float64` |
| rolling_Level_std_10 | `float64` |
| rolling_Level_std_5 | `float64` | 