'''Convert disquls XML comments to YAML.'''
import os
import pathlib
import hashlib
import yaml
import iso8601
import xmltodict
from rebuild_comments import encrypt


COMMENT_DIR = os.environ.get('COMMENT_DIR', './_source/_data/comments')


def get_disqus_threads(infile):
    with open(infile, 'r', encoding='utf-8') as file:
        disqus = xmltodict.parse(file.read())['disqus']

    threads = {}
    for trd in disqus['thread']:
        threads[trd['@dsq:id']] = trd
        threads[trd['@dsq:id']]['posts'] = []

    for pst in disqus['post']:
        key = pst['thread']['@dsq:id']
        if key in threads:
            threads[key]['posts'].append(pst)

    return threads


def write(thread):
    uid = os.path.basename(thread['link']).replace('.html', '')
    comments = transform(thread)
    if comments:
        with open(os.path.join(COMMENT_DIR, f'{uid}.yml'), 'a+', encoding='utf8') as file:
            yaml.dump(comments,
                file,
                default_flow_style=False,
                allow_unicode=True)


def transform(thread):
    '''Convert disqus form data to a normal comment.'''
    comments = []
    for post in thread['posts']:
        comment = {
            'id': post['@dsq:id'],
            'created_at': iso8601.parse_date(post['createdAt']),
            'name': post['author']['name'],
            'email': hashlib.md5(post['author']['email'].encode('ascii')).hexdigest(),
            'bucket': encrypt(post['author']['email']),
            'website': make_profile_url(post),
            'message': post['message'],
            'disqus': True}
        comments.append(comment)
    return comments


def make_profile_url(post):
    return 'https://disqus.com/by/{}/'.format(post['author']['username']) if post['author']['isAnonymous'] == 'false' else ''


def main():
    # Load disqus
    disqus_threads = get_disqus_threads(infile='db.xml')

    # Make sure the comment directory exists
    pathlib.Path(COMMENT_DIR).mkdir(parents=True, exist_ok=True)

    # Convert disqus to current comment format. Use posts mapping.
    for trd in disqus_threads.values():
        # Filter out invalid records
        if trd['link'].startswith('http://mehdix.ir') and 'mehdix.org' not in trd['link']:
            write(trd)


if __name__ == '__main__':
    main()
    print('Done.')