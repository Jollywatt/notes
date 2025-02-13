#import "@local/notes:0.1.0"
#show: notes.style

#let row(..args) = $(#(args.pos().join($space$)))$
#let re = $overline(e)$
#let RE = $overline(E)$

= Reciprocal basis

#notes.result-box[
	Let ${e_i} subset V$ be a basis and $dot : V times V -> RR$ a bilinear form.

	A _reciprocal basis_ ${re_i} subset V$ with respect to ${e_i}$ and $dot$ satisfies  $e_i dot re_i = delta_(i j)$.
]

The basis ${e_i}$ need not be orthogonal.

== Solving for the reciprocal basis

There exists some matrix $A$ such that $u dot v = u^T A v$.

Using matrix notation, $E = row(e_1, dots.c, e_n)$ is an $n times n$ matrix.

Define:
$ G = E^T A E <==> G_(i j) = e_i^T A e_j = e_i dot e_j $

We want to find $RE = row(re_1, dots.c, re_n)$ so that:
$ I = E^T A RE <==> delta_(i j) = e_i^T A re_j = e_i dot re_j $

Solve this as $RE = (E^T A)^(-1)I = (E^T A E E^(-1))^(-1) = (G E^(-1))^(-1) = E G^(-1) <=> re_i = e_i G^(-1)$.

#notes.result-box[$
	RE = E G^(-1) <==>
	re_k = e_k [e_i dot e_j]_(i j)^(-1)
$]

See @reciprocal-basis-test for Julia example.