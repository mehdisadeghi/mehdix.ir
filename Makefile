all: build
.PHONY: init serve publish clean
init:
	bundle config set path vendor/bundle
	bundle install
build:
	bundle exec jekyll build
serve:
	bundle exec jekyll serve
publish: build
	rsync -vr _site/* mehdix.ir:/var/www/mehdix.ir/
clean:
	rm -rf _site
	rm -rf **/.jekyll-cache

