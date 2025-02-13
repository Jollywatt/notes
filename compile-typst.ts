import { walkSync } from "@std/fs"

export function log(verb: string, message = "", color = "white") {
	console.log(
		`%c${verb}%c ${message}`,
		`color: ${color}; font-weight: bold`,
		"",
	)
}

async function compileTypstFiles(
	directory: string,
) {
	// Collect all *.typ files in the directory
	const walker = walkSync(directory, { exts: ["typ"], includeDirs: false })
	const typFiles = Array.from(walker).map((entry) => entry.path)

	// Compile all .typ files in parallel
	const tasks = typFiles.map(async (file: string): Promise<void> => {
		const command = new Deno.Command("typst", {
			args: ["compile", file],
			stderr: "piped",
		})

		const process = command.spawn()
		const { code, stdout, stderr } = await command.output()

		if (code === 0) {
			log("Compiled", file, "green")
		} else {
			const error = new TextDecoder().decode(stderr)
			log("Error", `compiling typst file ${file}`, "red")
			console.error(error)
		}
	})

	await Promise.all(tasks)
}

if (import.meta.main && Deno.args.length == 1) {
	const directory = Deno.args[0]
	compileTypstFiles(directory)
} else {
	throw new Error(
		"Must be called with zero or one argument: directory to search",
	)
}
