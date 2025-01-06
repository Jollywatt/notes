#import "@local/notes:0.1.0"
#show: notes.style

#let mooncake = link("https://compintell.github.io/Mooncake.jl")[Mooncake.jl]

#let ip(left, right) = $lr(angle.l left, right angle.r)$

#let eqnum(it) = {
	set math.equation(numbering: "(1)")
	it
}

= Understanding #mooncake

#mooncake is a reverse-mode automatic differentiation framework for Julia which aims, in particular, to support mutation.

== Notations

If $x$ is a primal value, then $dot(x)$ is like $dif x$, and $overline(x)$ is like $diff/(diff x)$.

=== Pushforward, or directional derivative

Let $f : X -> Y$ be a function between normed spaces $(X, ||dot.c||_X)$ and $(Y, ||dot.c||_Y)$.

The directional derivative of $f$ at $x$ in the direction $dot(x)$ is
#eqnum[$
DD f[x](dot(x)) := lim_(epsilon -> 0) (f(x + epsilon dot(x)) - f(x))/epsilon
$]
where the limit of a function $h : RR -> Y$ is understood as to mean:
$
lim_(epsilon -> 0) h(epsilon) = h_0 <==> lim_(epsilon -> 0) ||h(epsilon) - h_0||_Y = 0
$
You may prefer to write this as a Fréchet derivative:
$
lim_(||dot(x)||_X -> 0) (||f(x + dot(x)) - f(x) - DD f[x](dot(x))||_Y)/(||dot(x)||_X) = 0
$
Or in Landau notation:
$
f(x + dot(x)) = f(x) + DD f[x](dot(x)) + cal(O)(dot(x))
$

=== Adjoints of linear operators

Adjoint $A^*$ of a linear operator $A$:
$
ip(A(dot(x)), overline(y)) = ip(dot(x), A^*(overline(y)))
$
Define this inner product on the Hilbert space of "types", e.g., on tuples of numbers and vectors:
$
ip((x, arrow(u)), (y, arrow(v))) = x y + ip(arrow(u), arrow(v))
$
This just makes bookkeeping easier: we don't need to write all linear operators as matrices in order to find the adjoint.


== Quick questions

- Is forward mode supported? E.g., to differentiate $f : RR -> RR^N$ in one pass.
	- Not currently, but it's in the works.
- Are `CoDual` elements the categorical dual of `Dual` numbers, as in https://higherlogics.blogspot.com/2020/05/dualcodual-numbers-for-forwardreverse.html?
	- No relation; `CoDual` is simply a primal value paired with a tangent (no distinction is drawn between vector spaces and dual vector spaces).
- How does the interface work? If I define a method on `ftype_data()`, how do I make it visible to `fdata()`, which is a _generated_ function?
	- Only overload `tangent_type` is you want to. But it should work out-of-the-box with custom types.
- How do I make `tangent(fdata(x), rdata(x)) === x` for `x::MyType`?

== Things to look into

- `test_tangent_consistency`, `test_data`
- How does the choice of inner product affect things?


