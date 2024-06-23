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
    df = df.copy()
    dummies = pd.get_dummies(df[col], prefix=col, dtype='int')
    df = pd.concat([df, dummies], axis=1)
    df = df.drop(col, axis=1)
    return df

def processing(data, det_data):
    data = data.copy()
    data = data.replace(np.nan, None)
    det_df = pd.DataFrame(det_data)
    df = data.merge(det_df, how='outer', on='species')

    for col in df.columns:
        if col != 'species' and col != 'fork_length_mm' and col != 'water_temp_start':
            df = one_hot_encoding(df, col, col)
    
    return df

if __name__ == '__main__':
    processed_data = processing(data=field, det_data=det_table)