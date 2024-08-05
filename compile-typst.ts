import { walkSync } from "@std/fs"

export function log(verb: string, message = "", color = "white") {
	console.log(
		`%c${verb}%c ${message}`,
		`color: ${color}; font-weight: bold`,
		"",
	)
}

async function compileTypstFiles(
	directoryOrFile: string,
) {
	// Check if the input is a file or a directory
	const fileInfo = await Deno.stat(directoryOrFile)

	let typFiles: string[] = []

	if (fileInfo.isFile) {
		// If it's a file, check if it has the .typ extension
		if (directoryOrFile.endsWith(".typ")) {
			typFiles.push(directoryOrFile)
		} else {
			log("Error", `${directoryOrFile} is not a .typ file`, "red")
			return
		}
	} else if (fileInfo.isDirectory) {
		// If it's a directory, collect all *.typ files
		const walker = walkSync(directoryOrFile, { exts: ["typ"], includeDirs: false })
		typFiles = Array.from(walker).map((entry) => entry.path)
	} else {
		log("Error", `${directoryOrFile} is neither a file nor a directory`, "red")
		return
	}

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
