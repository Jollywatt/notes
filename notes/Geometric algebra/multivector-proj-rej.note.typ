#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *
#let iff = $quad <==> quad$

#let lemma(body) = rect(
	width: 100%,
	inset: (x: 0em, y: 1em),
	outset: (x: 1em),
	fill: green.lighten(90%),
	stroke: green,
	[*Lemma.* #body])

#set math.cancel(stroke: red)
#set enum(numbering: "1)")

= Projections and rejections of vectors by blades

Let $u$ be a $1$-vector and let $A$ be a blade.
We can decompose $u$ into orthogonal components $u = proj(u, A) + rej(u, A)$ given by
$
proj(u, A) &= (u lcont A)A^(-1) &= 1/2 (u - A^star u A^(-1)) \
rej(u, A) &= (u wedge A)A^(-1) &= 1/2 (u + A^star u A^(-1)) \
$
so that $proj(u, A)$ is _contained in_ $A$ and $rej(u, A)$ is _orthogonal to_ $A$.
The expanded forms follow immediately from @ga-product-identities[the vector product identities].
#lemma[
+ $u = proj(u, A) + rej(u, A)$
+ $proj(u, A) wedge A = rej(u, A) lcont A = 0$
+ $proj((proj(u, A)), A) = proj(u, A)$, $rej((rej(u, A)), A) = rej(u, A)$, $proj((rej(u, A)), A) = rej((proj(u, A)), A) = 0$
]
*Proof.* The first part is trivial.
For 2), assume $A$ is a $k$-blade and write:
$
proj(u, A) wedge A &= grade((u lcont A)A^(-1) A, k + 1) &&= grade(u lcont A, k + 1) &= 0 \
rej(u, A) lcont A &= grade((u wedge A)A^(-1) A, k - 1) &&= grade(u wedge A, k - 1) &= 0 \
$

To show that these are projections, note that
$
(u^plus.minus)^plus.minus
	&= 1/2 (u^plus.minus plus.minus A^star u^plus.minus A^(-1))
	= 1/4 (u plus.minus A^star u A^(-1) plus.minus A^star u A^(-1) + A^star A^star u A^(-1) A^(-1))
\	&= 1/2 (u plus.minus A^star u A^(-1))
	= u^plus.minus
$
where here we write $u^+ equiv rej(u, A)$ and $u^- equiv proj(u, A)$.
Lastly,
$
(u^plus.minus)^minus.plus
	= 1/2(u^plus.minus minus.plus A^star u^plus.minus A^(-1))
	= 1/4 (u plus.minus A^star u A^(-1) minus.plus A^star u A^(-1) - A^star A^star u A^(-1) A^(-1)) = 0
$
which shows that $proj(u, A)$ and $rej(u, A)$ are orthogonal projections.
#pagebreak()

= Projections and rejections of multivectors by vectors

Let $u$ be a $1$-vector.
We can decompose any multivector $A$ into orthogonal components $A = proj(A, u) + rej(A, u)$ given by
$
proj(A, u) &:= (A rcont u) u^(-1) &= 1/2 (A - u A^star u^(-1)) \
rej(A, u) &:= (A wedge u) u^(-1) &= 1/2 (A + u A^star u^(-1)) \
$
so that $proj(A, u)$ _contains_ $u$ and $rej(A, u)$ is _orthogonal to_ $u$.
The expanded forms follow immediately from @ga-product-identities[the vector product identities].
#lemma[
+ $A = proj(A, u) + rej(A, u)$
+ $u wedge proj(A, u) = u lcont rej(A, u) = 0$
+ $proj((proj(A, u)), u) = proj(A, u)$, $rej((rej(A, u)), u) = rej(A, u)$, $proj((rej(A, u)), u) = rej((proj(A, u)), u) = 0$
]
*Proof.* The first part is trivial.
For 2), assume $A$ is of grade $k$ and write:
$
proj(A, u) wedge u &= grade((A rcont u)u^(-1)u, k + 1) &&= grade(A rcont u, k + 1) &= 0 \
rej(A, u) rcont u &= grade((A wedge u)u^(-1)u, k - 1) &&= grade(A wedge u, k - 1) &= 0 \
$


To show that these are projections, note that
$
proj((proj(A, u)), u)
	&= u wedge (u^(-1) lcont (u wedge (u^(-1) lcont A)) \
	&= u wedge (u^(-1) lcont u) wedge (u^(-1) lcont A) - cancel(u wedge u) wedge (u^(-1) lcont (u^(-1) lcont A))
	= proj(A, u)
$
using the @ga-product-identities[anti-derivation identity]. Since $rej((proj(A, u)), u) = u lcont (cancel(u^(-1) wedge u) wedge (u^(-1) lcont A)) = 0$, we have also $rej((rej(A, u)), u) = rej((A + proj(A, u)), u) = rej(A, u)$.
#sym.qed
