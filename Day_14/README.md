The xFusionCorp Industries ML team utilizes DVC pipelines to ensure the reproducibility of data processing. The fraud-detection project has the processing scripts and raw data in place but does not yet define a pipeline. Define a two-stage DVC pipeline so the data processing runs reproducibly from start to finish with dvc repro.


A project exists at /root/code/fraud-detection/ with DVC initialised. The scripts are at src/data/process_data.py and src/data/split_data.py, and the raw input is at data/raw/transactions.csv. Do not modify the Python files or the input data.

Create a dvc.yaml defining two stages (use dvc stage add, or write the YAML directly):

process_data – runs python3 src/data/process_data.py; depends on data/raw/transactions.csv and src/data/process_data.py; produces data/processed/clean_transactions.csv.
split_data – runs python3 src/data/split_data.py; depends on data/processed/clean_transactions.csv (the upstream stage's output, so DVC chains the stages) and src/data/split_data.py; produces data/processed/train.csv and data/processed/test.csv.
Run the pipeline with dvc repro so both stages execute in order and dvc.lock is written.

After your changes, dvc status must report no stale stages.

Use python3 (not python) in the stage commands. Once the pipeline is valid, dvc dag prints the dependency graph showing how the two stages chain together.
