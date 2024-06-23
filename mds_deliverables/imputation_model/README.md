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

| Folder Name | Stored File Formats | Description |
| --- | --- | --- |
|data/raw_data|csv|The data used for training the field model - `field_genetics_species.csv`, predictions were made on `sql_field_imputation.csv`. `microtroll_train and `microtroll_test` are for training and testing a microtroll model in the future.|
|data/raw_data/sql_for_data.md| markdown file | Stores all the queries used to pull the data for training and testing from the Strait of Georgia Data Center|
|data/result|

## 2. Installation (ENV)
how to reproduce
## 3. Running scripts
which order, where are things
## 4. Expected outcome
results
