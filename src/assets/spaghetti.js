function getAnchors() {
	const els = document.querySelectorAll(".anchor")
	window.anchors = {}
	window.connections = {}
	for (const el of els) {
		const name = el.getAttribute("data-note-name")
		window.anchors[name] = el
		window.connections[name] = JSON.parse(el.getAttribute("data-connections"))
	}
}

function curve(p1, p2, hash) {
	const [x1, y1] = p1
	const [x2, y2] = p2
	ctx.strokeStyle = '#8884'
	ctx.lineWidth = 3

	const r = new TextEncoder().encode(hash).reduce((a, b) => a * b) % 100
	const d = -Math.sqrt((50 + r)*Math.abs(y1 - y2))

	ctx.beginPath()
	ctx.moveTo(x1, y1)
	ctx.bezierCurveTo(x1 + d, y1, x2 + d, y2, x2, y2)
	ctx.stroke()
}

function createCanavs() {
	const canvas = document.createElement('canvas')
	window.ctx = canvas.getContext('2d')
	window.ratio = window.devicePixelRatio || 1

	function resizeCanvas() {
		const width = document.documentElement.scrollWidth
		const height = document.documentElement.scrollHeight

		canvas.width = width * ratio
		canvas.height = height * ratio

		canvas.style.width = width + 'px'
		canvas.style.height = height + 'px'

		plotConnections()
	}
	
	resizeCanvas()
	window.addEventListener('resize', resizeCanvas)

	// Apply styles to position the canvas
	canvas.style.position = 'absolute'
	canvas.style.top = '0'
	canvas.style.left = '0'
	canvas.style.pointerEvents = 'none' // Prevent interactions
	
	document.body.appendChild(canvas)

}

function anchorPoint(el) {
	const rect = el.getBoundingClientRect()
	return [
		(rect.left + window.scrollX)*window.ratio - 10,
		(rect.y + rect.height/2 + 1 + window.scrollY)*window.ratio
	]
}

function plotConnections() {
	ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)
	for (const [name, anchor] of Object.entries(anchors)) {
		const from = anchorPoint(anchor)
		if (anchor.offsetParent == null) continue
		for (const toName of connections[name]) {
			const toAnchor = anchors[toName]
			if (toAnchor.offsetParent == null) continue
			const to = anchorPoint(toAnchor)
			console.log(toName, to)
			curve(from, to, toName)
		}
	}
}

window.addEventListener("load", () => {
	getAnchors()

	window.addEventListener("search-input", () => {
		plotConnections()
	})

	createCanavs()
})
