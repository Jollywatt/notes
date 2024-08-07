using HTTP
using FileWatching

function serve(; serverroot="./site", clientroot="/notes", port=8000)

	HTTP.listen("127.0.0.1", port) do http::HTTP.Stream

		path = http.message.target

		if startswith(path, clientroot)
			path = serverroot*path[1 + length(clientroot):end]
		else
			HTTP.setstatus(http, 404)
			HTTP.startwrite(http)
			write(http, "Path must start with root $clientroot.")
			return
		end

		if isfile("$path.html")
			path = "$path.html"
		elseif isdir(path)
			path = joinpath(path, "index.html")
		end

		if isfile(path)
			@info "Serving" path
			HTTP.setstatus(http, 200)
			HTTP.startwrite(http)
			write(http, read(path))
		else
			@warn "Not found" path
			HTTP.setstatus(http, 404)
			HTTP.startwrite(http)
			write(http, "not found: $path")
		end
	end

end

