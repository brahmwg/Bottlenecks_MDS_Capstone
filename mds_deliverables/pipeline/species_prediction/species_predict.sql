CREATE OR REPLACE FUNCTION classify_species()
RETURNS VOID AS $$
import pickle
import numpy as np
import plpy

def preprocess_data(data):
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

    # This is bound to change
    prob_cols = ['water_temp_start', 'fork_length_mm', 'watershed_cowichan',
                'watershed_englishman', 'watershed_nanaimo', 'watershed_puntledge',
                'river_center creek', 'river_cowichan', 'river_englishman',
                'river_haslam creek', 'river_nanaimo', 'river_puntledge',
                'river_shelly creek', 'site_70.2', 'site_above tsolum',
                'site_cedar bridge', 'site_center creek', 'site_condensory bridge',
                'site_cow bay', 'site_hamilton ave', 'site_jack point',
                'site_little mexico', 'site_living forest', 'site_mainstem fence',
                'site_martindale rd', 'site_newcastle', 'site_side channel',
                'site_skutz', 'site_snuneymuxw beach', 'site_t-bone road',
                'site_tsolum confluence', 'site_vimy pool', 'method_beach seine',
                'method_g-trap', 'method_rst', 'method_smolt trap', 'local_in-river',
                'local_marine', 'eye_size_large', 'eye_size_medium', 'eye_size_small',
                'snout_shape_NA', 'snout_shape_long and pointy', 'snout_shape_pointy',
                'snout_shape_short and blunt', 'snout_shape_short and rounded',
                'parr_marks_NA', 'parr_marks_faded', 'parr_marks_slightly faded',
                'parr_marks_length_long', 'parr_marks_length_short',
                'spotting_density_high', 'spotting_density_medium', 'fin_type_anal fin',
                'fin_type_caudal fin']

    det_data = data[det_cols].values
    prob_data = data[prob_cols].values
    return det_data, prob_data

def voting_classifier_deterministic(data, deterministic_models):
    det_data, _ = preprocess_data(data)
    print(np.array([det_data])[0])
    predictions = []

    for key, value in deterministic_models.items():
        model = pickle.load(open(value, 'rb'))
        predictions.append(model.predict(det_data.reshape(1, -1))[0])

    prediction = max(set(predictions), key=predictions.count)
    return prediction, predictions

def voting_classifier_probabilistic(data, probabilistic_models, pred_1):
    _, prob_data = preprocess_data(data)
    predictions = [pred_1]
    print(prob_data)

    for key, value in probabilistic_models.items():
        print(key)
        model = pickle.load(open(value, 'rb'))
        predictions.append(model.predict(prob_data.reshape(1, -1))[0])

    if pred_1 == 'pink':
        return predictions, 'pink'
    elif pred_1 == 'so':
        return predictions, 'so'
    else:
        prediction = max(set(predictions), key=predictions.count)
        return predictions, prediction

results = plpy.execute("SELECT * FROM staging.species")

deterministic_models = {'model_42': '/content/model_42.pkl',
                        'model_231': '/content/model_231.pkl',
                        'model_351': '/content/model_351.pkl',
                        'model_701': '/content/model_701.pkl',
                        'model_996': '/content/model_996.pkl',
                        'model_523': '/content/model_523.pkl',
                        'model_710': '/content/model_710.pkl',
                        'model_686': '/content/model_686.pkl',
                        'model_568': '/content/model_568.pkl',
                        'model_268': '/content/model_268.pkl'}
probabilistic_models = {
                        'model_dt': '/content/model_dt.pkl',
                        'model_dl': '/content/model_dl.pkl'
}


# This is bound to change because it should return a table
for row in results:
    data = plpy.execute("SELECT * FROM staging.species WHERE id = %s" % row['id'])[0]

    pred_1, det_predictions = voting_classifier_deterministic(data, deterministic_models)

    predictions, final_prediction = voting_classifier_probabilistic(data, probabilistic_models, pred_1)

    # Insert the result into ods.species_prediction
    plpy.execute("""
        INSERT INTO ods.species_prediction (id, det_predictions, final_prediction)
        VALUES (%s, %s, %s)
    """ % (row['id'], str(det_predictions), final_prediction))
$$ LANGUAGE plpython3u;
