---
layout: default
---
{% assign projects_by_date = site.data.projects | reverse %}

<h1 class="page-heading">❖ &nbsp; برنامه‌ها</h1>

<ul class="post-list-mini">
{% for project in projects_by_date %}
  <li class="post-list-item" id="project-main-list">
    <span class="list-meta-col">
      {{ project.date | jdate: "%d %b %Y" | habify }}
    </span>
    <ul class="post-list-mini">
      <li>
        <h3><a href="{{ project.repository.url }}">{{ project.name }}</a></h3>
      </li>
      <li>
        {{ project.description.short }}
      </li>
      <li>
        {{ project.description.long }}
      </li>
      <li>
        زبان برنامه‌نویسی: {{ project.language }}
      </li>
      {% if project.website %}
      <li>
        <a href="{{ project.website }}">Langing page</a>
      </li>
      {% endif %}
    </ul>
  </li>
{% endfor %}
</ul>


