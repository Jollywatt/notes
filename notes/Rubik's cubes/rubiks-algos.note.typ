#import "@preview/cetz:0.4.0"
#import "rubiks.note.typ": *

#set page(width: 15cm, height: auto, margin: 12mm)
#set text(font: "CMU Concrete")
#show math.equation: set text(font: "Concrete Math")
#show heading: it => {
  if target() == "html" { return it }
  pad(y: 0.5em, it)
}
#show pagebreak: it => {
  if target() == "html" { return }
  it
}

#let darkmode = false
#set page(fill: luma(15%)) if darkmode
#set text(white) if darkmode
#set table(stroke: none)

#let framed(it) = context {
  if target() == "html" { html.frame(it) } else { it }
}

#show math.equation: it => {
  if target() == "html" {
    box(html.frame(it))
  } else { it }
}

#let vis(alg, ..args) = framed(align(center, pad(0.5em, {
  draw-cube(twist(solved, eval-alg(alg)), ..args)
  display(alg)
})))
#let vis-top(alg, ..args) = framed(align(center, pad(0.5em, context {
  let a = eval-alg(alg)
  let arrows = state("show-arrows").get() == true
  draw-top(twist(solved, a), scale: 0.5, ..args, arrows: if arrows { a })
  display(alg)
})))
#let vis-3d(alg, ..args) = framed(align(center, pad(0.5em, {
  draw-3d(twist(solved, eval-alg(alg)), scale: 0.5, ..args)
  display(alg)
})))
#let vis-row(..args) = {
  let algs = args.pos()
  table(
    columns: (1fr,)*algs.len(),
    ..algs.map(alg => vis-top(alg, ..args.named()))
  )
}


#let show-reps(n, alg, ..args, columns: 3) = context {
  table(
    columns: columns,
    ..args,
    ..range(n).map(k => vis-top(rep(k + 1, alg)))
  )
}

#let def(name, alg) = {
  (kind: "variable", sym: name, def: alg)
}

#title[Cubing Algorithms]

#outline()


= Orient last layer

#let ruru = def($rho$, con(c(R, U), com(Ri, U)))
$ #formula(ruru, subs, expand) $

#show-reps(6, ruru, columns: 3)

== Crosses

#let fF = def($frak({f F})$, c(con(f, com(R, U)), con(F, com(R, U))))
$ formula(fF; subs;; expand) $
#show-reps(6, fF, columns: 3)

#let Ff = def($frak({F f})$, c(con(F, com(R, U)), con(f, com(R, U))))
$ formula(Ff; subs;; expand) $
#show-reps(6, Ff, columns: 3)


=== Deformed crosses


#let deform-fF(X) = def(${frak(f) display(#X) frak(F)}$, c(con(f, com(R, U)), X, con(F, com(R, U))))
$ formula(#deform-fF(X) ; subs;; expand) $
#show-reps(4, deform-fF(U), columns: 4)
#let deform-Ff(X) = def(${frak(F) display(#X) frak(f)}$, c(con(F, com(R, U)), X, con(f, com(R, U))))
$ formula(#deform-Ff(X) ; subs;; expand) $
#show-reps(4, deform-Ff(U), columns: 4)


== Headlights

#let bow = def($frak(H)$, con(R, com(con(R, D), U2)))

#let mini-top(..args, scale: 0.3) = $#draw-top(twist(solved, eval-alg(..args)), scale: scale)$
#let mini-3d(..args, scale: 0.5) = $#draw-3d(twist(solved, eval-alg(..args)), scale: scale)$

#mini-top(inv(bow)) is solved by #formula(bow, subs).

#let bow-alt = simplify(refl(z, (con(R2, com(D, con(Ri, U2))))))
Alternatively, #mini-top(inv(bow-alt)) is solved by #formula(bow-alt).

#show-reps(3, bow)
Pronouce as #display(c(g(R2, D), g(Ri, U2), g(R, Di, Ri), g(U2, Ri))).

Compare:
#table(
  columns: 2,
  vis-top(bow),
  vis-top(rot2(y, rep(3, ruru)))
)

== Bug eyes


#let bug = def($frak(B)$, c(con(c(r, U), Ri), con(F, R)))
#mini-top(inv(bug)) is solved by #formula(bug, subs, expand).
#show-reps(3, bug)



== Crossfinder

#let crossfinder = def($plus.square$, con(F, com(R, U)))
#show-reps(6, crossfinder)

== Swish-swish

#let swishswish = c(com(R, U), com(Ri, F))
#show-reps(3, swishswish)

#pagebreak()

= Permute last layer

#state("show-arrows").update(true)

== Edges

=== Z-permutation
#vis-top(c(g(M2, U), g(M2, U), g(M, U2), g(M2, U2), g(M, U2)))

=== H-permutation

#vis-top(c(M2, U, M2, U2, M2, U, M2))

=== U-permutation

#let uperm = def($frak(U)$, c(g(R2, U), g(R, U), rep(2, c(Ri, Ui)), g(Ri, U, Ri)))

$
  formula(uperm; subs) \
  formula(inv(uperm); subs, simplify) \
  formula(refl(x, uperm); simplify)
$

#table(
  columns: 2,
  vis-top(uperm),
  vis-top(refl(x, uperm)),
)

