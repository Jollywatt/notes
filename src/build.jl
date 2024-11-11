#!/usr/bin/env julia

if !isdefined(Main, :Revise)
	const includet = include
end

includet("templates.jl")


"""
Infer the type or kind of a note by which file extensions are present.
For example, a pair of `*.tex` and `*.pdf` files with the same name form a LaTeX note.
"""
function notekind(byext::Dict{Symbol,String})

	combos = Dict(
		Set([:typ, :pdf]) => :typst_pdf,
		Set([:tex, :pdf]) => :latex_pdf,
		Set([:jl, :html]) => :pluto_notebook,
		Set([:jl]) => :julia_code,
		Set([:desmos]) => :desmos_link,
	)

	if keys(byext) in keys(combos)
		combos[keys(byext)]
	else
		@error "Can't recognise multi-file note" byext
	end

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

	Dict(k => (kind = notekind(v.files), v...) for (k, v) in notes)
end


function totree(notes::Dict{String})
	paths = [(name => info) => info.categories for (name, info) in notes]
	flattenned = sort!(paths, by=last)
	totree(flattenned)
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


template(::Val{:typst_pdf}, n) = Templates.pdf(n)
template(::Val{:latex_pdf}, n) = Templates.pdf(n)
template(::Val{:pluto_notebook}, n) = Templates.html(n, read(joinpath(n.srcdir, n.files[:html]), String))
template(::Val{:julia_code}, n) = Templates.code(n, read(joinpath(n.srcdir, n.files[:jl]), String), :julia)
template(::Val{:desmos_link}, n) = Templates.desmos(n, read(joinpath(n.srcdir, n.files[:desmos]), String))
template(::Val, n) = @warn "Skipping note" n
template(::Val{:desmos_link}, n) = Templates.desmos(n, read(joinpath(n.srcdir, n.files[:desmos]), String))


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
			html = template(Val(note.kind), note)
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


if !isinteractive()
	build()
end
