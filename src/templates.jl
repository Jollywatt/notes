module Templates

ROOT = "/notes"

permalink(url) = "https://jollywatt.github.io$ROOT/"*url

link(name, ext, label) = "• <a href=$(repr("$name.$ext"))>$label</a>"

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
			link(n.name, :pdf, "raw PDF")
		else
			""
		end
	)
	$(
		if :typ in keys(n.files)
			link(n.name, :typ, "typst source")
		elseif :tex in keys(n.files)
			link(n.name, :tex, "LaTeX source")
		elseif :jl in keys(n.files)
			link(n.name, :jl, "Julia source")
		else
			""
		end
	)
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
		<h1>Joseph’s notes</h1>
		<p>
		Welcome to my Zettelkasten garden of notes.
		Here is where I put scraps and notes from my research and coursework.
		</p>

		$(toc_item(tree))
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

