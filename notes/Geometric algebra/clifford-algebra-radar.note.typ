#import "@preview/fletcher:0.5.1": diagram, node, edge
#set page(width: auto, height: auto, margin: 10mm)


#let field-from-p-q = (
	$RR$, $RR^2$, $RR$, $CC$, $HH$, $HH^2$, $HH$, $CC$,
)
#let dim(n, i) = {
	let m = (
		n/2,
		(n - 1)/2,
		n/2,
		(n - 1)/2,
		(n - 2)/2,
		(n - 3)/2,
		(n - 2)/2,
		(n - 1)/2,
	).at(calc.rem(i, 8))
	calc.pow(2, int(m))
}
#let coord(r, i) = {
	let θ = 90deg - i/8*360deg
	(to: (0,0), rel: (θ, r*12mm))
}

#let Cl(p, q) = $"Cl"_(#p, #q)$
#let s = (dash: "solid", cap: "round", thickness: 0.3pt, paint: luma(80%))

#diagram(
	for n in range(8 + 1) {
		for p in range(n + 1) {
			let q = n - p
			let d = dim(p + q, p - q)
			let F = field-from-p-q.at(calc.rem(p - q, 8))
			let repr = text(0.8em, teal.darken(20%), $#F (#d)$)

			let cl = if p >= 4 or q >= 4 {
				if p == q and (p, q) != (4, 4) {
					Cl(p, q)
				} else if p > q {
					$#Cl(p, q) tilde.equiv #Cl(p - 4, q + 4)$
				}
			} else {
				Cl(p, q)
			}
			if cl != none {
				node(coord(p + q, p - q))[#cl \ #repr]
			}

		}


		node((0,0), shape: circle, fill: none, stroke: s, radius: n*12mm, snap: false, layer: -1)

	},
	for i in range(8) {
		let a = coord(9.4 + if i in (2, 6) { 1 } else { 0 }, i)
		node(a, $p - q = #i$, fill: none, outset: 7pt)
		edge(a, (0,0), stroke: s, field-from-p-q.at(i), label-pos: 0, center)
	}

)