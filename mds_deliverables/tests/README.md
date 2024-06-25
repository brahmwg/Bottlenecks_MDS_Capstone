# Running Tests

This repository contains tests for the `process` and `prediction` functions for both the Species Prediction and Outmigration models.

## **Set up a virtual environment:**

   ```bash
   conda create env -f environments/environment_ml.yml
   ```

## **Running Tests**

To run the tests for the functions, follow these steps:

1. **Navigate to the tests directory:**

   ```bash
   cd mds_deliverables/tests
   ```

2. **Run the pytest command:**

   ```bash
    python test_species_process.py
    python test_species_predict.py
    python test_outmigration_process.py
    python test_outmigration_predict.py
   ```

   This command runs all the test functions defined in the test files (`test_species_predict.py`, etc.).

3. **View test results:**

   - If all tests pass, you will be return a newline character `\n`.
   - If any test fails, the scripts will output the error.

## Additional Notes

- Ensure that your environment is properly set up and activated before running the tests.
- Adjust paths and specific commands based on your project structure and environment setup.
