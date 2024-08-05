#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let boxed(it) = box($it$, stroke: green, inset: 1em)

= Rotor of best fit formula

*Definition.*
The rotor of best fit $S$ which sends a frame ${e_i}$ to another frame ${f_i}$ is defined by
$
	S prop sum_I f_I e^I
$
where the constant of proportionality is chosen so that $S rev(S) = 1$.

#notes.result-box[
*Theorem.*
If the target frame $f_i = R e_i rev(R)$ is given by a rotation of ${e_i}$, then the rotors $R$ and $S$ are equivalent in the sense that
$
	f_i = S e_i rev(S)
$
and are equal $S = plus.minus R$ when ${e_i}$ spans the whole vector space.
]

To show this result, 


@lasenby2024

With the multivector derivative, if $X in G$ is a general multivector then
$∂_X X = dim G$
and if $P$ is some projection operator then
$P(∂_X) X = dim P(G)$.
In particular, if $cen(plus.minus, A)$ are the @centralizers[(anti)centralizer projection operators] then
$
cen(plus.minus, A, ∂_X) A X
= sum_(I) cen(plus.minus, A, e^I) A e_I
= sum_(I in cen(plus.minus, A)) e^I A e_I
= plus.minus A sum_(I in cen(plus.minus, A)) e^I e_I
= plus.minus A dim cen(plus.minus, A, G)
$
where $I in cen(plus.minus, A)$ means the multi-index ranges over basis blades $e_I in cen(plus.minus, A, G)$ which (anti)commute with $A$.

With this in mind,
$
	∂_X R X
	&= sum_k ∂_X grade(R, k) X \
	&= sum_k (cen(+, grade(R, k), ∂_X) + cen(-, grade(R, k), ∂_X)) grade(R, k) X \
	&= sum_k grade(R, k) (cen(+, grade(R, k), ∂_X) - cen(-, grade(R, k), ∂_X)) X \
	&= sum_k grade(R, k) (dim cen(+, grade(R, k)) - dim cen(-, grade(R, k))) \
	&= dim G grade(R, 0) + cases(dim G grade(R, n) &"if" n "is odd", 0 &"otherwise")
$
the last line follows from the @ga-centralizer-sizes[equal dimension of (anti)centralizers] for non-(pseudo)scalar blades: if $a$ is a $k$-blade, 

$
	dim cen(plus.minus, a, G) = 1/2 dim G
$
if $0 < k < n$, and for scalars
$
	dim cen(+, 1, G) = dim G
	quad "and" quad
	dim cen(-, 1, G) = 0
$
and finally for pseudoscalars
$
	dim cen(+, II, G) = cases(1/2 dim G &"if" n "even", dim G &"if" n "odd")
	quad "and" quad
	dim cen(-, II, G) = cases(1/2 dim G &"if" n "even", 0 &"if" n "odd")
$


Therefore, if $R$ is even,
$
	boxed( ∂_X R X rev(R) = 2^n grade(R, 0) rev(R) )
$


Choosing a basis ${e_i}$,
$
	1/2^n sum_I e^I R e_I rev(R) = grade(R, 0) rev(R)
$
which motivates the formula
$
	2^n grade(R, 0) rev(R) = sum_I e^I f_I
$
where $f_i = R e_i rev(R)$

== Best fit rotors

Let ${e_1, ..., e_m}$ be some initial frame and let $f_i = R e_i rev(R) + epsilon_i$ define final frame with some small noise.

The rotor of best fit $S$ is given by
$
	2^m grade(S, 0) rev(S) = sum_I e^I f_I = 2^m grade(R, 0) rev(R) + sum_(i=1)^m e^i epsilon_i + cal(O)(epsilon^2)
$
