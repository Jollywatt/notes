#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *
  
#let e0 = $e_0$
#let boost(..args) = {
  if args.pos().len() == 1 {
    let (dir,) = args.pos()
    $mono(B)_dir$
  } else if args.pos().len() == 2 {
    let (dir, it) = args.pos()
    $boost(dir)[it]$
  }
}

= Blade classifications

Any Lorentzian blade is of the form
$
  X = cases(
    boost(zeta, E) & zeta parallel E & "spacelike",
    E wedge (hat(n) + e) quad & E perp hat(n)\, norm(hat(n)) = 1 quad & "lightlike",
    boost(zeta, E wedge e0) & zeta perp E & "timelike",
  )
$
for a Euclidean blade $E$ and rapidity vector $zeta in RR^n$.

*Proof.*

We can always use write
$
  X = rej(X, e0) + proj(X, e0) = Y wedge xi, quad xi = arrow(x) + x_0 e0
$
using @multivector-proj-rej[projections and rejections] where $Y$ is a Euclidean blade and $Y perp arrow(x)$.

+ *Spacelike case.* If $X rev(X) > 0$, then $xi^2 > 0$ and by @sta-boosts we have
  $
    xi = boost(zeta, h) quad h = sqrt(xi^2) arrow(x)/norm(arrow(x))
  $
  where $tanh zeta = x_0 slash arrow(x) in RR^n$ and $h in RR^n$.
  Now, since $Y perp arrow(x)$, we have $Y perp zeta$ also, and $boost(zeta, Y) = Y$ so that
  $
    X = Y wedge boost(zeta, h) = boost(zeta, Y wedge h) = boost(zeta, E)
  $
  and since $E wedge h = 0$ we have $E parallel zeta$.
+ *Timelike case.* If $X rev(X) < 0$, then $xi^2 < 0$ and by @sta-boosts we have
  $
    xi = boost(zeta, sqrt(-xi^2) e0)
  $
  where $tanh zeta = arrow(x) slash x_0$ so that
  $
    X = Y wedge boost(zeta, sqrt(-xi^2) e0) = boost(zeta, E wedge e0)
  $
  where $E =  sqrt(-xi^2) Y$. Since $Y perp arrow(x)$ we have $E perp zeta$.

== Older notes
_First method._

Consider the case where $X$ is a spacelike vector first.
Then
$
  X = arrow(x) + x_0 e0
$
where $arrow(x) in RR^n$ is the spatial part and $x_0$ is the time component, with $norm(arrow(x))^2 > x_0^2$.

Let $s = sqrt(X^2)$, let $hat(n) = arrow(x) slash norm(arrow(x)) in RR^n$ and let $zeta = "arctanh"(x_0 slash norm(arrow(x)))$.
Then
$
  boost(zeta hat(n), s hat(n)) = s hat(n) cosh(zeta) + s e0 sinh(zeta)
  = s (hat(n) + e_0 x_0/norm(arrow(x)))/sqrt(1 - x_0^2/norm(arrow(x))^2)
  = s (norm(arrow(x)) hat(n) + x_0 e0)/(s) = arrow(x) + x_0 e0 = x
$
No we may consider a spacelike blade, $X$. It has a @multivector-proj-rej[decomposition]
$
  X = rej(X, e0) + proj(X, e0) = Y wedge (arrow(x) + x_0 e0)
$
with $Y perp arrow(x)$ which must factorise because $X$ is a blade.
You can solve for $Y x_0 = proj(X, e0) e0^(-1) = X dot e0^(-1)$ and hence $arrow(x)/x_0 = Y^(-1) dot rej(X, e0)$.
Then
$
  boost(zeta hat(n), Y wedge s hat(n)) = Y wedge boost(zeta hat(n), s hat(n)) = Y wedge (arrow(x) + x_0 e0) = 0
$
because $Y perp hat(n)$ where $hat(n) = arrow(x)/norm(arrow(x))$ and $s = sqrt(arrow(x)^2 - x_0^2)$ as before.
So we have written $X$ in terms of the Euclidean blade $E = Y wedge s hat(n)$ with rapidity $zeta hat(n)$.
Note that the Euclidean blade $E$ and rapidity vector are incident.

_Second method._

If $X rev(X) > 0$ then $X$ is spacelike, and we may define the timelike vector
$
  mu = 1/2 (e0 + hat(X) e0 X^(-1)) = (e0 wedge X) X^(-1) = rej(e0, X)
$
which satisfies $mu dot X = 0$ and then define
$
  zeta = "arctanh"(arrow(mu)/mu_0)
$
where $mu = arrow(mu) + mu_0 e0$ is the split into spacelike $arrow(mu) in RR^n$ and time $mu_0$ components.
Notice that
$
  boost(zeta, e0) = e0 cosh(zeta) + sinh(zeta) = (e0 + arrow(mu)/mu_0)/sqrt(1 - arrow(mu)^2/mu_0^2) = (mu_0 e0 + arrow(mu))/sqrt(mu_0^2 - arrow(mu)^2) = mu/sqrt(abs(mu^2))
$
using identities for $cosh compose "arctanh"$ and $sinh compose "arctanh"$.
Then,
$
  E := boost(-zeta, X)
$
is spacelike because
$
  E dot e0 &= boost(-zeta, X dot boost(zeta, e0)) = X dot mu/sqrt(abs(mu^2)) = 0
$
so overall we have $X = boost(zeta, E)$ where $E$ is a Euclidean blade and $zeta in RR^n$ is a rapidity vector.

It's also true that $zeta parallel E$, but this is harder to see this way.