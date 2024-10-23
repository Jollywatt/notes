#!/usr/bin/env julia

if !isdefined(Main, :Revise)
	const includet = include
end

includet("templates.jl")

cd(dirname(@__FILE__))
SOURCE_DIR = "../notes"
TARGET_DIR = "../site"


function multinote(byext::Dict{Symbol,String})

	combos = Dict(
		Set([:typ, :pdf]) => (file=:pdf, src=:typ),
		Set([:tex, :pdf]) => (file=:pdf, src=:tex),
		Set([:jl, :html]) => (file=:html, src=:jl),
		Set([:jl]) => (file=:jl, src=nothing),
	)

	if keys(byext) in keys(combos)
		roles = combos[keys(byext)]
		byrole = map(roles) do ext
			get(byext, ext, nothing)
		end
		(kind=roles.file, srckind=roles.src, byrole...)
	else
		@error "Can't recognise multi-file note" byext
	end

end

function findnotes(srcdir)
	filesbyname = Dict{String,Dict{Symbol,String}}()

	for (root, dirs, files) in walkdir(srcdir)
		filter!(!startswith("."), files)
		for file in files

			m = match(r"^(.*)\.note\.(\w+)$", file)
			isnothing(m) && continue
			name, ext = m
			path = joinpath(root, file)

			if name ∉ keys(filesbyname)
				filesbyname[name] = Dict()
			end
			filesbyname[name][Symbol(ext)] = path
		end
	end

	Dict(name => multinote(files) for (name, files) in filesbyname)
end



function totree(notes::Dict{String,<:NamedTuple})
	paths = [(name => info) => splitpath(dirname(info.file)) for (name, info) in notes]
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



"""
Make a link of the source file in current directory,
with `.note.` removed from the filename.
"""
function tohere(srcfile::String)
	dest = replace(basename(srcfile), ".note."=>".")
	run(`ln $srcfile $dest`)
	dest
end




function rendernote(::Val{:pdf}, name, note)
	tohere(note.src)
	pdf = tohere(note.file)
	open("$name.html", "w") do f
		html = Templates.pdf(
			title=name,
			file=pdf,
			meta=note
		)
		write(f, html)
	end
end

function rendernote(::Val{:jl}, name, note)
	file = tohere(note.file)
	open("$name.html", "w") do f
		html = Templates.julia(
			title=name,
			code=read(note.file, String),
			meta=note
		)
		write(f, html)
	end
end

function rendernote(::Val{:html}, name, note)
	tohere(note.file)
end

function exportpermalinks(notes)
	open("typst-template/permalinks.csv", "w") do file
		for name in sort!(collect(keys(notes)))
			write(file, name, ",", Templates.permalink(name), "\n")
		end
	end
end



function build(srcdir="../notes", targetdir="../site")
	@info "Building Zettelkasten"

	rm(targetdir, recursive=true, force=true)
	mkpath(targetdir)

	cp("assets", joinpath(targetdir, "assets"))

	notes = findnotes(srcdir)

	cd(targetdir) do
		# index page
		tree = totree(notes)
		for i in splitpath(srcdir) # strip srcdir path prefix
			tree = tree[1].second
		end
		open("index.html", "w") do f
			write(f, Templates.toc(tree))
		end

		# individual notes
		for (name, note) in notes
			println("Rendering note ", repr(name))
			rendernote(Val(note.kind), name, note)
		end
	end

	exportpermalinks(notes)

	nothing
end


if !isinteractive()
	build()
end
