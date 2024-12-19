module ZettelkastenNotes

include("templates.jl")
include("compiletypst.jl")

export build


"""
Infer the type or kind of a note by which file extensions are present.
For example, a pair of `*.tex` and `*.pdf` files with the same name form a LaTeX note.
"""
function notekind(byext::Dict{Symbol,String})
	Templates.combos

	if keys(byext) in keys(Templates.combos)
		Templates.combos[keys(byext)]
	else
		@error "Can't recognise multi-file note" byext
	end

end



noteinfo(::Val, n) = nothing
function noteinfo(::Val{:url}, n)
	content = read(joinpath(n.srcdir, n.files[:url]), String)
	m = match(r"^URL=(.*)$"m, content)
	isnothing(m) && @error "Invalid `.url` file format, see https://fileinfo.com/extension/url" m
	url = m[1]
	sites = [
		"www.desmos.com" => "Desmos plot"
	]
	i = findfirst(sites) do (k, v)
		contains(url, k)
	end
	site = isnothing(i) ? "Permalink" : last(sites[i])
	(
		url=url,
		site=site,
	)
end

"""
	findnotes(srcdir)

Search `srcdir` for combinations of files in "notes" format
and return a dictionary of note info by name.
"""
function findnotes(srcdir)
	notes = Dict{String,Any}()
	for (root, dirs, files) in walkdir(srcdir)
		for file in files
			m = match(r"^(.*)\.note\.(\w+)$", file)
			isnothing(m) && continue

			name, ext = m

			if name ∉ keys(notes)
				categories = relpath(root, srcdir)
				categories = categories == "." ? String[] : splitpath(categories)
				notes[name] = (
					name=name,
					srcdir=root,
					categories,
					files=Dict{Symbol,String}(),
				)
			end

			notes[name].files[Symbol(ext)] = relpath(joinpath(root, file), notes[name].srcdir)
		end
	end

	isempty(notes) && @warn "Could not find any notes" srcdir pwd()

	Dict(k => let kind = notekind(v.files)
		(kind, v..., info=noteinfo(Val(kind), v))
	end for (k, v) in notes)
end


function totree(notes::Dict{String})
	paths = [(name => info) => info.categories for (name, info) in notes]
	flattenned = sort!(paths, by=last)
	totree(paths)
end

function totree(nodes::AbstractVector{<:Pair})
	tree = "root" => []
	stack = [tree]
	for (node, path) in nodes

		i = 1
		while i < min(length(path) + 1, length(stack))
			path[i] == stack[i + 1].first || break
			i += 1
		end

		while length(stack) > i
			sort!(stack[end].second, by=((name, v),) -> (v isa Vector, name))
			pop!(stack)
		end

		while length(stack) <= length(path)
			subtree = path[length(stack)] => []
			push!(stack[end].second, subtree)
			push!(stack, subtree)
		end

		push!(stack[end].second, node)

	end
	tree.second
end



function exportpermalinks(notes, path=joinpath(dirname(@__FILE__), "typst-template/permalinks.csv"))
	open(path, "w") do file
		@info "Exporting permalinks" path
		for name in sort!(collect(keys(notes)))
			write(file, name, ",", Templates.permalink(name), "\n")
		end
	end
end



function build(srcdir="notes/", targetdir="site/")
	srcdir = abspath(expanduser(srcdir))
	targetdir = abspath(expanduser(targetdir))
	@info "Building Zettelkasten" srcdir targetdir

	rm(targetdir, recursive=true, force=true)
	mkpath(targetdir)

	cp(joinpath(dirname(@__FILE__), "assets"), joinpath(targetdir, "assets"))

	notes = findnotes(srcdir)
	exportpermalinks(notes)

	# index page
	open(joinpath(targetdir, "index.html"), "w") do f
		# tree = reduce(vcat, last.(totree(notes)))
		tree = totree(notes)
		write(f, Templates.toc(tree))
	end

	# # individual notes
	for (name, note) in notes
		@info "Rendering note $(repr(name))"

		# create HTML page for note
		open(joinpath(targetdir, "$name.html"), "w") do f
			html = Templates.template(Val(note.kind), note)
			write(f, html)
		end

		# link auxiliary files into target directory
		# e.g., raw PDF files to be embedded in HTML pages
		for (ext, file) in note.files
			ext == :html && continue
			src = joinpath(note.srcdir, file)
			target = joinpath(targetdir, "$name.$ext")
			run(`ln $src $target`)
		end

	end
	nothing
end

end