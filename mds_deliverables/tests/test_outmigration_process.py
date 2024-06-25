import pandas as pd
import numpy as np
import json
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from outMigration_model.scripts.outMigration_preprocessing import preprocess_sql, preprocessing

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
    result = preprocess_sql(salmon, cowichan_historic, output)

    expected_columns = ['date', 'count', 'site1', 'site2', 'ck', 'co']
    
    for col in expected_columns:
        assert col in result.columns, f"Column {col} should be in the result"
    
    assert result.shape[0] == 4, "The resulting dataframe should have 4 rows"
    
def test_preprocessing():
    mock_data = load_mock_data('mock_data_outmigration_raw.json')
    df_salmon = pd.DataFrame(mock_data['field_data'])
    df_temp = pd.DataFrame(mock_data['temp_data'])
    df_level = pd.DataFrame(mock_data['level_data'])
    df_flow = pd.DataFrame(mock_data['flow_data'])
    
    result = preprocessing('ck', df_salmon, df_temp, df_level, df_flow)
    
    expected_columns = [
        'date', 'month', 'year', 'Temp', 'Flow', 'Level', 'count',
        'january_Flow', 'february_Temp', 'march_Temp', 'rolling_Temp_mean_15',
        'rolling_Flow_mean_15', 'rolling_Level_mean_15'
    ]
    
    for col in expected_columns:
        assert col in result.columns, f"Column {col} should be in the result"
    
    assert result.shape[0] == 2, "The resulting dataframe should have 2 rows"
    assert result['Temp'].iloc[0] == 15, "First row should have Temp as 15"
    assert result['Flow'].iloc[0] == 2.0, "First row should have Flow as 2.0"
    assert result['Level'].iloc[0] == 1.0, "First row should have Level as 1.0"

if __name__ == '__main__':
    test_preprocess_sql()
    test_preprocessing()
