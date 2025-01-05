import { Minimal, Project } from "zettelsite"
import {
	build,
	ExternalURLNote,
	JuliaCodeNote,
	LaTeXNote,
	PlutoNotebookNote,
	TypstNote,
} from "./theme.tsx"

const project = new Project({
	srcdir: "notes/",
	sitedir: "site/",
	noteTypes: [
		TypstNote,
		LaTeXNote,
		JuliaCodeNote,
		PlutoNotebookNote,
		ExternalURLNote,
	],
	builder: build,
})

const [command] = Deno.args

if (command === "build") project.build()
else if (command === "serve") {
	project.build()
	project.serve()
}
