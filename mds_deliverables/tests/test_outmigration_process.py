import pandas as pd
import numpy as np
import json
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from outmigration_model.scripts.outMigration_preprocessing import preprocess_sql, preprocessing
import warnings
warnings.filterwarnings("ignore")


def load_mock_data(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data

def test_preprocess_sql():
    mock_data = load_mock_data('mock_data_outmigration_raw.json')
    new_mock = pd.DataFrame(mock_data)
    output = new_mock[['salmon_data','cowichan_historic_data']]
    salmon = pd.DataFrame(mock_data['salmon_data'])
    cowichan_historic = pd.DataFrame(mock_data['cowichan_historic_data'])
    result = preprocess_sql(salmon, cowichan_historic)


    
    assert result.shape[0] == 4, "The resulting dataframe should have 4 rows"
    
def test_preprocessing():
    mock_data = load_mock_data('mock_data_outmigration_raw.json')
    df_salmon = pd.DataFrame(mock_data['field_data'])
    df_temp = pd.DataFrame(mock_data['temp_data'])
    df_level = pd.DataFrame(mock_data['level_data'])
    df_flow = pd.DataFrame(mock_data['flow_data'])
    
    result = preprocessing('ck', df_salmon, df_temp, df_level, df_flow)
    

    assert result.shape[0] == 2, "The resulting dataframe should have 2 rows"
    assert result['Temp'].iloc[0] == 15, "First row should have Temp as 15"

if __name__ == '__main__':
    test_preprocess_sql()
    test_preprocessing()
    
