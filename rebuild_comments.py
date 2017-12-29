'''Netlify comments processing script.'''
import os
import json
import pathlib
import hashlib
from collections import OrderedDict

import yaml
import requests
from cryptography.fernet import Fernet


SECRET = os.environ['SECRET']
COMMENT_DIR = os.environ.get('COMMENT_DIR', './_data/comments')

ACCESS_TOKEN = os.environ.get('NETLIFY_ACCESS_TOKEN')
FORM_ID = os.environ.get('NETLIFY_FORM_ID')
SITE_ID = os.environ.get('NETLIFY_SITE_ID')

BASE = 'https://api.netlify.com/api/v1'
SITE = f'{BASE}/sites/{SITE_ID}'
SUBMISSIONS_ENDPOINT = f'{SITE}/forms/{FORM_ID}/submissions?access_token={ACCESS_TOKEN}'


def get_comments():
    '''Get a map of post_uuid => list of comment dicts.'''
    raw_comments = requests.get(f'{SITE}/forms/{FORM_ID}/submissions',
                                params={'access_token': ACCESS_TOKEN})
    comments = json.loads(raw_comments.content.decode('utf-8'))
    comments.sort(key=lambda x: x['number'])
    result = OrderedDict()
    for comment in comments:
        key = comment['data']['page_uuid']
        if key not in result:
            result[key] = []
        result[key].append(comment)
    return result


def transform_comment(netlify_comment):
    '''Convert Netlify form data to a normal comment.'''
    data = netlify_comment['data']
    return {'page_id': data['page_id'],
            'page_uuid': data['page_uuid'],
            'page_date': data['page_date'],
            'page_title': data['page_title'],
            'date': netlify_comment['created_at'],
            'name': data['name'],
            'email': hashlib.md5(data['email'].encode('ascii')).hexdigest(),
            'bucket': encrypt(data['email']),
            'website': data['website'],
            'message': data['message']}


def encrypt(data):
	'''Encrypt the data using SECRET key.'''
	f = Fernet(SECRET)
	s = json.dumps(data)
	return f.encrypt(s.encode('utf8'))


def decrypt(text):
	'''Decrypt the text using SECRET.'''
	f = Fernet(SECRET)
	s = f.decrypt(f)
	return json.loads(s.decode('utf8'))


def update_comments(file, comments):
    '''Update comments in the YAML data files of each post.'''
    file.seek(0)
    old_comments = yaml.load(file) or []
    # Use comment date as ID
    old_comment_ids = [cmnt['date'] for cmnt in old_comments]
    new_comments = list(filter(lambda x: x['date'] not in old_comment_ids,
        map(transform_comment, comments)))
    if new_comments:
        yaml.dump(new_comments,
            file,
            default_flow_style=False,
            allow_unicode=True)


def main():
    '''Update comments.'''
    netlify_comments = get_comments()
    pathlib.Path(COMMENT_DIR).mkdir(parents=True, exist_ok=True)
    for page_uuid, page_comments in netlify_comments.items():
        with open(os.path.join(COMMENT_DIR, f'{page_uuid}.yml'), 'a+', encoding='utf8') as file:
            update_comments(file, page_comments)


if __name__ == '__main__':
    main()
