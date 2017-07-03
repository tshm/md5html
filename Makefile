.PHONY: elm.js page dist publish

bundle.js: Main.elm src/main.js
	npm install
	npm run build
	npm run bundle

dist: index.html bundle.js
	npm run workbox
	rm -rf out
	mkdir out
	cp -r manifest.json *.ico *.png workbox*.js sw.js index.html bundle.js bower.json src ./out

publish: dist
	cd out; make -f ../Makefile page

page:
	git init
	git config user.name "Travis IC"
	git config user.email "2sm@csc.jp"
	git add .
	git commit -m "Deploy to GitHub pages"
	git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1

