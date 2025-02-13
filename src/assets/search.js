window.addEventListener("load", () => {
	const filterEl = document.getElementById("search-field")
	const tocEl = document.getElementById("toc")
	const tocItems = tocEl.querySelectorAll("li")

	document.getElementById("search-clear").addEventListener("click", () => {
		filterEl.value = ""
		applyFilters("")
		const url = `${location.origin}${location.pathname}`
		window.history.pushState({ path: url }, "", url)
		window.dispatchEvent(new Event("search-input"))
	})

	window.addEventListener("keydown", (event) => {
		if (event.metaKey) return
		if (event.ctrlKey) return
		if (/^\p{Ll}$/u.test(event.key)) filterEl.focus()
	})

	function applyFilters(string) {

		string = string.trim()

		if (string) {
			tocEl.classList.remove("show")
		} else {
			tocEl.classList.add("show")
			return
		}

		const tokens = string.toLowerCase().split(/\s+/)
		for (const item of tocItems) {
			const itemText = item.getAttribute("data-folder") ?? item.innerText

			// exact match
			if (string === itemText) {
				tocItems.forEach((item) => item.classList.remove("show"))
				item.classList.add("show")
				return
			}

			const hit = tokens.some((token) =>
				itemText.toLowerCase().indexOf(token) >= 0
			)
			if (hit) {
				item.classList.add("show")
			} else {
				item.classList.remove("show")
			}
		}

	}

	filterEl.addEventListener("input", (event) => {
		applyFilters(filterEl.value)
		window.dispatchEvent(new Event("search-input"))
	})

	for (const item of tocItems) {
		const foldername = item.getAttribute("data-folder")
		if (foldername !== null) {
			item.querySelector("& > span").addEventListener("click", (event) => {
				applyFilters(filterEl.value = foldername)
				window.dispatchEvent(new Event("search-input"))
				event.stopPropagation()
				const url = `${location.origin}${location.pathname}?s=${foldername}`
				window.history.pushState({ path: url }, "", url)
			})
		}
	}

	const query = new URLSearchParams(location.search).get("s")
	if (query) {
		filterEl.value = query
		applyFilters(query)
	}
})
