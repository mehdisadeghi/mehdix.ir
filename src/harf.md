---
layout: page
title: حرف
permalink: /harf/
published: true
---

اگر راه گم کردی و به این صفحه منتشر نشده رسیدی نمی‌دونم واقعا باید بهت چی بگم! به هر حال می‌تونی از فرم زیر برای ارسال پیام به من استفاده کنی. البته اگر پای مرگ و زندگی در میونه بهت پیشنهاد می‌کنم منتظر جواب من نباشی چون احتمالا وقتی ببینمش دخلت اومده!

<style>
#harf {
  display: grid;
  grid-template-columns: 0fr 1fr;
  grid-template-rows: 1fr 1fr 3fr;
  grid-gap: 1rem;
}
</style>

<form id="harf">
		<input name="bot-field" style="display:none">
    <label for="name">اسمت </label>
    <input id="name" type="text" name="name">
    <label for="email">ایمیلت </label>
    <input id="email" type="email" name="email">
    <label for="message">حرفت </label>
    <textarea id="message" name="message"></textarea>
    <button type="submit" style="grid-column: 2">برو به سلامت</button>
</form>