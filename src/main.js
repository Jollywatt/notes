import { Minimal, Project } from "zettelsite"
import { build } from "./theme.tsx"

const project = new Project({
	srcdir: "notes/",
	sitedir: "site/",
	noteTypes: {
		"markdown": ["md"],
		"typst pdf": ["typ", "pdf"],
		"latex pdf": ["tex", "pdf"],
		"pluto notebook": ["jl", "html"],
		"julia code": ["jl"],
		"plain text": ["txt"],
		"external link": ["url"],
	},
	builder: build,
})

const [command] = Deno.args

if (command === "build") project.build()
else if (command === "serve") {
	project.build()
	project.serve()
}
