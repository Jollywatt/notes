#import "@local/notes:0.1.0"

#show: notes.style

#let lemma(title, body) = {
	rect(stroke: (left: 1pt))[
		*Ingredient.* #emph(title)
		#body
	]
}

= Proof that $det compose exp = exp compose tr$

#lemma[Triangular matrices are closed under multiplication.][
	Let $A$ and $B$ be upper triangular matrices, so that $A_(i j) = B_(i j) = 0$ for $i > j$.
	From
	$
	(A B)_(i j) = sum_k A_(i k) B_(k j)
		= sum_k cases(A_(i k) B_(k j) & "if" i <= k <= j, 0 & "otherwise")
	$
	it follows that $A B$ is also upper triangular.
	In particular, $(A B)_(i i) = A_(i i) B_(i i)$.
]

#lemma[Only diagonal elements of triangular matrices affect the trace.][
	$
	tr(A B) = sum_k (A B)_(k k) = sum_k A_(k k) B_(k k) = "diag"(A) dot.c "diag"(B)
	$
]

#lemma[Only diagonal elements of triangular matrices affect the determinant.][
	If $A$ is triangular, then
	$ det(A) = sum_(sigma in S_n) (-1)^sigma product_(i=1)^n A_(i sigma(i)) = product_(i=1)^n A_(i i) $
	because all the permutations $sigma$ except the identity have some $1 <= k <= n$ such that $sigma(k) < k$.
]

#lemma[Any square matrix $A$ can be put in Jordan normal form $A = P J P^(-1)$, where $J$ is upper triangular.][]

$
	det(exp(A))
	&= det(exp(P J P^(-1))) \
	&= det(P exp(J) P^(-1)) \
	&= det(P) det(exp(J)) det(P^(-1)) \
	&= det(exp(J)) \
	&= product_(i=1)^n exp(J)_(i i) \
	&= product_(i=1)^n sum_(n=0)^oo 1/n! (J^n)_(i i) \
	&= product_(i=1)^n sum_(n=0)^oo 1/n! (J_(i i))^n \
	&= product_(i=1)^n exp(J_(i i)) \
	&= exp(sum_(i=1)^n J_(i i)) \
	&= exp(tr(J)) \
	&= exp(tr(P P^(-1) J)) \
	&= exp(tr(P J P^(-1))) \
	&= exp(tr(A)) \
$