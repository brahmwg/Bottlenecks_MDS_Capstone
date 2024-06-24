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

## 2. Installation 
### 2.1 Packages needed
The packages needed to run these scripts are
```
import pandas as pd
from tensorflow.keras.models import load_model
import numpy as np 

from sklearn.compose import make_column_transformer
from sklearn.preprocessing import (
    OneHotEncoder,
    OrdinalEncoder,
    StandardScaler,
    LabelEncoder
)

from sklearn.model_selection import train_test_split
from sklearn.dummy import DummyClassifier

import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras.optimizers import Adam

import matplotlib.pyplot as plt
import seaborn as sns
```
### 2.2 Setting up your environment
The results for this model are defined and complete. It is saved as `field_imputation_species.csv`. If you wish to run these notebooks locally, follow these steps:
1. Clone the repository
```
git clone https://github.com/brahmwg/Bottlenecks_MDS_Capstone.git
cd Bottlenecks_MDS_Capstone
```
2. Create a virtual environment
```
conda create -n mds-bottleneck -f environments/environment_ml.yml
```
3. Activate this environment
```
conda activate mds_bottleneck
```
4. Run the ipynb scripts using Jupyter Lab or any similar IDE
5. When complete, deactivate the environment
```
conda deactivate
```
## 3. Running scripts

The order in which you would generally run these scripts is starting at the training script, saving the trained model and then move on to the prediction script using the saved h5 model to finally produce the CSV file.

## 4. Expected outcome
The expected result of the prediction script is a CSV file with the following four columns; tag ID, species, predicted species and prediction probability.
An example output is:
| tag_id_long       | species | prediction | prediction probability |
|-------------------|---------|------------|------------------------|
| 989.001038747135  | co      | chinook    | 0.536905               |
| 989.001042042947  | ck      | chinook    | 0.648501               |
| 989.001042516590  | ck      | chinook    | 0.739064               |
| 989.001042048086  | co      | coho       | 0.427051               |
| 989.001038855867  | co      | chinook    | 0.471850               |
