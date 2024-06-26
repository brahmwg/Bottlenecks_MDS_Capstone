import pandas as pd
import numpy as np
import json
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from outmigration_model.scripts.outMigration_prediction import *
import warnings
warnings.filterwarnings("ignore")

def test_handling_missing_values():
    data = {
        'date': pd.date_range(start='1/1/2019', periods=100, freq='D'),
        'year': [2019]*100,
        'month': [4]*30 + [5]*30 + [6]*20 + [7]*20,
        'count': range(1, 101),
        'Temp': [None, None] + list(range(98, 0, -1)),
        'Flow': list(range(50, 150)),
        'Level': list(range(150, 250))
    }
    
    df = pd.DataFrame(data)
    

    try:
        prediction(df, prediction_year=2020, lower_percentile=5, upper_percentile=10, plot=False)
        print("Test 2 Passed: Handling missing values")
    except Exception as e:
        print(f"Test 2 Failed: {e}")


if __name__ == '__name__':
    test_handling_missing_values()