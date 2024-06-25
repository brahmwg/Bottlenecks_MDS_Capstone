import pandas as pd
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

def preprocess_data(data):
    """
    Splits the input data into two subsets: deterministic and probabilistic columns.

    Parameters
    ----------
    data : pandas.DataFrame
        The input data containing all features.

    Returns
    -------
    det_data : pandas.DataFrame
        Subset of the input data containing only deterministic columns.
        
    prob_data : pandas.DataFrame
        Subset of the input data containing only probabilistic columns.

    Notes
    -----
    - This function assumes that the input data contains all necessary columns listed in `det_cols` and `prob_cols`.
    """
    det_cols = ['tag_id_long', 'species', 'eye_size_large', 'eye_size_medium', 'eye_size_small',
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
    prob_cols = ['tag_id_long', 'species','water_temp_start', 'fork_length_mm', 'watershed_cowichan',
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

    det_data = data[det_cols]
    prob_data = data[prob_cols]
    return det_data, prob_data

def voting_classifier_deterministic(data):
    """
    Applies an ensemble voting classifier to the input data using multiple deterministic decision trees.

    Parameters
    ----------
    data : pandas.DataFrame
        The input data containing features and target labels.

    Returns
    -------
    pandas.DataFrame
        DataFrame containing 'tag_id_long' and the corresponding predicted species.

    Notes
    -----
    - The final prediction for each sample is determined by majority vote among the individual trees.
    """
    random_numbers = [42, 231, 351, 701, 996, 523, 710, 686, 568, 268]

    X = data.drop(['species','tag_id_long'], axis=1)
    y = data['species']
    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42)

    models = []
    for num in random_numbers:
        max_depth = 8
        dt = DecisionTreeClassifier(max_depth=max_depth, random_state=num)
        dt.fit(X_train, y_train)
        models.append(dt)
        
    all_predictions = []
    for dt in models:
        predictions = dt.predict(X)
        all_predictions.append(predictions)

    final_predictions = []
    for i in range(len(X)):
        row_predictions = [pred[i] for pred in all_predictions]
        prediction = max(set(row_predictions), key=row_predictions.count)
        final_predictions.append(prediction)

    data['prediction'] = final_predictions

    return data[['tag_id_long','prediction']]

def voting_classifier_probabilistic(data): 
    """
    Applies an ensemble voting classifier using a decision tree and a random forest on the input data.

    Parameters
    ----------
    data : pandas.DataFrame
        The input data containing features and target labels.

    Returns
    -------
    pandas.DataFrame
        DataFrame containing 'tag_id_long' along with predictions from both the decision tree and the random forest classifiers.

    Notes
    -----
    - Predictions from both classifiers are added to the input data as new columns: 'dt_prediction' and 'rf_prediction'.
    """

    data = data.copy()
    data = data.dropna()
    X = data.drop(['species', 'tag_id_long'], axis=1)
    y = data['species']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)


    dt = DecisionTreeClassifier(max_depth = 7, min_samples_split = 6, min_samples_leaf = 4, 
                                random_state = 42)
    dt.fit(X_train, y_train)

    rf = RandomForestClassifier(n_estimators=100, random_state=42)
    rf.fit(X_train, y_train)

    dt_pred = dt.predict(X)

    rf_pred = rf.predict(X) 

    data['dt_prediction'] = dt_pred
    data['rf_prediction'] = rf_pred

    return data[['tag_id_long','dt_prediction', 'rf_prediction']]



def voting_classifier(det_results,prob_results):
    """
    Combines deterministic and probabilistic classification results to return a final ensemble prediction.

    Parameters
    ----------
    det_results : pandas.DataFrame
        DataFrame containing deterministic classification results.
        
    prob_results : pandas.DataFrame
        DataFrame containing probabilistic classification results.

    Returns
    -------
    pandas.DataFrame
        DataFrame containing 'tag_id_long' and the final ensemble prediction.

    Notes
    -----
    - The two input DataFrames are merged on 'tag_id_long'.
    - The final prediction is determined by the following rules:
        - If 'pink' is among the predictions, the final prediction is 'pink'.
        - If 'so' is among the predictions, the final prediction is 'so'.
        - Otherwise, the final prediction is the most common prediction among the three.
    """
    df = det_results.merge(prob_results,on='tag_id_long',how='left')
    df.columns = ['tag_id_long','pred_1','pred_2','pred_3']

    ensemble_pred = []
    for row in range(len(df)):
        # predictions = []
        prediction = [df.iloc[row]['pred_1'],
                      df.iloc[row]['pred_2'],
                      df.iloc[row]['pred_3']]
        if 'pink' in prediction:
            ensemble_pred.append('pink')
        elif 'so' in prediction:
            ensemble_pred.append('so')
        else:
            ensemble_pred.append(max(set(prediction), key=prediction.count))


    df['prediction'] = ensemble_pred
    
    return df
        
        

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