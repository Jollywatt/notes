#import "@local/notes:0.1.0"

#show: notes.style

= Solution space of diagonal quadratic forms

Let $Lambda = "diag"(lambda_1, ..., lambda_k)$.
Consider the manifold of solutions $z in RR^k$ given by:
$
  z^T Lambda z = lambda_1 z_1^2 + dots.c + lambda_k z_k^2 = 0
$

Let $(p, q, r)$ be the number of entries $lambda_i$ which are positive, negative, and zero, respectively.
Without loss of generality, we can focus on the special case
$
  Lambda = +bb(1)_p plus.o -bb(1)_q plus.o bb(0)_r
  .
$
Given a solution for this matrix, we can obtain a solution to any diagonal matrix simply by permuting $z$ and scaling its components $z_i |-> z_i slash sqrt(abs(lambda_i))$.

Define the *half $n$-sphere* by
#let hemi(it) = $HH^it$
$
  // hemi(n) = {(cos theta_1, sin theta_1 cos theta_2, ..., product_(i=1)^n sin theta_i cos theta_(n + 1), product_(i=1)^(n + 1) sin theta_i) in RR^(n + 1) | theta_i in [0, pi)} \
  hemi(n) := { vec(
  cos theta_1,
  sin theta_1 cos theta_2,
  sin theta_1 sin theta_2 cos theta_3,
  dots.v,
  sin theta_1 dots.c sin theta_n cos theta_(n + 1),
  sin theta_1 dots.c sin theta_n sin theta_(n + 1),
  ) in RR^(n +1) mid(|) theta_i in [0, pi) }
$
noting that $hemi(0) = {(1)}$, $hemi(1) = {(cos theta, sin theta) | 0 <= theta < pi}$, etc, and $partial hemi(n) = SS^(n - 1)$.


The general set of solutions is then:
$
  z in {
    (a u, plus.minus a v, w) | a in [0, oo), u in hemi(p - 1), v in hemi(q - 1), w in RR^r}
  }
$