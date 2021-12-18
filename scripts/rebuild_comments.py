import hashlib
import json
import os
import sqlite3
from collections import defaultdict

import requests
import yaml
from cryptography.fernet import Fernet
from pathlib2 import Path


def get_netlify_form_submissions(form_submissions_endpoint, access_token):
    """Get a map of post_uuid => list of comment dicts."""
    raw_comments = requests.get(
        form_submissions_endpoint,
        params={"access_token": access_token},
    )
    comments = json.loads(raw_comments.content.decode("utf-8"))
    comments.sort(key=lambda x: x["number"])

    result = defaultdict(list)
    for comment in comments:
        key = comment["data"]["page_id"]
        if key.startswith('/'):
            key = key[1:]
        result[key].append(comment)

    return result


def detect_language(text):
    from langdetect import DetectorFactory, detect
    # Stay consistent between builds
    DetectorFactory.seed = 0

    return detect(text)


def encrypt(text, secret):
    """Encrypt the text using the secret."""
    f = Fernet(secret)
    s = json.dumps(text)
    return f.encrypt(s.encode("utf8"))


def decrypt(text, secret):
    """Decrypt the text using the secret."""
    f = Fernet(secret)
    s = f.decrypt(text.decode("utf8"))
    return json.loads(s)


def netlify_transformer(secret):
    def transform(comment):
        return {
            "id": comment["id"],
            "created_at": comment["created_at"],
            "reply_to": comment["data"].get("reply-to"),
            "page_id": comment["data"]["page_id"],
            "name": comment["data"]["name"],
            "email": hashlib.md5(comment["data"]["email"].encode(
                "ascii")).hexdigest(),
            "bucket": encrypt(comment["data"]["email"], secret),
            "website": comment["data"]["website"],
            "message": comment["data"]["message"],
        }
    return transform

def alef_transformer(secret):
    def transform(comment):
        return {
            "id": comment['legacy_id'] or str(comment["id"]),
            "created_at": comment["time"],
            "reply_to": comment["reply_to"],
            "page_id": comment["page_id"],
            "name": comment["name"],
            "email": hashlib.md5(comment["email"].encode(
                "ascii")).hexdigest(),
            "bucket": encrypt(comment["email"], secret),
            "website": comment["website"],
            "message": comment["message"],
        }
    return transform

def update_comments_file(file, comments, page_id, transformer_fn):
    """Update comments in the YAML data files of each post."""

    existing = [c["created_at"] for c in yaml.safe_load(file) or []]

    # A naive protection against spam.
    incoming = list(
        filter(
            lambda x: x["created_at"] not in existing,
            map(transformer_fn, comments),
        )
    )

    if incoming:
        print('Dumping yml for: {}'.format(page_id))
        yaml.dump(
            incoming, file, default_flow_style=False, allow_unicode=True)
    else:
        print('Already updated: {}'.format(page_id))


def get_netlify_comments():
    # Download comments from Netlify.
    netlify_site_endpoint = \
        "https://api.netlify.com/api/v1/sites/{site_id}".format(
            site_id=os.environ["NETLIFY_SITE_ID"])

    form_submissions_endpoint = \
        "{netlify_site_endpoint}/forms/{form_id}/submissions".format(
            netlify_site_endpoint=netlify_site_endpoint,
            form_id=os.environ["NETLIFY_FORM_ID"])

    return get_netlify_form_submissions(
        form_submissions_endpoint,
        os.environ["NETLIFY_ACCESS_TOKEN"])


def netlify(secret):
    return get_netlify_comments(), netlify_transformer(secret)


def alef(dbpath, secret):
    return get_alef_comments(dbpath), alef_transformer(secret)


def get_alef_comments(dbpath):
    def dict_factory(cursor, row):
        d = {}
        for idx, col in enumerate(cursor.description):
            d[col[0]] = row[idx]
        return d
    with sqlite3.connect(dbpath) as con:
        con.row_factory = dict_factory
        cur = con.cursor()
        cur.execute('SELECT * from comments')
        res = defaultdict(list)
        for row in cur.fetchall():
            res[row['page_id']].append(row)
        cur.close()
        return res


def main():
    # Make sure the taget directory exists
    comments_dst = os.environ.get("COMMENT_DIR", "src/_data/comments")
    Path(comments_dst).mkdir(parents=True, exist_ok=True)

    # Get the fn to transform external format to the internal
    comments, transformer = alef(
        os.getenv('DBPATH', 'mehdix.db'), os.environ["SECRET"])

    # Add new comments to the target yaml files.
    for page_id, submissions in comments.items():
        if page_id.startswith('/'):
            page_id = page_id[1:]
        comments_yamlfile = os.path.join(
            comments_dst, "{}.yml".format(page_id))

        with open(comments_yamlfile, "a+", encoding="utf8") as file:
            file.seek(0)
            update_comments_file(
                file, submissions, page_id, transformer)


if __name__ == "__main__":
    main()
    print("Finished building comments.")
