#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *



#let ee(it) = $bold(e)_it$
#let e0 = ee(0)
#let up = math.op("up")

#let (ldual, rdual) = (math.op("ldual"), math.op("rdual"))
#let ldual(it) = $underline(it)$
#let rdual(it) = $overline(it)$
#let trans = versor.with[T]

= Plane-based Projective Geometric Algebra and Intrinsic/Extrinsic Orientation
In Euclidean $n$-space, a hyperplane $A$ has homogeneous form
$
  A: a_1 x_1 + dots.c + a_n x_n + b = 0
$
which motivates its representation as the vector
$
  A := a_1 ee(1) + dots.c + a_n ee(n) + e0
  .
$

Next, $k$-planes can be represented as $(n - k + 1)$-fold wedge products of planes of this form.
$
  (n - k)"-plane" : A_0 wedge dots.c wedge A_(k - 1)
$
In particular, points are wedges of $n$ different hyperplanes.

== Non-metrical duality

Later, we will want to adopt a degenerate metric. We would still like a non-degenerate duality between $k$- and $(n - k)$-blades, however.
This means we cannot use pseudoscalar multiplication as a duality, like in @cga[conformal geometric algebra].

Introduce a metric-invariant dual operation defined by
$
  ee(I) rdual(ee(I)) = II quad "(right dual)"
$ <rdual>
for any multi-index $I$ where $II$ is a _choice_ of unit pseudoscalar.
There are two unit pseudoscalars per algebra; let's pick $II = ee(1)ee(2)dots.c ee(n) e0$ for now.


Note that @dorst2024 calls the dual defined in @rdual the "Hodge dual". I think this is misleading, because the Hodge dual should be metric-depentent, according to its most recognisable definition as something like $alpha wedge star beta = chevron.l alpha, beta chevron.r omega$ or $star A = rev(A) II$ in GA.

I prefer to call the duality defined by @rdual the *right dual*, or `rdual` in code, as opposed to the *left dual* satisfying $ldual(ee(I)) ee(I) = II$.
#link("https://rigidgeometricalgebra.org/wiki/index.php?title=Complements")[Eric Lengyel calls these _left and right complements_.]

Note that the dual $rdual(A)$ has inverse $ldual(A)$ and while $rdual(ldual(A)) = A$ always, in general we have $rdual(rdual(A)) = ldual(ldual(A)) = plus.minus A$ (depending on whether the grade of $A$ and dimension of the algebra are even or odd).

== Point embedding and the translation versor

We may define the point embedding map $up : RR^n -> R^(n + 1)$ as
$
  up(arrow(x)) = rdual(arrow(x) + e0)
  .
$

If we pick the metric $ee(i)^2 = 1$, $e0^2 = 0$, then the translation versor $trans(arrow(p))[up(arrow(x))] = up(arrow(p) + arrow(x))$ is given by
$
  trans(arrow(p)) = exp(inline(1/2) arrow(p) e0)
  .
$

== Left/right duals do not commute with versors

Note that $trans(arrow(p), rdual(A)) != rdual(trans(arrow(p), A))$ in general, even though $trans(arrow(p))$ is an algebra automorphism.
This is because left/right duality is not expressible with "pure GA" operations.

Compare this to CGA, where the dual operation is a composition of geometric multiplication (with the pseudoscalar) and possibly other automorphisms (usually reversion).

= Orientation

In @dorst2024, Leo introduces a cute notation for _intrinsic_ and _extrinsic_ notation.
Here we consider the case for basis blades of grade one and two in three dimensions only.

