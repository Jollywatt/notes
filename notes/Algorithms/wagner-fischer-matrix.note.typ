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
		} else if matrix.at(i - 1).at(j) < matrix.at(i).at(j) {
			i -= 1
			steps.push((type: "delete", i: i, j: j))

		} else if matrix.at(i).at(j - 1) < matrix.at(i).at(j) {
			j -= 1
			steps.push((type: "insert", i: i, j: j))

		} else {
			let zero-cost = matrix.at(i - 1).at(j - 1) == matrix.at(i).at(j)
			i -= 1
			j -= 1
			if zero-cost {
				steps.push((type: "identity", i: i, j: j))
			} else {
				steps.push((type: "swap", i: i, j: j))
			}
		}
	}
	return steps.rev()
}


#let wagner-fischer-table(a, b) = {
	let d = wagner-fischer-matrix(a, b)
	let path = find-path(d).map(step => (step.i, step.j))
	table(
		columns: b.len() + 1,
		fill: (x, y) => {
			if x*y == 0 { teal }
			else if (y - 1, x - 1) in path { yellow }
			else { none }
		},
		none, ..b.clusters(),
		..a.clusters().zip(d).map(((letter, row)) => (letter, ..row))
			.flatten().map(i => [#i])
	)
}


#wagner-fischer-table("abc ", "axcde ")

#find-path(wagner-fischer-matrix("abc ", "aX "))
