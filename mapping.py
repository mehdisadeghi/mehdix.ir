---
layout: none
published: false
---
mapping = {
    {% for post in site.posts %}
    'http://mehdix.ir{{ post.id }}.html': 
           {'page_id': '{{post.id}}',
            'page_uuid': '{{post.uuid}}',
            'page_date': '{{post.date}}',
            'page_title': '{{post.title}}',
            'date': '',
            'name': '',
            'email': '',
            'bucket': '',
            'website': '',
            'message': ''},
    {% endfor %}
}