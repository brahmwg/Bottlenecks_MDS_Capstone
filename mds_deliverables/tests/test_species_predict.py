import unittest
import pandas as pd
import json
from src.species_prediction import preprocess_data

def load_mock_data(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return pd.DataFrame(data['data'])

def test_preprocess_data():
    data = load_mock_data('mock_data_species.json')
    det_data, prob_data = preprocess_data(data)
    
    assert det_data.shape[1] == 30, "Deterministic data should have 30 columns"
    assert prob_data.shape[1] == 58, "Probabilistic data should have 58 columns"


if __name__ == '__main__':
    test_preprocess_data()