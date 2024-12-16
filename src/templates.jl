module Templates

SITE = "https://jollywatt.github.io"
ROOT = "/notes"

permalink(url) = "$SITE$ROOT/"*url

link(url, label) = "• <a href=$(repr(url))>$label</a>"

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

headercontent(n) = """
	<a href="$ROOT">Joseph’s notes</a> / <span style="font-family: monospace; font-size: initial;">$(n.name)</span>
	$(
		if :pdf in keys(n.files)
			link("$(n.name).pdf", "raw PDF")
		else
			""
		end
	)
	$(
		if :typ in keys(n.files)
			link("$(n.name).typ", "typst source")
		elseif :tex in keys(n.files)
			link("$(n.name).tex", "LaTeX source")
		elseif :jl in keys(n.files)
			link("$(n.name).jl", "Julia source")
		else
			""
		end
	)
	$(link(copyright_url(), "©"))
"""


note(content, n; args...) = base("""
	<div id="header">
		$(headercontent(n))
	</div>
	<div id="content">
		$content
	</div>
	"""; title=n.name, args...)

pdf(n) = note("""
	<object data="$ROOT/$(n.name).pdf" type="application/pdf"/>
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

