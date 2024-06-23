# Species Prediction - Imputation of missing species
## 0. Objective
The objective of this model is to ensure data quality by making it clean, precise, complete, and accurate. Knowing the species of a fish can be very critical in understanding various patterns and trends in salmon fish and ensures that most datapoits are informative. This enhancement will facilitate future analysis, leading to clearer, more reliable results and improving the overall integrity of the data.

The goals of the model are:
1. To impute data in places where the species of a fish was not recorded 
2. To detect and correct mislabelled species if any

## 1. Folder structure
```
- data
  |- raw_data
    |- field_genetics_species.csv
    |- microtroll_test.csv
    |- microtroll_train.csv
    |- sql_field_imputation_data.csv
    |- sql_for_data.md            
  |- result
    |- field_imputation_species.csv   
- exploration
  |- decision_tree.ipynb 
  |- decision_tree.png
- model
  |- field_imputation_model.h5              
- scripts
  |- model_prediction.ipynb
  |- model_training.ipynb 
```
Here are some descriptions for our folders to better understand the files:
| Folder Name | Stored File Formats | Description |
| --- | --- | --- |
|Data/raw_data|CSV|The data used for training the field model - `field_genetics_species.csv`, predictions were made on `sql_field_imputation.csv`. `microtroll_train and `microtroll_test` are for training and testing a microtroll model in the future.|
|Data/raw_data/sql_for_data.md| markdown file | Stores all the queries used to pull the data for training and testing from the Strait of Georgia Data Center.|
|Data/result|CSV| `field_imputation_species.csv` is the prediction from the model stored in a CSV (comma separated variable) format. This file has the following columns: tag_is_long, species, predicted_species, predicted-probability.|
|Model|h5|The deep learning model and its weights, trained on field data is saved in a .h5 file in order to facilitate predictions. Predictions on field data can be made by calling this model.| 
|Scripts|ipynb|`model_training.ipynb` is the training script needed to understand, replicate or re-train the model for future use. `model_prediction.ipynb` has the script using which we have predicted species for the test data.|

## 2. Installation (ENV)
how to reproduce
## 3. Running scripts
which order, where are things
## 4. Expected outcome
results
