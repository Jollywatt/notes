#!/usr/bin/env julia

if !isdefined(Main, :Revise)
	const includet = include
end

includet("templates.jl")


function clean()
	rm("site", recursive=true, force=true)
end


function multinote(byext::Dict{Symbol,String})

	combos = Dict(
		Set([:typ, :pdf]) => (file=:pdf, src=:typ),
		Set([:jl, :html]) => (file=:html, src=:jl),
		Set([:jl]) => (file=:jl, src=nothing),
	)

	if keys(byext) in keys(combos)
		roles = combos[keys(byext)]
		byrole = map(roles) do ext
			get(byext, ext, nothing)
		end
		(kind=roles.file, byrole...)
	else
		@error "Can't recognise multi-file note" byext
	end

end


function insitedir(srcfile)
	dest = replace(basename(srcfile), ".note."=>".")
	run(`ln $srcfile site/$dest`)
	dest
end


function findnotes()
	filesbyname = Dict{String,Dict{Symbol,String}}()

	for (root, dirs, files) in walkdir("notes/")
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


function rendernote(::Val{:pdf}, name, note)
	insitedir(note.src)
	pdf = insitedir(note.file)
	open("site/$name.html", "w") do f
		html = Templates.pdf(
			title=name,
			file=pdf,
		)
		write(f, html)
	end
end

function rendernote(::Val{:jl}, name, note)
	file = insitedir(note.file)
	open("site/$name.html", "w") do f
		html = Templates.julia(
			title=name,
			code=read(joinpath("site", file), String),
		)
		write(f, html)
	end
end

function rendernote(::Val{:html}, name, note)
	insitedir(note.file)
end

function exportpermalinks(notes)
	open("typst-template/permalinks.csv", "w") do file
		for name in sort!(collect(keys(notes)))
			write(file, name, ",", Templates.permalink(name), "\n")
		end
	end
end

function build()
	@info "Building Zettelkasten"

	rm("site", recursive=true, force=true)
	mkpath("site")

	cp("assets", "site/assets")

	notes = findnotes()

	for (name, note) in notes
		println("Rendering note ", repr(name))
		rendernote(Val(note.kind), name, note)
	end

	cd("site") do
		open("index.html", "w") do f
			write(f, Templates.toc(notes))
		end
	end

	exportpermalinks(notes)

	nothing
end


if !isinteractive()
	build()
end
