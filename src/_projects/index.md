---
layout: default
---
{% assign projects_by_date = site.data.projects | sort: 'date' | reverse %}

<div class="card">
  <h1>❖ &nbsp; برنامه‌ها</h1>
  <ul class="list-meta">
  {% for project in projects_by_date %}
  {% assign prefix = '/projects/,' | split: "," %}
  {% assign middle = project.id | split: '/' %}
  {% assign arr = prefix | concat: middle %}
  {% assign pid = arr | join: '' %}
  {% assign proj = site.projects | where:"id", pid | first %}
    <li class="post-list-item">
      <span class="list-meta-col">
        {{ project.date | jdate: "%d %b %Y" | habify }}
      </span>
      <span>
        <a href="{{ proj.id }}.html">{{ project.name }}</a>
      </span>
    </li>
  {% endfor %}
  </ul>
</div>