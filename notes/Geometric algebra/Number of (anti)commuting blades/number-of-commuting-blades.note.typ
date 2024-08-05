#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#set par(justify: true)


= Number of (anti)commuting blades

How many $k$-blades (anti)commute with a given $q$-blade in $n$ dimensions?
Or expressed in terms of @centralizers[(anti)centralizers], what is the dimension of $cen(plus.minus, A, grade(G, k))$ for a $q$-blade $A$?

#env(accent: yellow)[Theorem][
If $A$ is a $q$-blade in an $n$-dimensional non-degenerate geometric algebra, then
$
	dim cen(plus.minus, A, grade(G, k)) = 
	cases(
		W_(n k q) &"if" (-1)^(k q) = plus.minus 1,
		binom(n, k) - W_(n k q) &"otherwise",
	)
	quad "where" quad
	W_(n k q) = sum_(m "even") binom(q, m) binom(n - q, k - m)
$
is the number of linearly independent $k$-blades that (anti)commute with $A$.
]

See @number-of-commuting-blades-tests for numerical verification of this result.

#proof[
Without loss of generality, choose an orthonormal basis ${e_i}$ such that
$ A = e_1 e_2 dots.c e_q $
and consider the $k$ blade
$ B = e_i_1 e_i_2 dots.c e_i_k $
where $1 <= i_1 < i_2 < dots.c < i_k <= n$.
If we count the number of basis $k$-blades of the form $B$ which (anit)commute with $A$, we compute the dimension of the vector space $cen(plus.minus, A, grade(G, k))$.

Let's rearrange $A B$ into $B A$ step by step.

First consider commuting a single vector $e_i$ through the $q$-blade $A$, from right to left.

If $e_i$ does not appear in $A$, then it anticommutes through $q$ basis vectors, introducing a factor of $(-1)^q$.
Otherwise, if $e_i$ appears in $A$, it anticommutes $q - 1$ one times (it commutes with itself) and introduces a factor of $(-1)^(q - 1) = -(-1)^q$.
In other words,
$
	A e_i = e_1 e_2 dots.c e_q e_i = e_i e_1 e_2 dots.c e_q cases(
		(-1)^q &"if" e_i perp A,
		(-1)^(q - 1) &"if" e_i parallel A,
	) = e_i A^star cases(+1 "if" q < i, -1 "if" i <= q)
	=: (-1)^delta(i <= q) e_i A^star
$
where $delta(i <= q)$ is $1$ if $i <= q$ and $0$ otherwise.

Now commute the $k$-blade $B$ through $A$, by repeatedly applying the above.
$
	A B
	&= A e_i_1 e_i_2 dots.c e_i_k \
	&= (-1)^q (-1)^delta(i_1 <= q) e_i_1 A e_i_2 dots.c e_i_k \
	&= (-1)^(2q) (-1)^(delta(i_1 <= q) + delta(i_2 <= q)) e_i_1 e_i_2 A e_i_3 dots.c e_i_k \
	&dots.v \
	&= (-1)^(k q) (-1)^dim(A sect B) B A
$
Observe that the $delta(i_j <= q)$ terms count the number of basis vectors ${e_i_1, ..., e_i_k}$ which appear in $A = e_1 e_2 dots.c e_q$.
This is the same as the dimension of the subspace $A sect B$ when viewing the two blades as vector subspaces.

Our original problem can now be written as
$
	dim cen(plus.minus, A, grade(G, k))
	&= dim {B in grade(G, k) | A B = plus.minus B A} \
	&= dim {B in grade(G, k) | (-1)^dim(A sect B) = plus.minus (-1)^(k q)} \
	&= (#block[number of basis $k$-blades $B$\ where $dim(A sect B)$ is $cases("even" &"if" (-1)^(k q) = plus.minus 1, "odd" &"otherwise")$])
$
Recall that $dim(A sect B)$ is the number of shared indices in $A$ and $B$ in our orthogonal basis.

This boils down to the @binary-bag-combos[the following combinatorics problem]: How many ways $W_(n k q)$ are there to select $k$ indices from ${1, 2, ..., n}$ such that the number of indices in common with ${1, 2, ..., q}$ is even?
The answer is
$
	W_(n k q) = sum_(m "even") binom(q, m) binom(n - q, k - m)
$
where the contributing terms are in the range $0 <= m <= min(k, q)$.

Pulling this all together, we have
$
	dim cen(plus.minus, A, grade(G, k)) &= cases(
		W_(n k q) &"if" (-1)^(k q) = plus.minus 1,
		binom(n, k) - W_(n k q) &"otherwise",
	)
$
where $A$ is a $q$-blade.
]