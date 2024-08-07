#!/usr/bin/env julia
using BetterFileWatching: watch_folder
include("build.jl")

function watch(path=get(ARGS, 1, "notes/"))
	while true
		@info "Watching for changes" path
		watch_folder(path)
		build()
		sleep(0.1)
	end
end

if !isinteractive()
	watch()
end
