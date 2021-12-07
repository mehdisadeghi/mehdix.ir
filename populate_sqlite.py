import os
import yaml

for dirpath, dirname, filenames in os.walk('.').
    for yfile in filenames:
        with open(file) as f:
            for doc in yaml.safe_load(f):
                print(doc['email'])