Alternatively:
$
  display(uperm) &= #display(con(R, c(con(rep(2, R, U), Ri), U)))) \
  display(refl(x, uperm)) = display(inv(uperm)) &= #display(con(R, c(Ui, con(rep(2, R, U), R))))) \
$

The U-permutation can also be derived from this:

#table(
  columns: 2*(1fr,),
  align: center,
  vis(c(U, con(Mi, U2), U), scale: 0.5),
  vis(con(F2, c(U, con(Mi, U2), U)), scale: 0.5),
)

#pagebreak()

== Corners

=== A-permutation

Clockwise, positioned bottom-left:
#let tri = def($frak(A)$, c(g(Ri, F, Ri), con(c(B2, R), Fi), R2))
$
  formula(tri, subs, expand) \
  formula(inv(tri); subs, simplify) \
$
Anticlockwise, positioned bottom-right:
$ #formula(refl(x, tri), simplify, expand) $
#table(
  columns: 2,
  vis-top(tri),
  vis-top(refl(x, tri)),
)




=== Y-permutation

#let yperm = def($frak(y)$, c(con(F, con(con(R, Ui), Ui)), com(R, U), com(Ri, F)))
#let yperm = def($frak(y)$, c(con(c(F, con(R, Ui)), Ui), com(R, U), com(Ri, F)))
$
  formula(yperm, subs) \
  = formula(inv(yperm); subs, simplify) \
  formula(refl(x, yperm), simplify)
$


#show-reps(2, yperm)


=== J-permutation

#vis-top(c(Li, U2, L, U, Li, U2, R, Ui, L, U, Ri))
#vis-top(c(con(Li, U2), U, Li, U2, R, Ui, L, U, Ri))
#vis-top(c(R, U2, Ri, Ui, R, U2, Li, U, Ri, Ui, L))

#pagebreak()

=== R-permutation

#let rperm = def($frak(R)$, c(g(Ri, U2, R, U2), Ri, F, g(R, U, Ri, Ui), Ri, Fi, R2, Ui))
$
formula(rperm, subs) \
formula(refl(x, rperm); subs, simplify) \
$

#vis-row(rperm, refl(x, rperm))

=== T-permutation

#vis-top(c(com(R, U), g(Ri, F, R2), con(c(Ui, Ri), Ui), Ri, Fi))

=== F-permutation

#let spin = def($op(arrow.ccw)$, c(xi, zi))
#let fperm = def($frak(F)$, c(com(R, U), R, U2, spin, com(R, U), spin, com(Ri, Ui), R2))
$
  formula(spin, subs) =
  #mini-3d(I, scale: 0.2) |->
  #mini-3d(spin, scale: 0.2) \
  formula(fperm, #(i => i.def))
$


#mini-3d(inv(fperm)) is solved by #display(fperm)


=== E-permutation

#let eperm = def($Xi$, c(g(Ui, R, U, Li), g(Ui, Ri, U, L), g(Ui, Ri, U, Li), g(Ui, R, U, L)))


$
  formula(eperm, subs) \
  formula(refl(x, eperm); subs, simplify) \
  formula(refl(z, eperm); subs, simplify) \
  formula(rot(z, eperm); subs, simplify) \
$

#table(
  columns: 3*(1fr,),
  align: bottom, 
  vis-3d(eperm),
  vis-top(con(xi, eperm)),
  vis-3d(refl(z, eperm)),
)

=== V-permutation

#let vperm = def($frak(V)$, c(com(Ri, U2), con(c(con(c(L, Ui), Ri)), U)))
$
  formula(vperm; subs;;expand)
$
#vis-top(vperm)


=== N-permutation


#let nperm = def($frak(N)$, c(g(R,U,Ri,U,R,U,Ri,Fi), com(R, U), g(Ri, F), g(R2, Ui, Ri, U2, R, Ui, Ri)))
$
  formula(nperm; subs;; expand)
$
#vis-top(nperm)


Alternatively:

#let nperm = def($frak(N_star)$, c(
  rep(2, Ri, U, Li, U2, R, Ui, L), U
))
#vis-top(nperm)
#vis-top(refl(x, nperm))
$
formula(nperm; subs, simplify) \
formula(refl(x, nperm); subs, simplify)
$


#let nperm = def($frak(N_star)$, c(
  z, rep(2, g(D, Ri, U), g(R2, Di, R, Ui)), R, zi
))
#vis-top(subs(nperm))


=== G-permutation


#let gperm = def($frak(G)$, c(con(Fi, Ui), con(c(R2, u, Ri, U), R)))
$
  formula(gperm; subs;; expand) \
  formula(inv(gperm); subs, simplify;; expand) \
  formula(refl(x, gperm); subs, simplify;; expand) \
$

#vis-top(gperm)
#vis-top(refl(x, gperm))


