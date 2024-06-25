import pandas as pd
import numpy as np
import json
from unittest.mock import patch

from species_prediction_model.scripts.process import *

def load_mock_data(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data

def test_processing():
    mock_data = load_mock_data('mock_data_species_raw.json')
    field_data = pd.DataFrame(mock_data['field_data'])
    det_table = mock_data['det_table']
    det_data = pd.DataFrame(det_table)
    result = processing(field_data, det_data)
    
    expected_columns = [
        'water_temp_start', 'fork_length_mm', 'species_ck', 'species_co', 
        'eye_size_large', 'snout_shape_pointy', 'snout_shape_short and blunt', 
        'parr_marks_slightly faded', 'parr_marks_length_long', 
        'spotting_density_medium', 'fin_type_anal fin', 
        'parr_marks_spacing_wider than interspaces', 'parr_marks_spacing_narrower than interspaces', 
        'spotting_characteristic_circle'
    ]
    
    for col in expected_columns:
        assert col in result.columns, f"Column {col} should be in the result"
    
    assert result.shape[0] == 2, "The resulting dataframe should have 2 rows"
    assert result['species_ck'].iloc[0] == 1, "First row should have species_ck as 1"
    assert result['species_co'].iloc[1] == 1, "Second row should have species_co as 1"

if __name__ == '__main__':
    test_processing()
