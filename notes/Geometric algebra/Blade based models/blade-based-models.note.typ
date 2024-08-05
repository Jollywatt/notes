#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let up = math.op("up")
#let opns = math.mono("OPNS")
#let ipns = math.mono("IPNS")

#let x = $bold(x)$

// #set page(fill: rgb("#171717"))
// #set text(white)

= Blade based models of geometry

Here is a scheme for making blade-based models of geometry.
Say there is a class of algberaic surfaces that you are intersted in.
You want to directly represent these surfaces, and intersections of such surfaces using blades.
This gives you the power of meet and join.

== Examples

For example, suppose we want to model lines
$
A + B x + C y = 0
$
and their intersections (points) or more generally all hyperplanes
$
mat(A_0, A_1, dots.c, A_n) vec(1, x_1, dots.v, x_n) = 0
$
aswell as the tower of lower-dimensional $k$-planes formed by taking intersections.
In PGA, we use homogeneous coordinates
$(x_1, ..., x_n) |-> (1, x_1, ..., x_n)$
and do everything with blades in $RR^(n + 1)$.
Points $P$ and $Q$ can be joined to form a line $P wedge Q$, and so on. 

Or, say we are interested in lines and circles, or curves of the form
$
A + B x + C y + D (x^2 + y^2) = 0
$
in the plane.
We can write the $n$-dimensional generalisation of this as
$
A + bold(B)^T bold(x) + C bold(x)^T bold(x) = 0
$
for $bold(B), bold(x) in RR^n$.
These surfaces are $(n - 1)$-planes and $(n - 1)$-spheres.
In CGA, we use the embedding $up(#x) = (1, #x, 1/2 #x^2) equiv n_0 + #x + 1/2 #x^2 n_oo$ written in terms of a specific basis and metric (but we do not need to consider any metrical properties at this point).
Then, if we have points $P_i = up(#x;_i)$ then the blade $P_1 wedge dots.c wedge P_k$ is exactly the unique $(k - 2)$-sphere through those points (in the OPNS representation).

== In generality

Both of the examples above are cases of the following scheme.
Suppose you wish to model surfaces in $RR^n$ of the form
#eqnum[$
sum_(i=1)^m A_i phi_i = 0
$ <general-surface>]
where $phi_i : RR^n -> RR$ are a set of basis functions.


Define the embedding map:
$
up &: RR^n -> RR^m \
up(#x) &= (phi_1 (#x), ..., phi_m (#x))
$

Now, if you have $(m - 1)$-many points $#x;_i$, then the blade
$
A = up(#x;_1) wedge dots.c wedge up(#x;_(m-1))
$
has outer product null space
$
opns(A) = {#x in RR^n | up(#x) wedge A = 0} 
$
exactly equal to the unique surface of the form of @general-surface which contains the points ${#x;_1, ..., #x;_(m-1)}$.
We know this because clearly $up(#x;_i) wedge A = 0$ and, if we choose a dual
We know $opns(A)$ is a surface of this form because, if we choose a dual (by chosing a Euclidean metric for example) then writing out $#x in opns(A) = ipns("dual"(A))$ implies
$
up(#x) dot "dual"(A) = sum_(i=1)^m A'_i phi_i (#x) = 0
$
for some $A'_i in RR$ which is exactly the form of @general-surface.
And we know $opns(A)$ includes all the points because clearly $up(#x;_i) wedge A = 0$.

If we consider blades of any grade
$
A = up(#x;_1) wedge dots.c wedge up(#x;_k)
$
when we find that $opns(A)$ is the intersection of all surfaces of the form @general-surface containing the points ${#x;_1, ..., #x;_k}$.
In the extreme case, $opns(up(#x))$ is a $0$-dimensional submanifold.
A say this instead of "point" because it is possible that $opns(up(#x))$ contains multiple points (for example, the @1dup-spherical[spherical 1d-up model] cannot represent points in the OPNS but point pairs).
