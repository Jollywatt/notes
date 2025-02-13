#let references() = [
	= References
	#bibliography(
		"library.bib",
		title: none,
		style: "american-psychological-association",
	)
]

#let get-permalinks() = {
	let links = (:)
	for (name, url) in csv("permalinks.csv") {
		links.insert(name, url)
	}
	links
}

#let refs = get-permalinks().keys()

#let note-crossref(label, url) = {
	let c = eastern.transparentize(85%)
	link(url, highlight(fill: c, label))
}

#let show-crossrefs(body) = {
	let s = underline.with(stroke: eastern + 0.06em)
	show link: s
	show ref: s
	show ref: it => {
		let name = str(it.target)
		let note-refs = get-permalinks()
		if name in note-refs {
			let label = if it.supplement == auto {
				raw("["+name+"]")
			} else {
				it.supplement
			}
			note-crossref(label, note-refs.at(name))
		} else {
			if it.element == none {
				// probably a bibliography entry
				counter("bib-entries").update(1)
			}
			it
		}
	}
	
	body
}

#let style(body, bibliography: auto) = {
	set page(width: 18cm, height: auto, margin: 12mm)

	set text(font: "CMU Concrete")
	show math.equation: set text(font: "Concrete Math")

	show heading: pad.with(y: 0.5em)

	show: show-crossrefs
	
	body

	if bibliography == true { references() }
	else if bibliography == auto {
		context if counter("bib-entries").get().at(0) > 0 {
			references()
		}
	}
}

#let result-box(body, tint: green) = {
	block(
		width: 100%,
		inset: 1em,
		stroke: tint,
		fill: tint.lighten(95%),
		body,
	)
}
