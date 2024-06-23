# Species prediction model
## 1. Objective
The goal of this model is to predict the species of a fish given its physical features, location, and site where it was detected.

## 2. About the Data
The data needed to train this model is a combination of deterministic features (the physical features of the fish) and non-deterministic features (the location, site method, and locality of the fish).

### 2.1 Deterministic Features
The deterministic features for each species of fish are as follows:

1. Eye size
2. Snout shape
3. Parr marks
4. Parr marks length
5. Spotting density
6. Fin type
7. Parr marks spacing
8. Spotting characteristic

<img width="600" alt="fish feats" src="https://github.com/brahmwg/Bottlenecks_MDS_Capstone/assets/85408127/6b2a605b-afe5-4cfa-83f7-15f8262c81a3">


### 2.2 Non-deterministic Features 

1. Location
2. Site method
3. Locality

<img width="600" alt="field feats" src="https://github.com/brahmwg/Bottlenecks_MDS_Capstone/assets/85408127/d1360dbb-e245-4ec2-9fd7-1ea4356a99e2">


These two sets of features are merged to create a complete dataset that is processed and fed into the probabilistic models. For the deterministic decision trees, only the deterministic features of the fish were used.

## 3. Pre-processing
### 3.1 Probabilistic Models
1. **Numerical Features**: The numerical features were kept as they were for the decision trees but were standard-scaled for the deep learning model.
2. **Categorical Features**: All the categorical features were one-hot encoded.
3. **Features Count**: Finally, we had 61 features for the probabilistic models.
### 3.2 Deterministic Models
Since all the deterministic features are categorical and non-ordinal, the only required processing is to transform the features into binary features using the OneHot encoding technique.

## 4. Ensemble Modeling
The idea for the ensemble model was to create a voting classifier. As illustrated in the figure, there are two branches: the deterministic branch and the probabilistic branch.

<img width="600" alt="voting classifier" src="https://github.com/brahmwg/Bottlenecks_MDS_Capstone/assets/85408127/ba1ee2ac-9f12-4fbc-94f1-96aec6d24ef6">


### 4.1 Deterministic Branch
The deterministic branch consists of 10 decision trees, each randomly trained on different physical features of the fish. The prediction from each tree is combined using a majority vote, and the resulting prediction is used as the output of the deterministic branch.

### 4.2 Probabilistic Branch
The probabilistic branch includes two models:
1. **Decision Tree Classifier**: This model is trained on the entire feature set, including both deterministic features (physical features of the fish) and non-deterministic features (location, water temperature, site, method, etc.).
2. **Deep Learning Neural Network**: This model, implemented on a TensorFlow framework, consists of 4 layers. It uses ReLU activations for the input and hidden layers, and a softmax activation for the output layer. This model is also trained on the complete feature set.

### 4.3 Voting Mechanism
The final prediction is made by the voting classifier, which combines the outputs from both branches:
- The output from the deterministic branch contributes 1/3 of the total vote.
- The outputs from the two probabilistic models (the decision tree and the deep learning model) each contribute 1/3 of the total vote.

The final prediction is determined by taking the majority vote from these three contributions, ensuring a balanced consideration of both deterministic and probabilistic features. This approach leverages the strengths of both branches to improve the accuracy and robustness of the species prediction.

### 5. Final Product
The final product delivered includes the pipeline code and a cron file. The pipeline code will be delivered in two scripts:

1. Processing File: An SQL file where all the processing mentioned in the document is performed.
2. Predict File: An SQL file where all the species predictions are performed.
The cron file, however, is not mandatory due to its nature; it is an orchestration file that the partners will work on internally since only they have the knowledge of when to schedule each of the pipelines.
