Assuming you're already inside the repository:

```bash
cd /root/code/fraud-detection
```

### Step 1: Verify Git is tracking the dataset

```bash
git ls-files data/raw/transactions.csv
```

You should see:

```text
data/raw/transactions.csv
```

---

### Step 2: Remove the dataset from Git tracking (keep the file on disk)

Use `--cached` so the file is not deleted locally:

```bash
git rm --cached data/raw/transactions.csv
```

---

### Step 3: Track the dataset with DVC

```bash
dvc add data/raw/transactions.csv
```

This will create:

```text
data/raw/transactions.csv.dvc
data/raw/.gitignore
```

The `.gitignore` will contain an entry preventing Git from tracking the dataset itself.

---

### Step 4: Check the changes

```bash
git status
```

You should see something similar to:

```text
deleted:   data/raw/transactions.csv
new file:  data/raw/transactions.csv.dvc
new file:  data/raw/.gitignore
```

---

### Step 5: Stage the DVC files

```bash
git add data/raw/transactions.csv.dvc
git add data/raw/.gitignore
```

---

### Step 6: Commit the changes

```bash
git commit -m "Track transactions dataset with DVC"
```

---

### Step 7: Verify DVC tracking

```bash
dvc status
```

And check:

```bash
git status
```

The dataset should now be managed by DVC through `transactions.csv.dvc`, while Git tracks only:

* `data/raw/transactions.csv.dvc`
* `data/raw/.gitignore`

The actual `transactions.csv` remains on disk but is no longer tracked directly by Git.
