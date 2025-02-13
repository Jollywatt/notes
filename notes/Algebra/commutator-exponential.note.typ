#set page(width: 16cm, height: auto)
#show heading: pad.with(bottom: 1em)

#let lemma(..args) = {
	let counter = counter(figure.where(kind: "lemma")).display()
	let statement = args.pos().at(0)
	let proof = args.pos().at(1, default: none)
	let cells = if proof == none {
			(
				[*Lemma #counter*] + statement,
			)
	} else {
		(
			[*Lemma #counter*] + statement,
			[*Proof*] + proof
		)
	}
	figure(
		kind: "lemma",
		supplement: [Lemma],
		{
			set align(left)
			table(
				columns: 1fr,
				stroke: (left: 1pt, rest: none, ),
				gutter: 5pt,
				// fill: (x, y) => (blue, teal).at(y).transparentize(90%),
				..cells,
			)
		}
	)
}


= Proof that $exp([A, -])X = exp(A) X exp(-A)$.

#lemma[
	$ exp([A, -])X = exp(A) X exp(-A) $
][
	Expanding the r.h.s., $
	exp(A) X exp(-A)
		&= [sum_(n=0)^oo 1/n! A^n] X [sum_(n=0)^oo (-1)^n/n! A^n] \
		&= sum_(n=0)^oo sum_(k=0)^n (-1)^k/(k! (n - k)!) A^(n - k) X A^k \
		&= sum_(n=0)^oo 1/n! [A,-]^n X
		quad #[via @commutator-power]\
		&= exp([A, -]) X
	$
	
]
#lemma[
	$ [A, -]^n X = sum_(k=0)^n (-1)^k binom(n, k) A^(n-k) X A^k $
][
	by induction. Assuming true for $n$,
	#let k2 = $overline(k)$
	$
	[A, -]^n A X
	&= sum_(k=0)^(n + 1) (-1)^k binom(n + 1, k) (n + 1 - k)/(n+1) A^((n+1)-k) X A^k \
	$
	via @binom1, and
	$
	[A, -]^n X A
	&= sum_(k=0)^n (-1)^k binom(n + 1, k + 1) (k + 1)/(n + 1) A^((n + 1) - (k + 1)) X A^(k + 1) \
	&= -sum_(k2=0)^(n + 1) (-1)^k2 binom(n + 1, k2) k2/(n + 1) A^((n + 1) - k2) X A^k2
	$
	via @binom2.
	Taking both together,
	$
	[A, -]^(n + 1) X
	&= [A, -] (A X - X A) \
	&= sum_(k=0)^(n+1) (-1)^k binom(n + 1, k) A^((n+1)-k) X A^k
	$
	which shows that the $n+1$ case holds, and hence $forall n$.
	
] <commutator-power>

#lemma[
	$ binom(n, k) = binom(n + 1, k) (n + 1 - k)/(n+1) $
][
	$
	n!/(k!(n - k)!)
	= ((n + 1)!)/(k! (n + 1 - k)!) (n + 1 - k)/(n+1)
	$
] <binom1>

#lemma[
	$ binom(n, k) = binom(n + 1, k + 1) (k + 1)/(n + 1) $
][
	$
	n!/(k!(n - k)!)
	= (n + 1)!/((k + 1)!(n - k)!) (k + 1)/(n + 1)  $
] <binom2>

