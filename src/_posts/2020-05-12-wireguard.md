---
title: وایرگارد
uuid: e3404380-6ef2-4b01-9879-0555d3149523
category: آموزش
tags: شبکه کرنل امنیت لینوکس
---
وایرگارد ابزاری است برای ایجاد آسان یک اتصال رمزشده میان چند کامپیوتر متصل به شبکه اما دور از هم. وایرگارد از نسخه ۵.۶ لینوکس وارد بدنه اصلی کرنل شده است.

[وایرگارد] چند سالی است که توسط [Jason A. Donenfeld] توسعه پیدا کرده است و در نهایت وارد بدنه کرنل لینوکس شده است به این معنی که برای نصب وایرگارد دیگر نیازی به نصب هیچ ماژولی در کرنل نیست. فقط کافیست ابزارهای _userspace tools_ شامل `wg` و در صورت نیاز به کمک بیشتر `wg-quick` را جهت تنظیم اتصالات نصب کرد.

وایرگارد از تمام تکنولوژی‌های مشابه ساده‌تر و سریع‌تر و جمع و جورتر است. اصل آن حدود ۳۰۰۰ خط کد است. کوچکترین در نوع خود که بررسی توسط متخصصین امنیت را بسیار ساده می‌کند (در مقایسه با صدها هزار خط کد در سایر برنامه‌های اینچنینی). به کمک آن می‌توان به سرعت چند کامپیوتر را چه در اینترنت چه در یک شبکه‌های جدا از اینترنت به یکدیگر متصل کرد. فایل تنظیمات آن متنی است و کلیدهای عمومی و خصوصی لازم را با ابزار `wg` می‌توان به سرعت ساخت. پروتکل آن هم به طور مفصل در [وایت‌پیپر] آن شرح داده شده است.

# راه‌اندازی
در مثال زیر روی یک سرور Ubuntu 20.04 LTS وایرگارد را راه می‌اندازیم (وایرگارد را بک‌پورت کرده‌اند به کرنلشان). کلاینت برای ویندوز و اندروید و مانند اینها را می‌توانید از [سایت خودشان] بگیرید. روش کار اینست که ما برای هر کامپیوتر یک جفت کلید می‌سازیم. یک جفت برای سرور و یک جفت برای هر کلاینت. در ادامه کلید عمومی سرور را به کلاینت‌ها و کلید عمومی کلاینت‌ها را به سرور اضافه می‌کنیم. اول نصب ابزارهای لازم.

```
# apt install wireguard resolvconf
```
بعد فایل `/etc/wireguard/wg0.conf` را می‌سازیم و تنظیمات را وارد می‌کنیم (اسم فایل مهم است).

```
[Interface]
PrivateKey = <server_privatekey>
Address = 10.0.0.1/24,fd9e:cc01:4001::1/48
ListenPort = <portnumber e.g. 51820>

[Peer]
# Peer No. 1
PublicKey = <peer1_publickey>
PresharedKey = <peer1_preshared_key>
AllowedIPs = 10.0.0.2/32,fd9e:cc01:4001::2/64

[Peer]
# Peer No. 2
PublicKey = <peer2_publickey>
PresharedKey = <peer2_preshared_key>
AllowedIPs = 10.0.0.3/32,fd9e:cc01:4001::3/64
```
انتخاب رنج IPv4 ساده است. برای انتخاب رنج IPv6 در اینترنت `IPv6 address range generator` یا مشابه آن را جستجو کنید یا مقادیر این مثال را بجز دو حرف اول تغییر بدهید. فعلا راه سریع‌تری سراغ ندارم. فایل تنظیمات وایرگارد همیشه یک `Interface` دارد و تعدادی `Peer`. اولی تنظیمات کارت شبکه مجازی است که روی این کامپیوتر ساخته می‌شود. دومی هم کلید و آی‌پی مجاز کلایت‌هاست. می‌بینید که خبری از DHCP و این قبیل چیزها نیست. باید آی‌پی را خودمان تعیین کنیم. در مثال بالا جای کلیدها خالی است. آنها را باید اینطور ساخت:

