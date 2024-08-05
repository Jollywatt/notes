#import "@local/notes:0.1.0"
#show: notes.style

#import "@preview/cetz:0.3.4"

= Midpoint of stereographic projection of antipedal points

*Theorem.* Let $A$ and $B$ be opposite points on a circle, and let $a$ and $b$ the stereographic projection of $A$ and $B$ into the $x$-axis through the south pole $S$.
Then the midpoint $a$ and $b$ is the point $c$ where the perpendicular to $A B$ through the south pole meets the $x$-axis.

#let fig = cetz.canvas(length: 2.5cm, {

	import cetz.draw
	let pointlabel(coord, label) = draw.on-layer(1, draw.content(coord, circle($ label $, inset: 1pt, fill: white.transparentize(10%))))

	draw.circle((0,0))

	let A = 30deg
	let B = 180deg + A
	let a = calc.cos(A)/(1 + calc.sin(A))
	let b = -1/a
	let S = (0,-1)

	pointlabel((0,0), $O$)
	pointlabel(S, $S$)

	let (w, h) = (calc.max(calc.abs(a), calc.abs(b)), 1)
	draw.group({
		draw.set-style(stroke: (thickness: 0.5pt, dash: "dashed"))
		draw.line((-w,0), (+w,0))
		draw.line((0,-h), (0,+h))
	})

	draw.line((A,1), (A,-1), name: "diagonal")
	// let rr = 1.2
	// draw.content((A,+rr), $A$)
	// draw.content((A,-rr), $B$)
	pointlabel((A,+1), $A$)
	pointlabel((A,-1), $B$)

	draw.group({
		draw.set-style(stroke: teal)
		draw.line(S, (A,1), )
		draw.line(S, (B,1))
		draw.line(S, (a,0), )
		draw.line(S, (b,0), )
		pointlabel((a,0), $a$)
		pointlabel((b,0), $b$)
	})

	let m = (a - 1/a)/2
	draw.line(S, (m,0), stroke: blue, name: "midpoint-line")

	draw.intersections("mid", "diagonal", "midpoint-line")
	pointlabel("mid.0", $C$)
	pointlabel((m,0), $c$)
})

#figure(fig)

#let theline(stroke) = box(line(stroke: stroke), baseline: -.25em)

*Proof.*
Because the line #theline(blue) is perpendicular to the hypotenuse #theline(black), it cuts the right triangle $A B S$ into two other right triangles $A S C$ and $S B C$.
All three triangles are similar.
Similarly, the line $O S$ splits the right triangle $b a S$ into $S a O$ and $b S O$, all of which are similar.
Furthermore, since $A O S$ is isosceles, triangles $A B S$ and $S a O$ share angles and so are also similar.
Both groups of similar triangles are therefore similar to each other, and in particular, triangles $b S O$ and $S B C$ are similar, meaning $b c S$ is isosceles.
The two isosceles triangles share a leg, so $b c = S c = a c$ and hence $c$ is the midpoint of $a b$.