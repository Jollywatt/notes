module Templates

const SITE = "https://jollywatt.github.io"
const ROOT = "/notes"

const combos = Dict(
	Set([:typ, :pdf]) => :typst_pdf,
	Set([:tex, :pdf]) => :latex_pdf,
	Set([:jl, :html]) => :pluto_notebook,
	Set([:jl]) => :julia_code,
	Set([:url]) => :url,
)

template(::Val{:typst_pdf}, n) = Templates.pdf(n)
template(::Val{:latex_pdf}, n) = Templates.pdf(n)
template(::Val{:pluto_notebook}, n) = Templates.html(n, read(joinpath(n.srcdir, n.files[:html]), String))
template(::Val{:julia_code}, n) = Templates.code(n, read(joinpath(n.srcdir, n.files[:jl]), String), :julia)
template(::Val{:url}, n) = Templates.iframe(n, n.info.url)
template(::Val{kind}, n) where kind = error("No template function defined for note kind $(repr(kind))!")


permalink(url) = "$SITE$ROOT/"*url

link(url, label) = "<a href=$(repr(url))>$label</a>"

copyright_url() = "https://creativecommons.org/licenses/by-nc-nd/4.0/"

copyright_footer() = """
	<p xmlns:cc="http://creativecommons.org/ns#" ><a rel="cc:attributionURL" href="https://github.com/Jollywatt/notes">This work</a> by <span property="cc:attributionName">Joseph Wilson</span> is licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-ND 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nd.svg?ref=chooser-v1" alt=""></a></p>
	"""

base(content; title, head="") = """
	<!DOCTYPE html>
	<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" href="$ROOT/assets/style.css">
		$head
		<title>Joseph's notes | $title</title>
	</head>
	<body>
		$content
	</body>
	</html>
	"""

function headercontent(n)
	items = String[
		link(ROOT, "Joseph’s notes"),
	]
	push!(items, """ / <span style="font-family: monospace; font-size: initial;">$(n.name)</span>""")
	:pdf in keys(n.files) && push!(items, link("$(n.name).pdf", "raw PDF"))
	:typ in keys(n.files) && push!(items, link("$(n.name).typ", "typst source"))
	:tex in keys(n.files) && push!(items, link("$(n.name).tex", "LaTeX source"))
	:jl in keys(n.files) && push!(items, link("$(n.name).jl", "Julia source"))
	join(items, " • ")
end


function crossref_tabs(note)


	arrivals = map(note.crossrefs.arrivals) do name
		"""<div class="notelink">$(link(joinpath(ROOT, name), name))</div>"""
	end
	departures = map(note.crossrefs.departures) do name
		"""<div class="notelink">$(link(joinpath(ROOT, name), name))</div>"""
	end

	items = String[]

	isempty(arrivals) || push!(items, """
		<div class="zettel-side-menu left">
			<div>
				<div>Arriving links:</div>
				$(join(arrivals))
				<span class="tab right">⟩</span>
			</div>
		</div>
	""")

	isempty(departures) || push!(items, """
		<div class="zettel-side-menu right">
			<div>
				<div>Departing links:</div>
				$(join(departures))
				<span class="tab left">⟩</span>
			</div>
		</div>
	""")

	join(items)
end


note(content, n; args...) = base("""
	<div id="header">
		$(headercontent(n))
	</div>
	<div id="content">
		$content
	</div>
	$(crossref_tabs(n))
	"""; title=n.name, args...)

pdf(n) = note("""
	<object data="$ROOT/$(n.name).pdf" type="application/pdf"></object>
	""", n)

code(n, text, lang) = note("""
	<div class="scroll">
		<pre><code class="language-$lang">$text</code></pre>
	</div>
	""", n, head="""
	<link rel="stylesheet" href="$ROOT/assets/highlight/styles/default.css">
	<script src="$ROOT/assets/highlight/highlight.min.js"></script>
	<script>hljs.highlightAll();</script>
	""")

iframe(n, link) = base("""
	<div id="wide-header">
		$(headercontent(n))
	</div>
	<iframe class="page" src=$(repr(link))></iframe>
	<style>
	iframe {
		border: none;
		display: block;
		height: calc(100vh - 30px);
		width: 100vw;
	}
	#wide-header {
		height: 20px;
		padding: 5px;
		border-radius: 0 0 5pt 0;
		color: white !important;
		background: #2A2A2A;
		box-shadow: 0 0 5pt #0005;
		z-index: 10000;
	}
	#wide-header a {
		color: white
	}
	</style>
"""; title=n.name)

html(n, htmlcontent) = """
	$htmlcontent
	<div id="floating-header">
		$(headercontent(n))
	</div>
	<style>
	#floating-header {
		position: fixed;
		top: 0;
		left: 0;
		height: var(--header-size);
		padding: 5px;
		border-radius: 0 0 5pt 0;
		background: light-dark(white, #0004);
		box-shadow: 0 0 5pt #0005;
		z-index: 10000;
	}
	</style>
	"""

toc(tree) = base("""
	<img id="background" src="$ROOT/assets/background.png"/>
	<div id="toc" class="pad">
		<h1><a href="$SITE">Joseph</a>’s notes</h1>
		<p>
		Welcome to my Zettelkasten garden of notes.
		Here is where I put scraps and notes from my research and coursework.
		</p>

		$(toc_item(tree))

		$(copyright_footer())

	</div>
	"""; title = "Home")

notelink(name, info) = """
	<a class="notelink" href="$ROOT/$name">[$name]</a>
	<span style="font-size: 80%">$(replace(string(info.kind), "_"=>" "))</span>
"""

toc_item((name, info)::Pair{String}) = """
	<li>$(notelink(name, info))</li>
"""

toc_item(items::AbstractVector) = """
	<ul>
	$(join(toc_item.(items)))
	</ul>
"""

function toc_item((subdir, items)::Pair{String,<:AbstractVector})
	if length(items) == 1
		(name, info) = first(items)
		"""
		<li>
			$subdir:
			$(notelink(name, info))
		</li>
		"""
	else
		"""
		<li>
			$subdir:
			<ul>
			$(join(toc_item.(items)))
			</ul>
		</li>
		"""
	end
end

end # module

