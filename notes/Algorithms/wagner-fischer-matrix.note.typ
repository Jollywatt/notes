#import "@local/notes:0.1.0"
#show: notes.style

= Wagner-Fischer algorithm for finding string edit paths

#let wagner-fischer-matrix(a, b) = {
	let d = ((0,)*b.len(),)*a.len()
	for i in range(a.len()) { d.at(i).at(0) = i }
	for j in range(b.len()) { d.at(0).at(j) = j }
	for i in range(1, a.len()) {
		for j in range(1, b.len()) {
			let substitution-cost = int(a.at(i - 1) != b.at(j - 1))
			d.at(i).at(j) = calc.min(
				d.at(i - 1).at(j) + 1,
				d.at(i).at(j - 1) + 1,
				d.at(i - 1).at(j - 1) + substitution-cost,
			)
		}
	}
	d
}

#let find-path(matrix) = {
	let i = matrix.len() - 1
	let j = matrix.at(0).len() - 1
	let steps = ()
	while i + j > 0 {
		if false {
		} else if matrix.at(i).at(j - 1) < matrix.at(i).at(j) {
			j -= 1
			steps.push((op: "insert", i: i, j: j))

		} else if matrix.at(i - 1).at(j) < matrix.at(i).at(j) {
			i -= 1
			steps.push((op: "delete", i: i, j: j))

		} else {
			let zero-cost = matrix.at(i - 1).at(j - 1) == matrix.at(i).at(j)
			i -= 1
			j -= 1
			if zero-cost {
				steps.push((op: "identity", i: i, j: j))
			} else {
				steps.push((op: "swap", i: i, j: j))
			}
		}
	}
	return steps.rev()
}

#let colors = (
	insert: green,
	delete: red,
	swap: orange,
	identity: gray,
)

#let wagner-fischer-table(s, t) = {
	let a = s.clusters()
	let b = t.clusters()
	a.push($diameter$)
	b.push($diameter$)
	let d = wagner-fischer-matrix(a, b)
	let path = find-path(d)
	let coords = path.map(step => (step.i, step.j))
	let size = 1.6em

	rect(["#s" #sym.arrow "#t"])
	
	table(
		columns: (size,)*(b.len() + 1),
		rows: size,
		align: center + bottom,
		fill: (x, y) => {
			if x*y == 0 { return teal }
			let i = coords.position(c => c == (y - 1, x - 1))
			if i != none {
				colors.at(path.at(i).op)
			}
		},
		none, ..b,
		..a.zip(d)
			.map(((letter, row)) => (letter, ..row))
			.flatten().map(i => [#i]),
	)

	let steps = path.map(((op, i, j)) => {
		let t = if op == "insert" {
			sym.plus + b.at(j)
		} else if op == "swap" {
			a.at(i) + "/" + b.at(j)
		} else if op == "delete" {
			sym.minus + a.at(i)
		} else {
			a.at(i)
		}
		text(colors.at(op), t)
	}).join[, ]

	rect(steps)
}

#wagner-fischer-table("Mondays", "Wednesday")


First form a matrix $A$ whose rows correspond to letters in the source $S$ string (length $m$) and columns to letters in the $T$ target (length $n$).

Initialise an $m times n$ matrix as
$
A = mat(
	0, 1, dots, n;
	1, 0, dots, 0;
	dots.v, dots.v, dots.down, dots.v;
	m, 0, dots, 0;
)
$
and apply the rule
$
A_(i, j) &= min{
		A_((i - 1),j) + 1,
		A_(i,(j - 1)) + 1,
		A_((i - 1),(j - 1)) + s
	} \
s &= cases(0 "if" S_i = T_j, 1 "otherwise")
$
in order of increasing $i, j > 1$.

Then, form a path through the entries of $A$, starting from the $(m + 1, n + 1)$ position (bottom right), moving one step to the neighboring cell of minimum value until the $(1, 1)$ position (top left) is reached.

Left steps $arrow.l$ correspond to #text(green)[insertions], and upward steps $arrow.t$ correspond to #text(red)[deletions].
Diagonal steps $arrow.tl$ correspond to accepting the current character when the cell values are equal, or #text(orange)[substituting] characters otherwise.

Finally, moving along this path in the $arrow.br$ direction, you can read off the character operations which map the source string to the target.

== More examples!

Generated with the above algorithm in @wagner-fischer-matrix[this document]'s Typst source code.


#wagner-fischer-table("For Wednesday", "From Monday")
\
#wagner-fischer-table("Typst", "Typeset")
\
#wagner-fischer-table("ABC@YZ", "AB@XYZ")
