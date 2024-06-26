import unittest
import pandas as pd
import json
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from species_prediction_model.scripts.predict import preprocess_data

def load_mock_data(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return pd.DataFrame(data['data'])

def test_preprocess_data():
    data = load_mock_data('mock_data_species.json')
    det_data, prob_data = preprocess_data(data)
    assert det_data.shape[1] == 33, "Deterministic data should have 33 columns"
    assert prob_data.shape[1] == 57, "Probabilistic data should have 57 columns"


if __name__ == '__main__':
    test_preprocess_data()