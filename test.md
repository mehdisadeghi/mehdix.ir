---
layout: page
title: تست
permalink: /test/
published: true
uuid: 9a4972ef-a1d5-409e-8f91-6a0616c4223a
---

 <section id="static-comments">

    {% assign comments = site.data.comments[page.uuid] %}
    {% if comments %}
    <div id="comments">
      <h4>نظرات سایر خوانندگان</h4> {% for comment in comments %}
      <article>
        <div class="comment-image-wrapper"><img class="comment-avatar" src="https://www.gravatar.com/avatar/{{comment.email}}?s=200&d=robohash" /></div>
        <div class="comment-body-wrapper">
          <h5 style="display: inline"><a href={{comment.url}}>{{ comment.name }}</a></h5>
          <p class="post-meta" style="display: inline"> •&nbsp {{ comment.date }}</p>
          <p>{{ comment.text }}</p>
        </div>
      </article>
      {% endfor%}
    </div>
    {% endif %}

    <form id="comment-form" name="comment" netlify>
      <input id="bot-field" name="bot-field" style="display:none">
      <input id="page_id" name="page_id" style="display:none" value="{{page.id}}">
      <input id="page_uuid" name="page_uuid" style="display:none" value="{{page.uuid}}">
      <input id="page_date" name="page_date" style="display:none" value="{{page.date}}">
      <input id="page_title" name="page_title" style="display:none" value="{{page.title}}">
      <label for="message">دیدگاه
        <textarea id="message" name="message" required alt="no!!"></textarea>
      </label>
      <label for="name">نام
        <input id="name" type="text" name="name" required>
      </label>
      <label for="email">ایمیل
        <input id="email" type="email" name="email" required>
      </label>
      <label for="website">وبسایت
        <input id="website" type="url" name="website">
      </label>
      <div style="text-align:left">
        <button type="submit">برو به سلامت</button>
      </div>
    </form>

  </section>