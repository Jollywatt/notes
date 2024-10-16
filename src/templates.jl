module Templates

ROOT = "/notes"

permalink(url) = "https://jollywatt.github.io$ROOT/"*url

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

note(content; title, args...) = base("""
	<div id="header">
		<a href="$ROOT">Joseph's notes</a> / $title
	</div>
	<div id="content">
		$content
	</div>
	"""; title, args...)

pdf(; title, file) = note("""
	<object data="$ROOT/$file" type="application/pdf"/>
	"""; title)

julia(; title, code) = note("""
	<div class="scroll">
		<pre><code class="language-julia">$code</code></pre>
	</div>
	"""; title, head="""
	<link rel="stylesheet" href="$ROOT/assets/highlight/styles/default.css">
	<script src="$ROOT/assets/highlight/highlight.min.js"></script>
	<script>hljs.highlightAll();</script>
	""")


toc(tree) = base("""
	<div id="content" class="pad">
	Welcome to my Zettelkasten garden of notes.

	$(toc_item(tree))
	</div>
	"""; title = "Home")

notelink(name, info) = """
	<a class="notelink" href="$ROOT/$name">[$name]</a> <span style="font-size: 80%">($(info.kind))</span>
"""

toc_item((name, info)::Pair{String,<:NamedTuple}) = """
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

