#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *
#let iff = $quad <==> quad$



#set math.cancel(stroke: red)

= Projections and rejections of multivectors by vectors

Let $u in G$ be a $1$-vector.
We can decompose any multivector $A in G$ into orthogonal components $A = proj(A, u) + rej(A, u)$ given by
$
proj(A, u) &:= u wedge (u^(-1) lcont A) \
rej(A, u) &:= u lcont (u^(-1) wedge A) \
$
so that $proj(A, u)$ "contains" $u$ and $rej(A, u)$ is "orthogonal" to $u$.

#notes.result-box[
*Lemma.*
#set enum(numbering: "1)")
+ $A = proj(A, u) + rej(A, u)$
+ $u wedge proj(A, u) = u lcont rej(A, u) = 0$
+ $proj((proj(A, u)), u) = proj(A, u)$, $rej((rej(A, u)), u) = rej(A, u)$, $proj((rej(A, u)), u) = rej((proj(A, u)), u) = 0$
]
*Proof.*
To show $A = proj(A, u) + rej(A, u)$ note that
$
rej(A, u) = u lcont (u^(-1) wedge A) = (u lcont u^(-1)) wedge A - u^(-1) wedge (u lcont A) = A - u wedge (u^(-1) lcont A) = A - proj(A, u)
$
using the @ga-product-identities[anti-derivation property] of $u lcont$.

We have $u wedge proj(A, u) = cancel(u wedge u) wedge (u^(-1) lcont A) = 0$ immediately and $u lcont rej(A, u) = u lcont (u lcont (u^(-1) wedge A)) = cancel((u wedge u)) lcont (u^(-1) wedge A)$ by the @ga-product-identities[double contraction identity].

To show that these are projections, note that
$
proj((proj(A, u)), u)
	&= u wedge (u^(-1) lcont (u wedge (u^(-1) lcont A)) \
	&= u wedge (u^(-1) lcont u) wedge (u^(-1) lcont A) - cancel(u wedge u) wedge (u^(-1) lcont (u^(-1) lcont A))
	= proj(A, u)
$
again using the anti-derivation identity. Since $rej((proj(A, u)), u) = u lcont (cancel(u^(-1) wedge u) wedge (u^(-1) lcont A)) = 0$, we have also $rej((rej(A, u)), u) = rej((A + proj(A, u)), u) = rej(A, u)$.
#sym.qed
