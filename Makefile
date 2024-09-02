all: build index.html

clean:
	rm -rf build

# Ensure the build directory exists
build-dir:
	mkdir -p build

# Rule to process each .md file into the build directory
build: build-dir $(patsubst pages/%.md,build/%.html,$(wildcard pages/*.md))
	cp sources/*.css sources/*.js build/

# Pattern rule to convert .md to .html
build/%.html: pages/%.md sources/template.html Makefile
	pandoc --toc -s --css reset.css --css index.css -i $< -o $@ --template=sources/template.html

# Target to generate the index file with paths
pages/.index.md: pages/*.md
	@cp sources/.index-template.md pages/.index.md
	@for file in pages/*.md; do \
		base=$$(basename $$file .md); \
		echo "- [$$base](build/$$base.html)" >> pages/.index.md; \
	done

# Ensure index.html depends on .index.md
index.html: pages/.index.md build
	pandoc --css reset.css --css index.css -s -o build/index.html pages/.index.md --template=sources/template.html

.PHONY: all clean build build-dir
