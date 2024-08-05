#import "@preview/cetz:0.4.0"
#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *
#let up = math.op("up")

= Stereographic projection identites


#let fig = cetz.canvas(length: 3cm, {
	import cetz.draw: *
	set-style(
  mark: (fill: black, scale: 1),
  stroke: (thickness: 0.4pt, cap: "round"),
	angle: (
		fill: green.lighten(80%),
		stroke: (paint: green),
	),
	content: (padding: 4pt)
	)

	circle((0,0), radius: 1)

	let a = 90deg - 70deg
	cetz.angle.angle((0,0), (a, 1), (0,1), label: text(green, $theta$),
		radius: 1.5em, label-radius: 2.5em)
	cetz.angle.angle((0,-1), (a, 1), (0,1), label: text(green, $theta/2$),
		radius: 2em, label-radius: 3em)

	line((-1, 0), (1, 0), mark: (end: "stealth"))
	content((), $ hat(p) in RR^n $, anchor: "west")
	line((0, -1), (0, 1), mark: (end: "stealth"))
	content((), $ e_0 $, anchor: "south")

	set-style(mark: (anchor: "center", scale: 0.8))

	let x = calc.cos(a)
	let y = calc.sin(a)

	let w = 0.1
	let white-label = box.with(fill: white, inset: 3pt)
	floating({
		line((0,0), (a, 1), mark: (end: "o"))
		content((), $up(p) in SS^n$, anchor: "south-west")

		line((0,-1), (a, 1), stroke: (dash: "dashed"))
		content((x/(1 + y), 0), $p$, anchor: "north-west")
		mark((), (a, 1), symbol: "o")

		let z = 1
		line((x + z, y), (x + z + w, y), (x + z + w, -1), (x + z, -1))
		content((x + z + w, (y - 1)/2), white-label($ script(1 + cos(theta)) $), angle: 90deg)

	})
	let z = 1.3
	line((0, z), (0, z + w), (x, z + w), (x, z))
	content((x/2, z + w), box(fill: white, inset: 2pt, $ script(sin(theta)) $))
})

#figure(fig)


In one dimension:
$
up(x) = ((2x)/(1 + x^2), (1 - x^2)/(1 + x^2)) = (sin theta, cos theta)
$
Coordinate maps:
$
tan theta = (2x)/(1 - x^2) <==> tan theta/2 = x
$