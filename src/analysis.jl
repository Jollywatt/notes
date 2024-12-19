function extractlinks(note)
	if note.kind == :typst_pdf
		file = joinpath(note.srcdir, note.files[:typ])
		src = read(file, String)
		src = replace(src, r"^#import .*$"m=>"")
		hits = eachmatch(r"@([\w-]+)\b", src)
		names = getindex.(hits, 1)
	else
		String[]
	end
end

function linkgraph(notes)
	allnames = keys(notes)
	arrivals = Dict{String,Vector{String}}()
	departures = Dict{String,Vector{String}}()
	for (srcname, note) in notes
		destnames = extractlinks(note)
		intersect!(destnames, allnames)
		if !isempty(destnames)
			departures[srcname] = destnames
			for destname in destnames
				if destname ∉ keys(arrivals)
					arrivals[destname] = String[]
				end
				push!(arrivals[destname], srcname)
			end
		end
	end
	(; arrivals, departures)
end

function addlinks(graph, note::NamedTuple)
	(
		note...,
		crossrefs=(
			arrivals=get(graph.arrivals, note.name, String[]),
			departures=get(graph.departures, note.name, String[]),
		),
	)
end

addlinks(graph, notes::Dict) = Dict(
	k => addlinks(graph, v) for (k, v) in notes
)
