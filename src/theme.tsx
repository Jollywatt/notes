import { Note, NoteFolder, Project } from "zettelsite"
import { CSS, render as renderMarkdown } from "@deno/gfm"
import { render } from "preact-render-to-string"
import { copySync } from "@std/fs"
import { join as pathJoin } from "@std/path"

const pageTitle = (title: string) => <title>Joseph’s notes | {title}</title>

const base = ({ title, head, body }) => (
	<html>
		<head>
			<meta charSet="utf-8" />
			<meta name="viewport" content="width=device-width, initial-scale=1" />
			<link rel="stylesheet" href="./assets/style.css" />
			<link rel="stylesheet" href="./assets/widgets.css" />
			{pageTitle(title)}
			{head}
		</head>
		<body>
			{body}
		</body>
	</html>
)

const copyrightFooter =
	`<p xmlns:cc="http://creativecommons.org/ns#"><a rel="cc:attributionURL" href="https://github.com/Jollywatt/notes">This work</a> by <span property="cc:attributionName">Joseph Wilson</span> is licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-ND 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""/><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""/><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""/><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nd.svg?ref=chooser-v1" alt=""/></a></p>`
const copyrightURL = "https://creativecommons.org/licenses/by-nc-nd/4.0/"

/* Index page with table of contents */

const indexPage = (tree: NoteFolder) =>
	base({
		head: <title>Joseph’s notes</title>,
		body: (
			<>
				<img id="background" src="./assets/background.png" />
				<div id="toc" className="pad">
					<h1>
						<a href="/">Joseph</a>’s notes V. II
					</h1>
					<p>
						Welcome to my Zettelkasten garden of notes. Here is where I put
						scraps and notes from my research and coursework.
					</p>

					{toc(tree)}

					<div dangerouslySetInnerHTML={{ __html: copyrightFooter }} />
				</div>
			</>
		),
	})

const tocEntry = (note: Note) => (
	<li>
		<a className="notelink" href={`${note.name}`}>
			[{note.name}]
		</a>{" "}
		<span style={{ fontSize: "80%" }}>{note.type}</span>
	</li>
)

function toc(node: NoteFolder) {
	const notenames = Object.keys(node.notes).sort()
	const foldernames = Object.keys(node.folders).sort()
	return (
		<ul>
			{notenames.map((name) => tocEntry(node.notes[name]))}
			{foldernames.map((name) => (
				<li>
					{name}
					{toc(node.folders[name])}
				</li>
			))}
		</ul>
	)
}

/* Individual note pages */

function headerContent(note: Note) {
	let el = (
		<>
			<a href="/">Joseph’s notes</a> / {note.dir.map((a) => `${a} / `)}
			<span className="notelink">{note.name}</span>
		</>
	)
	el = (
		<>
			{el} • <a href={copyrightURL}>&copy;</a>
		</>
	)
	return el
}

const header = (note) => <div id="header">{headerContent(note)}</div>

const json = (obj) => <pre>{JSON.stringify(obj, null, 2)}</pre>

const defaultRenderer = (note) => {
	console.warn(
		`%cUsing default renderer for note "${note.name}" of type "${note.type}"`,
		"color: yellow",
	)
	return base({
		title: note.name,
		body: (
			<main>
				{header(note)}
				No renderer is defined for note type <code>{note.type}</code>.
				<pre>{JSON.stringify(note, null, 2)}</pre>
			</main>
		),
	})
}

const noteRenderers: { [noteType: string]: Function } = {}

noteRenderers["markdown"] = async function (note) {
	let md = await Deno.readTextFile(note.files.md)
	md = md
		.replace(/\(@([-\w]+)\)/g, (_, name) => `(${name}.html)`)
		.replace(/@([-\w]+)/g, (handle, name) => `[${handle}](${name}.html)`)
	const html = renderMarkdown(md)
	return base({
		title: note.name,
		head: <style>{CSS}</style>,
		body: (
			<>
				{header(note)}
				<pre>{md}</pre>
				<pre>{html}</pre>
				<main
					dangerouslySetInnerHTML={{ __html: html }}
					className="markdown-body"
				>
				</main>
			</>
		),
	})
}

noteRenderers["plain text"] = async function (note: Note) {
	const txt = await Deno.readTextFile(note.files.txt)
	return base({
		title: note.name,
		body: (
			<>
				{header(note)}
				<main>
					<pre>{txt}</pre>
				</main>
			</>
		),
	})
}

noteRenderers["pluto notebook"] = async function (note: Note) {
	const html = await Deno.readTextFile(note.files.html)
	const attachment = (
		<>
			{pageTitle(note.name)}
			<link rel="stylesheet" href="/assets/widgets.css" />
			<div className="zettel-floating-header">
				{headerContent(note)}
			</div>
		</>
	)
	return `${html}\n${render(attachment)}`
}

function pdfRenderer(note: Note) {
	const pdfFileName = `${note.name}.pdf`
	Deno.copyFile(note.files.pdf, pathJoin("site", pdfFileName))
	return base({
		title: note.name,
		body: (
			<>
				{header(note)}
				<div id="content">
					<object data={pdfFileName} type="application/pdf" />
				</div>
			</>
		),
	})
}

noteRenderers["typst pdf"] = pdfRenderer
noteRenderers["latex pdf"] = pdfRenderer

async function codeRenderer(
	note: Note,
	{ srcfile, lang }: { srcfile: string; lang: string },
) {
	const src = await Deno.readTextFile(note.files.jl)
	return base({
		title: note.name,
		head: (
			<>
				<link rel="stylesheet" href="/assets/highlight/styles/default.css" />
				<script src="/assets/highlight/highlight.min.js" />
				<script>hljs.highlightAll();</script>
			</>
		),
		body: (
			<>
				{header(note)}
				<div id="content">
					<div className="scroll">
						<pre><code className={`language-${lang}`}>{src}</code></pre>
					</div>
				</div>
			</>
		),
	})
}

noteRenderers["julia code"] = (note) =>
	codeRenderer(note, { srcfile: note.files.jl, lang: "julia" })

export async function build(project: Project) {
	const { notes, tree } = project.analyse()
	project.renderPage("index.html", indexPage(tree))

	copySync("src/assets", pathJoin(project.sitedir, "assets"))

	for (const name in notes) {
		const note: Note = notes[name]
		const renderer = noteRenderers[note.type ?? "unknown"] ?? defaultRenderer
		const html = await renderer(note)
		project.renderPage(`${name}.html`, html)
	}
}
