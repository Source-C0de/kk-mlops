Follow these steps carefully.

### 1. Go to the repository

```bash
cd /root/code/fraud-detection
```

---

### 2. Inspect the current DVC configuration

```bash
cat .dvc/config
```

Look for something similar to:

```ini
['remote "s3"']
    url = ...
    endpointurl = ...
```

Common problems are:

* Wrong bucket name
* Wrong endpoint URL
* Remote not set as default
* URL not using `s3://`

---

### 3. Configure the remote URL to the correct bucket

```bash
dvc remote modify s3 url s3://dvc-storage
```

---

### 4. Configure the SeaweedFS endpoint

```bash
dvc remote modify s3 endpointurl http://localhost:8333
```

---

### 5. Make `s3` the default remote

```bash
dvc remote default s3
```

This updates:

```ini
[core]
    remote = s3
```

---

### 6. Verify the configuration

```bash
cat .dvc/config
```

Expected structure:

```ini
[core]
    remote = s3

['remote "s3"']
    url = s3://dvc-storage
    endpointurl = http://localhost:8333
    access_key_id = weedadmin
    secret_access_key = weedadmin123
```

(The credentials should already exist.)

---

### 7. Test the remote

```bash
dvc remote list
```

Expected:

```text
s3    s3://dvc-storage    (default)
```

---

### 8. Push the tracked data

```bash
dvc push
```

Expected output resembles:

```text
1 file pushed
```

or

```text
Everything is up to date.
```

(if it was already uploaded).

---

### 9. Verify the objects exist in SeaweedFS

You can either:

```bash
dvc status -c
```

or open the **SeaweedFS Filer UI** (port 8888) and navigate:

```text
/buckets/
└── dvc-storage/
    └── files/
        └── md5/
            └── ...
```

The presence of objects under:

```text
files/md5/
```

confirms that `dvc push` succeeded and the dataset is stored in the SeaweedFS bucket.

---

### Useful one-liner sequence

```bash
cd /root/code/fraud-detection

dvc remote modify s3 url s3://dvc-storage
dvc remote modify s3 endpointurl http://localhost:8333
dvc remote default s3

cat .dvc/config
dvc push
```

If `dvc push` still fails, run:

```bash
dvc push -v
```

and inspect the exact error message—it usually points directly to the remaining configuration issue.
