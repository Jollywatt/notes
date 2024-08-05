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
#let vv(it) = $bold(overline(it))$

= Boosts in spacetime algebra

Define the boost versor as
$
  boost(bold(zeta)) = exp(1/2 e0 bold(zeta))
$
where $bold(zeta) in RR^n$ is called the _rapidity vector_ and $e0^2 = -1$, the _relativistic velocity_ $bold(beta) = tanh bold(zeta)$ and the _gamma factor_ $gamma = cosh bold(zeta) = (1 - bold(beta)^2)^(-1/2)$.

For a Euclidean vector $bold(p) = bold(p)^perp + bold(p)^parallel$ where $bold(p)^perp dot bold(zeta) = 0$ and $bold(p)^parallel wedge bold(zeta) = 0$:
$
boost(bold(zeta), e0) &= cosh(bold(zeta)) e0 + sinh(bold(zeta)) = gamma(e0 + bold(beta)) \
boost(bold(zeta), bold(p)^perp) &= bold(p)^perp \
boost(bold(zeta), bold(p)^parallel) &= cosh(bold(zeta)) bold(p)^parallel + sinh(bold(zeta)) bold(p)^parallel e0 = gamma(bold(p)^parallel + bold(beta) bold(p)^parallel e0) \
boost(bold(zeta), bold(p)) &= bold(p)^perp + cosh(bold(zeta)) bold(p)^parallel + (sinh(bold(zeta)) dot bold(p)) e0 \
$
(@lsg-tests[Numerical checks])

== Unboosting a vector

Consider a spacetime vector $x in RR^(n,1)$
$
  x = vv(x) + x_0 e0
$
with a Euclidean spatial part $vv(x) in RR^n$ and time component $x_0 in RR$.
Let its norm be $norm(x) = plus.minus sqrt(abs(vv(x)^2 - x_0^2))$ to match the sign of $x^2$.

+ *Spacelike.* $x^2 > 0$, or $norm(vv(x)) slash x_0 > 1$. Then

  $
    x/norm(x) = boost(bold(zeta), vv(x)/norm(vv(x)))
  $
  where $bold(zeta) = "arctanh"(x_0 slash vv(x))$.

  _Proof._
  Note that $bold(beta) = x_0 slash vv(x)$ and $gamma = (1 - x_0^2 slash vv(x)^2)^(-1/2) = norm(vv(x))/norm(x)$
  $
    boost(bold(zeta), vv(x)/norm(vv(x))) = gamma/norm(vv(x)) (vv(x) + vv(x) dot bold(beta) e0) = 1/norm(x) (vv(x) + x_0 e0) = x/norm(x)
    quad qed
  $

+ *Timelike.* $x^2 < 0$, or $norm(vv(x)) slash x_0 < 0$. Then
  $
    x/norm(x) = boost(vv(zeta), e0/norm(e0))
  $
  where $vv(zeta) = "arctanh"(vv(x) slash x_0)$.

  _Proof._
  Note that $bold(beta) = vv(x) slash x_0$ and $gamma = (1 - vv(x)^2 slash x_0^2)^(-1/2) = x_0/norm(x)$
  $
    boost(bold(zeta), e0/norm(e0)) = gamma/norm(e0) (e0 + bold(beta)) = 1/norm(e0) (x_0 e0 + vv(x))/norm(x) = x/norm(x)
    quad qed
  $