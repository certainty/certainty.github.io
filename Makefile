.PHONY: publish clean build update_code dev

build:
	bundle exec jekyll build

dev:
	bundle exec jekyll build --drafts --incremental --watch

clean:
	bundle exec jekyll clean

local:
	bundle exec jekyll serve --drafts --incremental --watch

update_code:
	bundle update

publish:
	git checkout live 
	git merge --no-commit --ff-only master
	git push origin live
	git checkout master



