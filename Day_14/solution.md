This is a typical DVC pipeline task. The goal is to create a reproducible pipeline where one stage automatically feeds the next.

Let's do it exactly as you would on the server.

---

# Step 1: Go to the project

```bash
cd /root/code/fraud-detection
```

Check the project:

```bash
pwd
ls
```

You should see something similar to

```
data/
src/
.dvc/
```

---

# Step 2: Verify DVC is initialized

Run

```bash
dvc status
```

If DVC is initialized correctly, you'll either see

```
There are no data or pipelines tracked in this project yet.
```

or

```
Pipeline is up to date.
```

If you get

```
ERROR: you are not inside of a DVC repository
```

then you're in the wrong directory.

---

# Step 3: Verify the scripts exist

```bash
ls src/data
```

Expected

```
process_data.py
split_data.py
```

---

# Step 4: Verify raw data exists

```bash
ls data/raw
```

Expected

```
transactions.csv
```

---

# Step 5: Create the first stage

Run

```bash
dvc stage add \
-n process_data \
-d data/raw/transactions.csv \
-d src/data/process_data.py \
-o data/processed/clean_transactions.csv \
python3 src/data/process_data.py
```

Explanation

```
-n
stage name

-d
dependencies

-o
output

python3 ...
command to execute
```

You should see something like

```
Added stage 'process_data' in dvc.yaml
```

---

# Step 6: Create the second stage

Run

```bash
dvc stage add \
-n split_data \
-d data/processed/clean_transactions.csv \
-d src/data/split_data.py \
-o data/processed/train.csv \
-o data/processed/test.csv \
python3 src/data/split_data.py
```

Expected output

```
Added stage 'split_data'
```

---

# Step 7: Inspect dvc.yaml

Open it

```bash
cat dvc.yaml
```

It should look like

```yaml
stages:
  process_data:
    cmd: python3 src/data/process_data.py
    deps:
      - data/raw/transactions.csv
      - src/data/process_data.py
    outs:
      - data/processed/clean_transactions.csv

  split_data:
    cmd: python3 src/data/split_data.py
    deps:
      - data/processed/clean_transactions.csv
      - src/data/split_data.py
    outs:
      - data/processed/train.csv
      - data/processed/test.csv
```

Notice

```
clean_transactions.csv
```

is

* output of Stage 1
* dependency of Stage 2

This is what creates the pipeline chain.

---

# Step 8: Execute the pipeline

Run

```bash
dvc repro
```

Expected

```
Running stage 'process_data'

...

Running stage 'split_data'

...

Generating lock file 'dvc.lock'
```

At the end you'll have

```
dvc.lock
```

created automatically.

---

# Step 9: Verify outputs

Run

```bash
ls data/processed
```

Expected

```
clean_transactions.csv
train.csv
test.csv
```

---

# Step 10: Verify pipeline status

Run

```bash
dvc status
```

Expected

```
Data and pipelines are up to date.
```

or

```
Pipeline is up to date.
```

There should be **no stale stages**.

---

# Step 11: Display the pipeline graph

Run

```bash
dvc dag
```

Expected

```
process_data
      |
      |
split_data
```

or an equivalent ASCII graph showing `process_data` feeding into `split_data`.

---

# Step 12: Verify the lock file

Open it

```bash
cat dvc.lock
```

You'll see something like

```yaml
schema: '2.0'

stages:
  process_data:
    cmd: python3 src/data/process_data.py
    deps:
      ...
    outs:
      ...

  split_data:
    cmd: python3 src/data/split_data.py
    deps:
      ...
    outs:
      ...
```

This file stores hashes of dependencies and outputs so DVC can determine whether a stage needs to be rerun.

---

# Final project structure

```
fraud-detection/
│
├── data
│   ├── raw
│   │     transactions.csv
│   │
│   └── processed
│         clean_transactions.csv
│         train.csv
│         test.csv
│
├── src
│   └── data
│         process_data.py
│         split_data.py
│
├── dvc.yaml
├── dvc.lock
└── .dvc/
```

---

# All commands together

```bash
cd /root/code/fraud-detection

dvc stage add \
-n process_data \
-d data/raw/transactions.csv \
-d src/data/process_data.py \
-o data/processed/clean_transactions.csv \
python3 src/data/process_data.py

dvc stage add \
-n split_data \
-d data/processed/clean_transactions.csv \
-d src/data/split_data.py \
-o data/processed/train.csv \
-o data/processed/test.csv \
python3 src/data/split_data.py

dvc repro

dvc status

dvc dag
```

This sequence satisfies all the requirements: it defines the two-stage pipeline, uses `python3`, generates `dvc.lock`, reports no stale stages with `dvc status`, and shows the dependency chain with `dvc dag`.
