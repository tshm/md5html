.PHONY: page publish

dist/bundle.js: src/*
	npm install
	npm run dist

publish: dist/bundle.js
	cd dist; make -f ../Makefile page

page:
	git init
	git config user.name "Travis IC"
	git config user.email "2sm@csc.jp"
	git add .
	git commit -m "Deploy to GitHub pages"
	git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1

