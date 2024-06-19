import pandas as pd
import numpy as np
import pyarrow

cowichan_historic_query = """
SELECT DATE(min_dt.date_time) AS date, min_dt.species, COUNT(DISTINCT min_dt.TAG_ID_LONG) AS count
FROM (
    SELECT TAG_ID_LONG, species, MIN(date_time) as date_time
    FROM cowichan_historical
    WHERE origin IN ('W', 'w', 'W COHO') AND date_time IS NOT NULL
    GROUP BY TAG_ID_LONG, species
) AS min_dt
GROUP BY DATE(min_dt.date_time), min_dt.species
ORDER BY DATE(min_dt.date_time);
"""

cowichan_historic = pd.DataFrame(plpy.execute(cowichan_historic_query))

salmon_query = """
SELECT DATE(MIN(f.date)) AS date, f.watershed, f.site, f.species, COUNT(DISTINCT f.tag_id_long) AS count
FROM FIELD f
INNER JOIN (
    SELECT tag_id_long, MIN(DATE(date)) AS min_date
    FROM FIELD
    GROUP BY tag_id_long
) AS subquery ON f.tag_id_long = subquery.tag_id_long AND DATE(f.date) = DATE(subquery.min_date)
GROUP BY f.watershed, f.site, f.species, DATE(f.date)
ORDER BY DATE(f.date);
"""

salmon = pd.DataFrame(plpy.execute(salmon_query))

level_query = """
SELECT DATE(MIN(f.date)) AS date, f.watershed, f.site, f.species, COUNT(DISTINCT f.tag_id_long) AS count
FROM FIELD f
INNER JOIN (
    SELECT tag_id_long, MIN(DATE(date)) AS min_date
    FROM FIELD
    GROUP BY tag_id_long
) AS subquery ON f.tag_id_long = subquery.tag_id_long AND DATE(f.date) = DATE(subquery.min_date)
GROUP BY f.watershed, f.site, f.species, DATE(f.date)
ORDER BY DATE(f.date);
"""

level = pd.DataFrame(plpy.execute(level_query))

flow_query = """
SELECT DATE(MIN(f.date)) AS date, f.watershed, f.site, f.species, COUNT(DISTINCT f.tag_id_long) AS count
FROM FIELD f
INNER JOIN (
    SELECT tag_id_long, MIN(DATE(date)) AS min_date
    FROM FIELD
    GROUP BY tag_id_long
) AS subquery ON f.tag_id_long = subquery.tag_id_long AND DATE(f.date) = DATE(subquery.min_date)
GROUP BY f.watershed, f.site, f.species, DATE(f.date)
ORDER BY DATE(f.date);
"""

flow = pd.DataFrame(plpy.execute(flow_query))


def preprocess_sql(salmon, cowichan_historic):
    # Filter and reset index for Cowichan watershed
    salmon_cow_temp = salmon[salmon['watershed'] == 'cowichan'].reset_index()
    salmon_cow = salmon_cow_temp[['date', 'species', 'site', 'count']]
    salmon_cow = salmon_cow[salmon_cow['species'].isin(['co', 'ck'])]

    # Create dummy variables for sites
    site_dummies = pd.get_dummies(salmon_cow['site'])
    df_expanded = pd.concat([salmon_cow, site_dummies], axis=1)
    df_expanded = df_expanded.drop('site', axis=1)

    # Standardize species names and concatenate datasets
    cowichan_historic['species'] = cowichan_historic['species'].str.lower()
    df_long = pd.concat([cowichan_historic, df_expanded]).reset_index(drop=True)
    df_long['species'] = df_long['species'].replace('cn', 'ck')

    # Filter and create dummy variables for species
    df_long_filter = df_long[df_long['species'].isin(['co', 'ck'])]
    species_dummies = pd.get_dummies(df_long_filter['species'])
    df_expanded_1 = pd.concat([df_long_filter, species_dummies], axis=1)
    df_expanded_1 = df_expanded_1.drop('species', axis=1)

    return df_expanded_1
    
salmon_concat = preprocess_sql(salmon, cowichan_historic)

def preprocessing(species, df_salmon, df_temp, df_level, df_flow):
    df_salmon = df_salmon[df_salmon[species] == True][["date", "count"]].groupby("date").sum().reset_index()

    df_files = [("Level", "LEVEL", df_level), ("Flow", "FLOW", df_flow)]

    pivoted_dfs = {}
    for value_name, col_prefix, df in df_files:
        df_pivoted = df.melt(id_vars=["STATION_NUMBER", "YEAR", "MONTH"], var_name="Day", value_name=value_name)
        df_pivoted["Day"] = df_pivoted["Day"].str.replace(col_prefix, "").astype(int)
        df_pivoted["Date"] = pd.to_datetime(df_pivoted["YEAR"].astype(str) + "-" + df_pivoted["MONTH"].astype(str) + "-" + df_pivoted["Day"].astype(str), errors='coerce')
        df_pivoted = df_pivoted.dropna(subset=["Date"]).sort_values(by="Date")
        df_pivoted[value_name] = pd.to_numeric(df_pivoted[value_name], errors='coerce')
        numeric_columns = df_pivoted.select_dtypes(include=[np.number]).columns
        pivoted_dfs[value_name] = df_pivoted.groupby("Date")[numeric_columns].mean().reset_index()
 
    comb = df_salmon.merge(df_temp[["UTC_DATE", "TEMP"]], left_on="date", right_on="UTC_DATE", how="right").drop("date", axis=1).fillna(0).rename(columns={"UTC_DATE": "date"})
    comb["date"] = pd.to_datetime(comb["date"])
    comb["month"], comb["year"] = comb["date"].dt.month, comb["date"].dt.year

    comb_df = comb.merge(pivoted_dfs["Flow"], left_on="date", right_on="Date").merge(pivoted_dfs["Level"], left_on="date", right_on="Date")
    comb_df = comb_df[["date", "month", "year", "TEMP", "Flow", "Level", "count"]].rename(columns={"TEMP": "Temp"})

    month_key = {1: "january", 2: "february", 3: "march", 4: "april", 5: "may", 6: "june", 7: "july", 8: "august", 10: "october", 11: "november", 12: "december"}
    variables = [("Flow", [10, 11]), ("Temp", [12, 1, 2]), ("Level", [10, 11])]

    for variable, months in variables:
        for month in months:
            comb_df[f"{month_key[month]}_{variable}"] = 0
        for year in comb_df["year"].unique():
            for month in months:
                temp_df = comb_df[comb_df["year"] == year] if month in [1, 2] else comb_df[comb_df["year"] == year - 1]
                month_avg = temp_df[temp_df["month"] == month][variable].mean()
                comb_df.loc[comb_df["year"] == year, f"{month_key[month]}_{variable}"] = month_avg

    rolling_windows = [(45, 30), (40, 30), (35, 30)]
    metrics = ["mean", "std"]

    for variable in ["Temp", "Flow", "Level"]:
        for mean_metric in metrics:
            for window_start, window_end in rolling_windows:
                diff = window_start - window_end
                col_name = f"rolling_{variable}_{mean_metric}_{diff}"
                comb_df[col_name] = comb_df[variable].rolling(window=window_start - window_end).agg(mean_metric)

    comb_df.fillna(comb_df.median(), inplace=True)
    return comb_df

preprocessed = preprocessing("ck", salmon_concat, ,level, flow)