#let references() = bibliography(
	"library.bib",
	title: [References],
	style: "american-psychological-association",
)

#let get-permalinks() = {
	let links = (:)
	for (name, url) in csv("permalinks.csv") {
		links.insert(name, url)
	}
	links
}

#let refs = strong[Referenceable notes: #get-permalinks().keys()]

#let note-crossref(name, url) = {
	let c = eastern.transparentize(85%)
	link(url, highlight(fill: c, raw(name)))
}

#let style(body) = {
	set page(width: 18cm, height: auto, margin: 12mm)

	show heading: pad.with(y: 0.5em)

	let s = underline.with(stroke: eastern + 0.06em)
	show link: s
	show ref: it => {
		let name = str(it.target)
		let note-refs = get-permalinks()
		if name in note-refs {
			note-crossref(name, note-refs.at(name))
		} else { it }
	}

	body
}
