#set text(font: "Crimson Pro")
#set page(margin: 15mm, width: 16cm, height: auto)



#let color-box(title, color, body) = {
  block(fill: color.lighten(98%), stroke: color.lighten(70%) + 0.6pt, radius: .7em, inset: .7em, width: 100%)[
    #text(color.lighten(30%))[_#title:_]
    
    #body
  ]
}

#let define = color-box.with([Define], orange)
#let note = color-box.with([Note], blue)
#let derive = color-box.with([Derive], gray)
#let summary = color-box.with([Summary], purple)


// spacetime algebra
#let vs = $arrow(sigma)$
#let del = $arrow(nabla)$

#let wedge = math.and

#let grade(i, a) = $underbrace(#a, (#i))$

#let proj(it) = $angle.l it angle.r$


#show heading: it => it + v(2em, weak: true)
#show heading.where(level: 1): it => pagebreak(weak: true) + it


= Spacetime algebra

#define[
- The spacetime basis vectors $gamma_0^2=-gamma_i^2 = plus.minus 1$ for $i in {1,2,3}$ and $gamma_i gamma_j = -gamma_i gamma_j$ for $i != j$.
- $gamma^mu = plus.minus gamma_mu$ such that $gamma^mu gamma_mu = 1$ for each of $mu in {0,1,2,3}$.
- The relative vectors $vs_i := gamma_i gamma^0$ and $vs^i := gamma_0 gamma^i$.
- The pseudoscalar $II := gamma_0 gamma_1 gamma_2 gamma_3$.
]

#note[
- The relative vectors $vs_i$ for $i in {1,2,3}$ form a basis for the geometric algebra of 3d space.
- $vs_i^2=(vs^i)^2=1$ for each $i in {1,2,3}$.
- $II = gamma_0 gamma_1 gamma_2 gamma_3 = vs_1 vs_2 vs_3$ and  $-II = gamma^0 gamma^1 gamma^2 gamma^3 = vs^1 vs^2 vs^3$
]

#define[
$
diff &:= gamma^mu diff_mu equiv sum_(mu=0)^3 gamma^mu diff/(diff x_mu) \
del &:= vs^i diff_i = sum_(i=1)^3 vs^i diff/(diff x_i) \
$
]

#note[
$
gamma_0 diff &= diff_0 + del = 1/c diff/(diff t) + del \
diff gamma_0 &= diff_0 - del = 1/c diff/(diff t) - del \
$
]


= Maxwell's equations

#define[
- The Faraday bivector $F = arrow(E) + c II arrow(B)$ where $arrow(E) = E^i vs_i$ and $arrow(B) = B^i vs_i$.
- The 4-current $J = J_mu gamma^mu$ where $J_0 = rho/epsilon_0$ and $J_i vs^i = - c mu_0 arrow(j)$.
- Maxwell's equation $diff F = J$.
]

#derive[
Perform a spacetime split by left-multiplying by $gamma_0$.
$
gamma_0 diff F &= gamma_0 J \
= (1/c diff/(diff t) + del)(arrow(E) + c II arrow(B)) &= J_0 + vs^i J_i \
= 1/c (diff arrow(E))/(diff t) + del arrow(E) + II (diff arrow(B))/(diff t) + c del II arrow(B) &= rho/epsilon_0 - c mu_0 arrow(j)
$
Using $dot$ and $wedge$ in the sense of the 3d algebra, note that
$del arrow(E) = grade(0, del dot arrow(E)) + grade(2, del wedge arrow(E))$
and
$
del II arrow(B) &= grade(1, del dot II arrow(B)) + grade(3, del wedge II arrow(B)) \
  &= proj(II del arrow(B))_1 + proj(II del arrow(B))_3 \
  &= II proj(del arrow(B))_2 + II proj(del arrow(B))_0 \
  &= grade(1, II del wedge arrow(B)) + grade(3, II del dot arrow(B))
$
Separate the spacetime split Maxwell equation into grades:
#align(center, table(
  columns: 2,
  align: horizon,
  inset: 1em,

  [Grade], [Projection],
  [0], $del dot arrow(E) = rho/epsilon_0$,
  [1], $1/c (diff arrow(E))/(diff t) + c II del wedge arrow(B) = -c mu_0 arrow(j)$,
  [2], $del wedge arrow(E) + II (diff arrow(B))/(diff t) = 0$,
  [3], $II del dot arrow(B) = 0$
))
Using the relation $arrow(u) wedge arrow(v) = II (arrow(u) times arrow(b))$ with the vector cross product, these take the traditional form:
$
"Gauß’s law" && #h(3em)
del dot arrow(E) &= rho/epsilon_0 \
"Ampère’s law"&&
del times arrow(B) &= mu_0 arrow(j) + 1/c^2 (diff arrow(E))/(diff t) = mu_0(arrow(j) + epsilon_0 (diff arrow(E))/(diff t))\
"Faraday’s law" &&
del times arrow(E) &= -(diff arrow(B))/(diff t) \
&&
del dot arrow(B) &= 0
$

]

#summary[
If $arrow(E)$ and $arrow(B)$ are the electric and magnetic fields, $rho$ is charge density, and $arrow(j)$ is current density,
- $F = arrow(E) + c II arrow(B)$ is the Faraday bivector, and
- $J = rho/epsilon_0 gamma^0 - c mu_0 j_i gamma^i$ is the charge 4-current,
then Maxwell's equations are $diff F = J$.
]

= Electromagnetic plane waves

A solution to $diff F = 0$ is
$
F = A sin(omega t - k x) (vs_y + II vs_z)
$which is a plane wave moving in the $+x$ direction, with $arrow(E)$ oscillating along $+y$ and $arrow(B)$ along $+z$.

#let gradestack(..args) = {
  math.mat(
    ..args.pos()
      .enumerate()
      .rev()
      .map(((i, item)) => (text(0.8em, $(#i)$), item)),
    column-gap: 1em,
    delim: "{"
  )
}

#derive[
$
diff F
  &= gradestack(1/c diff/(diff t), del, 0, 0) A sin(omega t - k x) gradestack(0, vs_y, II vs_z, 0) \
  &= A sin(omega t - k x) gradestack(1/c omega, -k vs_x, 0, 0) gradestack(0, vs_y, II vs_z, 0) \
  &= A sin(omega t - k x) gradestack(-k vs_x dot vs_y, omega/c vs_y -k vs_x dot (II vs_z), omega/c II vs_z - k vs_x wedge vs_y , -k vs_x wedge II vs_z) \
  &= A sin(omega t - k x) gradestack(0, (omega/c - k) vs_y, (omega/c - k) vs_x vs_y, 0) \
$
This vanishes if and only if $k = omega/c$.
]
