import pandas as pd
import pickle
import random
import warnings
import numpy as np


warnings.filterwarnings("ignore")

class VotingClassifier:
    def __init__(self, deterministic_models, probabilistic_models):

        self.deterministic_models = deterministic_models
        self.probabilistic_models = probabilistic_models

    def preprocess_data(self, data):

        det_cols = ['eye_size_large', 'eye_size_medium', 'eye_size_small',
                    'eye_size_very large', 'snout_shape_NA', 'snout_shape_long and pointy',
                    'snout_shape_pointy', 'snout_shape_short and blunt',
                    'snout_shape_short and rounded', 'parr_marks_NA', 'parr_marks_faded',
                    'parr_marks_slightly faded', 'parr_marks_length_NA',
                    'parr_marks_length_irregular', 'parr_marks_length_long',
                    'parr_marks_length_short', 'spotting_density_NA',
                    'spotting_density_high', 'spotting_density_medium', 'fin_type_anal fin',
                    'fin_type_caudal fin', 'parr_marks_spacing_NA',
                    'parr_marks_spacing_half',
                    'parr_marks_spacing_narrower than interspaces',
                    'parr_marks_spacing_variable',
                    'parr_marks_spacing_wider than interspaces',
                    'spotting_characteristic_NA', 'spotting_characteristic_circle',
                    'spotting_characteristic_irregular', 'spotting_characteristic_row',
                    'spotting_characteristic_variable']
        
        # RIYA ADD YOUR COLUMNS HERE
        prob_cols = ['fork_length_mm', 'watershed_cowichan', 'watershed_englishman',
       'watershed_nanaimo', 'watershed_puntledge', 'river_center creek',
       'river_cowichan', 'river_englishman', 'river_haslam creek',
       'river_nanaimo', 'river_puntledge', 'river_shelly creek', 'site_70.2',
       'site_above tsolum', 'site_cedar bridge', 'site_center creek',
       'site_condensory bridge', 'site_cow bay', 'site_hamilton ave',
       'site_jack point', 'site_little mexico', 'site_living forest',
       'site_mainstem fence', 'site_martindale rd', 'site_newcastle',
       'site_side channel', 'site_skutz', 'site_t-bone road',
       'site_tsolum confluence', 'site_vimy pool', 'method_beach seine',
       'method_g-trap', 'method_rst', 'method_smolt trap', 'local_in-river',
       'local_marine', 'eye_size_large', 'eye_size_medium', 'eye_size_small',
       'snout_shape_NA', 'snout_shape_long and pointy', 'snout_shape_pointy',
       'snout_shape_short and blunt', 'snout_shape_short and rounded',
       'parr_marks_NA', 'parr_marks_faded', 'parr_marks_slightly faded',
       'parr_marks_length_long', 'parr_marks_length_short',
       'spotting_density_high', 'spotting_density_medium', 'fin_type_anal fin',
       'fin_type_caudal fin', 'parr_marks_spacing_NA',
       'parr_marks_spacing_narrower than interspaces',
       'parr_marks_spacing_variable',
       'parr_marks_spacing_wider than interspaces',
       'spotting_characteristic_NA', 'spotting_characteristic_circle',
       'spotting_characteristic_irregular',
       'spotting_characteristic_variable']

        det_data = data[det_cols].values
        prob_data = data[prob_cols].values
        return det_data,prob_data

    def voting_classifier_deterministic(self, data):
      
        print('Det started')
        data = self.preprocess_data(data)
        print(np.array([data])[0])
        predictions = []

        for key, value in self.deterministic_models.items():
            model = pickle.load(open(value, 'rb'))
            predictions.append(model.predict(data.reshape(1, -1))[0])



        prediction = max(set(predictions), key=predictions.count)

        return prediction,predictions

    def voting_classifier_probabilistic(self, data, pred_1):
        print('prob started')
        _,data = self.preprocess_data(data)
        predictions = [pred_1]
        print(data)

        for key, value in self.probabilistic_models.items():
            print(key)
            model = pickle.load(open(value, 'rb'))
            predictions.append(model.predict(data.reshape(1, -1))[0])

        if pred_1 == 'pink':
            return predictions, 'pink'
        elif pred_1 == 'so':
            return predictions, 'so'
        else:
            prediction = max(set(predictions), key=predictions.count)
            return predictions, prediction
