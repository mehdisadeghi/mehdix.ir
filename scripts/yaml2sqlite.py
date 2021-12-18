import json
import os
import sqlite3
from datetime import datetime

import yaml
from cryptography.fernet import Fernet
from dateutil import parser


def encrypt(text, secret):
    """Encrypt the text using the secret."""
    f = Fernet(secret)
    s = json.dumps(text)
    return f.encrypt(s.encode("utf8"))


def decrypt(text, secret):
    """Decrypt the text using the secret."""
    f = Fernet(secret)
    s = f.decrypt(text)
    return json.loads(s)


for dirpath, dirname, filenames in os.walk('.'):
    for yfile in filenames:
        if not yfile.endswith('yml') and not yfile.startswith('.'):
            continue
        #print(yfile)
        with open(yfile, encoding='utf8') as f:
            ydocs = yaml.safe_load(f)
            if not ydocs:
                continue
            for doc in ydocs:
                #print(doc.get('page_id'), doc['id'])
                #print(doc['created_at'])
                #time = parser.parse(doc['created_at'])
                #print(decrypt(doc['bucket'], os.environ['SECRET']))
                #continue
                time = doc['created_at']
                #print(time)
                #continue
                name = doc['name']
                email = decrypt(doc['bucket'], os.environ['SECRET'])
                page_id = doc.get('page_id', '')
                reply_to = doc.get('reply_to', '')
                website = doc['website']
                spam = 0
                message = doc['message']
                legacy_id = doc['id']
                #if page_id and page_id.startswith('/'):
                #    page_id = page_id[1:]
                with sqlite3.connect('mehdix.db') as con:
                    cur = con.cursor()
                    q = """
insert into comments (time, name, email,
page_id, reply_to, website, spam, message,
legacy_id) values (?, ?, ?, ?, ?, ?, ?, ?, ?)"""
                    cur.execute(q, (time, name, email,
page_id, reply_to, website, spam,
message, legacy_id))
                    con.commit()