#let leoji = (:)
#{
  let line = image("leojis/line.png", height: 1.5em)
  let axis = image("leojis/axis.png", height: 1.5em)
  let plane = image("leojis/plane.png", height: 1.5em)
  let persp-cw = image("leojis/persp cw.png", height: 1.5em)
  let persp-ccw = image("leojis/persp ccw.png", height: 1.5em)
  let norm-out = image("leojis/norm out.png", height: 1.5em)
  let norm-in = image("leojis/norm in.png", height: 1.5em)
  let line-out = image("leojis/line out.png", height: 1.3em)
  let line-in = image("leojis/line in.png", height: 1.3em)
  let line-cw = image("leojis/line cw.png", height: 1.1em)
  let line-ccw = image("leojis/line ccw.png", height: 1.1em)
  let plane-out = image("leojis/plane out.png", height: 1.2em)
  let plane-in = image("leojis/plane in.png", height: 1.2em)

  let r = rotate.with(reflow: true)
  let flip = scale.with(x: -100%)

  leoji.i = (:)
    leoji.i.line = (:)
      leoji.i.line.t = line
      leoji.i.line.r = r(90deg,  line)
      leoji.i.line.b = r(180deg,  line)
      leoji.i.line.l = r(270deg,  line)
      leoji.i.line.out = line-out
      leoji.i.line.in = line-in

    leoji.i.plane = (:)
      leoji.i.plane.ccw = (:)
        leoji.i.plane.ccw.z = plane
        leoji.i.plane.ccw.r = persp-ccw
        leoji.i.plane.ccw.l = flip(persp-cw)
        leoji.i.plane.ccw.t = r(-90deg, persp-ccw)
        leoji.i.plane.ccw.b = r(90deg, persp-ccw)
      
      leoji.i.plane.cw = (:)
        leoji.i.plane.cw.z = flip(plane)
        leoji.i.plane.cw.r = persp-cw
        leoji.i.plane.cw.l = flip(persp-ccw)
        leoji.i.plane.cw.t = r(-90deg, persp-cw)
        leoji.i.plane.cw.b = r(90deg, persp-cw)
  leoji.o = (:)
    leoji.o.line = (:)
      leoji.o.line.t = axis
      leoji.o.line.b = flip(axis)
      leoji.o.line.r = r(90deg, axis)
      leoji.o.line.l = r(90deg, flip(axis))
      leoji.o.line.cw = line-cw
      leoji.o.line.ccw = line-ccw
    leoji.o.plane = (:)
      leoji.o.plane.out = (:)
        leoji.o.plane.out.t = r(-90deg, norm-out)
        leoji.o.plane.out.b = r(90deg, norm-out)
        leoji.o.plane.out.r = norm-out
        leoji.o.plane.out.l = flip(norm-out)
        leoji.o.plane.out.z = plane-out
      leoji.o.plane.in = (:)
        leoji.o.plane.in.t = r(-90deg, norm-in)
        leoji.o.plane.in.b = r(90deg, norm-in)
        leoji.o.plane.in.r = norm-in
        leoji.o.plane.in.l = flip(norm-in)
        leoji.o.plane.in.z = plane-in

}

#let blade-to-leoji = (
  "e1":     (i: leoji.i.line.r,       o: leoji.o.line.r),
  "-e1":    (i: leoji.i.line.l,       o: leoji.o.line.l),
  "e2":     (i: leoji.i.line.out,     o: leoji.o.line.cw),
  "-e2":    (i: leoji.i.line.in,      o: leoji.o.line.ccw),
  "e3":     (i: leoji.i.line.t,       o: leoji.o.line.t),
  "-e3":    (i: leoji.i.line.b,       o: leoji.o.line.b),
  "e12":    (i: leoji.i.plane.ccw.t,  o: leoji.o.plane.out.t),
  "-e12":   (i: leoji.i.plane.cw.t,   o: leoji.o.plane.in.t),
  "e13":    (i: leoji.i.plane.ccw.z,  o: leoji.o.plane.out.z),
  "-e13":   (i: leoji.i.plane.cw.z,   o: leoji.o.plane.in.z),
  "e23":    (i: leoji.i.plane.ccw.r,  o: leoji.o.plane.out.r),
  "-e23":   (i: leoji.i.plane.cw.r,   o: leoji.o.plane.in.r),
)

#figure(table(
  columns: 3,
  align: horizon + center,
  [Blade], [Intrinsic], [Extrinsic],
  ..blade-to-leoji.pairs().map(((k, v)) => {
    let (sign, indices) = k.replace("-", "–").split("e")
    ($op(sign)e_indices$, v.i, v.o)
  }).flatten()
), caption: [Icons for basis blades in $RR^3$ with intrinsic/extrinsic orientation.])


