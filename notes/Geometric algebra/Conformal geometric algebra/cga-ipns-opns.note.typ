#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let (eo, eoo) = ($cal(o)$, $oo$)

#let trans(p, ..args) = {
	if args.pos().len() == 1 { $trans(#p)[#args.pos().at(0)]$ }
	else { $mono(T)_#p$ }
}

#show math.equation.where(block: true): box.with(width: 100%)

#let (ipns, opns) = ("ipns", "opns").map(math.op)
#let up = math.op("up")

#show math.frac: it => {
	if it.num == [1] and it.denom == [2] { math.inline(it) } else { it }
}


= Outer and Inner Product Null Spaces for @cga[CGA] Blades

#emph[See also @cga-ipns-opns-summary[summary of these results].]

Using the @cga-blade-classification[classification of blades] in @cga[conformal geometric algebra], 

$
X = cases(
	bold(E) eoo
		&"direction",
	trans(bold(p), bold(E))
		&"dual flat",
	trans(bold(p), eo wedge bold(E) wedge eoo)
		&"flat",
	trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E))
		quad &"round",
)
$
we can easily characterise the inner and outer product null spaces
$
ipns(X) &:= {x in Q | x lcont X = 0} \
opns(X) &:= {x in Q | x wedge X = 0} \
$
of an arbitrary blade $X$ where $Q := {u in RR^(n + 2) | u^2 = 0} = {up(x) | x in RR^n} union {eoo}$.

#let conclusion(body) = box(body, stroke: (bottom: green.darken(20%)), outset: (y: 0.6em))

= OPNS

- *Directions, $bold(E) eoo$:*

	Assuming $up(x) wedge (bold(E) eoo) = 0$ implies
	$
	(eo + x + 1/2 x^2 eoo) wedge bold(E) wedge eoo = (eo + x) wedge bold(E) = 0
	$
	which is impossible because $eo wedge bold(E)$ is always nonzero.
	Additionally, $eoo wedge bold(E) eoo = 0.$

	#conclusion[Therefore $opns(bold(E) eoo) = {eoo}$.]

- *Dual flats, $trans(bold(p), bold(E))$:*

	Assuming $up(x) wedge trans(bold(p), bold(E)) = 0$ implies
	$
	trans(bold(p), up(x - p) wedge bold(E)) = 0 <==> (eo + x - p + 1/2 (x - p)^2 eoo) wedge bold(E) = 0
	$
	which is impossible because it includes the linearly independent term $eo wedge bold(E) != 0$.
	Additionally, $eoo wedge trans(bold(p), bold(E)) = trans(bold(p), eoo bold(E)) != 0$.


	#conclusion[Therefore $opns(trans(bold(p), bold(E))) = nothing$.]

- *Flats, $trans(bold(p), eo wedge bold(E) wedge eoo)$:*

	Assuming $up(x) wedge trans(bold(p), eo wedge bold(E) wedge eoo) = 0$ implies
	$
	trans(bold(p), up(x - p) wedge eo wedge bold(E) wedge eoo) = 0 <==> (x - p) wedge eo wedge bold(E) wedge eoo = 0
	$
	which vanishes if and only if $x = p + u$ for some vector $u in "span"(bold(E)) <==> u wedge bold(E) = 0$.
	Additionally, $eoo wedge trans(bold(p), eo wedge bold(E) wedge eoo) = 0$.

	#conclusion[Therefore $opns(trans(bold(p), eo wedge bold(E) wedge eoo)) = {up(p + r) | r wedge bold(E) = 0} union {eoo}$.]

- *Rounds, $trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E))$:*

	Assuming $up(x) wedge trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E)) = 0$ implies
	$
	trans(bold(p), up(x - p) wedge (eo plus.minus 1/2 r^2 eoo) wedge bold(E)) = 0 <==> \
	(eo + (x - p) + 1/2 (x - p)^2 eoo) wedge (eo plus.minus 1/2 r^2 eoo) wedge bold(E) \
	= (1/2 (x - p)^2 minus.plus 1/2 r^2) eoo wedge eo wedge bold(E) + (x - p) wedge (eo plus.minus 1/2 r^2 eoo) wedge bold(E) = 0
	$
	which, since these two terms are linearly independent, means both must vanish
	$
	norm(x - p)^2 = plus.minus r^2
	quad "and" quad
	(x - p) wedge bold(E) = 0
	$
	which, in the $+$ case, describes a $k$-sphere within the flat $x = p + u$ for $u in "span"(bold(E))$ centred at $p$ with radius $r > 0$ (so $u^2 = r^2$).
	Additionally, $eoo wedge trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E)) != 0$.

	#conclusion[Therefore $opns(trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E))) = {up(p + u) | u wedge bold(E) = 0, u^2 = plus.minus r^2 }$.]



