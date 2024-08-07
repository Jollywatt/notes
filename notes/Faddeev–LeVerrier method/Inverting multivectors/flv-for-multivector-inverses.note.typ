#import "@local/notes:0.1.0"

#show: notes.style

= The minimum number of steps required for the Faddeev--LeVerrier multivector inverse algorithm

#let data = csv("steps-by-n-k.csv", row-type: dictionary)

#let max-dim = calc.max(..data.map(row => int(row.at("n"))))

#show figure: fig => style(styles => {
	let fig-width = measure(fig.body, styles).width
	show figure.caption: box.with(width: fig-width)
	fig
})

#let clos(it) = $lr(⟦it⟧)$
#let GL = "GL"

The @flv-derivation[Faddeev--LeVerrier inverse algorithm] may be used to find the inverse of an $n times n$ matrix $A$ in exactly $n$ steps (with one matrix multiplication per step).
As input, the algorithm takes the matrix $A$ and the dimension $n$.
The algorithm succeeds if and only if an inverse exists.


This method can be used to invert elements in a geometric algebra $cal(A)$ by considering a linear representation $rho : cal(A) -> GL(n)$.

For best performance, we would like to know the minimum number of steps required by the algorithm for a given multivector.

== Trivial cases

Trivially, real scalars admit a one-dimensional linear representation, and the method takes a single step.

If an element $A$ has a scalar square $A^2 in RR$, then its inverse is trivially $A^(-1) = A slash A^2$.
Additionally, since $A^(2n) in RR$ and $A^(2n + 1) prop A$, the algebraic closure of $A$ is $clos(A) = RR plus.circle "span"{A}$ and hence there exists a two dimensional representation $rho : clos(A) -> GL(2)$.
Any $k$-vector with $k in {0, 1, d - 1, d}$ has scalar square and hence can be inverted in two steps.

== General cases

Any geometric algebra over a $d$-dimensional vector space is itself $2^d$-dimensional, so by the existence of the standard linear representation we know the algorithm works in $2^d$ steps.
However, this can be reduced to $2^ceil(d slash 2)$ for a general $d$-dimensional multivector @prodanov2024.

== From numerical simulations

We have "seen" that even multivectors may be inverted in $2^floor(d slash 2)$ steps (tested for non-degenerate geometric algebras in $<= 13$ dimensions).
Furthermore, for homogeneous multivectors of a given grade, the minimum number of steps is shown in @patterns.

#figure({
	let datum(val, ..args) = table.cell(
		..args,
		fill: gradient.linear(..color.map.spectral)
			.sample(calc.log(int(val), base: 2)/7*100%)
	)[#val]
	set text(0.8em)
	table(
		columns: (6mm,)*(max-dim + 2) + (8mm,)*2,
		rows: (6mm,)*(max-dim + 1),
		align: center + horizon,

		table.cell(inset: 0pt, {
			place(line(length: 100%*calc.sqrt(2), angle: 45deg))
			place(pad(2.2pt, $d$), bottom + left)
			place(pad(2.2pt, $k$), top + right)
		}),
		..range(max-dim + 1).map(i => (
			table.cell(x: i + 1, y: 0, fill: black, text(white)[#i]),
			table.cell(x: 0, y: i + 1, fill: black, text(white)[#i]),
		)).flatten(),
		..data.map(((n, k, steps)) => {
			datum(steps, x: int(k) + 1, y: int(n) + 1)
		}),

		table.cell(x: max-dim + 2, y: 0, [full]),
		..range(max-dim	+ 1).map(i => {
			datum(calc.pow(2, calc.ceil(i/2)), x: max-dim + 2, y: i + 1)
		}),

		table.cell(x: max-dim + 3, y: 0, [even]),
		..range(max-dim	+ 1).map(i => {
			datum(calc.pow(2, calc.floor(i/2)), x: max-dim + 3, y: i + 1)
		}),
	)},
	caption: [
		Minimum number of steps required to invert a $d$-dimensional $k$-vector (for any non-degenerate metric).
	],
) <patterns>

#notes.references()
