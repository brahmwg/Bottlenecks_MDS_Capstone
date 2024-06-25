# Outmigration Model- Outmigration Date Prediction 
## 1. Objective
The goal of this model is to predict the outmigration timing of salmon. With accurate predictions, biologists at the Pacific Salmon Foundation will be able to conduct fieldwork tagging the salmon on the right day. 

## 2. Method
### 2.1. Data Collection 
The data used in this model comes from three different sources. The historical tagging data from 2014 to 2023 is collected by the Pacific Salmon Foundation; the data on river flow and level is from the [National Water Data Archive: HYDAT](https://www.canada.ca/en/environment-climate-change/services/water-overview/quantity/monitoring/survey/data-products-services/national-archive-hydat.html); the temperature data is from [ECCC/MSC’s National Climate Archive](https://climate-change.canada.ca/climate-data/#/hourly-climate-data).

### 2.2. Preprocessing 
After using SQL to retrieve the data from the Strait of Georgia Data Center, we used two functions to preprocess the data before using them to train the model. Function preprocess_sql is used to contact the 2014-2020 data stored in the `cowichan_historic.csv` file with the 2021-2023 data stored in the `data_salmon2.csv` file. The output, along with flow, level, and temperature will then be preprocessed with the `preprocessing` function that merges the data frames together; this function will also create the rolling mean of 30-35, 30-40, and 30-45 days prior to a given tagging date. 

### 2.3. Modeling 
#### 2.3.1 Feature engineering 
During modeling, we discovered that FLOW and LEVEL data were highly correlated, therefore, we decided to eliminate all LEVEL variables since the biologists suggested that FLOW would be more indicative of outmigration. Since the data is time series, the function also created lagged features of FLOW value, which is the FLOW value of the previous 31-34 days corresponding to a given date. 

Since outmigration only happens around summer, the function also eliminates months other than April, May, June, July, and August so the data is not sparse. 
The function also inputs missing values with the medium value of the column. 

#### 2.3.2 Model selection 
To predict the day of outmigration- we are modeling using each historical date as a row, and the count as outcome variable. We tried modeling using linear regression, SARIMAX, and XGBoost regressor. With the amount of turning that we were able to invest, XGBoost returned the best prediction on the test set. 

#### 2.3.3 Model training 
The model will take an input year of prediction and split the predictors, which are everything besides count, as the X_test and keep the rest as X_train and y_train. 
The model will use a standard scaler to ensure the columns are on similar scales. With Lasso regression, the function then did feature selection and the best alpha value for the XGBoost model using cross-validation. 

#### 2.3.4 Model prediction 
Trained with X_train and y_train, the model then will be used to make predictions on the test year. The function adjusts the prediction to non-negative values by turning the negative values to zero. The function has two outputs- First is a graph to visualize the count from April to August and to be more informative, the function also returns a string indicating the date interval of the first 5-10% of the outmigration of the test year. 

## 3. Future recommandations 
As mentioned previously, there is more than one modeling approach that can be used to predict outmigration dates. So far this project only developed the XGBoost approach in depth, with more feature engineering and model tuning, other modeling approaches might be able to deliver accurate results as well. 



