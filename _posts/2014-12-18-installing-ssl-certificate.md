---
date: 18 Dec 2014
title: طریقه نصب گواهینامه SSL روی سرور شخصی
tags: ssl امنیت
category: امنیت
style: "article p img {width: 200px;}"
uuid: e367a6cc-329f-4a68-a995-d7aa579db246
---
امنیت رو باید جدی گرفت. هرچند من متخصص امنیت نیستم ولی برای درک اهمیت استفاده از پروتکل‌های امن نیازی به متخصص بودن نیست. اینکه اسم کاربری و کلمه عبور و سایر داده‌های حساس باید به شکل رمزگذاری شده ارسال بشوند دیگر چیزی بدیهی به نظر می‌رسد.


بنابراین من تصمیم گرفتم به قول معروف برای «فال و تماشا» یک گواهینامه SSL برای دامنه [mehdix.org](mehdix.org) تهیه و فعال کنم. دستورات این راهنما رو من از سایت ‎[آرال بالکان](https://aralbalkan.com/scribbles/setting-up-ssl-with-nginx-using-a-namecheap-essentialssl-wildcard-certificate-on-digitalocean/) برداشتم.

#بسته آموزشی گیت‌هاب
من در این راهنما از یک سرور شخصی روی [DigitalOcean](https://digitalocean.com) و همچنین یک گواهینامه SSL از namecheap.com استفاده کردم. من برای تهیه اینها پولی پرداخت نکردم، بلکه اینها رو از طریق [بسته آموزشی گیت‌هاب](https://education.github.com) بدست آوردم. برای اینکار فقط کافیه یک ایمیل دانشگاهی داشته باشید و در پروژه‌ی بالا ثبت نام کنید و به سرویس‌های مختلفی برای تقریبا یک سال به رایگان دسترسی پیدا کنید.

{: .center}
![image](https://education.github.com/assets/sdp-backpack-6f872c4211af1bac3aef0c6e2b5fbb7a.png "Github Developer Pack")

#خرید گواهینامه
من ابتدا یک گواهینامه *Positive SSL* از سایت *namecheap.com* برای دامنه‌ام خریداری کردم. بدون خرید گواهینامه هم می‌شه روی سرور شخصی اتصال *https* داشت اما توسط مرورگر تایید نمی‌شه و پیام هشدار دریافت می‌کنید. در حالی که گواهینامه بالا بعد از نصب به رنگ سبز در نوار آدرس کروم نمایش داده می‌شه. گواهینامه‌ای که من خریدم فقط برای یک دامنه تنها اعتبار داره و شامل زیردامنه‌ها نخواهد بود. برای اینکار باید از یک گواهینامه گرانتر بنام *Wildcard SSL Certificate* استفاده کرد.

#تولید کلیدهای اولیه
اول به ماشین مورد نظر *ssh* می‌کنیم و دستور زیر رو جهت تولید یک کلید خصوصی وارد می‌کنیم:

{% highlight bash %}
openssl genrsa 2048 > key.pem
{% endhighlight %}

فراموش نکنید که کلیدها رو به ماشین خودتون *scp* کنید. حالا یک **درخواست گواهینامه** تولید می‌کنیم:
{% highlight bash %}
openssl req -new -key key.pem -out csr.pem
{% endhighlight %}

به سوالات پرسیده شده جواب بدین و برای گزینه *Common Name* اسم دامنه خودتون را با پسوندش وارد کنید (بدون پیشوند). لزومی به وارد *Challenge Password* نیست.

در هنگام خرید گواهینامه در سایت صادرکننده از ما درخواست *csr* خواهد شد که مخفف کلمه **Certificate Signing Request** است. در آنجا جهت فعالسازی گواهینامه و انجام کامل عملیات صدور باید محتویات فایل *csr.pem* را کپی کنیم. بعد از این مرحله و تکمیل مراحل صدور یک فایل زیپ شده حاوی فایل‌های زیر برای ما ایمیل خواهد شد:

* yourdomain_extension.crt
* COMODORSADomainValidationSecureServerCA.crt
* COMODORSAAddTrustCA.crt
* AddTrustExternalCARoot.crt

حال باید از روی اینها ما یک *Certificate Bundle* بسازیم:
{% highlight bash %}
cat STAR_yourdomain_ext.crt COMODORSADomainValidationSecureServerCA.crt COMODORSAAddTrustCA.crt AddTrustExternalCARoot.crt > bundle.cer
{% endhighlight %}

#کپی فایل‌های گواهینامه
من روی سرورم اوبونتو ۱۴.۰۴ نصب کردم و برای نصب nginx تنها کافی بود که دستور زیر رو وارد کنم:
{% highlight bash %}
sudo apt-get install ngingx
{% endhighlight %}

برای کپی کردن فایل‌ها مراحل زیر رو انجام می‌دیم:

1. `sudo mkdir /etc/nginx/ssl`
2. `sudo mv PATH_TO_BUNDLE_FILE /etc/nginx/ssl/`
3. `sudo mv PATH_TO_KEY.PEM_FILE /etc/nginx/ssl/`
4. `sudo chmod 600 /etc/nginx/ssl`

دستور آخر دسترسی به پوشه فوق رو محدود به مالک می‌کنه. چون من با کاربری غیر از روت به دستگاه وصل شدم و با کاربر روت این پوشه رو ساختم دیگر تنها روته که می‌تونه رو این پوشه بخونه و بنویسه.

#تنظیم nginx
حالا *nginx* رو تنظیم می‌کنیم که همه ترافیک *http*‌ رو بفرسته روی *https*:
{% highlight bash %}
sudo vim /etc/nginx/sites-available/default
{% endhighlight %}

{% highlight bash %}
server {
        listen 80 default_server;

        server_name mehdix.org;

        return   301 https://$server_name$request_uri;
}
{% endhighlight %}

روی پورت ۸۰ گوش کن و هرچه درخواست برای *mehdix.org* بدستت رسید بفرست با کد ۳۰۱ روی همین سرور ولی با *https*. حالا وقت تنظیمات خود *https* رسیده:
{% highlight bash %}
server {
        listen 443;

        server_name mehdix.org;

        root /usr/share/nginx/html;
        index index.html index.htm;

        ssl on;
        ssl_certificate /etc/nginx/ssl/bundle.cer;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
}
{% endhighlight %}

و یک ریستات و والسلام:
{% highlight bash %}
sudo service nginx restart
{% endhighlight %}

و این هم رنگ خوش سبز *https* در کروم:

![image](assets/pimg/https.png)
