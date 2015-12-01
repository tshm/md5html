.PHONY: build page

elm.js: main.elm
	npm run build

publish: index.html elm.js
	rm -rf out
	mkdir out
	pushd out; make -f ../Makefile page

page:
	cp -r ../index.html ../elm.js ../bower.json ../src ./
	npm run bower
	git init
	git config user.name "Travis IC"
	git config user.email "2sm@csc.jp"
	git add .
	git commit -m "Deploy to GitHub pages"
	git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1

