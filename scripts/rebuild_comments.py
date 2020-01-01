"""Netlify comments processing script."""
import os
import json
import hashlib
from collections import OrderedDict

import yaml
import requests
from pathlib2 import Path
from cryptography.fernet import Fernet
from langdetect import DetectorFactory, detect


# Stay consistent between builds
DetectorFactory.seed = 0

SECRET = os.environ["SECRET"]
COMMENT_DIR = os.environ.get("COMMENT_DIR", "src/_data/comments")

ACCESS_TOKEN = os.environ["NETLIFY_ACCESS_TOKEN"]
FORM_ID = os.environ["NETLIFY_FORM_ID"]
SITE_ID = os.environ["NETLIFY_SITE_ID"]

BASE = "https://api.netlify.com/api/v1"
SITE = "{base}/sites/{site_id}".format(base=BASE, site_id=SITE_ID)
SUBMISSIONS_ENDPOINT = "{site}/forms/{form_id}/submissions?access_token={access_token}".format(
    site=SITE, form_id=FORM_ID, access_token=ACCESS_TOKEN
)


def get_comments():
    """Get a map of post_uuid => list of comment dicts."""
    raw_comments = requests.get(
        "{site}/forms/{form_id}/submissions".format(site=SITE, form_id=FORM_ID),
        params={"access_token": ACCESS_TOKEN},
    )
    comments = json.loads(raw_comments.content.decode("utf-8"))
    comments.sort(key=lambda x: x["number"])
    result = OrderedDict()
    for comment in comments:
        comment["language"] = detect(comment["data"]["message"])
        key = comment["data"]["page_id"]
        if key not in result:
            result[key] = []
        result[key].append(comment)

    return result


def transform_comment(comment):
    """Convert Netlify form data to a normal comment."""
    return {
        "id": comment["id"],
        "created_at": comment["created_at"],
        "reply_to": comment["data"].get("reply-to"),
        "page_id": comment["data"]["page_id"],
        "name": comment["data"]["name"],
        "email": hashlib.md5(comment["data"]["email"].encode("ascii")).hexdigest(),
        "bucket": encrypt(comment["data"]["email"]),
        "website": comment["data"]["website"],
        "message": comment["data"]["message"],
        "spam": comment.get("spam"),
        "language": comment.get("language"),
    }


def encrypt(data):
    """Encrypt the data using SECRET key."""
    f = Fernet(SECRET)
    s = json.dumps(data)
    return f.encrypt(s.encode("utf8"))


def decrypt(text):
    """Decrypt the text using SECRET."""
    f = Fernet(SECRET)
    s = f.decrypt(text.decode("utf8"))
    return json.loads(s)


def update_comments(file, comments):
    """Update comments in the YAML data files of each post."""
    file.seek(0)
    old_comments = yaml.safe_load(file) or []

    # Use comment date as ID
    old_comment_ids = [cmnt["created_at"] for cmnt in old_comments]
    # Avoid duplicates and avoid non-Persian comments. A naive protection against spam.
    new_comments = list(
        filter(
            lambda x: x["created_at"] not in old_comment_ids
            ,#and x["language"] in ("fa", "ar"),
            map(transform_comment, comments),
        )
    )

    if new_comments:
        yaml.dump(new_comments, file, default_flow_style=False, allow_unicode=True)


def main():
    """Update comments."""
    netlify_comments = get_comments()
    Path(COMMENT_DIR).mkdir(parents=True, exist_ok=True)
    for page_uuid, page_comments in netlify_comments.items():
        if page_comments:
            uid = os.path.basename(page_comments[0]["data"]["page_id"])
            path = os.path.join(COMMENT_DIR, "{uid}.yml".format(uid=uid))
            with open(path, "a+", encoding="utf8") as file:
                update_comments(file, page_comments)


if __name__ == "__main__":
    main()
    print("Done.")
