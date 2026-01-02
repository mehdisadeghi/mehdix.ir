REMOTE ?= mehdix.ir:/var/lib/alef/mehdix.db
DBPATH ?= mehdix.db
POSTS_DIR = src/_posts
DRAFTS_DIR = src/_drafts
TEMPLATE = src/_templates/post.yaml

.PHONY: all init build serve publish clean fmt lint test post draft promote comments comments-sync

all: dev

init:
	bundle config set path vendor/bundle
	bundle install

build:
	bundle exec jekyll build

serve:
	bundle exec jekyll serve

dev:
	bundle exec jekyll serve -D

publish: build
	rsync -vr _site/* mehdix.ir:/var/www/mehdix.ir/

clean:
	rm -rf _site
	rm -rf **/.jekyll-cache
	rm -rf vendor .bundle

fmt:
	bundle exec standardrb --fix
	npx prettier --write 'src/**/*.scss'

lint:
	bundle exec standardrb

comments-sync:
	cp $(DBPATH) $(DBPATH).$$(date -I) 2>/dev/null || true
	scp $(REMOTE) $(DBPATH)

comments:
	SECRET=$${SECRET:-$$(pass infra/mehdix.ir/secret | head -n1)} DBPATH=$(DBPATH) bundle exec rake comments

post:
	@read -p "Post title: " title && \
	filename="$$(date +%Y-%m-%d)-$$(echo "$$title" | tr '[:upper:] ' '[:lower:]-').md" && \
	uuid=$$(uuidgen | tr '[:upper:]' '[:lower:]') && \
	sed "s/^title: $$/title: $$title/; s/^uuid: $$/uuid: $$uuid/" $(TEMPLATE) > $(POSTS_DIR)/$$filename && \
	echo "Created $(POSTS_DIR)/$$filename" && \
	$${EDITOR:-vim} $(POSTS_DIR)/$$filename

draft:
	@read -p "Draft title: " title && \
	filename="$$(echo "$$title" | tr '[:upper:] ' '[:lower:]-').md" && \
	uuid=$$(uuidgen | tr '[:upper:]' '[:lower:]') && \
	sed "s/^title: $$/title: $$title/; s/^uuid: $$/uuid: $$uuid/" $(TEMPLATE) > $(DRAFTS_DIR)/$$filename && \
	echo "Created $(DRAFTS_DIR)/$$filename" && \
	$${EDITOR:-vim} $(DRAFTS_DIR)/$$filename

promote:
	@if which fzf >/dev/null; then \
		draft=$$(ls -1 $(DRAFTS_DIR)/*.md 2>/dev/null | xargs -n1 basename | fzf --prompt="Select draft: "); \
	else \
		echo "Available drafts:"; \
		select draft in $$(ls -1 $(DRAFTS_DIR)/*.md 2>/dev/null | xargs -n1 basename); do break; done; \
	fi && \
	[ -n "$$draft" ] && \
	newname="$$(date +%Y-%m-%d)-$$draft" && \
	mv $(DRAFTS_DIR)/$$draft $(POSTS_DIR)/$$newname && \
	echo "Promoted to $(POSTS_DIR)/$$newname"
