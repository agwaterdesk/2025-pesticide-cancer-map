PHONY: github agwaterdesk

github:
	npm run build
	rm -rf docs
	cp -r dist docs
	touch docs/.nojekyll
	