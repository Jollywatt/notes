#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let up = math.op("up")
#let opns = math.sans("OPNS")
#let ipns = math.sans("IPNS")
#let ma(trix) = $mono(trix)$


#let blades(..args) = {
  let (k, n) = if args.pos().len() == 2 {args.pos()} else {(none, args.pos().first())}
  $#move(dy: -0.06em, scale(wedge, y: 126%, origin: bottom))^#k #h(-.01em)RR^#n$
}

= Visualising blades by sampling points in $opns$ or $ipns$

Suppose we have a blade based model of geometry in which points in the _base space_ $RR^n$ are represented by null vectors in a _representation space_ $RR^m$.
We are interested in determining which points are contained in the outer or inner product null space of a given $k$-blade $A in blades(k, m)$.
Specifically, we want to sample from the sets
$
  opns(A) = {u in RR^m mid(|) u^2 = u wedge A = 0} \
  ipns(A) = {u in RR^m mid(|) u^2 = u dot A = 0} \
$

#rect[
  For example, in 3d CGA, $bold(x) in RR^3$ is represented by the vector $up(bold(x)) = n_0 + bold(x) + 1/2 bold(x)^2 n_oo$ satisfying $up(bold(x))^2 = 0$, and lines may be constructed as
  $L = up(bold(x)) wedge up(bold(y)) wedge n_oo$.
  We seek an algorithm to sample points $bold(z) = t bold(x) + (1 - t) bold(y)$ that works similarly for all blades.
]

== Method

_Given a blade $A in blades(k, m)$, find a vector $u in RR^m$ such that $u dot u = 0$ and $u wedge A = 0$ (for the $opns$)._

+ Find a factorisation $A = arrow(a)_1 wedge dots.c wedge arrow(a)_k$ where $arrow(a)_i in RR^m$ using the method of #cite(<fontijne2010>, form: "prose"), for example.

+ Form the matrix $ma(A) = [arrow(a)_1 dots.c arrow(a)_k]$.
  If we have $u := ma(A) v$ for some $v in RR^k$ then $u$ necessarily lies in the column span of $ma(A)$, thus $u wedge A = 0$.

+ The condition $u dot u = 0$ is equivalent to $u^T eta u = 0$ where $eta$ is the matrix of metric components. (E.g., for 3d CGA, $eta = "diag"(1,1,1,1,-1)$.)

  Ensuring this condition holds means $u^T eta u = v^T ma(A)^T eta ma(A) v = 0$.

+ Diagonalise the symmetric matrix $ma(B) := ma(A)^T eta ma(A)$ so it is of the form $ma(B) = ma(U)^T ma(D) ma(U)$ where $ma(D)$ is diagonal and $ma(U)^T ma(U) = ma(I)$.
  This standard factorisation is the same as finding the eigenvalues and eigenvectors.

+ If we set $w = ma(U)v$ then $u^T eta u = v^T ma(A)^T eta ma(A) v = v^T ma(U)^T ma(D) ma(U) v = w^T ma(D) w = 0$.
  This means the condition $u dot u = 0$ is equivalent to $w^T ma(D) w = 0$.
  Finding such values for $w$ once we knoe $ma(D)$ is easy.

+ Let $ma(D) = "diag"(lambda_1, ..., lambda_k)$ and let $I_+, I_-, I_0$ be the sets of indices for which the corresponding entries $lambda_i$ are positive, negative, or zero, respectively.
  + *If $I_+ != nothing$ and $I_- != nothing$*, then choose any values for the components $w_i$, but scale the components corresponding to $I_+$ and $I_-$ appropriately so that
    $ sum_(i in I_+) w_i^2 = sum_(j in I_j) w_j^2 $
    which can be achieved by normalising the two subsets of components.
  + *If $I_+ = nothing$ or $I_- = nothing$*, then any value $w_i$ can be chosen for each $i in I_0$, while all others must be zero, $j in.not I_0 => w_j = 0$.
    In particular, if $I_0 = nothing$, then only the trivial solution $w = 0$ exists.
  
  If such a $w$, we can recover $u = ma(A)ma(U)^T w$

  By varying $w$, subject to the constraints above (e.g., by randomly sampling $w$ and applying normalisations) we can explore the family of solutions.

#notes.references()