This task is about **DVC Parameter Tracking**. The important concept is that **DVC only monitors parameters that are declared in `dvc.yaml`**. Even though your Python code already reads `params.yaml`, DVC won't know that changing `params.yaml` should trigger the `train` stage unless you explicitly declare it.

---

# Step 1: Go to the project directory

```bash
cd /root/code/fraud-detection
```

Verify the project.

```bash
ls
```

You should see something similar to

```
data/
dvc.yaml
params.yaml
src/
models/
```

---

# Step 2: Check the current pipeline

View the pipeline.

```bash
cat dvc.yaml
```

The train stage probably looks something like this.

```yaml
stages:
  train:
    cmd: python src/models/train.py
    deps:
      - src/models/train.py
      - data/processed/train.csv
      - data/processed/test.csv
    outs:
      - models/model.pkl
```

Notice there is **no `params:` section**.

---

# Step 3: Check params.yaml

```bash
cat params.yaml
```

Output

```yaml
n_estimators: 100
```

The Python code already reads this file.

---

# Step 4: Edit dvc.yaml

Open it.

```bash
vi dvc.yaml
```

(or nano)

Locate the **train** stage.

Add a **params** section.

Before

```yaml
train:
  cmd: python src/models/train.py
  deps:
    - src/models/train.py
    - data/processed/train.csv
    - data/processed/test.csv
  outs:
    - models/model.pkl
```

After

```yaml
train:
  cmd: python src/models/train.py
  deps:
    - src/models/train.py
    - data/processed/train.csv
    - data/processed/test.csv
  params:
    - n_estimators
  outs:
    - models/model.pkl
```

Save and exit.

---

# Step 5: Reproduce the pipeline

Run

```bash
dvc repro
```

Expected output

```
Running stage 'train':
> python src/models/train.py

Updating lock file 'dvc.lock'
```

Only the train stage should execute if the previous stages are already up to date.

---

# Step 6: Verify dvc.lock

Open

```bash
cat dvc.lock
```

Inside the train stage you'll now see something similar to

```yaml
train:
  cmd: python src/models/train.py
  params:
    params.yaml:
      n_estimators: 100
```

This proves DVC is now tracking the parameter.

---

# Step 7: Commit the current experiment

```bash
git add .
git commit -m "Track n_estimators parameter"
```

---

# Step 8: Change the parameter

Open

```bash
vi params.yaml
```

Change

```yaml
n_estimators: 100
```

to

```yaml
n_estimators: 200
```

Save.

---

# Step 9: Run the pipeline again

```bash
dvc repro
```

Now DVC compares

Old

```
100
```

with

New

```
200
```

Because the parameter changed, only the train stage is rerun.

Expected output

```
Stage 'process_data' didn't change, skipping

Stage 'split_data' didn't change, skipping

Running stage 'train':
> python src/models/train.py
```

Exactly what the task requires.

---

# Step 10: Verify dvc.lock updated

```bash
cat dvc.lock
```

Now you'll see

```yaml
params:
  params.yaml:
    n_estimators: 200
```

instead of

```yaml
100
```

---

# Step 11: Verify the model was regenerated

Check the timestamp.

```bash
ls -l models/model.pkl
```

The modification time should now be updated.

---

# Step 12: Commit the new experiment

```bash
git add .
git commit -m "Increase n_estimators to 200"
```

---

# Step 13: Compare parameter values

Run

```bash
dvc params diff
```

Example output

```text
Path         Param          Old    New
params.yaml  n_estimators   100    200
```

This compares the tracked parameter between Git commits and demonstrates parameter-driven reproducibility.

---

# Why only the train stage reruns

Pipeline dependency graph:

```
params.yaml
      │
      ▼
+-------------------+
|      Train        |
+-------------------+
         │
         ▼
models/model.pkl
```

The stages `process_data` and `split_data` do **not** depend on `n_estimators`, so DVC skips them.

```
process_data     ✔ skipped
split_data       ✔ skipped
train            ✔ rerun
```

---

# Final `train` stage

Your `train` stage should look like this:

```yaml
train:
  cmd: python src/models/train.py
  deps:
    - src/models/train.py
    - data/processed/train.csv
    - data/processed/test.csv
  params:
    - n_estimators
  outs:
    - models/model.pkl
```

---

## Commands summary

```bash
cd /root/code/fraud-detection

cat params.yaml
cat dvc.yaml

# Edit dvc.yaml
vi dvc.yaml

# Reproduce
dvc repro

# Commit baseline
git add .
git commit -m "Track n_estimators parameter"

# Change parameter
vi params.yaml

# Reproduce again
dvc repro

# Verify
cat dvc.lock
ls -l models/model.pkl

# Commit new experiment
git add .
git commit -m "Increase n_estimators to 200"

# Compare parameter values
dvc params diff
```

This satisfies all the acceptance criteria:

* `n_estimators` is declared under the `params:` section of the `train` stage.
* `dvc repro` reruns only the `train` stage when `n_estimators` changes.
* `dvc.lock` records the updated parameter value.
* `dvc params diff` reports the parameter changes across Git commits.
