all: build index.html

clean:
	rm -rf build

# Rule to process each .md file into the build directory
build: $(patsubst pages/%.md,build/%.html,$(wildcard pages/*.md))
	mkdir -p build
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

.PHONY: all clean build



#all: build index
#
#clean:
#	rm -rf build
#
## Rule to process each .md file into the build directory
#build: $(patsubst pages/%.md,build/%.html,$(wildcard pages/*.md))
#	mkdir -p build
#	cp sources/*.css sources/*.js build/
#
## Pattern rule to convert .md to .html
#build/%.html: pages/%.md sources/template.html Makefile
#	pandoc --toc -s --css reset.css --css index.css -i $< -o $@ --template=sources/template.html
#
## Target to generate the index file with paths
#index: build
#	@cp sources/default.index.md pages/.index.md
#	@for file in pages/*.md; do \
#		base=$$(basename $$file .md); \
#		echo "- build/$$base.html" >> pages/.index.md; \
#	done
#
#.PHONY: all clean build index
