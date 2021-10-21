# book-tricks

A starter kit for book creation from HTML. Takes every HTML file in the `html` directory and turns it into a PDF, EPUB, and MOBI file.

## The Basics

This script requires: [pandoc](https://pandoc.org/index.html), node, [pagedjs-cli](https://gitlab.pagedmedia.org/tools/pagedjs-cli) (installed via `npm install`), [calibre](https://calibre-ebook.com/download) (ebook-convert), GNU make, bash.

Currently it's in the form of a `Makefile`, with preprocessing, that converts every `.html` file in the `html/` folder into PDF (using pagedjs), EPUB, and MOBI.

Run `make` in this directory and it will generate new files for every `.html` file that has been modified since you last ran make.

(In theory, running `make install` should also install all required dependencies except for [calibre](https://calibre-ebook.com/download) but I haven't tested it on a mac.)

You edit the `global-metadata.yaml` file to add metadata globally (currently language and author).

The Makefile renders PDFs using Paged.js, which is a polyfill for various paged CSS features that runs in the browser.

Paged.js supports full CSS and JavaScript (if you want to run a script with the HTML's DOM before rendering the PDF). It should in theory support a broad range of CSS and paged CSS but is occasionally a bit buggy. It exports tagged PDFs with an outline.

The script generates a regular EPUB3 by running the HTML file through pandoc. It adds an additional `epub.css` file from the `styles` folder that can be used to add epub-specific styles. This epub is then used to generate the MOBI file using `ebook-convert` from Calibre.

Generally speaking, if your readers use email delivery to send ebooks to their Kindle devices, they're usually best off by sending the PDF, not the mobi. And if you want to sell via Kindle Direct Publishing, you need to upload the EPUB as Amazon is phasing out mobi support.

The CSS (paged and epub) included is super minimal.

## Missing features

- Preprocessing and filtering of the EPUB file to remove potential problem features (like JS, iframes, etc.) for _EPUB_ output
- Preprocessing and filtering of the EPUB file to remove potential problem features (like JS, iframes, etc.) for _MOBI_ output

## Additional notes

The `Makefile` has a few comments. Most of the same information should also be in this README but I may have missed some.

Apple's books app works well for testing epubs but if you want more standards-compliant testing I recommend [Thorium Reader](https://www.edrlab.org/software/thorium-reader/). It's made by EDRlab and is based on the opensource Readium epub rendering library (which is also used by Aldiko, several library apps, and, last I checked, partially used by Kobo). Thorium is also cross-platform.

### Metadata

You can edit the `global-metadata.yaml` file to add things like a cover image to the epub and mobi files. See Pandoc's [EPUB Metadata documentation](https://pandoc.org/MANUAL.html#epub-metadata).

If an `*.html` file has a matching `*.html.yaml` metadata file then that _replaces_ the global one. This lets you have custom metadata for each file.

### Fonts

All `.otf` and `.ttf` font files in the `fonts` directory will be included in the epub and the mobi. The Kindle doesn't support `.woff` at this point so only the older file formats are supported.

The `fonts` directory is added to the archive in the same folder as the `style` directory, so to refer to the font files from a CSS file you need to do something like: `url("../fonts/FontName.ttf")`. These fonts are _not_ included in the PDF version so make sure to only use them from the `epub.css` stylesheet.
