This task is about one of the most useful DVC features: **parameter tracking**.

Normally, DVC tracks **files** (datasets, models, scripts). It **does not automatically track values inside YAML files** unless you explicitly tell it.

---

# Current Pipeline

```
params.yaml
-------------
n_estimators: 100
```

```
src/models/train.py

read params.yaml
↓
n_estimators = 100
↓
Train RandomForest
↓
models/model.pkl
```

Your Python code already reads the parameter.

The problem is:

```
params.yaml changed
        ↓
DVC doesn't know
        ↓
train stage is skipped ❌
```

because `dvc.yaml` never declared that `n_estimators` is an input.

---

# Why DVC needs params:

Imagine these two experiments.

Experiment A

```
n_estimators = 100
accuracy = 91%
```

Experiment B

```
n_estimators = 300
accuracy = 94%
```

If DVC doesn't know that `n_estimators` matters,

it thinks

```
Nothing changed.
No need to retrain.
```

which is wrong.

Adding a `params:` section tells DVC

> "This stage depends on this value."

Then DVC hashes that value just like it hashes files.

---

# Step 1 Go to project

```bash
cd /root/code/fraud-detection
```

Check the pipeline

```bash
cat dvc.yaml
```

You'll probably see something similar to

```yaml
stages:
  train:
    cmd: python src/models/train.py
    deps:
      - src/models/train.py
      - data/split
    outs:
      - models/model.pkl
```

Notice

There is **no**

```yaml
params:
```

section.

---

# Step 2 Edit dvc.yaml

Open it

```bash
vi dvc.yaml
```

or

```bash
nano dvc.yaml
```

Find the train stage.

Change it to

```yaml
train:
  cmd: python src/models/train.py
  deps:
    - src/models/train.py
    - data/split
  params:
    - n_estimators
  outs:
    - models/model.pkl
```

If params.yaml looked like

```yaml
model:
  n_estimators: 100
```

then you'd write

```yaml
params:
  - model.n_estimators
```

But your task says

```
n_estimators: 100
```

so use

```yaml
params:
  - n_estimators
```

Save.

---

# Why this works

Now DVC stores

```
train stage depends on

✓ train.py
✓ split data
✓ n_estimators
```

So if **any** of these change,

train will rerun.

---

# Step 3 Reproduce pipeline

Run

```bash
dvc repro
```

Expected

```
Running stage 'train':
...
Updating dvc.lock
```

Now inspect

```bash
cat dvc.lock
```

You should see something similar

```yaml
train:
  cmd: python src/models/train.py

  params:
    params.yaml:
      n_estimators: 100

  outs:
    - models/model.pkl
```

Notice

```
100
```

is now recorded.

Before,

```
dvc.lock

(no parameter stored)
```

After,

```
dvc.lock

n_estimators = 100
```

---

# Step 4 Commit first experiment

```bash
git add .
git commit -m "Track n_estimators parameter"
```

This becomes your baseline experiment.

---

# Step 5 Change parameter

Open

```bash
params.yaml
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

# Step 6 Reproduce again

Run

```bash
dvc repro
```

Expected output

```
Running stage 'train'
```

Only

```
train
```

should execute.

Not

```
process_data
split_data
```

because nothing upstream changed.

This is the important concept.

Instead of rebuilding everything,

```
process_data  skipped ✔
split_data    skipped ✔
train         rerun ✔
```

Only the affected stage executes.

---

# Step 7 Check dvc.lock again

Now

```bash
cat dvc.lock
```

should show

```yaml
params:
  params.yaml:
    n_estimators: 200
```

instead of

```yaml
100
```

DVC automatically updated the lock file.

---

# Step 8 Verify model regenerated

Check modification time

```bash
ls -l models/model.pkl
```

The timestamp should now be newer.

That proves

```
train reran
↓

new model generated
```

---

# Step 9 Commit second experiment

```bash
git add .
git commit -m "Change n_estimators to 200"
```

Now Git has

Commit 1

```
n_estimators = 100
```

Commit 2

```
n_estimators = 200
```

---

# Step 10 Compare experiments

Run

```bash
dvc params diff HEAD~1 HEAD
```

or simply

```bash
dvc params diff
```

depending on your current branch and commit history.

Expected output

```
Path         Param          Old   New
params.yaml  n_estimators   100   200
```

This is incredibly useful.

Suppose six months later you have

| Experiment | Accuracy |
| ---------- | -------- |
| A          | 90%      |
| B          | 94%      |
| C          | 92%      |

Instead of opening every commit,

```
dvc params diff
```

immediately shows

```
learning_rate
batch_size
epochs
n_estimators
dropout
```

and exactly what changed.

---

# What happened internally?

Before:

```
params.yaml
      │
      ▼
train.py
      │
      ▼
model.pkl
```

DVC only knew

```
train.py
```

was an input.

Changing

```
params.yaml
```

didn't trigger anything.

After adding:

```yaml
params:
  - n_estimators
```

the dependency graph becomes

```
params.yaml
       │
       ▼
train stage
       │
       ▼
model.pkl
```

Now DVC hashes the parameter value.

```
100
```

↓

Hash A

Change to

```
200
```

↓

Hash B

Hash changed → stage becomes stale → DVC reruns only that stage.

---

## Final result (acceptance criteria)

* ✅ `train` stage in `dvc.yaml` includes:

  ```yaml
  params:
    - n_estimators
  ```

* ✅ `dvc repro` reproduces the pipeline and records `n_estimators` in `dvc.lock`.

* ✅ Changing `params.yaml` from `100` to `200` causes **only the `train` stage** to rerun and regenerates `models/model.pkl`.

* ✅ `dvc.lock` updates to store the new parameter value (`n_estimators: 200`).

* ✅ `dvc params diff` shows the parameter change across Git commits, making experiments reproducible and easy to compare.