= IPNS

- *Directions, $bold(E) eoo$:*

	Assuming $up(x) lcont (bold(E) eoo) = 0$ implies
	$
	(eo + x + x^2/2 eoo) lcont (bold(E) eoo) = (x lcont bold(E)) eoo + bold(E)^star (eo lcont eoo) = (x lcont bold(E)) wedge oo - bold(E)^star = 0
	$
	which is impossible because the two terms are linearly independent.
	Additionally, $eoo lcont bold(E) eoo = 0.$

	#conclusion[Therefore $ipns(bold(E) eoo) = {eoo}$.]

- *Dual flats, $trans(bold(p), bold(E))$:*

	Assuming $up(x) lcont trans(bold(p), bold(E)) = 0$ implies
	$
	trans(bold(p), up(x - p) lcont bold(E)) = 0 <==> (eo + x - p + 1/2 (x - p)^2 eoo) lcont bold(E) = (x - p) lcont bold(E) = 0
	$
	which implies $x = p + u$ for some vector $u in "span"(bold(E))^perp <==> u lcont bold(E) = 0$.
	Additionally, $eoo lcont trans(bold(p), bold(E)) = trans(bold(p), eoo lcont bold(E)) = 0$.

	#conclusion[Therefore $ipns(trans(bold(p), bold(E))) = {up(p + u) | u lcont bold(E) = 0} union {eoo}$.]

- *Flats, $trans(bold(p), eo wedge bold(E) wedge eoo)$:*

	Assuming $up(x) lcont trans(bold(p), eo wedge bold(E) wedge eoo) = 0$ implies
	$
	trans(bold(p), up(x - p) lcont (eo wedge bold(E) wedge eoo)) = 0 <==> \
	(eo + (x - p) + 1/2 (x - p)^2 eoo) lcont (eo wedge bold(E) wedge eoo) \
	= -1/2 (x - p)^2 bold(E) eoo - eo wedge ((x - p) lcont bold(E)) wedge eoo - eo bold(E)^star wedge (eo lcont eoo) = 0
	$
	which is impossible because the terms are linearly independent and $eo bold(E)^star != 0$.
	Additionally, $eoo lcont trans(bold(p), eo wedge bold(E) wedge eoo) = -trans(bold(p), bold(E) eoo) != 0$.

	#conclusion[Therefore $ipns(trans(bold(p), eo wedge bold(E) wedge eoo)) = nothing$.]

- *Rounds, $trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E))$:*

	Assuming $up(x) lcont trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E)) = 0$ implies
	$
	trans(bold(p), up(x - p) lcont ((eo plus.minus 1/2 r^2 eoo) wedge bold(E))) = 0 <==> \
	((eo + x - p + 1/2 (x - p)^2 eoo) lcont (eo plus.minus 1/2 r^2 eoo)) wedge bold(E) - (eo plus.minus 1/2 r^2 eoo) wedge (up(x - p) lcont bold(E)) \
	= -(1/2 (x - p)^2 plus.minus 1/2 r^2) wedge bold(E) - (eo plus.minus 1/2 r^2 eoo) wedge ((x - p) lcont bold(E)) = 0
	$
	which, since these two terms are linearly independent, means both must vanish
	$
	norm(x - p)^2 = minus.plus r^2
	quad "and" quad
	(x - p) lcont bold(E) = 0
	$
	which, in the $-$ case, describes a $k$-sphere within the flat $x = p + u$ for $u in "span"(bold(E))^perp$ centred at $p$ with radius $r > 0$ (so $u^2 = minus r^2$).
	Additionally, $eoo lcont trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E)) -trans(bold(p), bold(E)) != 0$.

	#conclusion[Therefore $ipns(trans(bold(p), (eo plus.minus 1/2 r^2 eoo) wedge bold(E))) = {up(p + u) | u lcont bold(E) = 0, u^2 = minus.plus r^2 }$.]

