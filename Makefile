DBPATH=mehdix.db
all: build
.PHONY: init serve publish clean

init: init_db
	bundle config set path vendor/bundle
	bundle install

build: comments
	bundle exec jekyll build

comments:
	@echo rebuilding alef comments
	rsync -v mehdix.ir:/var/lib/alef/mehdix.db mehdix.db
	python scripts/rebuild_comments.py

serve:
	bundle exec jekyll serve

publish: build
	rsync -vr _site/* mehdix.ir:/var/www/mehdix.ir/

clean:
	rm -rf _site
	rm -rf **/.jekyll-cache

init_db: scripts/schema.sql
	sqlite3 ${DBPATH} < scripts/schema.sql

