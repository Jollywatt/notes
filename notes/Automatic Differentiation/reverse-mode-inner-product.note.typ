#import "@local/notes:0.1.0"
#show: notes.style

#let ip(left, right) = $lr(angle.l left, right angle.r)$
#set math.equation(numbering: "(1)")

= On the choice of inner product for reverse mode autodiff

Forward mode @forward-reverse-mode-autodiff[automatic differentiation] transforms a program which computes a function $f : X -> Y$ into a program that returns the primal value $y = f(x)$ along with the directional derivative $DD f[x](dot(x))$ in some given direction $dot(x)$.

In reverse mode, we obtain a program which computes the primal value along with the _adjoint_ of the directional derivative operator $DD f[x]^* : Y -> X$.
This adjoint is only defined with respect to a _choice of inner products_ on the vector spaces $X$ and $Y$.
This choice is usually implicit, even though from the defining relation of the adjoint
$
ip(DD f[x]^*(overline(y)), dot(x))_X = ip(overline(y), DD f[x](dot(x)))_Y
$ <adjoint>
it is clear that different choices of inner product result in different operators $DD f[x]^*$.

== Does the choice of inner product matter?

We care about the actual derivative $DD f[x]$, not the adjoint $DD f[x]^*$.
What we really do in reverse mode is use @adjoint to recover the derivative $DD f[x](dot(x))$ in terms of $DD f[x]^*(overline(y))$ by fixing various values of $overline(y)$ and $dot(x)$.

Indeed, the original choice of inner product is arbitrary.
Varying the inner product varies $DD f[x]^*$ --- but the inner product must be used again to obtain $DD f[x](dot(x))$, and this 'cancels out' the dependence on the inner product.

== Examples to illustrate

When $f : RR^N -> RR$, we chose $overline(y) = 1$ to obtain
$
ip(DD f[x]^*(1), dot(x)) = DD f[x](dot(x)) .
$ <grad>
After computing $overline(x) := DD f[x]^*(1)$ with a single reverse pass, we simply evaluate @grad for each standard basis vector $dot(x) in {dot(e)_1, ..., dot(e)_N}$ in order to obtain the full gradient
$
nabla f[x] := vec(DD f[x](dot(e)_1), dots.v, DD f[x](dot(e)_N)) = vec(ip(overline(x), dot(e)_1), dots.v, ip(overline(x), dot(e)_N)) .
$

When $f : RR^N -> RR^M$, we compute $DD f[x](overline(e)_i)$ once for each standard basis vector $overline(e)_i$ of $RR^M$.
Then, instead of @grad, we have
$
vec(ip(DD f[x]^*(overline(e)_1), dot(x)), dots.v, ip(DD f[x]^*(overline(e)_M), dot(x))) = DD f[x](dot(x)) in RR^M
$
which we may then evaluate for each $dot(x) in {dot(e)_1, ..., dot(e)_N}$ to recover the "gradient" (which is now an $N$-vector of $M$-vectors).