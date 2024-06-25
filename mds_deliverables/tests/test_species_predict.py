import pandas as pd
import json
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

from species_prediction_model.scripts.predict import *

def load_mock_data(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return pd.DataFrame(data['data'])

def test_voting_classifier_deterministic():
    data = load_mock_data('mock_data_species.json')

    det_data = data
    result = voting_classifier_deterministic(det_data)
    
    assert 'tag_id_long' in result.columns, "Result should contain 'tag_id_long' column"
    assert 'prediction' in result.columns, "Result should contain 'prediction' column"
    assert result.shape[0] == det_data.shape[0], "Number of rows should match input data"

def test_voting_classifier_probabilistic():
    data = load_mock_data('mock_data_species.json')

    prob_data = data 

    result = voting_classifier_probabilistic(prob_data)
    
    assert 'tag_id_long' in result.columns, "Result should contain 'tag_id_long' column"
    assert 'dt_prediction' in result.columns, "Result should contain 'dt_prediction' column"
    assert 'rf_prediction' in result.columns, "Result should contain 'rf_prediction' column"
    assert result.shape[0] == prob_data.shape[0], "Number of rows should match input data"

def test_voting_classifier():
    det_results = load_mock_data('mock_data_species_det_results.json')
    prob_results = load_mock_data('mock_data_species_prob_results.json')

    result = voting_classifier(det_results, prob_results)
    
    assert 'tag_id_long' in result.columns, "Result should contain 'tag_id_long' column"
    assert 'prediction' in result.columns, "Result should contain 'prediction' column"
    assert result.shape[0] == len(det_results), "Number of rows should match deterministic results"

if __name__ == '__main__':
    test_voting_classifier_deterministic()
    test_voting_classifier_probabilistic()
    test_voting_classifier()
