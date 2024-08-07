#!/usr/bin/env julia
using Revise

includet("build.jl")

const LAST_TIME = Ref(0.0)

function watch()
	Revise.entr(["../notes", "../src"], postpone=true) do
		time() - LAST_TIME[] < 1 && return
		build()
		LAST_TIME[] = time()
	end
end

if !isinteractive()
	watch()
end
