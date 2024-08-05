import { Project } from "@jollywatt/zettelbuilder"
import * as Jollywatt from "./theme.tsx"

const project = new Project({
	srcDir: "notes/",
	buildDir: "site/",

	copyPaths: {
		"src/assets": "assets",
	},
	renderers: Jollywatt.noteTypes,
	indexPage: Jollywatt.indexPage,
	include: [/\.note\./],
	noteId: (name) => name.replace(".note", ""),
})

const [command] = Deno.args

if (command === "build") project.build()
else if (command === "serve") {
	project.build()
	project.serve({ urlRoot: "notes", port: 2525 })
} else {
	project.build()
}
