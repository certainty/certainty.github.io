.PHONY: publish clean build update_code dev

build:
	bundle exec jekyll build

dev:
	bundle exec jekyll build --incremental --watch

clean:
	bundle exec jekyll clean

update_code:
	bundle update

