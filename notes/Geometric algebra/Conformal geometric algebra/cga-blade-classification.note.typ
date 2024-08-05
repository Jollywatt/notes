#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let ((eo, eoo), (Xeo, Xeoo)) = if true {
	// Leo's old notation
	(($cal(o)$, $oo$), ($X_cal(o)$, $X_oo$))
} else {
	// Joan's preferred notation
	(($n_0$, $n_oo$), ($X_0$, $X_oo$))
}

#show math.frac: it => {
	if it.num == [1] and it.denom == [2] {
		math.inline(it)
	} else {
		it
	}
}

#show enum: it => {
	show math.equation.where(block: true): box.with(width: 100%)
	it
}

#let eqnum(body) = {
	set math.equation(numbering: "(1)")
	body
}

#let casebox(body) = box(body, outset: .4em, fill: yellow.lighten(50%)) + linebreak()
#let result(body) = text(green.darken(20%), body)
#let span(..args) = $op("span"){#args.pos().join($, $)}$

#let trans(p, ..args) = {
	if args.pos().len() == 1 { $trans(#p)[#args.pos().at(0)]$ }
	else { $mono(T)_#p$ }
}

= Classification of blades in @cga[CGA]

Consider an arbitrary $k$-blade in a conformal geometric algebra $Cl(n + 1, 1) tilde.equiv RR^(n + 2)$, assuming a basis ${eo, e_1, ..., e_n, eoo}$ where $eo^2 = eoo^2 = 0$ and $eo dot eoo = -1$.

#notes.result-box[
*Result.* Any $k$-blade $X$ is of exactly one of the forms
$
X = cases(
	trans(bold(p), bold(E)),
	trans(bold(p), bold(E) wedge eoo) = bold(E) eoo,
	trans(bold(p), eo wedge bold(E) wedge eoo),
	trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E)),
)
$
where $bold(E)$ is a Euclidean blade in the base space $Cl(n)$, $bold(p) in RR^n$ is a Euclidean position vector and $r >= 0$ is a radius.
The translation operator $trans(bold(p), X) equiv trans(bold(p)) space X space rev(trans(bold(p)))$ has the form
$
	trans(bold(p)) = exp(1/2 eoo bold(p)) = 1 + 1/2 eoo bold(p)
$
and satisfies $trans(bold(p), "up"(bold(x))) = "up"(bold(x) + bold(p))$ where $"up"(bold(x)) := eo + bold(x) + 1/2 bold(x)^2 eoo$ and $trans(bold(p), eoo) = eoo$.
]




_Proof._
We may write $X = u_1 wedge dots.c wedge u_k$ for linearly independent vectors $u_i$.
Recall that the vectors @cga-vector-classification[can each be written in one of the following forms]
#eqnum[$
u_i prop cases(
	eo + bold(p) + 1/2 (bold(p)^2 plus.minus r^2) eoo,
	bold(hat(n)) + d eoo,
	eoo
)
$ <general-vector>]
where $prop$ denotes a nonzero scalar factor.

+ *Case $X wedge eoo = 0$.* We have
	$ X prop u_1 wedge dots.c wedge u_(k - 1) wedge eoo $
	where, because of the $eoo$ factor, each $u_i$ is of the form
	$ u_i prop cases(eo + bold(p), bold(hat(n))) $
	obtained by rejecting the $eoo$ components of the forms in @general-vector.
	+ *Case $X rcont eoo = 0$.* This implies $u_i rcont eoo = 0$ for all $u_i$, so the only permissible form for each is $u_i prop bold(hat(n))$. In other words,
		$ X prop bold(E) wedge eoo = bold(E) eoo $
		where $bold(E) := bold(v)_1 wedge dots.c wedge bold(v)_(k - 1)$ is a blade in the base space, $bold(v)_i in span(e_1, ..., e_n) tilde.equiv RR^n$.

	+ *Case $X rcont eoo != 0$.* This implies there is at least one $u_i$ for which $u_i rcont eoo != 0$, meaning $u_i prop eo + bold(p)_i$.
		Without loss of generality, say $u_1 prop eo + bold(p)$.
		We can add a multiple of $eoo$ to $u_1$ to get
		$
			X prop (eo + bold(p) + 1/2 bold(p)^2 eoo) wedge u_2 wedge dots.c wedge u_(k - 1) wedge eoo
		$
		since this is annihilated by the $eoo$ factor in $X$.
		The first factor is now the conformal point $"up"(bold(p))$.
		Using the translation operator $trans(bold(p))$, 
		$
			X &prop trans(bold(p), eo) wedge u_2 wedge dots.c wedge u_(k - 1) wedge eoo \
			&= trans(bold(p), eo wedge u'_2 wedge dots.c wedge u'_(k - 1) wedge eoo)
		$
		where $u'_i := trans(-bold(p), u_i)$ are translated vectors of the general form in @general-vector.
		However, because of factors of $eo$ and $eoo$, we may reject those components in each of the $u'_i$ so they become purely Euclidean vectors, $u'_i in span(e_1, ..., e_n)$.
		The final form is then
		$ X prop trans(bold(p), eo wedge bold(E) wedge eoo) $
		where $bold(E)$ is a $(k - 2)$-blade in the base space.

