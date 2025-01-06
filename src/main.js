import { Minimal, Project } from "zettelbuilder"
import {
	build,
	ExternalURLNote,
	JuliaCodeNote,
	LaTeXNote,
	PlutoNotebookNote,
	TypstNote,
} from "./theme.tsx"

const project = new Project({
	srcDir: "notes/",
	urlRoot: "notes",
	buildDir: "site/",
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
} else {
	project.build()
}