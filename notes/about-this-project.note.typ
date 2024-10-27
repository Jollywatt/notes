#import "@preview/diatypst:0.1.0": *

#set text(font: "Helvetica Neue")
#show link: underline

#show: slides.with(
  title: [Minimal note hosting for messy scientists], // Required
  subtitle: [Static site generator for hyperlinked notes],
  date: [
    Project for #link("https://lu.ma/o07b5s8m")[Hack Day: Tools for Science 2024]
  ],
  authors: (
    "Joseph Wilson",
    "Mete Polat",
  ),

  // Optional Styling
  ratio: 16/9,
  layout: "medium",
  title-color: teal.darken(40%),
  footer: true,
  counter: true,
)

#outline()

= There are many ways to take notes in this modern world

== Existing note-taking solutions

- Obsidian, http://obsidian.md/
  - Markdown-based
  - Extensible
- Notion, http://notion.so
  - All-in-one organisational tool
- "Zettelkasten" gardens, https://notes.andymatuschak.org
  - Highly hyperlinked webs of small markdown files
  - Beautiful web frontend
- Evernote, https://evernote.com/

== How I want to take my notes

- Format agnostic
  - Markdown files with quick notes
  - Word documents
  - Jupyter notebooks with words and data
  - LaTeX or Typst PDFs

- Easy hyperlinking and cross-referencing
  - Link to other notes
  - Cite published material

- Easy to share
  - Free online hosting

- Don't tell me how I should take and organise my notes!

= The simplest useful note hosting system you could imagine

== 