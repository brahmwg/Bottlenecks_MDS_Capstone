# Species prediction model - Imputation of missing species
## 1. Objective
The goal of this model was to make the data stored in the data center as complete as possible by imputing the species of the fish wherever possible and/or necessary. This was to be done on data that had been collected in the past by experts doing field work.
Thus, the 2 primary objectives were:
1. To impute data in places where the species of a fish was not recorded 
2. To detect and correct mislabelled species if any

## 2. Method
The modelling approach used is a Deep learning neural network on a tensorflow framework. The reason for finalizing this model was due to its validation accuracy (95%) and due to its ability to detect subtle nuances in the dataset.
### 2.1 Data collection
The data for training had to be confirmed data. Out of the 57k data points (fishes) in the field table, 5000 of them had their species confirmed by the genetics lab. This became our training set. The extracted dataset (from the data center) had the following columns,
<img width="768" alt="SQL op for imputation" src="https://github.com/brahmwg/Bottlenecks_MDS_Capstone/assets/85408127/a258bc49-b8ac-4780-befe-1e9a2e21250e">

The queries to extract the [train](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/tree/main/mds_deliverables/imputation_model/data/raw_data) and [test](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/blob/main/mds_deliverables/imputation_model/data/raw_data/sql_field_imputation_data.csv) data needed for this model is saved in the [data folder](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/blob/main/mds_deliverables/imputation_model/data/raw_data/sql_for_data.md). 

### 2.2 Pre-processing
Since the data pulled from the data center is not in a model ingestable format, we did the following preprocessing steps:
1. Removed null values (if any)
2. Added 2 new features extracted from date: day of the year (a  whole number between 1 and 365) and the year (2021-2023)
3. Removed tag_id (since it is unique), applied standard scaling to fork length and day of the year and one-hot encoded the rest of the features to make it in a model ingestible format.
   
### Model training and prediction
The model employed is a deep learning neural network consisting of four layers: one input layer, two hidden layers, and one output layer. The architecture is defined using TensorFlow's Keras API, with the following configuration: `dl_model = tf.keras.Sequential([ layers.Input(shape=(num_features,)), layers.Dense(128, activation='relu'), layers.Dense(64, activation='relu'), layers.Dense(3, activation='softmax') ])`. The ReLU (Rectified Linear Unit) activation function is applied after the input layer and between the hidden layers to introduce non-linearity, enabling the model to learn complex patterns. The softmax activation function is used in the output layer to convert the output into a probability distribution over the possible classes, facilitating multi-class classification.

The model is compiled using the Adam optimizer with a learning rate of 0.0001. Adam (Adaptive Moment Estimation) is a popular optimizer in deep learning due to its ability to adapt the learning rate for each parameter, combining the advantages of both RMSProp and SGD with momentum. This results in faster convergence and improved performance on complex tasks. The loss function used is categorical crossentropy, which is suitable for multi-class classification problems as it measures the difference between the predicted probability distribution and the true distribution. Additionally, accuracy is used as a metric to evaluate the model's performance during training.

After training, the model is saved in an .h5 format, a versatile file format that allows for the storage of the complete architecture, weights, and optimizer state, ensuring the model can be easily loaded and used for future predictions.
