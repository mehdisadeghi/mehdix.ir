---
title: دات‌فایل‌ها
tags: کانفیگ
category: tech
---
در این مقاله در مورد دات‌فایل‌ها حرف می‌زنیم و تجربه‌ام را از چهارسال نگهداری و استفاده مجدد از آنها شرح می‌دهم.


## کمی قصه
در ابتدا بیاید طبق معمول نگاهی به معانی و مفاهیم اولیه داشته باشیم. دات‌فایل‌ها، مانند بسیاری دیگر از مفاهیمی که در سیستم‌های لینوکسی و مانند آن امروزه رایج است (بی‌اس‌دی و مک‌او‌اس و WSL و غیره)، بیش از پنجاه سال پیش در هنگام خلق سیستم عامل یونیکس در آزمایشگاه‌های بل به وجود آمدند. با مقداری جستجو در اینترنت نقل قول آرشیوی زیر را از راب پاک،‌ خالق زبان برنامه‌نویسی گو و سیستم‌عامل پلن ۹ و یو‌تی‌اف ۹ و مانند آنها، پیدا کردم که برای آنکه دوباره بتوانم پیدایش کنم اینجا نقل قول می‌کنم:

<blockquote cite="https://web.archive.org/web/20141205101508/https://plus.google.com/+RobPikeTheHuman/posts/R58WgWwN9jp">
<pre dir="auto" style="text-wrap:auto">
Rob Pike
Shared publicly  -  Aug 3, 2012

A lesson in shortcuts.

Long ago, as the design of the Unix file system was being worked out, the entries . and .. appeared, to make navigation easier. I'm not sure but I believe .. went in during the Version 2 rewrite, when the file system became hierarchical (it had a very different structure early on).  When one typed ls, however, these files appeared, so either Ken or Dennis added a simple test to the program. It was in assembler then, but the code in question was equivalent to something like this:
   if (name[0] == '.') continue;
This statement was a little shorter than what it should have been, which is
   if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0) continue;
but hey, it was easy.

Two things resulted.

First, a bad precedent was set. A lot of other lazy programmers introduced bugs by making the same simplification. Actual files beginning with periods are often skipped when they should be counted.

Second, and much worse, the idea of a "hidden" or "dot" file was created. As a consequence, more lazy programmers started dropping files into everyone's home directory. I don't have all that much stuff installed on the machine I'm using to type this, but my home directory has about a hundred dot files and I don't even know what most of them are or whether they're still needed. Every file name evaluation that goes through my home directory is slowed down by this accumulated sludge.

I'm pretty sure the concept of a hidden file was an unintended consequence. It was certainly a mistake.

How many bugs and wasted CPU cycles and instances of human frustration (not to mention bad design) have resulted from that one small shortcut about  40 years ago?

Keep that in mind next time you want to cut a corner in your code.

(For those who object that dot files serve a purpose, I don't dispute that but counter that it's the files that serve the purpose, not the convention for their names. They could just as easily be in $HOME/cfg or $HOME/lib, which is what we did in Plan 9, which had no dot files. Lessons can be learned.)﻿
</pre>
</blockquote>

ترجمه:


<blockquote>

درسی راجع به میان‌برها.

خیلی وقت پیش، هنگامی که طرح فایل‌سیستم یونیکس در حال شکل‌گیری بود، مدخل‌های «.» و «..» ظاهر شدند تا جهت‌یابی را ساده کنند. مطمئن نیستم، اما باور دارم .. موقع بازنویسی یونیکس نسخه‌ی ۲ وارد شد، زمانی که فایل‌سیستم سلسله‌مراتبی شد (در روزهای نخستین ساختار متفاوتی داشت). هرچند وقتی کسی ls تایپ می‌کرد این مداخل ظاهر می‌شدند، بنابراین کن یا دنیس (کن تامپسون و دنیس ریچی - م.) یک تست ساده به برنامه اضافه کردند. آن زمان برنامه به اسمبلی بود اما کد مورد اشاره شبیه این بود:

    if (name[0] == '.') continue;

این دستور کمی کوتاه‌تر از چیزی بود که باید می‌بود، که این است:

    if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0) continue;

اما هی، آسون بود.

</blockquote>