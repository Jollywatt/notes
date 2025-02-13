#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

= Multivector Conjugation


#env[Lemma][
	Conjugation by a $1$-vector $u$ is a reflection.
	In terms of the @multivector-proj-rej[projections and rejections],
	$
		u A u^(-1) = (rej(A, u))^star - (proj(A, u))^star 
	$
	for any multivector $A$.
] <conj-vector>

// #proof[
// 	$u proj(A, u) = u dot proj(A, u) = proj(A, u) dot u = proj(A, u) u$ and $u rej(A, u) = u wedge rej(A, u) = -rej(A, u) wedge u = - rej(A, u) u$
// ]

#proof[
Assume $A$ is a $k$-vector and then use linearity to extend to general multivectors.
Using the @multivector-proj-rej[projection and rejection] to write $A = rej(A, u) + proj(A, u)$, we have
$
	u rej(A, u) = u wedge rej(A, u) = (rej(A, u))^star wedge u = (rej(A, u))^star u
$
and similarly
$
u proj(A, u) = u lcont proj(A, u) = rev(rev(proj(A, u)) rcont u) = revsign(k - 1)revsign(k) proj(A, u) rcont u = -(-1)^k proj(A, u) rcont u = -(proj(A, u))^star rcont u = -(proj(A, u))^star  u
$
where $revsign(k)$ is the @reversion-sign[reversion sign].
Summing and left-multiplying by $u^(-1)$ gives the result.
]

#env[Lemma][Conjugation by an invertible multivector $s$ is an automorphism.]
#proof[
	Let $a, b in G$ be general multivectors. then $s a b s^(-1) = (s a s^(-1)) (s b s^(-1))$.
]

In particular, this means multivector conjugation is grade-preserving.