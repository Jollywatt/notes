#import "@local/notes:0.1.0"
#show: notes.style

= Poincaré half-plane model

Define a metric on the upper half-plane $RR times (0, oo)$ by
$
g = (dif x^2 + dif y^2)/y^2
$
Transformations in the half-plane which preserve this metric (the isometries) are given by
$
z |->^psi (a z + b)/(c z + d)
$
where $z = x + i y$, for any real numbers $a, b, c, d$.
By differentiating this mapping, we find that tangent vectors transform as
$
delta z |-> J delta z
quad "where" quad J := (a d - b c)/(c z + d)^2
$
where $delta z$ is a tangent vector at $z$.
By showing that
$
g(u, v)|_z = g(J u, J v)|_psi(z)
$
we prove that the metric is preserved by this family of transformations.

See @hyperbolic-isometries for numerical proofs.

== Example transformations

An upward ray transforms as:
$
i e^t |-> (a i e^t + b)/(c i e^t + d)
$
which, written without reference to complex numbers, is
$
vec(x, y) |-> 1/(c^2 e^(2t) + d^2) vec(a c e^(2t) + b d, a d e^t - b c e^t)
$