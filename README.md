# Joseph's notes

A simple Zettelkasten garden of technical notes, deployed to GitHub pages at
[jollywatt.github.io/notes/](https://jollywatt.github.io/notes/).

## How it works

### Organisation

The contents of the `notes/` directory can contain any files organised however
you like.

Files with paths of the form

```
/notes/<path>/<name>.note.<extension>
```

are recognised as "notes", where `<name>` is the ID of the note which determines
its permalink, for example `https://jollywatt.github.io/notes/<name>`. Notes can
reference other notes by their permalink, and can be moved without breaking
their permalink so long as they keep the same `<name>`.

A note can have multiple associated files, for example `<name>.note.tex` and
`<name>.note.pdf`. The format of the note is determined by the combination of
file extensions present. For example, `.tex + .pdf` forms a LaTeX PDF note,
`.jl + .html` forms a
[Pluto.jl](https://www.google.com/search?client=safari&rls=en&q=pluto.jl&ie=UTF-8&oe=UTF-8)
notebook.

### Format agnosticism

In principle, notes can be markdown files, LaTeX or [Typst](http://typst.app)
source-PDF pairs, standalone images or PDFs, plain HTML files, Jupyter or
[Pluto.jl](https://www.google.com/search?client=safari&rls=en&q=pluto.jl&ie=UTF-8&oe=UTF-8)
notebooks, etc.

The only requirements are that:

- the filename must be of the form `<name>.note.*`,
- the build script `src/build.jl` must implement an HTML template for the
  required combination of file extensions.

#### Typst integration

In practice, I mostly use Typst to write notes, and have therefore written a
Typst package `src/typst-template/` which applies common styles and makes it
easy to reference other notes with `@name`.

To use it locally, the package should be installed under
`{data-dir}/typst/packages/local/notes/0.1.0/` and loaded with
`import "@local/notes:0.1.0"` (see the readme for
https://github.com/typst/packages for details).

I also use Zotero maintain a references file `src/typst-template/library.bib`
which is shared between all Typst notes. Zotero has a synchronization feature
which means it automatically writes to `library.bib` as references are added.

### Static site generation

The build script `src/build.jl` generates a static site in `site/` populated
from files in `notes/`. This build script determines which files are notes an
the final HTML file at the note's permalink.
