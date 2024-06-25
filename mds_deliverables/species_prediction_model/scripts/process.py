import pandas as pd
import numpy as np
det_table = {
    'species':['ck', 'co', 'cm', 'pink', 'so', 'stl', 'ct', 'rbt'],
    'eye_size':['large', 'large', 'medium', 'medium', 'very large', 'small', 'small', 'small'],
    'snout_shape':['pointy', 'short and blunt', 'NA', 'NA', 'NA', 'short and rounded', 'long and pointy', 'short and rounded'],
    'parr_marks':['slightly faded', 'slightly faded', 'faded', 'NA', 'slightly faded', 'faded', 'faded', 'NA'],
    'parr_marks_length':['long', 'long', 'short', 'NA', 'irregular', 'short', 'short', 'short'],
    'spotting_density':['medium', 'medium', 'medium', 'NA', 'NA', 'high', 'high', 'high'],
    'fin_type':['anal fin', 'anal fin', 'caudal fin', 'caudal fin', 'caudal fin', 'caudal fin', 'caudal fin', 'caudal fin'],
    'parr_marks_spacing':['wider than interspaces', 'narrower than interspaces', 'NA', 'half', 'variable', 'variable', 'variable', 'NA'],
    'spotting_characteristic':['circle', 'circle', 'variable', 'NA', 'row', 'irregular', 'irregular', 'NA']
}

def one_hot_encoding(df, col, prefix):
    """
    Performs one-hot encoding on a specified column of the input DataFrame.

    Parameters
    ----------
    df : pandas.DataFrame
        The input DataFrame containing the column to be encoded.
        
    col : str
        The name of the column to be one-hot encoded.
        
    prefix : str
        The prefix to use for the new one-hot encoded column names.

    Returns
    -------
    pandas.DataFrame
        DataFrame with the specified column one-hot encoded and the original column dropped.

    Notes
    -----
    - The function creates dummy variables for the unique values in the specified column.
    - The new columns are added to the DataFrame with names prefixed by the original column name.
    - This function already exists in sklearn but it's so much safer to write it on your own, trust me.
    """

    df = df.copy()
    dummies = pd.get_dummies(df[col], prefix=col, dtype='int')
    df = pd.concat([df, dummies], axis=1)
    df = df.drop(col, axis=1)
    return df

def processing(data, det_data):
    """
    Processes the input data by replacing NaN values, merging with deterministic data, and applying one-hot encoding.

    Parameters
    ----------
    data : pandas.DataFrame
        The input DataFrame queried from database.
        
    det_data : array-like
        Deterministic data.

    Returns
    -------
    pandas.DataFrame
        DataFrame with NaN values replaced, deterministic data merged, and categorical columns one-hot encoded.

    Notes
    -----
    - The deterministic data is converted to a DataFrame and merged with the input data on the 'species' column.
    - One-hot encoding is applied to all columns except 'species', 'fork_length_mm', 'water_temp_start', and 'tag_id_long' because these features are numerical.
    """
    data = data.copy()
    data = data.replace(np.nan, None)
    det_df = pd.DataFrame(det_data)
    df = data.merge(det_df, how='outer', on='species')

    for col in df.columns:
        if col != 'species' and col != 'fork_length_mm' and col != 'water_temp_start' and col!='tag_id_long':
            df = one_hot_encoding(df, col, col)
    
    return df

if __name__ == '__main__':
    processed_data = processing(data=field, det_data=det_table)