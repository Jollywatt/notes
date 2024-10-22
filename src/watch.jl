#!/usr/bin/env julia

using Revise

includet("build.jl")

const LAST_TIME = Ref(0.0)

function watch()
	Revise.entr(["../notes", "../src"], postpone=true) do
		time() - LAST_TIME[] < 1 && return
		try
			build()
		catch error
		end
		LAST_TIME[] = time()
		println("Watching...")
	end
end

if !isinteractive()
	watch()
end
