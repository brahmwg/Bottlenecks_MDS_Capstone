import pandas as pd
import numpy as np
import json

import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from unittest.mock import patch
from species_prediction_model.scripts.process import one_hot_encoding, processing

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
    
    assert result.shape[0] == 2, "The resulting dataframe should have 2 rows"

if __name__ == '__main__':
    test_processing()
