#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

= (Anti)centralizers

Let $G$ be an associative algebra (for example, a geometric algebra).
For any invertible element $a in G$, define the _(anti)commuting part_ of $b in G$ as
$ cen(plus.minus, a, b) := 1/2 (b plus.minus a b a^(-1)). $
#notes.result-box[
	*Lemma.*
	+ $a b = plus.minus b a ==> b = cen(plus.minus, a, b)$
	+ $a b = plus.minus b a <== b = cen(plus.minus, a, b)$ if $a^2 b = b a^2$
]
*Proof.*
Assuming $a b = plus.minus b a$ then $cen(plus.minus, a, b) = 1/2 (b + b a a^(-1)) = b$.
Going the other way, $a cen(plus.minus, a, b) = 1/2 (a b plus.minus a^2 b a^(-1)) = plus.minus 1/2 (plus.minus a b + b a) = plus.minus cen(plus.minus, a, b) a$, but only provided $a^2 b a^(-1) = b a$.
#sym.qed

#block(stroke: yellow, inset: 1em)[
	From now on, assume the element $a$ has a square $a^2$ which commutes with everything.
]

If $a^2$ is in the centre of $G$, define the _(anti)centralizer_ of a given element $a in G$ to be the vector space
$ cen(plus.minus, a, G) := {cen(plus.minus, a, b) | b in G} = { b in G | a b = plus.minus b a } $
of elements which (anti)commute with $a$.

#notes.result-box[
	// *Lemma.* For any $a in G$, the map $b |-> b^plus.minus := 1/2 (b plus.minus a b a^(-1))$ is a projection $G -> cen(plus.minus, a, G)$.
	*Lemma.* The maps $cen(plus.minus, a) : G -> cen(plus.minus, a, G)$ are projections so that $G = cen(+, a, G) plus.circle cen(-, a, G)$.
]
*Proof.*
The maps $cen(plus.minus, a, b)$ are clearly linear in $b in G$.
They are idempotent since
$ cen(plus.minus, a, cen(plus.minus, a, b)) = 1/2 ( cen(plus.minus, a, b) plus.minus a cen(plus.minus, a, b) a^(-1) ) = 1/4 ( b plus.minus 2 a b a^(-1) plus.minus a^2 b a^(-2) ) = 1/2 (b plus.minus a b a^(-1)) = cen(plus.minus, a, b) $
and are hence projections.
Finally, since $cen(+, a, b) + cen(-, a, b) = b$, any element is of the form $b = b^+ + b^-$ where $b^plus.minus in cen(plus.minus, a, G)$.
#sym.qed

#notes.result-box[
	*Lemma.*
	$G = cen(+, a, G) plus.circle cen(-, a, G)$ forms a $ZZ_2$-grading: elements multiply under the geometric product according to the multiplication table:
	#let even = $cen(+, a, G)$
	#let odd = $cen(-, a, G)$
	#align(center, grid(
		align: center + horizon,
		columns: 3,
		inset: (x: 4pt, y: 8pt),
		grid.vline(x: 1),
		grid.hline(y: 1),
		none, even,  odd,
		even, even,  odd,
		odd,  odd,  even,
	))
]
*Proof.*
Let $b in cen(+, a, G)$ and $c in cen(plus.minus, a, G)$. Then
$a b c = b a c = plus.minus b c a$ so $b c in cen(plus.minus, a, G)$.
This shows the first row/column of the table.
Now if $b in cen(-, a, G)$ with $c$ the same, we have 
$a b c = - b a c = minus.plus b c a$ so $b c in cen(minus.plus, a, G)$.
This completes the table.
#sym.qed
