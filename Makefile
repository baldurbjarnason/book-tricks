# Do we have brew or apt-get
homebrew := $(shell command -v brew 2> /dev/null)
apt := $(shell command -v apt 2> /dev/null)

CALIBRE_MACOSX := /Applications/calibre.app/Contents/MacOS/ebook-convert

# This tests to see if the macOS path for the Calibre CLI tools is executable or not. If they are then we use those tools, otherwise we trust that they can be found in Bash's path
ifeq ($(shell command -v $(CALIBRE_MACOSX) 2> /dev/null),$(CALIBRE_MACOSX))
  CALIBRE := /Applications/calibre.app/Contents/MacOS/ebook-convert
else
  CALIBRE := ebook-convert
endif

## In theory pagedjs-cli and pandoc support web-hosted files as a source


DIST :=  dist
DIST_DIRECTORY := $(abspath dist)
HTML :=  html
HTML_DIRECTORY := $(abspath $(HTML))
html_files := $(wildcard html/*.html)
html_filenames := $(notdir $(html_files))
pagejs_targets := $(addprefix $(DIST)/, $(addsuffix .pdf, $(basename $(html_filenames))))
epub_targets := $(addprefix $(DIST)/, $(addsuffix .epub, $(basename $(html_filenames))))
mobi_targets := $(addprefix $(DIST)/, $(addsuffix .mobi, $(basename $(html_filenames))))

.PHONY:build
build: pdf epub mobi

pdf: $(pagejs_targets) | $(DIST_DIRECTORY)
	@echo Building PDFs done

# Apple's books app works well for testing epubs but if you want more standards-compliant testing I recommend Thorium Reader
# It's made by EDRlab and is based on the opensource Readium epub rendering library (which is also used by Aldiko, several library apps, and, last I checked, partially used by Kobo) https://www.edrlab.org/software/thorium-reader/
# Thorium is also cross-platform
epub: $(epub_targets)
	@echo Building EPUBs done

mobi: $(mobi_targets)
	@echo Building mobis done````````

# PDF build recipe
## loading="lazy" on images breaks pagedjs. It won't finish loading so the preprocess script removes it.
## A PDF toc outline requires headings to have an id. The preprocess script adds them when missing.
# Unless the heading elemends have ids, pagedjs will crash when trying to generate an outline, and you're going to need an outline for accessibility.
$(DIST)/%.pdf: html/%.html | $(DIST_DIRECTORY)
	@echo $(html_filenames)
	@echo building $? to $@
	@npx pagedjs-cli $? -o $@ --browserArgs=--disable-font-subpixel-positioning --additional-script pagedjs-process.js --outline-tags "h1,h2"

# --stylesheet <filename_or_URL> to add a custom stylesheet to weasyprint
$(DIST)/%.weasyprint.pdf: html/%.html | $(DIST_DIRECTORY)
	@echo building $? to $@
	@cat $? | weasyprint - $@ -u $? --stylesheet styles/paged.css

## Epub Buid recipe
# The highlight theme file lets you customise the syntax highlighting that pandoc renders.
$(DIST)/%.epub: html/%.html | $(DIST_DIRECTORY)
	@echo building $? to $@ with metadata from $(if $(wildcard $?.yaml),$?.yaml,global-metadata.yaml)
	@cat $? | pandoc -o $@ --resource-path=.:html -f html --css=styles/epub.css --metadata-file=$(if $(wildcard $?.yaml),$?.yaml,global-metadata.yaml) --epub-embed-font='fonts/*.ttf' --epub-embed-font='fonts/*.otf' --highlight-style highlight.theme

## mobi Buid recipe
$(DIST)/%.mobi: $(DIST)/%.epub | $(DIST_DIRECTORY)
	@echo building $? to $@
	@echo $(shell command -v /Applications/calibre.app/Contents/MacOS/ebook-convert 2> /dev/null)
	@$(CALIBRE) $? $@ 

# Build install
.PHONY:install
install: | npm-install native-install
	pip install weasyprint
	weasyprint --info
	@echo Please install calibre manually from https://calibre-ebook.com/download

.PHONY:native-install
native-install:
ifdef homebrew
	@echo Using homebrew
	brew install python pango libffi pandoc
else ifdef apt
	@echo Using apt
	sudo apt install python3-pip python3-cffi python3-brotli  libpango1.0-dev libpangoft2-1.0-0 pandoc
else
	@echo Please install the CLI tools manually (weasyprint, pandoc, and calibre)
endif

.PHONY:npm-install
npm-install:
	npm install


# Remember that directory timestamps are updated whenever their contents update. That's why you only want existence checks for directories not regular checks.
$(DIST_DIRECTORY):
	mkdir $@

$(HTML_DIRECTORY):
	mkdir $@
	
# Remove the dist directory
.PHONY:clean
clean:
	rm -rf $(DIST_DIRECTORY)