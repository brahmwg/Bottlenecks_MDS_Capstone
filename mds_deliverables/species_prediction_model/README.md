# Species Prediction Model
## 0. Objective
The goal of this model is to accurately predict the species of a fish based on its physical characteristics, the location where it was found, and the specific site of detection. This model is particularly useful in cases where a scientist forgets to record the species or is uncertain about the identification, providing reliable predictions to ensure data accuracy.

## 1. Folder structure

```
- data
  |- det.json      
  |- new_field.csv
- demo
  |- __init__.py
  |- demo.ipynb
- exploration
  |- Decision_tree_pipeline.ipynb 
  |- Deep_Learning_pipeline.ipynb
  |- Final_train_riya.ipynb
  |- Prediction_riya.ipynb
  |- dl_riya_new.h5
  |- dt_riya_new.pkl
- img
  |- Decision_tree.png
- model
  |- dl_riya_new.h5
  |- dt_riya_new.pkl
  |- dt_riya.h5
  |- dl_riya.h5            
- scripts
  |- __init__.py
  |- ensenble.py
  |- predict.py
  |- process.py
```
Here are some descriptions for our folders to better understand the files:
| Folder Name | Stored File Formats | Description |
| --- | --- | --- |
|Data/new_field.csv|CSV|Dummy data to run and understand the demo|
|Demo/demo.ipynb|ipynb| A notebook showing a simplified version of the actual pipeline. It takes the dummy data, preprocesses the data (using `process.py`), and injests the data into custom functions for training and predicting on the data. There is finally a function for the voting classifier that gives us the final result.|
|Model|h5/pkl| Contains all the models trained so far. Saved as .h5 or .pkl in case needed for later use.|
|Scripts| py | Contains all the scripts being used to train, predict and vote on the results|


## 2. Installation

### 2.1 Setting up your environment
This model is being delivered on a PL/Python pipeline orchastrated by cron. However, if you wish to run these notebooks locally, to understand the working of the model, follow these steps:
1. Clone the repository
```
git clone https://github.com/brahmwg/Bottlenecks_MDS_Capstone.git
cd Bottlenecks_MDS_Capstone
```
2. Create a virtual environment
```
conda env create -f environment_ml.yml
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

### 2.2 Packages needed
```
import pandas as pd
import pickle
import random
import warnings
import numpy as np

from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split

from sklearn.preprocessing import StandardScaler, LabelEncoder
import tensorflow as tf
from tensorflow.keras import layers
from tensorflow.keras.optimizers import Adam
```

## 3. Demo

Once you install and activate the environment, run the `demo.ipynb` file to view the working of the model. The expected result is a dataframe constisting of tag ID, pred_1 (prediction from deterministic branch), pred_2 (prediction from probabilistic decision tree), pred_3 (prediction from probabilistic tensorflow model) and prediction (model of the 3 predictions. Here is an example of the table:

| tag_id_long      | pred_1 | pred_2 | pred_3 | prediction |
|------------------|--------|--------|--------|------------|
| 989.001038884511 | ck     | ck     | pink     | ck         |
| 989.001038884511 | ck     | ck     | ck     | ck         |
| 989.001038885629 | ck     | co     | ck     | ck         |
| 989.001038888882 | ck     | ck     | ck     | ck         |
| 989.001038889013 | co     | co     | ck     | co         |

