import pandas as pd
import numpy as np
import pyarrow

def preprocess_sql(salmon, cowichan_historic):
    """
    Processes salmon data for the Cowichan watershed by filtering species, standardizing species names,
    and handling site data through dummy variables, then merges it with historical data.

    Parameters
    ----------
    salmon: pandas.DataFrame 
        A pandas DataFrame containing salmon data with columns for watershed, date, species, site, and count.
    cowichan_historic: pandas.DataFrame 
        A pandas DataFrame containing historical data for species in the Cowichan watershed.

    Returns
    ----------
    df_expanded_1: pandas.DataFrame
        A processed DataFrame that combines filtered salmon data and historical data with dummy variables for species and site, excluding the original species and site columns.
    """
    salmon_cow_temp = salmon[salmon['watershed'] == 'cowichan'].reset_index()
    salmon_cow = salmon_cow_temp[['date', 'species', 'site', 'count']]
    salmon_cow = salmon_cow[salmon_cow['species'].isin(['co', 'ck'])]

    site_dummies = pd.get_dummies(salmon_cow['site'])
    df_expanded = pd.concat([salmon_cow, site_dummies], axis=1)
    df_expanded = df_expanded.drop('site', axis=1)

    cowichan_historic['species'] = cowichan_historic['species'].str.lower()
    df_long = pd.concat([cowichan_historic, df_expanded]).reset_index(drop=True)
    df_long['species'] = df_long['species'].replace('cn', 'ck')

    df_long_filter = df_long[df_long['species'].isin(['co', 'ck'])]
    species_dummies = pd.get_dummies(df_long_filter['species'])
    df_expanded_1 = pd.concat([df_long_filter, species_dummies], axis=1)
    df_expanded_1 = df_expanded_1.drop('species', axis=1)

    return df_expanded_1

def preprocessing(species, df_salmon, df_temp, df_level, df_flow):
    """
    Processes environmental and salmon count data by merging, pivoting, and calculating rolling statistics for specified periods.
    
    Parameters
    ----------
    species: string
        Species name used to filter the salmon data.
    df_salmon: pandas.DataFrame
        DataFrame containing salmon count data.
    df_temp: pandas.DataFrame 
        DataFrame containing temperature data with date and temperature columns.
    df_level: pandas.DataFrame 
        DataFrame containing water level data across various days.
    df_flow: pandas.DataFrame 
        DataFrame containing water flow data across various days.

    Returns
    ----------
    comb_df: pandas.DataFrame
        A DataFrame that combines all the environmental and salmon count data with additional calculated metrics,
    including rolling averages and standard deviations, prepared for further analysis or modeling.
    """
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
            comb_df[f'{month_key[month]}_{variable}'] = 0
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


if __name__ == "__main__":
    salmon2 = pd.read_csv('../data/raw/data_salmon2.csv') 
    cow = pd.read_csv('../data/raw/cowichan_historic.csv')  

    salmon = preprocess_sql(salmon2, cow)
    
    temp_path = "../data/raw/northcochiwan_daily_temp.csv"
    flow_path = "../data/raw/flow_2023.csv"
    level_path = "../data/raw/level_2023.csv"
    
    temp = pd.read_csv(temp_path)
    level = pd.read_csv(level_path)
    flow = pd.read_csv(flow_path)

    final_df = preprocessing("ck", salmon, temp, level, flow)
    final_df.to_csv("../data/preprocessed/preprocessed_ck.csv", index=False)
    print("Final preprocessed data saved to data/preprocessed_ck.csv")