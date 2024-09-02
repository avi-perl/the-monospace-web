all: build

clean:
	rm -rf build

# Rule to process each .md file into the build directory
build: $(patsubst pages/%.md,build/%.html,$(wildcard pages/*.md))
	mkdir -p build
	cp sources/*.css sources/*.js build/

# Pattern rule to convert .md to .html
build/%.html: pages/%.md sources/template.html Makefile
	pandoc --toc -s --css reset.css --css index.css -i $< -o $@ --template=sources/template.html

.PHONY: all clean build
