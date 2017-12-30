'''Convert disquls XML comments to YAML.'''
import os
import copy
import pathlib
import hashlib
import yaml
import iso8601
import xmltodict
from postsinfo import mapping
from rebuild_comments import encrypt


COMMENT_DIR = os.environ.get('COMMENT_DIR', './_data/comments')


def get_disqus_threads(infile):
    with open(infile, 'r', encoding='utf-8') as file:
        disqus = xmltodict.parse(file.read())['disqus']

    threads = {}
    for trd in disqus['thread']:
        if not is_local_thread(trd):
            threads[trd['@dsq:id']] = trd
            threads[trd['@dsq:id']]['posts'] = []

    for pst in disqus['post']:
        key = pst['thread']['@dsq:id']
        if key in threads:
            threads[key]['posts'].append(pst)

    return threads


def is_local_thread(thread):
    return '0.0.0.0' in thread['link'] or '://localhost' in thread['link']


def write(thread, post_info):
    uid = post_info['page_id'][1:]
    comments = transform(thread, post_info)
    if comments:
        with open(os.path.join(COMMENT_DIR, f'{uid}.yml'), 'a+', encoding='utf8') as file:
            yaml.dump(comments,
                file,
                default_flow_style=False,
                allow_unicode=True)


def transform(thread, post_info):
    '''Convert disqus form data to a normal comment.'''
    comments = []
    for post in thread['posts']:
        comment = copy.copy(post_info)
        comment.update(
            {'date': iso8601.parse_date(post['createdAt']),
             'name': post['author']['name'],
             'email': hashlib.md5(post['author']['email'].encode('ascii')).hexdigest(),
             'bucket': encrypt(post['author']['email']),
             'website': make_profile_url(post),
             'message': post['message']})
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
        # Update comment files with converted disqus comments
        if trd['link'] in mapping:
            write(trd, mapping[trd['link']])


if __name__ == '__main__':
    main()