```
# Generate a key pair for the server
# wg genkey | tee server_privatekey | wg pubkey > server_publickey

# Peer 1
# wg genkey | tee peer1_privatekey | wg pubkey > peer1_publickey
# Generate a pre-shared key
# wg genpsk > peer1_preshared_key

# Peer 2
# wg genkey | tee peer2_privatekey | wg pubkey > peer2_publickey
# Generate a pre-shared key
# wg genpsk > peer2_preshared_key
```
مقداری که `wg genpsk` می‌سازد باید به ازای هر Peer هم در کلاینت و در سرور در تنظیمات `Peer` وارد بشود و یکی باشد. خروجی `wg genkey` کلید خصوصی است (اگر به تنهایی اجرایش کنید) که می‌رود در بخش Interface. از کلید خصوصی کلید عمومی را ساختیم (که ما در یک خط با هم انجام دادیم) که می‌رود در تنظیمات کلاینت‌هایی که می‌خواهند به این سرور وصل بشوند (مقادیر را باید از فایل‌هایی که تولید کردیم برداریم و در فایل `wg0.conf` وارد کنیم).

حالا می‌توانیم سرور وایرگارد را راه بیندازیم:

```
# wg-quick up wg0
# systemctl enable wg-quick@wg0.service <- to enable after each boot
```
با دستور `ip link` یا `ip addr` می‌توانید اینترفیس جدیدی که به نام `wg0` ساخته شده و مشخصات آن را ببینید. کار سرور اینجا تمام است. برای هر کلاینت هم مشابه همین فایل را می‌سازیم. اینجا فقط اولی را نشان می‌دهم:

```
[Interface]
PrivateKey = <peer1_privatekey>
Address = 10.10.0.2/24 ,fd9e:cc01:4001::2/48

[Peer]
PublicKey = <server_publickey>
PresharedKey = <peer1_preshared_key>
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = <server_ip>:<server_port>
```

این فایل را در کلاینت اندروی یا ویندوز وارد بکنید و اتصال را استارت بزنید یک شبکه مجازی بین آن دستگاه و سرور ساخته می‌شود که مثل فولاد محکم و نفوذناپذیر است. اینکار برای اتصال اجزاء مختلف یک برنامه یا کامپیوترهای شخصی یا اداری بسیار سودمند است. یک بیزینس کوچک هم می‌تواند بخش‌های مختلف و ساختمانهای مختلف را به این صورت به هم وصل کند.

اگر بخواهید کلاینت‌ها پس از اتصال بتوانند به اینترنت سرور وصل بشوند باید روی سرور IP Routing داشته باشیم. یعنی سرور را به روتر تبدیل کنیم تا بسته‌ها بین شبکه‌های مختلف بتوانند حرکت بکنند. با افزودن `net.ipv4.ip_forward=1` به فایل `/etc/sysctl.conf` آنرا فعال می‌کنیم:

```
# vim /etc/sysctl.conf
# net.ipv4.ip_forward=1 <- uncomment this line
# sysctl -p # activate it
```
و جدول `iptables` را تغییر بدهید تا لینوکس بداند ترافیک مجاز است بین اینترفیس مجازی وایرگارد و کارت شبکه‌ای هدف (اینجا eth0) حرکت بکند:

```
iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

این دو خط را می‌شود به فایل تنظیمات وایرگارد هم اضافه کرد تا به شکل اتوماتیک با حذف و اضافه اینترفیس اینها هم اضافه و کم بشوند (فقط روی سرور):

```
[Interface]
...
...
DNS = 1.1.1.1 <- optional: set peers' dns
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
...
...
```

برای اطلاعات بیشتر [ویدیوی معرفی] سال ۲۰۱۸ را ببینید یا این [ویدیوی راه‌اندازی سریع] را.

<video controls="" width="100%">
<source src="https://www.wireguard.com/talks/talk-demo-screencast.mp4">
<caption>Source: www.wireguard.com</caption>
</video>
ویدیو از سایت وایرگارد است.

[وایرگارد]: https://www.wireguard.com/
[Jason A. Donenfeld]: https://www.zx2c4.com/
[وایت‌پیپر]: https://www.wireguard.com/papers/wireguard.pdf
[سایت خودشان]: https://www.wireguard.com/install/
[ویدیوی معرفی]: https://www.youtube.com/watch?v=CejbCQ5wS7Q&feature=youtu.be
[ویدیوی راه‌اندازی سریع]: https://www.wireguard.com/talks/talk-demo-screencast.mp4
