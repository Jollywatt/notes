#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

= Multivector reversion sign

@wilson2022

Let $A$ be a $k$-blade. Its reverse is $rev(A) = revsign(k)A$ where the _reversion sign_ is defined by
$ revsign(k) := (-1)^binom(k, 2) = (-1)^(((k - 1)k)/2) $
which is the sign of the permutation $(1, ..., k) -> (k, ..., 1).$

#let r(k) = calc.pow(-1, (k - 1)*k/2) // calculate reversion sign
#let pm(k) = if k > 0 { $+$ } else { $-$ }

#let cols = 12
#let row(fn) = range(cols).map(k => fn(k))

#align(center, table(
	columns: cols + 1,
	align: center,
	stroke: none,

	$k$, ..row(k => $#k$),
	table.hline(),
	$revsign(k)$, ..row(k => pm(r(k))),
	$revsign(k + 1)$, ..row(k => pm(r(k + 1))),
	$revsign(k)revsign(k + 1)$, ..row(k => pm(r(k)*r(k + 1))),
	$revsign(k - 1)revsign(k)$, ..row(k => pm(r(k - 1)*r(k))),

	table.vline(x: 1),
	..range(1, calc.ceil(cols/4)).map(x => {
		// add period lines every 4 columns
		table.vline(x: 1 + 4*x, stroke: (thickness: 0.5pt, dash: "dashed"))
	}),
))


#env[Lemma][
	$revsign(k)revsign(k + 1) = (-1)^k$, 
	$revsign(k - 1)revsign(k) = -(-1)^k$,
	$revsign(k)revsign(k + 2) = -1$.
]
