#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

= Multivector derivative identities

#env[Lemma][
	If $P : G -> G$ is a projection on a geometric algebra $G$, then
	$ P(diff_X) X = diff_X P(X) = dim P(G) $
	where $P(G) = {P(a) | a in G}$.
] <mvd-proj>
#proof[
Without loss of generality, choose a basis ${e_1, ..., e_N}$ for the entire geometric algebra $G$ such that $P$ is defined by $P(e_i) = e_i$ for $1 <= i <= k$ and $P(e_i) = 0$ for $k < i <= N$.
(If $G$ is over a base vector space $V$ then $N = 2^(dim V)$.)
We therefore have
$	
	diff_X P(X) = sum_(i = 1)^N e^i P(e_i) = sum_(i = 1)^k 1 + sum_(i = k+1)^N 0 = k
$
and similarly for $P(diff_X) X$ if we simiply choose the reciprocal basis ${e^i}$ to have the desired properties instead of ${e_i}$.
]

#env(accent: teal)[Corollary][
	Let $A in G$ be a multivector and let $dim G = 2^n$.
	$ 1/2^n diff_X A X = grade(A, 0) + cases(grade(A, n) &"if" n "odd", 0 &"if" n "even") $
] <diff-A-X>
#proof[
Let $A = A_0 + sum_i A_i + A_n$ be a sum of blades $A_i$ with scalar part $A_0 = grade(A, 0)$ and pseudoscalar part $A_n = grade(A, n)$.
We can decompose the multivector operator $diff_X$ into @centralizers[parts which (anti)commute] with a given blade.
$
	diff_X A X
		&= sum_i diff_X A_i X \
		&= sum_i {cen(+, A_i, diff_X) + cen(-, A_i, diff_X)} A_i X \
		&= sum_i A_i {cen(+, A_i, diff_X) - cen(-, A_i, diff_X)}  X \
		&= sum_i A_i {dim cen(+, A_i, G) - dim cen(-, A_i, G)} \
$
We use @mvd-proj to obtain $cen(plus.minus, A_i, diff_X) X = dim cen(plus.minus, A_i, G)$.
Finally, from @ga-centralizer-sizes[the note on the dimension of (anti)centralizers of blades], we know that $dim cen(+, A_i, G) = dim cen(-, A_i, G)$ for all blades $i in.not {0, n}$, and also for $i = n$ if $n$ is even.
Those terms vanish.
We also have $dim cen(+, A_i, G) = dim G$ and $dim cen(-, A_i, G) = 0$ for scalars $i = 0$, and also for pseudoscalars $i = n$ if $n$ is odd.
Since $dim G = 2^n$ the result follows.
]

#env(accent: teal)[Corollary][
	If $R in G$ is an $n$-dimensional even multivector:
	$ diff_X R X = 2^n grade(R, 0) $
]
#proof[Special case of @diff-A-X.]

#env[Lemma][
	For a $k$-blade $A$ and $1$-vector $u$,
	$
	diff_u A u = (n - 2k) A^star
	$
]
#proof[
This uses the same trick: split $u$ into parts which (anti)commute with $A$, rearrange, and apply @mvd-proj.
The problem reduces to finding the @ga-centralizer-sizes[dimensions of (anti)centralizers].
$
	diff_u A u
	&= diff_u A {cen(+, A, u) + cen(-, A, u)} \
	&= diff_u {cen(+, A, u) - cen(-, A, u)} A \
	&= {dim cen(+, A, V) - dim cen(-, A, V)} A \
	&= A cases(
		dim rej(V, A) - dim proj(V, A) &"if" A "even",
		dim proj(V, A) - dim rej(V, A) &"if" A "odd",
	) \
	&= A cases(
		(n - k) - k &"if" k "even",
		k - (n - k) &"if" k "odd",
	) \
	&= (n - 2k) (-1)^k A 
	= (n - 2k) A^star
$
Here, $V = grade(G, 1)$ is the base space of $1$-vectors.
If $A$ is even, then vectors perpendicular to all directions in $A$ commute ($dim cen(+, A, V) = dim rej(V, A)$) and otherwise anticommute ($dim cen(-, A, V) = dim proj(V, A) = n - dim rej(V, A)$).
The opposite holds for $A$ odd.
]

#env[Lemma][
	For a $k$-vector $A$ and $q$-vector $B$,
	$
	diff_A B A = [2 sum_(m "even") binom(q, m)binom(n - q, k - m) - binom(n, k)] (-1)^(k q) B
	$
]

#proof[
$
	diff_A B A
	&=  diff_A B {cen(+, B, A) + cen(-, B, A)} \
	&=  diff_A {cen(+, B, diff_A) - cen(-, B, diff_A)} B \
	&=  {dim cen(+, B, grade(G, k)) - dim cen(-, B, grade(G, k))} B \
$
The terms $dim cen(plus.minus, B, grade(G, k))$ are given by @number-of-commuting-blades[the number of (anti)commiting blades].
$
	diff_A B A = {2W_(n k q) - binom(n, k)} (-1)^(k q) B
$
where $W_(n q k) = sum_(m "even") binom(q, m)binom(n - q, k - m)$.
]