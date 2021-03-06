current_dir:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY=build
build:
	docker run --rm -v $(current_dir):/src peaceiris/hugo:latest-mod --gc --minify --cleanDestinationDir

.PHONY=deploy
deploy:
	rsync -azP --delete public/* bardelli@sftp.itd.umich.edu:~/Public/html

.PHONY=theme
theme:
	docker run --rm -v $(current_dir):/src peaceiris/hugo:latest-mod mod clean
	docker run --rm -v $(current_dir):/src peaceiris/hugo:latest-mod mod get -u
	docker run --rm -v $(current_dir):/src peaceiris/hugo:latest-mod mod tidy

.PHONY=server
serve:
	docker run --rm -p 1313:1313 -v $(current_dir):/src peaceiris/hugo:latest-mod serve --bind "0.0.0.0"

.PHONY=publications
publications:
	rm -rf content/publication/*; \
	docker run --rm -v $(current_dir):/hugo ebardelli/hugo-academic:latest import --bibtex publications.bib --overwrite --publication-dir=publication --normalize; \
	tmpfile=$(mktemp /tmp/publications.XXXXXX); \
	sed 's/  keywords = {My Work\/Papers}.*$$//' working-papers.bib | sed 's/  file =.*$$//' | sed 's/techreport/unpublished/' > "$tmpfile";\
	docker run --rm -v $(current_dir):/hugo ebardelli/hugo-academic:latest import --bibtex "$tmpfile" --overwrite --publication-dir=publication --normalize; \
	rm "$tmpfile"
