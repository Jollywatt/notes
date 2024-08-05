#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let Gu = $rej(G, u)$

= Blades and the dimension of their (anti)centralizers

#env[Theorem][
	If $a in G$ is a non-(pseudo)scalar blade, then
	$ dim cen(+, a, G) = dim cen(-, a, G) = 1/2 dim G $
	where $cen(plus.minus, a, G)$ are the @centralizers[(anti)centralizers] of $a$.
] <same-dim-cen>

#proof[
By induction due to @lasenby2024.
Assume this holds for all geometric algebras in $n$ dimensions.
Let $G$ be a geometric algebra in $n + 1$ dimensions, and pick a $k$-blade $a in G$ with $0 < k <= n$.
Choose a $1$-vector $u in G$ orthogonal to $a$ in the sense that $u lcont a = 0$, which must be possible since $a$ is not a pseudoscalar.
Note that $u a = u wedge a = (-1)^k a wedge u = (-1)^k a u$, which we use later.

The @ga-orthogonal-split[orthogonal subalgebra split]
$ G = Gu plus.circle u Gu $
lets us write $G$ in terms of the closed subalgebra $Gu subset G$ of elements orthogonal to $u$.
Projecting $G$ onto the @centralizers[subspaces that (anti)commute] with $a$ gives us
$
	cen(plus.minus, a, G) = cen(plus.minus, a, rej(G, u)) plus.circle cen(plus.minus, a, u rej(G, u))
$
since the (anti)centralizers $cen(plus.minus, a)$ are linear operators so distribute over the direct sum.

Remember we want to show that the dimensions of $cen(plus.minus, a, G)$ are equal.

+ For the first term in the direct sum, since $rej(G, u)$ is itself a geometric (sub)algebra in $n$ dimensions, we have
	$
		dim cen(+, a, rej(G, u)) = dim cen(-, a, rej(G, u)) = 1/2 dim rej(G, u) = 1/4 dim G
	$
	from our inductive assumption.

+ For the second term in the direct sum, observe that if we pick some $u b in u rej(G, u)$ then the (anti)commutation relation
	$a (u b) = plus.minus (u b) a$ is equivalent to $a b = plus.minus (-1)^k b a$ because $a u b = (-1)^k u a b$.
	This means
	$
		u b in cen(plus.minus, a, rej(G, u)) <==>b in cases(
			cen(plus.minus, a, G) & "if" k "is even",
			cen(minus.plus, a, G) & "if" k "is odd",
		)
	$
	or in other words that the space $cen(plus.minus, a, u rej(G, u))$ is equal to $u cen(plus.minus, a, rej(G, u))$ for even $k$ and $u cen(minus.plus, a, rej(G, u))$ otherwise.
	Either way, this is useful because it means
	$
		dim cen(plus.minus, a, u rej(G, u)) = 1/4 dim G
	$
	since $dim u cen(plus.minus, a, rej(G, u)) = dim cen(plus.minus, a, rej(G, u)) = 1/4 dim G$.
Overall, we then have
$
	dim cen(plus.minus, a, G) = dim cen(plus.minus, a, rej(G, u)) + dim cen(plus.minus, a, u rej(G, u)) = 1/2 dim G
$
which proves the induction hypothesis for $n + 1$.

We need only show that the hypothesis is true for $n = 2$.
For any geometric algebra $G$ over a $2$-dimensional vector space and any $1$-vector $a in G$ we have simply
$
	cen(+, a, G) &= "span"{1, a} \
	cen(-, a, G) &= "span"{II, II a} \
$
where $II$ is the pseudoscalar.
]

#env(accent: teal)[Propostion][
	If $a$ is an $n$-dimensional $k$-blade, then
	$
		dim cen(+, a, G) &= cases(
			dim G &"if" k = 0,
			1/2 dim G &"if" 0 < k < n,
			1/2 dim G &"if" k = n "and" n "even",
			dim G &"if" k = n "and" n "odd",
		) \
		dim cen(-, a, G) &= cases(
			0 &"if" k = 0,
			1/2 dim G &"if" 0 < k < n,
			1/2 dim G &"if" k = n "is even",
			0 &"if" k = n "is odd",
		) \
	$
]
#proof[
Everything commutes with scalars, so the $k = 0$ case is trivial.
For $0 < k < n$ we use @same-dim-cen.
For the case $k = n$, note that the pseudoscalar $II = e_1 wedge dots.c wedge e_n$ commutes with $e_i$ if $n$ is odd, and hence everything commutes with $II$, and when $n$ is even, $e_i$ anticommutes, so that even elements commute with $II$ and odd elements anticommute.
]