If $A$ and $B$ are intrinsically oriented blades, the "correct" formula for $B$ reflected in $A$ is
#notes.result-box($
  A[B] = (-1)^(\#A \#B) A B A^(-1)
$)
derived from the vector reflection formula $b |-> -a b a^(-1)$. For each of the $\#B$ vector factors in $B$, there are $\#A$ many reflections, so $\#A \#B$ many sign flips in total. 

#pagebreak()

= Reflection experiments


#import "@local/parsely:0.0.1" as parsely: slot
#import "@local/tinyga:0.0.1" as ga

#let grammar = (
  sub: (infix: $-$, prec: 1),
  add: (infix: $+$, prec: 1, assoc: true),
  mul: (infix: $$, prec: 2, assoc: true),
  neg: (prefix: $-$, prec: 2),
  invol: (match: $hat(slot("inner*"))$),
  rev: (match: $rev(slot("inner*"))$),
  inv: (match: $slot("inner*")^(-1)$),
  pow: (match: $slot("base")^slot("exp")$),
  group: (match: $(slot("inner*"))$),
  grade: (prefix: $\#$, prec: 3),
)

#let eval-ga-expr(tree, scope) = parsely.walk(tree,
  leaf: it => {
    if repr(it.func()) == "symbol" {
      if it.text in scope { return scope.at(it.text) }
    } else if it.func() == text {
      eval(it.text)
    } else {
      panic(it)
    }
  },
  post: ((head, args, slots)) => {
    // if head == "inv" { ga.inv(slots.inner) }
    if head == "inv" { ga.inv(slots.inner) }
    else if head == "mul" { ga.mul(..args) }
    else if head == "add" { ga.add(..args) }
    else if head == "sub" { ga.add(args.first(), ga.mul(-1, args.last())) }
    else if head == "rev" { ga.rev(slots.inner) }
    else if head == "invol" { ga.invol(slots.inner) }
    else if head == "neg" { ga.mul(-1, args.first()) }
    else if head == "pow" {
      if type(slots.base) in (int, float) { calc.pow(slots.base, slots.exp)}
      else { panic("pow not implemented for", slots.base) }
    }
    else if head == "group" { slots.inner }
    else if head == "grade" { ga.grades(args.first()) }
    else {
      panic(head)
    }
  }
)

#let experiment(eq, senses: "ii", goal: ()) = {
  let tree = parsely.parse(eq, grammar).tree

  let (x, y, z) = ga.basis((euclidean: 3), 1)
  let basis = (x, y, z, ga.mul(y, z), ga.mul(z, x), ga.mul(x, y))

  // let basis = (x, z, ga.mul(x, z))

  let icon(mv, sense) = {
    let leoji = blade-to-leoji.at(ga.repr-mv(mv)).at(sense)
    $attach(limits(leoji), b: #ga.show-mv(mv))$
  }

  show table: set text(0.8em)
  set figure.caption(position: top)

  let goal = goal.map(row => row.clusters().map(c => c != " "))

  figure(table(
    columns: basis.len(),
    stroke: 0.5pt + gray,
    inset: 10pt,
    gutter: 2pt,
    align: center + horizon,
    ..basis.enumerate().map(((j, b)) => basis.enumerate().map(((i, a)) => {
      let c = eval-ga-expr(tree, (A: a, B: b))
      let left = icon(a, senses.first())
      let right = icon(b, senses.last())
      let result = icon(c, senses.last())
      let is-flipped = b.coeff != c.coeff
      let should-be-flipped = goal.at(j, default: ()).at(i, default: none)
      let s = if should-be-flipped == true { blue.lighten(50%) + 1pt}
      let f = if is-flipped { blue.lighten(90%) }
      table.cell($ left[right] = result $, fill: f, stroke: s)
    })).flatten()
  ), caption: [Cayley table for $A[B] := eq$])
}

#experiment($(-1)^(\#A\#B) A B A^(-1)$, senses: "ii", goal:(
  ".   ..",
  " . . .",
  "  ... ",
  " .. ..",
  ". .. .",
  ".. .. ",
))

#experiment($(-1)^((3 - \#A)\#B) A B A^(-1)$, senses: "io")
#experiment($(-1)^(\#A(3 - \#B)) A B A^(-1)$, senses: "oi")
#experiment($(-1)^((3 - \#A)(3 - \#B)) A B A^(-1)$, senses: "oo")
