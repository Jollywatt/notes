#import "@preview/diatypst:0.1.0": *

#set text(font: "Helvetica Neue")
#show link: underline

#show: slides.with(
  title: [Minimal file-based note system\ for messy scientists], // Required
  subtitle: [Static site generator for hyperlinked notes],
  date: [
    Project for #link("https://lu.ma/o07b5s8m")[Hack Day: Tools for Science 2024]
  ],
  authors: (
    "Joseph Wilson",
    "Mete Polat",
  ),

  // Optional Styling
  ratio: 14/9,
  layout: "small",
  title-color: teal.darken(40%),
  footer: false,
  counter: false,
)

= There are many ways to take notes in this modern world

== Existing solutions

- Obsidian, http://obsidian.md/
  - Markdown-based
  - Extensible
- Notion, http://notion.so
  - All-in-one organisational tool
- "Zettelkasten" gardens, https://notes.andymatuschak.org
  - Highly hyperlinked webs of small markdown files
  - Beautiful web frontend
- Evernote, https://evernote.com/

== What I want

- Format agnostic
  - Markdown files for quick notes
  - Jupyter notebooks with code and data
  - Word documents
  - LaTeX or Typst PDFs
  - Screenshots or image files with explanations

- Easy hyperlinking and cross-referencing
  - To other notes
  - Cite published material

- Free hosting, easy sharing

- Don't tell me how I should take and organise my notes!

= The simplest useful solution

== Just store notes as files

#align(center, image("files.png"))

#pagebreak()

Mark files as notes with `.note.` in filename.

Notes can have multiple files:

- `A.note.tex` + `A.note.pdf` = A LaTeX PDF
- `B.note.typ` + `B.note.pdf` = A Typst PDF
- `C.note.md` = A standalone markdown document
- `D.note.jl` = A raw Julia script
- `E.note.ipynb` + `E.note.html` = A Jupyter notebook with exported HTML
- `F.note.jl` + `F.note.html` = A Pluto.jl notebook
- `G.note.png` + `G.note.txt` = A picture with words

(All this is currently hard-coded into the build script)

== Make simple static site to host them

Put your notes in a Git repo.

Add a GitHub workflow to run this action:

https://github.com/Jollywatt/notes-deploy-action

When pushed, a static site is built and hosted on GitHub pages:

https://jollywatt.github.io/notes/


== Advantages

- Notes of all different sorts can live together

- Notes get permalinks so you can link to them and cross-reference

- To add a different format, the build script can be extended

- You can build and serve the site locally as an alternative way to navigate your files

- You get free hosting if you want your notes to be public

== Disadvantages

- Currently super basic and breakable

- Doesn't work with notes that you couldn't easily put on a Git repo\ (Google Docs, Apple Notes)

= Next steps

== Integration with Typst

To cite other notes, you can write, e.g.:
```typ
This was proven in #link("https://jollywatt.github.io/notes/proof-of-thing")[this note].
```

With a simple Typst package that hooks into metadata produced by the build script, you can write:

```typ
#import "@local/notes:0.1.0"
#show: notes.style

This was proven in @proof-of-thing[this note].
```


== Adding HTML renderers for different formats

- Renderer for plain markdown files

- A format for adding words to pictures, e.g., `idea.note.png` + `idea.note.txt` could produce an HTML page with both side-by-side.