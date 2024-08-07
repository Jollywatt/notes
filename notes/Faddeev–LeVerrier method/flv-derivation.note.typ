#import "@local/notes:0.1.0"
#import "@preview/lovelace:0.3.0"
#import "@preview/fletcher:0.5.1" as fletcher: node, edge

#show: notes.style

= The Faddeev--LeVerrier algorithm

#let adj = math.op("adj")
#let tag(eq) = math.equation(block: true, numbering: "(1)", eq)

#let boxy(title: none, prefix: none, color: teal, body) = {
	block(
		fill: color.lighten(60%),
		stroke: (left: color.lighten(30%) + 5pt),
		inset: 10pt,
		width: 100%,
	)[
		#if prefix == none {
			title
		} else {
			if title == none [*#prefix.*] else [*#prefix:* #title]
		}

		#body
	]
}

#let fact = boxy.with(prefix: [Useful fact], color: green)
#let caution = boxy.with(prefix: [Caution], color: red)


The Faddeev--LeVerrier algorithm may be used to determine the inverse, determinant, and characteristic polynomial of an $n times n$ matrix.
The algorithm terminates in $n$ steps, where each step involves a single matrix multiplication and only integer division.
It works like magic!


#lovelace.pseudocode-list(title: smallcaps[Faddeev-LeVerrier algorithm], hooks: .5em)[
+ *given* an $n times n$ matrix $A$
+ $c_n := 1$
+ $N <- bb(0)$
+ *for* $k in (n - 1, ..., 1, 0)$
	+ $N <- N + c_(k+1) II$
	+ $c_k := 1/(k - n) tr(A N)$
+ *return*
	+ $A^(-1) = -N slash c_0$
	+ $det(A) = (-1)^n c_0$ 
	+ $chi(lambda) = sum_(k=0)^n c_k lambda^k$
]

Also refer to a @flv-algorithm[Julia implementation].


== Derivation


Start with the characteristic polynomial of $A$.
$ chi(lambda) = det (lambda II - A) = sum_(k=0)^n c_k lambda^k $


#fact[
	The _adjunct_ of a matrix, $adj(X)$, satisfies $det(X) II = A adj(X)$.

	If $A$ is $n times n$, then $det(X)$, and hence the entries of $X adj(X)$, are degree $n$ polynomials in the entries of $A$.
	Hence, the entries of $adj(X)$ are degree $n - 1$ polynomials.
]

The entries of $N(lambda) := adj(lambda II - A)$ are $lambda$-polynomals of order $n - 1$, so $N(lambda) = sum_(k=0)^(n-1) N_k lambda^k$ where $N_k$ are matrices.
From $det(lambda II - A) II = (lambda II - A) N(lambda)$,

$
det(lambda II - A) II
	&= (lambda II - A) sum_(k=0)^(n-1) N_(k) lambda^k \
	&= -A N_0 + sum_(k=1)^(n-1) (N_(k-1) - A N_(k)) lambda^k + N_(n-1) lambda^n
$

Equating coefficients of $lambda$ with $chi(lambda) II$, we obtain:

$
c_0 II &= &class("binary", -) A N_0 \
c_k II &= N_(k-1) &- A N_k \
c_n II &= N_(n-1)
$

To remember these, just write $c_k II = N_(k-1) - A N_k$ for all $0 <= k <= n$ with the understanding that $N_k$ vanishes outside the range $0 <= k <= n - 1$.
Equivalently, $ N_k = N_(k+1) - c_(k+1)II $ gives a descending recurrence relation for $N_k$ in terms of the coefficients $c_k$.


== Finding $c_k$ in terms of $A$ and $N_k$

This stroke of genious is due to @hou1998.

#fact(title: [Laplace transform of derivative.])[$
	cal(L){f'(t)}(s)
	&= integral_0^oo f'(t) e^(-s t) dif t \
	&= lr( f(t) e^(-s t) |)_(t=0)^oo + s integral_0^oo f(t) e^(-s t) dif t  \
	&= -f(0) + s cal(L){f(t)}(s)
$]
Consider
$ (dif e^(A t))/(dif t) = A e^(A t) $
and perform the Laplace transform to obtain
$ -II + s cal(L){e^(A t)} = A cal(L){e^(A t)} $
and finally take the trace:
#tag($ s tr cal(L){e^(A t)} - n = tr(A cal(L){e^(A t)}) $) <n-L-L>

