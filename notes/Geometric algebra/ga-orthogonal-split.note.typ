#import "@local/notes:0.1.0"
#show: notes.style

#let wedge = $and$
#let lcont = math.op(sym.floor.r)
#let rcont = math.op(sym.floor.l)
#let iff = $quad <==> quad$

#let proj(obj, vec) = $obj^(parallel vec)$
#let rej(obj, vec) = $obj^(perp vec)$

#set math.cancel(stroke: red)

== Orthogonal splits of geometric algebras

Let $G$ be a geometric algebra.
For any $1$-vector $u$, we can define the subspaces
$
proj(G, u) &:= {proj(A, u) | A in G} = {A in G | u wedge A = 0} \
rej(G, u) &:= {rej(A, u) | A in G} = {A in G | u lcont A = 0} \
$
where we use the @multivector-proj-rej[multivector projections and rejections] $A = proj(A, u) + rej(A, u)$.

#notes.result-box[
	*Lemma.* $G = rej(G, u) plus.circle proj(G, u)$
]
*Proof.* Any $A in G$ is a sum of its @multivector-proj-rej[projections and rejections] $proj(A, u) in proj(G, u)$ and $rej(A, u) in rej(G, u)$.

#notes.result-box[
	*Lemma.* $rej(G, u)$ is a subalgebra.
]
*Proof.*
Let $A, B in rej(G, u)$ which means $u lcont A = u lcont B = 0$.
Since $u lcont$ is linear, $rej(G, u)$ is a vector space.
To show that $rej(G, u)$ is closed under the geometric product, observe that $u lcont (A B) = (u lcont A)B + A^star (u lcont B) = 0$ from the @ga-product-identities[anti-derivation identity]. #sym.qed

#notes.result-box[
	*Lemma.*
	Any element $A in proj(G, u)$ is of the form $A = u A_perp = u wedge A_perp$ where $A_perp in rej(G, u)$.
]
*Proof.* For any $A in proj(G, u)$ take $A_perp := u^(-1) A$.
To show $A_perp in rej(G, u)$, write
$ u lcont A_perp = u lcont (u^(-1) A) = (u lcont u^(-1))A - u^(-1)(u lcont A) = A - u^(-1) (u A) = 0 $
using the @ga-product-identities[anti-derivation identity].
Hence, $A = u A_perp$. #sym.qed


#notes.result-box[
	*Corollary.*
	$proj(G, u) = u rej(G, u) = {u A | A in rej(G, u)}$
]
*Proof.*
By the lemma above, the map $f(u A) = A$ is well defined for $f: proj(G, u) -> rej(G, u)$.
Since it has inverse $f^(-1)(A) = u A$ it is bijective so $f^(-1)(rej(G, u)) = proj(G, u)$ and hence $u rej(G, u) = proj(G, u)$.


#notes.result-box[
	*Lemma.* $G = rej(G, u) plus.circle proj(G, u)$ forms a $ZZ_2$-grading: elements multiply under the geometric product according to the multiplication table:
	#align(center, grid(
		align: center + horizon,
		columns: 3,
		inset: (x: 4pt, y: 8pt),
		none,
		grid.vline(),
		$rej(G, u)$,
		$proj(G, u)$,
		grid.hline(),
		$rej(G, u)$,
		$rej(G, u)$,
		$proj(G, u)$,
		$proj(G, u)$,
		$proj(G, u)$,
		$rej(G, u)$,
	))
]
*Proof.* We have already shown that $rej(G, u)$ is a subalgebra, so $rej(G, u) times rej(G, u) -> rej(G, u)$ under the geometric product.

To show that $rej(G, u) times proj(G, u) -> proj(G, u)$, take $A in rej(G, u)$ and $B in proj(G, u)$.
By the previous lemma, $B = u B_perp$ where $B_perp in rej(G, u)$.
We show $u wedge (A B) = 0$ and hence $A B in proj(G, u)$ by writing
$
u lcont (A B) = cancel((u lcont A)) u B_perp + A^star (u lcont (u B_perp)) = A^star u^2 B_perp - A^star u cancel((u lcont B_perp)) = u A u B_perp = u A B
$
where we used $u lcont A = 0 <==> u A = u wedge A = A^star wedge u = A^star u$.
Same for $proj(G, u) times rej(G, u) -> proj(G, u)$.

To complete the table, pick $A, B in proj(G, u)$ and let $A = u A_perp$ and $B = u B_perp$ where $A_perp, B_perp in rej(G, u)$ as before. We can show $u lcont (A B) = 0$ since
$
u lcont (u A_perp u B_perp)
	&= (u lcont u) A_perp u B_perp
	- u cancel((u lcont A_perp)) u B_perp
	- u A_perp^star (u lcont u) B_perp
	+ u A_perp^star u cancel((u lcont B_perp)) \
	&= A_perp u B_perp - u A_perp^star B_perp = A_perp u B_perp - A_perp u B_perp = 0
$
which means $A B in rej(G, u)$. #sym.qed