+ *Case $X wedge eoo != 0$.* We have
	$ X prop u_1 wedge dots.c wedge u_k $
	where none of the $u_i$ are scalar multiples of $eoo$, so are of the form:
	#eqnum[$ u_i prop cases(eo + bold(p) + 1/2(bold(p)^2 plus.minus r^2) eoo, bold(hat(n)) + d eoo) $ <finite>]

	+ *Case $X rcont eoo = 0$.*
		This implies $u_i rcont eoo = 0$ for each $i$ meaning all the vectors $u_i$ are of the form $bold(n)_i + d_i eoo$
		and we have
		#eqnum[$ X prop (bold(n)_1 + d_1 eoo) wedge dots.c wedge (bold(n)_k + d_k eoo) $ <trans-E>]
		for $bold(n)_i in span(e_1, ..., e_n)$ and $d_i in RR$.
		We may perform the Gram--Schmidt process on the factors of $X$ so that $(bold(n)_i + d_i eoo) dot (bold(n)_j + d_j eoo) = bold(n)_i dot bold(n)_j = 0$ whenever $i != j$.

		Note that @cga-drills[translating base space vectors] gives
		$ trans(bold(p), bold(n)_i) = bold(n)_i + (bold(n)_i dot bold(p)) eoo $
		so if we choose
		$bold(p) := sum_(i = 1)^k d_i/(norm(bold(n)_i)^2) bold(n)_i$
		so that $bold(n)_i dot bold(p) = d_i$ (remember the $bold(n)_i$ are mutually orthogonal) then we can rewrite all the factors as
		$ X prop trans(bold(p), bold(n)_1) wedge dots.c wedge trans(bold(p), bold(n)_k) = trans(bold(p), bold(E)) $
		where $bold(E) = bold(n)_1 wedge dots.c wedge bold(n)_k$ is a $k$-blade in the base space.

	+ *Case $X rcont eoo != 0$.* This implies there is at least one $u_i$ for which $u_i rcont eoo != 0$.
		Assume it is the first one.
		Then since it is only form allowed by @finite we must have
		$u_1 prop eo + bold(q) + 1/2 (bold(q)^2 plus.minus r^2) eoo$.
		Furthermore, we may take $u_2, ..., u_k$ to be of the form $u_i prop bold(n)_i + d_i eoo$, since we can always subtract an appropriate multiple of $u_1$ in order to eliminate any $eo$ component.
		Even further, we may assume that $bold(n)_i dot bold(n)_j = 0$ by performing Gram--Schmidt on $u_2, ..., u_k$ as in the previous case.
		Now we have:
		$
		X prop (eo + bold(q) + alpha eoo) wedge (bold(n)_2 + d_2 eoo) wedge dots.c wedge (bold(n)_k + d_k eoo)
		// X prop (eo + bold(q) + 1/2 (bold(q)^2 plus.minus r^2) eoo) wedge (bold(n)_2 + d_2 eoo) wedge dots.c wedge (bold(n)_k + d_k eoo)
		$
		Similarly to @trans-E, the trailing factors above may be written as
		$trans(bold(p), bold(E))$
		with $bold(E) = bold(n)_2 wedge dots.c wedge bold(n)_k$ by choosing the translation vector
		$bold(p) := sum_(i = 2)^k d_i/(norm(bold(n)_i)^2) bold(n)_i$.
		Putting everything inside this translation operator:
		$
		// X &prop trans(bold(p), trans(-bold(p), eo + bold(q) + alpha eoo) wedge bold(E) )
			// = trans(bold(p), (eo + bold(q)' + alpha' eoo) wedge bold(E))
		// X &prop trans(bold(p), trans(-bold(p), eo + bold(q) + 1/2 (bold(q)^2 plus.minus r^2) eoo) wedge bold(E) )
		X &prop trans(bold(p), (eo + bold(q)' + alpha' eoo) wedge bold(E) )
		// X &prop trans(bold(p), (eo + bold(q) - bold(p) + 1/2 ((bold(q) - bold(p))^2 plus.minus r^2) eoo) wedge bold(E) )
		$
		It does not matter what $bold(q)'$ and $alpha'$ are exactly --- we know it is of this form.
		Furthermore, we may take $bold(q)'$ to be perpendicular to $bold(E)$, since any parallel component is annihilated by the wedge product.
		Now, if $bold(q)' dot bold(E) = 0$ then $trans(bold(q)', bold(E)) = bold(E)$ (see @cga-drills[the translation law] for blades) which means we can translate again to get rid of $bold(q)'$.
		$
		X &prop trans(bold(p) - bold(q)', (eo + alpha'' eoo) wedge bold(E))
		$
		Finally, relabelling $bold(p) - bold(q)' |-> bold(p)$ and $alpha |-> plus.minus 1/2 r^2$ we have the final form
		$
		X = trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E))
		$
		where any constants of proportionality can be absorbed into $bold(E)$ to make this an exact equality.
		#h(1fr)#sym.qed

#v(1em)
#set figure.caption(position: top)
#figure(table(
	columns: 3,
	align: center,
	inset: 10pt,
	stroke: none,
	none, table.vline(), $X wedge eoo = 0$, $X wedge eoo != 0$,
	table.hline(),
	$X rcont eoo = 0$, $bold(E) eoo$, $trans(bold(p), bold(E))$,
	$X rcont eoo != 0$, $trans(bold(p), eo wedge bold(E) wedge eoo)$, $trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E))$,
), caption: [Summary of cases])