#fact(title: [the trace of a matrix exponential in terms of eigenvalues.])[
	If $lambda_i$ are the eigenvalues of $A$ then $tr(A) = sum_i lambda_i$.
	Also, $A$ can be put in Jordan normal form $A = P J P^(-1)$ where J is triangular with $"diag"(J) = (lambda_1, ..., lambda_n)$.
	Since it is triangular, $"diag"(J^k) = (lambda_1^k, ..., lambda_n^k)$.

	Therefore, $tr(A^k) = tr(P J^k P^(-1)) = tr(J^k P^(-1) P) = tr(J^k) = sum_(i=1)^n lambda_i^k$.

	Consequently, $tr(e^(A t)) = sum_(k=0)^oo t^k/k! tr(A^k) = sum_(k=0)^oo t^k/k! sum_(i=1)^n lambda_i^k = sum_(i=1)^n e^(lambda_i t)$.
]
We now compute the terms in @n-L-L.
$
cal(L){e^(A t)}
	&= integral_0^oo e^((A - s II)t) dif t
	= (A - s II)^(-1) lr(e^((A - s II)t) |, size: #150%)_(t=0)^oo
	= (s II - A)^(-1) \
$
#caution[
	I'm uncomfortable with these indefinite integrals. Why should $lim_(t -> oo) e^((A - s II)t)$ converge?
]
Note that from $chi(lambda) = det(lambda II - A) = (lambda II - A) N(lambda)$ we have
#tag($ (lambda II - A)^(-1) = N(lambda)/chi(lambda) $) <N-chi>

Let $(lambda_1, ..., lambda_n)$ be the eigenvalues of $A$.
Then $A - s II$ has eigenvalues $lambda_i - s$.
$
tr cal(L){e^(A t)}
	= integral_0^oo tr e^((A - s II)t) dif t 
	= sum_(i=1)^n integral_0^oo e^((lambda_i - s)t) dif t 
	= sum_(i=1)^n 1/(s - lambda_i)
$
Recall that the roots of the characteristic polynomial of $A$ are its eigenvalues, so $chi(s) = product_(i=1)^n (s - lambda_i)$.
#tag($
tr cal(L){e^(A t)}
	= sum_(i=1)^n dif/(dif s) ln(s - lambda_i)
	= dif/(dif s) ln (product_(i=1)^n (s - lambda_i))
	= dif/(dif s) ln chi(s)
	= (chi'(s))/chi(s)
$) <tr-L>

Substituting @N-chi and @tr-L into @n-L-L, we have
$ s chi'(s) - n chi(s) &= tr (A N(lambda)) \
sum_(k=0)^n (k - n) c_k s^k &= sum_(k=0)^(n-1) tr(A N_k) s^k
$
which, expanding and equating powers of $lambda$,
$ c_k = tr(A N_k)/(k - n) $
for all $0 <= k <= n$ where we define $N_n = 0$.

== Final algorithm


#fact[
$
chi(lambda)
	&=& c_0 &+ dots.c +& c_(n-1) &lambda^(n-1) &+ c_n &lambda^n \
	&=& det(-A) &+ dots.c +& tr(-A) &lambda^(n-1) &+ &lambda^n
$

$ c_0 = (-1)^n det(A), quad c_(n-1) = -tr(A), quad c_n = 1 $
]



== Visual summary


#fletcher.diagram(
	node-shape: rect,
	// node-stroke: 1pt,
	axes: (ttb, ltr),
	node((0,0), $ det(lambda II - A) = sum_(k=0)^n c_k lambda^k $),
	edge("->", <det-adj>),
	node((2,0), $ N(lambda) = sum_(k=0)^(n-1) N_k lambda^k $),
	edge("->", <det-adj>),
	node((1,0), $ det X = X adj X $, name: <det-adj>),
	edge("->", [equate coefficients], center, bend: 0deg, label-pos: .5),

	node((0,0.70), $ c_k II = N_(k-1) - A N_k $, name: <c_k>),


	node((0,2), $ cal(L){e^(A t)} = (s II - A)^(-1) $),
	edge("->", <L>),
	node((2,2), $ tr cal(L){(dif e^(A t))/(dif t)} $),
	edge("->", <L>),
	node((1,2), $ s tr cal(L){e^(A t)} - n = tr(A cal(L){e^(A t)}) $, name: <L>),
	edge("->", bend: 0deg),
	node((0,1.3), $ c_k = tr(A N_k)/(k - n) $, name: <N_k>),

	// edge(<N_k>, "->", auto),
	// edge(<c_k>, "->", auto),
	node((1,1), $ c_0, ..., c_n \ N_0, ..., N_(n-1) $, name: <k>),
	edge("->"),
	node((2,1), $ A^(-1) = -N_0 slash c_0 $, stroke: green, outset: 5pt),

	node(enclose: (<N_k>, <c_k>), stroke: none, snap: false, name: <both>),
	edge(<both>, "n->", <k>, [iterate], center)

)

#notes.references()