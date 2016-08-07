---
title: نصب نوم ۳ روی آرچ‌لینوکس
tags: archlinux آرچ امنیت yubikey gnome-shell گنوم نوم
uuid: 560a0848-785c-4184-8a44-d88d5faacf05
category: لینوکس
---
در مقاله قبلی نصب آرچ را شرح دادم. حالا می‌خواهم دسکتاپ مورد علاقه‌ام را روی آن نصب کنم یعنی gnome-shell.


اولین قدم ساخت یک کاربر جدید است:


~~~~
# useradd -m -s /bin/bash mehdi
# passwd mehdi
~~~~

برای اینکه این کاربر بتواند با sudo دستور اجرا کند باید آنرا به گروه sudo اضافه کنیم و با دستور visudo تنظیمات sudo را طوری تغییر بدهیم که کاربران عضو گروه sudo بتوانند دستورات روت را اجرا کنند. البته همه چیز با systemd عوض شده است و این روش قدیمی است. ولی من هنوز روش جدید را فرصت نکرده‌ام بخوانم.

~~~~
# visudo
# find line with # %sudo ALL=... and change it to:
%sudo ALL=(ALL) ALL
# useradd -aG sudo mehdi
~~~~

# نصب Display Server

قدم بعدی نصب یک Display Server است. من تصمیم گرفتم از سرور جدید Wayland و پیاده‌سازی آن بنام Weston استفاده کنم. Wayland رفته رفته جایگزین Xorg می‌شود. از جایی که Wayland نیاز به `Kernel Mode Setting (KVM)` دارد باید آنرا فعال کنیم:

~~~~
# vi /etc/mkinitcpio.conf
# go to line with MODULES=""
# change it to:
MODULES="i915"
~~~~

لپ‌تاپ من چیپ گرافیک مجزا ندارد و از پردازشگر گرافیکی اینتل استفاده می‌کند. برای فعال کردن KVM روی اینتل هم کافیست `i915` را به ماژول‌های کرنل اضافه کنم. ناگفته پیداست که باید ایمیج بوت دوباره ساخته بشود:

~~~~
# mkinitcpio -p kernel
~~~~

حالا بسته‌های لازم را نصب می‌کنیم:

~~~~
# pacman -S wayland weston xorg-server-wayland
~~~~

حالا Wayland را نصب کردیم که چیزی بیشتر از یک کتابخانه نیست. Wetson هم به تنهای به درد ما نمی‌خورد. xorg-sever-wayland هم برای اجرای برنامه‌های xorg از درون Wayland است. چیزی که الان نیاز داریم نصب یک دسکتاپ (نوم) و یک Display Manager برای داشتن یک صفحه لاگین اتوماتیک است.


# نصب Display Manager
اول بسته‌های لازم را نصب می‌کنیم:

~~~~
# pacman -S gnome gdm
~~~~

حالا باید سرویس `Gnome Display Manager (gdm)` را در systemd فعال کنیم تا با هربار ریبوت خودش اجرا بشود:

~~~~
# systemctl enable gdm.service
~~~~

اگر همه چیز مرتب پیش رفته باشد با یک ریبوت باید به صفحه لاگین گرافیکی هدایت بشویم. از تنظیمات لاگین Gnome on Wayland را انتخاب می‌کنم و لاگین می‌کنم.

باقی کارها را می‌توان به صورت گرافیکی از داخل محیط نوم انجام داد، مثل اضافه کردن چیدمان فارسی برای تایپ کردن و باقی کارها. من بسته‌های ضروری‌ام را همینجا نصب می‌کنم:

~~~~
# pacman -S gnome-extra gnome-boxes
~~~~
این بسته حاوی برنامه‌های رایج برای نوم است و البته ماشین مجازی نوم (باید قابلیت مجازی‌سازی در بایوس فعال باشد در غیر اینصورت خیلی کند خواهد بود). پک‌من سوالی می‌پرسد و من آنهایی را انتخاب می‌کنم که بدردم می‌خورد، بعد سایر برنامه‌های مهم:

~~~~
# pcaman -S openssh docker pass wget
# systemctl enable docker.service # Make docker service permanent
~~~~

# فعال‌سازی کلید سخت‌افزاری
بسیاری امروزه از کلیدهای سخت‌افزاری به عنوان ابزاری برای مکانیزم لاگین دو مرحله‌ای استفاده می‌کنند. مثلا برای لاگین در اکانت گیت‌هاب یا گوگل یا خیلی سرویس‌های دیگر. معروف‌ترین این کلید‌ها Yubikey است. من یک کلید ارزانتر بنام Happlink دارم. برای اینکه این کلیدها را لینوکس بشناسد باید یک قانون جدید به udev اضافه بشود. فایلی که اینجا به قوانین udev اضافه می‌کنیم حاوی شناسه تولیدکنندگان معروف این نوع کلیدهاست:


~~~~
# this udev file should be used with udev 188 and newer
ACTION!="add|change", GOTO="u2f_end"

# Yubico YubiKey
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess"

# Happlink (formerly Plug-Up) Security KEY
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="f1d0", TAG+="uaccess"

#  Neowave Keydo and Keydo AES
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1e0d", ATTRS{idProduct}=="f1d0|f1ae", TAG+="uaccess"

# HyperSecu HyperFIDO
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", ATTRS{idProduct}=="0880", TAG+="uaccess"

LABEL="u2f_end"
~~~~

مقادیر بالا را در فایلی بنام `70-u2f.rules` در مسیر `/etc/udev/rules.d/` ذخیره کرده و udev را ریلود می‌کنیم:

~~~~
# udevadm control --reload
~~~~

# فعالسازی افزونه‌های نوم با کرومیوم
برای اینکه بتوان از داخل براوزر افزونه‌های نوم را نصب کرد باید یک پلاگین روی فایرفاکس یا کروم نصب بشود. من اینجا نحوه نصب آنرا روی کروم توضیح می‌دهم. قسمت اول نصب پلاگین کروم است. کروم پلاگینی دارد بنام GNOME Shell Integration که می‌توان آنرا از از استور گوگل براحتی روی کرومیوم نصب کرد. این اکستنشن برای اینکه بتواند پلاگین‌های نوم را کنترل بکند نیاز به یک Connector دارد که باید جداگانه نصب بشود. برای این کار یک پکیج AUR وجود دارد. AUR مخفف Archlinux User Repository است. در AURها همواره یک فایل PKGBUILD وجود دارد که نصب را شرح می‌دهد و فایل‌های لازم حین نصب دانلود و بیلد می‌شوند:

~~~~
$ git clone https://aur.archlinux.org/chrome-gnome-shell-git.git
$ cd chrome-gnome-shell-git
$ makepkg -sri
~~~~

بعد از این مرحله کافیست به آدرس extensions.gnome.org برویم. حالا باید بتوان افزونه‌ها را فعال و غیرفعال کرد.

با دنبال کردن این دستورات یکه سیستم با دسکتاپ نوم ساختیم. ویکی آرچ بهترین منبع برای یادگیری و تنظیمات بیشتر سیستم است. در صورت علاقه ویکی را برای دستورات و تنظیمات بیشمار ممکن بخوانید.
