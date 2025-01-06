import { Note, NoteFolder, Project } from "zettelbuilder"
import { CSS, render as renderMarkdown } from "@deno/gfm"
import { render } from "preact-render-to-string"
import { copySync } from "@std/fs"
import { join as pathJoin } from "@std/path"

const pageTitle = (title: string) => <title>Joseph’s notes | {title}</title>

const root = "/notes"
const site = "https://jollywatt.github.io/"

const clientReloadScript = `
const ws = new WebSocket("ws://"+location.host)
ws.onmessage = (msg) => {
	if (msg.data === "reload") {
		location.reload()
	}
}
`
const AutoReloadScript = () => (
	<script dangerouslySetInnerHTML={{ __html: clientReloadScript }} />
)

function Base(
	{ title, head, children }: { title: string; head?: any; children: any },
) {
	return (
		<html>
			<head>
				<meta charSet="utf-8" />
				<meta name="viewport" content="width=device-width, initial-scale=1" />
				<link rel="stylesheet" href={pathJoin(root, "assets/style.css")} />
				<link rel="stylesheet" href={pathJoin(root, "assets/widgets.css")} />
				<AutoReloadScript />
				{pageTitle(title)}
				{head}
			</head>
			<body>
				{children}
			</body>
		</html>
	)
}

function NotePage({ note, children, head = <></> }) {
	return (
		<Base title={note.name} head={head}>
			<NoteHeader note={note} />
			<main>{children}</main>
			<CrossrefTabs note={note} />
		</Base>
	)
}

const CopyrightFooter = () => {
	const html =
		`<p xmlns:cc="http://creativecommons.org/ns#"><a rel="cc:attributionURL" href="https://github.com/Jollywatt/notes">This work</a> by <span property="cc:attributionName">Joseph Wilson</span> is licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-ND 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""/><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""/><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""/><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nd.svg?ref=chooser-v1" alt=""/></a></p>`
	return <div dangerouslySetInnerHTML={{ __html: html }} />
}
const copyrightURL = "https://creativecommons.org/licenses/by-nc-nd/4.0/"

/* Index page with table of contents */

const indexPage = (project: Project) => (
	<Base title={"Index"}>
		<img id="background" src={pathJoin(root, "assets/background.png")} />
		<div id="toc" className="pad">
			<h1>
				<a href="/">Joseph</a>’s notes V. II
			</h1>
			<p>
				Welcome to my Zettelkasten garden of notes. Here is where I put scraps
				and notes from my research and coursework.
			</p>

			<TableOfContents tree={project.analysis.tree} />

			<CopyrightFooter />
		</div>
	</Base>
)

function NoteLink({ note }: { note: Note }) {
	return (
		<a className="notelink" href={pathJoin(root, note.name)}>
			[{note.name}]
		</a>
	)
}

const tocEntry = (note: Note) => (
	<li>
		<NoteLink note={note} />{" "}
		<span style={{ fontSize: "80%" }}>{note.description}</span>
	</li>
)

function TableOfContents({ tree }: { tree: NoteFolder }) {
	const notenames = Object.keys(tree.notes).sort()
	const foldernames = Object.keys(tree.folders).sort()
	return (
		<ul>
			{notenames.map((name) => tocEntry(tree.notes[name]))}
			{foldernames.map((name) => (
				<li>
					{name}
					<TableOfContents tree={tree.folders[name]} />
				</li>
			))}
		</ul>
	)
}

function CrossrefTabs({ note }: { note: Note }) {
	const incoming = note.refs.incoming.map((note) => <NoteLink note={note} />)
	const outgoing = note.refs.outgoing.map((note) => <NoteLink note={note} />)

	return (
		<>
			{incoming.length
				? (
					<div class="zettel-side-menu left">
						<div>
							<li>Linking to here:</li>
							{incoming}
							<span class="tab right">⟩</span>
						</div>
					</div>
				)
				: null}
			{outgoing.length
				? (
					<div class="zettel-side-menu right">
						<div>
							<li>Linking from here:</li>
							{outgoing}
							<span class="tab left">⟩</span>
						</div>
					</div>
				)
				: null}
		</>
	)
}

/* Individual note pages */

