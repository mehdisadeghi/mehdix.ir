---
layout: default
---
{% assign projects_by_date = site.data.projects | sort: 'date' | reverse %}

<h1 class="page-heading">❖ &nbsp; برنامه‌ها</h1>

<ul class="post-list-mini projects">
{% for project in projects_by_date %}
  <li class="post-list-item" id="project-main-list">
    <span class="list-meta-col">
      {{ project.date | jdate: "%d %b %Y" | habify }}
    </span>
    <ul class="post-list-mini">
      {% assign prefix = '/projects/,' | split: "," %}
      {% assign middle = project.id | split: '/' %}
      {% assign arr = prefix | concat: middle %}
      {% assign pid = arr | join: '' %}
      {% assign proj = site.projects | where:"id", pid | first %}
      <li>
        <h3>
          {% if proj %}<a href="{{proj.id}}">{{ project.name }}</a> {% else %}
          {{ project.name }}
          {% endif %} &nbsp; <small><a href="{{ project.repository.url }}">سورس</a></small></h3>
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
