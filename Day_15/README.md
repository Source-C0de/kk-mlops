The xFusionCorp Industries ML team manages model hyperparameters using params.yaml, enabling experiments to be conducted without altering the code. In the fraud-detection project, the train stage retrieves the n_estimators parameter from params.yaml, but this parameter is not declared to DVC, which means that changing its value does not initiate retraining. Integrate the parameter into the pipeline and illustrate the concept of parameter-driven reproducibility.


A project exists at /root/code/fraud-detection/ with a three-stage DVC pipeline (process_data, split_data, train) and a params.yaml declaring n_estimators: 100. src/models/train.py already reads n_estimators from params.yaml. Do not modify the Python files.

The train stage in dvc.yaml currently has no params: section, so DVC does not track n_estimators — changing it would not re-run the stage.

Acceptance criteria:

    - The train stage in dvc.yaml lists n_estimators under a params: section, and the pipeline has been reproduced.
    - Parameter-driven retraining is demonstrated: with n_estimators changed to a different value (for example 200), re-running the pipeline re-executes only the train stage, records the new value in dvc.lock, and regenerates models/model.pkl.


dvc params diff reports changes to the tracked parameter values across Git commits, which is useful when comparing experiments.