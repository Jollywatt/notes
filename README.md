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

In principle, notes can be of any format: markdown files, LaTeX or [Typst](http://typst.app)
source/PDF pairs, standalone PDFs, plain HTML files, Jupyter or
[Pluto.jl](https://www.google.com/search?client=safari&rls=en&q=pluto.jl&ie=UTF-8&oe=UTF-8)
notebooks, etc.

The only requirements are that:

- the filename(s) must be of the form `<name>.note.*`,
- a renderer is defined for the note type (combination of file extensions).
