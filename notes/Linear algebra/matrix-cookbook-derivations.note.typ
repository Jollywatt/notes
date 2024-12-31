#import "@local/notes:0.1.0"
#show: notes.style

#let ee = $bold(e)$
#let ud(A, i, j) = $#A^#{i}_(#hide($i$)#j)$


= Deriving some Matrix Cookbook identities


== Linear algebra without matrix notation

Proving identities in @matrixcookbook using standard matrix notation can be cumbersome.
It can be helpful to employ explicit tensor notation with a basis of vectors ${ee_i}$ and dual vectors ${ee^i}$.
Dual vectors act on vectors as $ee^j (ee_i) = delta^j_i$.

To agree with the standard meaning of juxtaposition as matrix multiplication, juxtaposing (dual) vectors means either _application_ $ee^i ee_j = ee_i (ee_j)$ or the _tensor product_ $ee_i ee^j = ee_i times.circle ee^j$ depending on the order.
Note that $ee_i ee_j$ and $ee^i ee^j$ are left undefined (in the same way that row-row or column-column multiplications are undefined).

In tensorial notation, we have
$
vec(u^1, dots.v, u^n) &equiv u^i ee_i ,&quad
mat(v_1, dots.c, v_m) &equiv v_j ee^j ,&quad
mat(
	ud(A, 1, 1), dots.c, ud(A, 1, m);
	dots.v, dots.down, dots.v;
	ud(A, n, 1), dots.c, ud(A, n, m);
) &equiv ud(A, i, j) ee_i ee^j .
$

With this scheme, matrix multiplication looks like
$ A x equiv ud(A, i, j) x^k ee_i ee^j ee_k = ud(A, i, j) x^k ee_i delta^j_k = ud(A, i, j) x^j ee_i $
with implicit summation over $i, j, k$.

For transposition, define $(ee_i)^T = ee^i$.
If $a = a^i ee_i$ and $a^T = a_i ee^i$, then $a^i = a_i$.

== The derivative of a function from matrices to scalars

Suppose $f : KK^(n times m) -> KK$ is a scalar-valued function of matrices.
The derivative $∂ f(X) slash ∂ X$ is understood to be the matrix whose $i j$ component is the derivative of $f(X)$ with respect to the $i j$ component of the input matrix $X$.

This can be expressed concretely as
$
∂/(∂ X) f(X) equiv sum_(i j) lr(dif/(dif t) f(X + t ee_i ee^j)|)_(t = 0) ee_i ee^j
$
where the matrix form of $ee_i ee^j$ is the matrix with $i j$ component one and others zero.


== Identities from the Matrix Cookbook

#notes.result-box($ ∂/(∂ X) (a^T X b) = a b^T $)

$
∂/(∂ X) (a^T X b)
	&= sum_(i j) lr(dif/(dif t) a^T (X + t ee_i ee^j)b |)_(t = 0) ee_i ee^j
\	&= sum_(i j) (a^T ee_i ee^j b) ee_i ee^j
\	&= sum_(i j) (ee^i a)^T (ee^j b) ee_i ee^j
\	&= sum_(i j) (a^i) (b^j) ee_i ee^j
	&& "since" ee^i a = a^j ee^i (ee_j) = a^j delta^i_j
\	&= a^i b_j ee_i ee^j
	&& "since" b^j = b_j
\	&= a^i ee_i b_j ee^j
\	&= a b^T
$

#notes.result-box($ ∂/(∂ X) tr(A X B) = A^T B^T $)

$
∂/(∂ X) tr(A X B)
	&= lr(dif/(dif t) tr(A (X + t ee_i ee^j) B)|)_(t = 0) ee_i ee^j
\	&= tr(A ee_i ee^j B) ee_i ee^j
\	&= tr(ud(A, a, b) ee_a ee^b ee_i ee^j ud(B, c, d) ee_c ee^d) ee_i ee^j
\	&= ud(A, a, b) ud(B, c, d) tr(ee_a ee^b ee_i ee^j  ee_c ee^d) ee_i ee^j
\	&= ud(A, a, b) ud(B, c, d) delta^b_i delta^j_c tr(ee_a ee^d) ee_i ee^j
\	&= ud(A, a, i) ud(B, j, d) delta^d_a ee_i ee^j
\	&= ud(B, j, a) ud(A, a, i) ee_i ee^j
\	&= ud((B A), j, i) ee_i ee^j
\	&= ud(((B A)^T), i, j) ee_i ee^j
\	&= A^T B^T
$

#notes.result-box($ ∂/(∂ X) tr(X^2) = 2X^T $)

$
∂/(∂ X) tr(X^2)
	&= lr(dif/(dif t) tr((X + t ee_i ee^j)^2)|)_(t = 0) ee_i ee^j
\	&= lr(dif/(dif t) tr(X^2 + t X ee_i ee^j + t ee_i ee^j X + cal(O)(t^2))|)_(t = 0) ee_i ee^j
\	&= tr(X ee_i ee^j + ee_i ee^j X) ee_i ee^j
\	&= 2ud(X, a, b) tr(ee_a ee^b ee_i ee^j) ee_i ee^j
\	&= 2ud(X, a, b) delta^b_i tr(ee_a ee^j) ee_i ee^j
\	&= 2ud(X, a, i) delta_a^j ee_i ee^j
\	&= 2ud(X, j, i) ee_i ee^j
\	&= 2ud((X^T), i, j) ee_i ee^j
\	&= 2X^T

$