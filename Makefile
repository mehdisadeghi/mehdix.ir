DBPATH=mehdix.db
all: build
.PHONY: init serve publish clean


init: init_db
	bundle config set path vendor/bundle
	bundle install
	uv sync

build:
	bundle exec jekyll build

comments:
	@echo rebuilding alef comments
	cp mehdix.db $$(date -I)-mehdix.db 2>/dev/null || true
	rsync -v mehdix.ir:/var/lib/alef/mehdix.db mehdix.db
	uv run ./scripts/rebuild_comments.py

serve: build
	bundle exec jekyll serve

publish: build
	rsync -vr _site/* mehdix.ir:/var/www/mehdix.ir/

clean:
	rm -rf _site
	rm -rf **/.jekyll-cache
	rm -rf **/.yml

init_db: schema.sql
	sqlite3 ${DBPATH} < schema.sql
