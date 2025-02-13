#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let ip(left, right) = $lr(angle.l left, right angle.r)$
#set math.equation(numbering: "(1)")

= On the choice of inner product for reverse-mode autodiff

Forward mode @forward-reverse-mode-autodiff[automatic differentiation] transforms a program which computes a function $f : X -> Y$ into a program that returns the primal value $y = f(x)$ along with the directional derivative $dot(y) = DD f[x](dot(x))$ in some given direction $dot(x)$.

In reverse mode, we obtain a program which computes the primal value along with the _adjoint_ of the directional derivative operator $DD f[x]^* : Y -> X$.
_Then_, during the reverse pass, we evaluate this operator to obtain a final derivative $overline(x) = DD f[x]^* (overline(y))$ given some $overline(y)$.

#env(accent: teal)[Notation][
	In #link("https://compintell.github.io/Mooncake.jl/stable/")[Mooncake.jl], the adjoint operator $DD f[x]^*$ is the `pb!!` closure returned in
	```julia
	out, pb!! = rule(fx_fwds...)
	```
	and $overline(x)$ is the second return value of ```julia value_and_pullback!!(rule, ȳ, f, x...)```.

]

We tend to treat $dot(y)$ (returned by forward-mode) and $overline(x)$ (returned by reverse-mode) as the same.
We should be careful, because they do not strictly belong to the same space.
Instead, there is one more step we should do to recover $dot(y)$ from $overline(x)$ after reverse-mode.
We tend to skip this step because, with the standard adjoint operator, $dot(y)$ and $overline(x)$ both look the same.

== Adjoints and inner products

The adjoint $DD f[x]^*$ is dependent on a #highlight[choice of inner products] on the vector spaces $X$ and $Y$.
This choice is usually implicit, even though from the definition of the adjoint
$
ip(DD f[x]^*(overline(y)), dot(x))_X = ip(overline(y), DD f[x](dot(x)))_Y
$ <adjoint>
it is clear that different choices of inner product result in different operators $DD f[x]^*$.

== The gradient of a function

Forward-mode and reverse-mode calculate different things, but usually what we are ultimately interested in is the gradient $nabla f in X$ of $f : X -> RR$.
This is defined component-wise as
$
  (nabla f)_i = DD f[x](e_i)
$ <fgrad>
where ${e_i}$ is a basis of the  vector space $X$.
From reverse mode we have $DD f[x]^*(1)$ instead, but we can recover the gradient as
$
  (nabla f)_i = ip(DD f[x]^*(1), e_i)
$
which is equal to @fgrad by @adjoint.


== #highlight[Does the choice of inner product matter?]

Suppose $y = f(x)$.
The reverse-pass yeilds $overline(x) = DD f[x]^*(overline(y))$ for an initial $overline(y)$.
We are interested in the directional derivatives $dot(y) = DD f[x]^*(dot(x))$ for each linearly independent $dot(x)$.
Using @adjoint, we can obtain $dot(y)$ as
$
ip(overline(x), dot(x)) = ip(overline(y), text(#green.darken(20%), dot(y)))
$

At first glance it is not obvious that reverse-mode differentiation is independent of the inner products involved.

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
