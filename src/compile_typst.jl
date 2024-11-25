function compiletyp(pattern="")

	ps = Dict{String,Base.Process}()
	errs = Dict{String,IOBuffer}()
	paths = Dict{String,String}()
	for (name, note) in findnotes("notes/")
		note.kind == :typst_pdf || continue
		contains(name, pattern) || continue

		cd(note.srcdir) do
			src = note.files[:typ]
			paths[name] = joinpath(pwd(), src)
			@info "Compiling $name"
			errs[name] = IOBuffer()
			p = run(pipeline(`typst compile $src`, stderr=errs[name]), wait=false)
			ps[name] = p
		end
	end

	wait.(values(ps))

	for (name, p) in ps
		if !success(p)
			errmsg = String(take!(errs[name]))
			@error "Compilation failed for $name" path = paths[name]
			println(errmsg)
		end
	end

end