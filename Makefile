all: build
.PHONY: conf serve publish
conf:
	bundle config set path vendor/bundle
vendor:
	bundle install
build:
	bundle exec jekyll build
serve:
	bundle exec jekyll serve
publish: build
	rsync -r _site/* mehdix.org:/var/www/mehdix.ir/

