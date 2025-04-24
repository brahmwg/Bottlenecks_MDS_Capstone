import os
import pandas as pd
import numpy as np
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_absolute_error
import streamlit as st
import matplotlib.pyplot as plt

# Get the absolute path to the CSV file (using the script directory)
script_dir = os.path.dirname(os.path.abspath(__file__))  # Current directory of the script
csv_file_path = os.path.join(script_dir, 'data', 'preprocessed', 'preprocessed_ck.csv')

# Load the historical data from the CSV file
data = pd.read_csv(csv_file_path)

# Convert date to datetime
data['date'] = pd.to_datetime(data['date'])

# Feature Engineering for Seasonality
data['year'] = data['date'].dt.year
data['month'] = data['date'].dt.month
data['day'] = data['date'].dt.day
data['day_of_year'] = data['date'].dt.dayofyear  # For capturing seasonality

# Adding cyclic features to capture seasonality (sine and cosine transformations)
data['sin_month'] = np.sin(2 * np.pi * data['month'] / 12)
data['cos_month'] = np.cos(2 * np.pi * data['month'] / 12)
data['sin_day_of_year'] = np.sin(2 * np.pi * data['day_of_year'] / 365)
data['cos_day_of_year'] = np.cos(2 * np.pi * data['day_of_year'] / 365)

# Generate rolling features
data['rolling_temp_mean_10'] = data['Temp'].rolling(window=10).mean()
data['rolling_flow_mean_10'] = data['Flow'].rolling(window=10).mean()
data['rolling_level_mean_10'] = data['Level'].rolling(window=10).mean()

# Define target and features
target = 'count'
features = ['Temp', 'Flow', 'Level', 'sin_month', 'cos_month', 'sin_day_of_year', 'cos_day_of_year', 
            'rolling_temp_mean_10', 'rolling_flow_mean_10', 'rolling_level_mean_10']

# Remove rows with missing values
data = data.dropna(subset=features + [target])

# Split into training and test sets
X = data[features]
y = data[target]

# Split the data into train and test sets (80/20 split)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Normalize the features using StandardScaler
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Initialize the XGBoost model
model = xgb.XGBRegressor(objective='reg:squarederror', n_estimators=1000)

# Train the model
model.fit(X_train_scaled, y_train)

# Predict on the test set
y_pred = model.predict(X_test_scaled)


# Streamlit user interface components
st.title("Salmon Outmigration Timing Predictions")
prediction_year = st.number_input("Enter the year for prediction:", min_value=2020, max_value=2030, step=1)
lower_percentile = st.slider("Select the lower percentile of outmigration:", min_value=0, max_value=100, value=5)
upper_percentile = st.slider("Select the upper percentile of outmigration:", min_value=0, max_value=100, value=10)

# Generate the date range for the entire year (e.g., 2025)
start_date = f'{prediction_year}-01-01'
end_date = f'{prediction_year}-12-31'
date_range = pd.date_range(start=start_date, end=end_date, freq='D')

# Create a DataFrame for the prediction year
prediction_data = pd.DataFrame({'date': date_range})
prediction_data['year'] = prediction_data['date'].dt.year
prediction_data['month'] = prediction_data['date'].dt.month
prediction_data['day'] = prediction_data['date'].dt.day
prediction_data['day_of_year'] = prediction_data['date'].dt.dayofyear  # For capturing seasonality

# Add cyclic features to capture seasonality
prediction_data['sin_month'] = np.sin(2 * np.pi * prediction_data['month'] / 12)
prediction_data['cos_month'] = np.cos(2 * np.pi * prediction_data['month'] / 12)
prediction_data['sin_day_of_year'] = np.sin(2 * np.pi * prediction_data['day_of_year'] / 365)
prediction_data['cos_day_of_year'] = np.cos(2 * np.pi * prediction_data['day_of_year'] / 365)

# Use real or forecasted values for Temp, Flow, Level in future years (for example, let's use averages here)
prediction_data['Temp'] = np.random.uniform(15, 25, size=len(prediction_data))
prediction_data['Flow'] = np.random.uniform(0.5, 2.5, size=len(prediction_data))
prediction_data['Level'] = np.random.uniform(0.4, 1.0, size=len(prediction_data))

# Calculate rolling features for the prediction year data
prediction_data['rolling_temp_mean_10'] = prediction_data['Temp'].rolling(window=10).mean().fillna(method='ffill')
prediction_data['rolling_flow_mean_10'] = prediction_data['Flow'].rolling(window=10).mean().fillna(method='ffill')
prediction_data['rolling_level_mean_10'] = prediction_data['Level'].rolling(window=10).mean().fillna(method='ffill')

# Normalize the prediction data using the same scaler
X_pred = prediction_data[features]
X_pred_scaled = scaler.transform(X_pred)

# Make predictions on the prediction data
predictions = model.predict(X_pred_scaled)

# Add the predictions to the DataFrame
prediction_data['pred'] = predictions

# Adjust predictions (set to 0 if less than or equal to 0)
prediction_data["pred_adjust"] = prediction_data["pred"].apply(lambda x: 0 if x <= 0 else x)

# Calculate the total percentage and cumulative percentage for adjusted predictions
total_percentage = prediction_data["pred_adjust"].sum()
prediction_data["pred_adjust_cumulative_percentage"] = (prediction_data["pred_adjust"] / total_percentage).cumsum() * 100

# Filter the predictions by the specified percentile range
result_df = prediction_data[(prediction_data["pred_adjust_cumulative_percentage"] >= lower_percentile) & 
                             (prediction_data["pred_adjust_cumulative_percentage"] <= upper_percentile)]

# Get the start and end date of the predicted range
start_date_ts = result_df.iloc[0]['date']
end_date_ts = result_df.iloc[-1]['date']

# Display the predicted date range
st.write(f"The predicted date range for salmon counts between {lower_percentile}% and {upper_percentile}% of total adjusted counts in {prediction_year} is between {start_date_ts.strftime('%Y-%m-%d')} and {end_date_ts.strftime('%Y-%m-%d')}.")

# Plot the predictions
st.subheader("Prediction Plot")

df_plot = prediction_data.copy()
df_plot = df_plot.set_index('date')

plt.figure(figsize=(10, 6))
plt.plot(df_plot.index, df_plot['pred'], label='Prediction', color='red')
plt.plot(df_plot.index, df_plot['pred_adjust'], label=f'Adjusted Prediction ({lower_percentile}% to {upper_percentile}%)', color='blue')

# Highlight the prediction range
plt.axvline(x=start_date_ts, color='blue', linestyle='--', linewidth=2, alpha=0.7)
plt.axvline(x=end_date_ts, color='blue', linestyle='--', linewidth=2, alpha=0.7)

plt.title(f'Prediction and Adjusted Prediction Over Time in {prediction_year}')
plt.xlabel('Date')
plt.ylabel('Count of Salmon')
plt.legend()

# Show the plot in the Streamlit app
st.pyplot(plt)