function headerContent(note: Note) {
	let el = (
		<>
			<a href={root}>Joseph’s notes</a> / {note.dir.map((a) => `${a} / `)}
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

const NoteHeader = ({ note }) => <div id="header">{headerContent(note)}</div>

const json = (obj) => <pre>{JSON.stringify(obj, null, 2)}</pre>

export class PlutoNotebookNote extends Note {
	static override extensionCombo = ["jl", "html"]
	static override description = "pluto notebook"

	override extractRefs(allNames: Set<string>) {
		return new Set(
			this.files.jl.content.matchAll(
				/jollywatt\.github\.io\/notes\/([-\w]+)/g,
			).map((match) => match[1]),
		)
	}

	override render() {
		const html = this.files.html.content
		const attachment = (
			<>
				{pageTitle(this.name)}
				<link rel="stylesheet" href={pathJoin(root, "assets/widgets.css")} />
				<div className="zettel-floating-header">
					{headerContent(this)}
				</div>
			</>
		)
		return `${html}\n${render(attachment)}`
	}
}

function renderPDFPage(note: Note) {
	const pdfFileName = `${note.name}.pdf`
	Deno.copyFile(note.files.pdf.path, pathJoin("site", pdfFileName))
	return (
		<NotePage note={note}>
			<div id="content">
				<object data={pdfFileName} type="application/pdf" />
			</div>
		</NotePage>
	)
}

export class TypstNote extends Note {
	static override extensionCombo = ["typ", "pdf"]
	static override description = "typst pdf"

	override extractRefs(allNames: Set<string>) {
		return new Set(
			this.files.typ.content.matchAll(/@([-\w]+)/g).map((match) => match[1]),
		).intersection(allNames)
	}

	override render() {
		return renderPDFPage(this)
	}
}

export class LaTeXNote extends Note {
	static override extensionCombo = ["tex", "pdf"]
	static override description = "latex pdf"

	override render() {
		return renderPDFPage(this)
	}
}

function codeRenderer(
	note: Note,
	{ srcfile, lang }: { srcfile; lang: string },
) {
	const src = srcfile.content
	return (
		<NotePage
			note={note}
			head={
				<>
					<link
						rel="stylesheet"
						href={pathJoin(root, "assets/highlight/styles/default.css")}
					/>
					<script src={pathJoin(root, "assets/highlight/highlight.min.js")} />
					<script>hljs.highlightAll();</script>
				</>
			}
		>
			<div id="content">
				<div className="scroll">
					<pre><code className={`language-${lang}`}>{src}</code></pre>
				</div>
			</div>
		</NotePage>
	)
}

export class JuliaCodeNote extends Note {
	static override extensionCombo = ["jl"]

	override render() {
		return codeRenderer(this, {
			srcfile: this.files.jl,
			lang: "julia",
		})
	}
}

export class ExternalURLNote extends Note {
	static override extensionCombo = ["url"]

	override get description() {
		return `${this.url.host} link`
	}

	#url: URL | null = null
	get url(): URL {
		if (this.#url === null) {
			const match = this.files.url.content.match(/https?:.*/)
			if (match === null) {
				throw new Error(`Couldn't parse URL in ${this.files.url.path}.`)
			}
			this.#url = new URL(match[0])
		}
		return this.#url
	}

	override render() {
		return (
			<Base title={this.name}>
				<div id="wide-header">{headerContent(this)}</div>
				<iframe class="page" src={this.url.href}></iframe>
			</Base>
		)
	}
}

function exportPermalinksCSV(noteNames: string[]) {
	const prefix = pathJoin(site, root)
	let csv = noteNames.map((name) => {
		return [name, pathJoin(prefix, name)].map(JSON.stringify).join(",")
	})
	return csv.join("\n")
}

export async function build(project: Project) {
	const { notes, tree, refs } = project.analyse()
	project.renderPage("index.html", indexPage(project))

	copySync("src/assets", pathJoin(project.buildDir, "assets"))

	for (const name in notes) {
		const html = notes[name].render()
		project.renderPage(`${name}.html`, html)
	}

	const csv = exportPermalinksCSV(Object.keys(notes))
	Deno.writeTextFile(`src/typst-template/permalinks.csv`, csv)
}
