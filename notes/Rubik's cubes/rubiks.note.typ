#import "@preview/cetz:0.4.0"

#set page(width: 19cm, height: auto, margin: 12mm)
#set text(font: "CMU Concrete")
#show math.equation: set text(font: "Concrete Math")
#show heading: pad.with(y: 0.5em)


= Rubik's cube implementation

#let colors = (
  x: red,
  y: yellow,
  z: blue,
  X: orange,
  Y: white,
  Z: green
)

#let show-sticker(sticker) = {
  sticker.clusters().map(i => {
    text(fill: colors.at(i, default: black).darken(15%), i)
  }).join()
}

#set raw(lang: "sticker")
#show raw.where(lang: "sticker"): it => strong(show-sticker(it.text))

First, we give the six cubic directions names, `x`, `y` and `z`, forming a right-hand frame, and `X`, `Y` and `Z`, which are the opposites.
The faces of the standard Rubik's cube in each direction are coloured by their directions.

#let flip-axis(s) = {
  if s == upper(s) { lower(s) } else { upper(s) }
}
#assert.eq(flip-axis("x"), "X")
#assert.eq(flip-axis("Z"), "z")




Next, we define how the directions twist each other.
Below is a tabulation of the direction obtained by rotating the horizontal direction $90degree$ clockwise the vertical another direction as seen looking inwards from that direction.

#let twists = (
  x: (x: "x", y: "Z", z: "y"),
  y: (x: "z", y: "y", z: "X"),
  z: (x: "Y", y: "x", z: "z"),
)
#for i in "xyz" {
  for j in "xyz" {
    twists.at(i).insert(upper(j), flip-axis(twists.at(i).at(j)))
  }
  twists.insert(upper(i), twists.at(i).pairs().map(((j, k)) => (k, j)).to-dict())
}

#figure(table(
  columns: 7,
  stroke: none,
  ..{
    let terms = "1xyzXYZ".clusters()

    terms.map(a => {
      terms.map(b => {
        if a == "1" and b == "1" { return }
        let c = if a == "1" { b }
        else if b == "1" { a }
        else { twists.at(a).at(b) }
        raw(c)
      })
    }).flatten()
  },
  table.vline(x: 1),
  table.hline(y: 1),
))

For example, rotating `x` around `y` clockwise gives #show-sticker(twists.y.x).

== Sticker addressing

We identify stickers as tuples of directions. The six center pieces are specified with their direction (e.g., `z` is the blue sticker on the front face), edge pieces are specified with the face followed by the side of the face (e.g., `zx` is the blue-red piece on the right side of the front face) and corner pieces similarly by the face followed by the two directions toward the corner.

There are two valid ways of addressing each corner piece (e.g., `zyx` and `zxy` both identify the top-right piece on the front face) so we define a sticker-address normalisation function which always picks one.

#let normalize-addr(addr) = {
  addr.first() + addr.slice(1).clusters().sorted().join()
}



#let get-sticker(state, addr) = {
  state.at(normalize-addr(addr))
}

#let draw-sticker(coord, state, addr, label: none, stroke: 1pt, name: true) = {
  let s = stroke
  import cetz.draw: *
  let h = 0.85
  let colour = get-sticker(state, addr)
  rect(coord, (rel: (h,h)),
    fill: colour,
    stroke: (paint: colour.darken(20%), thickness: s),
    radius: 3pt,
    name: if name { addr },
  )
  if label != none {
    on-layer(1, content(coord, (rel: (h,h)), align(center + horizon, label)))
  }
}


#let draw-cube(state, labels: sticker => none, scale: 0.8) = cetz.canvas({
  cetz.draw.scale(scale)
  import cetz.draw: *

  let draw-face(origin, front, right, up) = group({
    translate(origin)
    for i in range(3) {
      for j in range(3) {
        let addr = normalize-addr({
          front
          (flip-axis(right), "", right).at(i)
          (flip-axis(up), "", up).at(j)
        })
        draw-sticker((i, j), state, addr, label: labels(addr))
      }
    }
  })

  draw-face((-3,0), "X", "z", "y")
  draw-face((0,0),  "z", "x", "y")
  draw-face((0,3),  "y", "x", "Z")
  draw-face((0,-3), "Y", "x", "z")
  draw-face((3,0),  "x", "Z", "y")
  draw-face((6,0),  "Z", "X", "y")
})


#let draw-face(state, face, up, right, scale: 0.8, arrows: (:)) = cetz.canvas({
  cetz.draw.scale(scale)
  import cetz.draw: *

  set-style(mark: (fill: black, scale: 0.5))

  for i in range(3) {
    for j in range(3) {
      let addr = normalize-addr({
        face
        (flip-axis(right), "", right).at(i)
        (flip-axis(up), "", up).at(j)
      })
      // if (i, j) == (2,2) { panic(addr) }
      draw-sticker((i, j), state, addr)
    }
    let x = (flip-axis(right), "", right).at(i)
    draw-sticker((i, 3), state, up + face + x, name: false)
    draw-sticker((i, -1), state, flip-axis(up) + face + x, name: false)
    let y = (flip-axis(up), "", up).at(i)
    draw-sticker((3, i), state, right + face + y, name: false)
    draw-sticker((-1, i), state, flip-axis(right) + face + y, name: false)

  }
  if arrows != none {
    get-ctx(ctx => {
      for (k, v) in arrows {
        if k in ctx.nodes and v in ctx.nodes {
          line(k, v + ".center", mark: (end: ">"))
        }
      }
    })
  }
})

#let draw-top(state, ..args) = draw-face(state, "y", "Z", "x", ..args)


#let draw-3d(
  state,
  labels: sticker => none,
  scale: 0.8,
  stroke: 1pt,
  up: "y",
  front: "z",
  right: "x",
) = cetz.canvas({
  cetz.draw.scale(scale)
  let s = stroke
  import cetz.draw: *

  let draw-face(origin, front, right, up) = group({
    translate(origin)
    for i in range(3) {
      for j in range(3) {
        let addr = normalize-addr({
          front
          (flip-axis(right), "", right).at(i)
          (flip-axis(up), "", up).at(j)
        })
        draw-sticker((i, j), state, addr, label: labels(addr), stroke: s)
      }
    }
  })

  ortho(x: 30deg, y: 35deg, {
    let h = 2.93
    on-xy(draw-face((0,0,+h), front, right, up))
    on-xz(draw-face((0,0,-h), up, right, front))
    on-yz(draw-face((0,0,-h), right, front, up))
  })
  
})


#let solved = {
  let dirs = "xyzXYZ".clusters()
  for i in dirs {
    for j in (none, ..dirs) {
      if lower(j) == lower(i) { continue } 
      for k in (none, ..dirs) {
        if lower(k) in (lower(i), lower(j)) and k != none { continue } 
        ((normalize-addr(i + j + k), colors.at(i)),)
      }
    }
  }
}.dedup().to-dict()
#assert(solved.len() == 6*9)



The state of the cube is represented as an associative map from sticker addresses to sticker colours.

#figure(draw-cube(solved, labels: it => {
  block(text(0.7em, raw(it)), fill: white, inset: 2pt, radius: 2pt)
}), caption: [Solved state showing sticker addresses.])


#figure(draw-3d(solved, labels: addr => {
  if addr.len() == 1 { block(raw(addr), fill: white, inset: 2pt, radius: 2pt) }
}), caption: [Solved state showing sticker addresses.])


== Twisting stickers

#let twist-sticker(sticker, axis) = {
  let m = twists.at(axis)
  normalize-addr(sticker.clusters().map(s => m.at(s)).join())
}

Stickers can be permuted by twisting each direction in their address.
For example, rotating sticker `zyx` around the `x` direction gives #raw(twist-sticker("zxy", "x"))


#let twist(state, move) = {
  state.pairs()
    .map(((addr, v)) => (move.at(addr, default: addr), v))
    .to-dict()
}


== Defining moves


#let invert-dict(map) = map.pairs().map(array.rev).to-dict()

#let compose-dicts(..args) = {
  let c(a, b) = {
    let ai = invert-dict(a)
    for (k, v) in b {
      if k in ai {
        a.at(ai.at(k)) = v
      } else {
        a.insert(k, v)
      }
    }
    return a
  }

  if args.pos().len() == 0 { return (:) }
  let (a, ..rest) = args.pos()
  if rest.len() == 0 { return a }
  let (b, ..rest) = rest
  return compose-dicts(c(a, b), ..rest)
}

#import "algebra.typ"
#import algebra: (
  display,
  expand,
  simplify,
  substitute-definitions as subs,
  product as c,
  inverse as inv,
  power as pow,
  commutator as com,
  conjugate as con,
)

#let g = c.with(group: true)

#let generate-twist(axis, layers) = {
  solved.keys().filter(addr => {
    let is-l1 = axis in addr
    let is-l3 = flip-axis(axis) in addr
    let is-l2 = not is-l1 and not is-l3
    1 in layers and is-l1 or 2 in layers and is-l2 or 3 in layers and is-l3
  }).map(addr => {
    (addr, twist-sticker(addr, axis))
  }).to-dict()
}

#let twist-names = (
  x: ("x", (1, 2, 3)),
  X: ("X", (1, 2, 3)),
  y: ("y", (1, 2, 3)),
  Y: ("Y", (1, 2, 3)),
  z: ("z", (1, 2, 3)),
  Z: ("Z", (1, 2, 3)),

  R: ("x", (1,)),
  L: ("X", (1,)),
  U: ("y", (1,)),
  D: ("Y", (1,)),
  F: ("z", (1,)),
  B: ("Z", (1,)),

  r: ("x", (1, 2)),
  l: ("X", (1, 2)),
  u: ("y", (1, 2)),
  d: ("Y", (1, 2)),
  f: ("z", (1, 2)),
  b: ("Z", (1, 2)),

  M: ("X", (2,)),
  E: ("Y", (2,)),
  S: ("z", (2,)),
)


#let eval-node(it) = {
  if "eval" in it {
    it.eval
  } else if "def" in it {
    it.def
  } else if "axis" in it and "layers" in it {
    generate-twist(it.axis, it.layers)
  } else if it.kind == "product" {
    compose-dicts(..it.terms).pairs()
      .filter(((k, v)) => k != v).to-dict()
  } else if it.kind == "inverse" {
    invert-dict(it.body)
  } else {
    panic(it)
  }
}
#let eval-alg(it) = algebra.walk(post: eval-node, algebra.expand(it))

#let rep(n, ..args) = algebra.power(algebra.product(..args), n)


#let mini-cubes(..args) = {
  args.pos().map(alg => {
    let s = twist(solved, eval-alg(alg))
    $display(alg) = #draw-3d(s, scale: 0.22, stroke: 0.4pt)$
  }).join[, ]
}

#let I = (kind: "variable", sym: $II$, eval: (:), order: 1)
/ Identity: #mini-cubes(I)

#let make-turn(name) = (
  kind: "variable",
  sym: name,
  axis: twist-names.at(name).first(),
  layers: twist-names.at(name).last(),
)

#let x = make-turn("x") + (order: 4)
#let y = make-turn("y") + (order: 4)
#let z = make-turn("z") + (order: 4)
/ Cube rotations: #mini-cubes(x, y, z)
#let (xi, yi, zi) = (x, y, z).map(inv)




#let R = make-turn("R") + (order: 4)
#let L = make-turn("L") + (order: 4)
#let U = make-turn("U") + (order: 4)
#let D = make-turn("D") + (order: 4)
#let F = make-turn("F") + (order: 4)
#let B = make-turn("B") + (order: 4)
/ Twists: #mini-cubes(R, L, U, D, F, B)

#let (Ri, Li, Ui, Di, Fi, Bi) = (R, L, U, D, F, B).map(inv)
/ Inverse twists: #mini-cubes(Ri, Li, Ui, Di, Fi, Bi)

#let (R2, L2, U2, D2, F2, B2) = (R, L, U, D, F, B).map(it => pow(it, 2))
/ Double twists: #mini-cubes(R2, L2, U2, D2, F2, B2)


#let r = make-turn("r") + (order: 4)
#let l = make-turn("l") + (order: 4)
#let u = make-turn("u") + (order: 4)
#let d = make-turn("d") + (order: 4)
#let f = make-turn("f") + (order: 4)
#let b = make-turn("b") + (order: 4)
/ Wide twists: #mini-cubes(r, l, u, d, f, b)

#let (ri, li, ui, di, fi, bi) = (r, l, u, d, f, b).map(inv)
/ Inverse wide twists: #mini-cubes(ri, li, ui, di, fi, bi)

#let (r2, l2, u2, d2, f2, b2) = (r, l, u, d, f, b).map(it => pow(it, 2))
/ Double wide twists: #mini-cubes(r2, l2, u2, d2, f2, b2)


#let (M, E, S) = array.zip(
  "MES".clusters(),
  "XYz".clusters()
).map(((sym, axis)) => (
  kind: "variable",
  sym: sym,
  axis: axis,
  layers: (2,),
))
#let M = make-turn("M") + (order: 4)
#let E = make-turn("E") + (order: 4)
#let S = make-turn("S") + (order: 4)
/ Slice twists: #mini-cubes(M, E, S)

#let (Mi, Ei, Si) = (M, E, S).map(inv)
/ Inverse slice twists: #mini-cubes(Mi, Ei, Si)

#let (M2, E2, S2) = (M, E, S).map(a => rep(2, a))
/ Double slice twists: #mini-cubes(M2, E2, S2)

== Algebraic operations

#let (X, Y, Z) = ($X$, $Y$, $Z$).map(sym => (
  kind: "variable",
  sym: sym,
))

#let show-eq(it) = $display(it) = display(algebra.expand(it))$
/ Conjugate: #show-eq(con(X, Y))
/ Commutator: #show-eq(com(X, Y))

#let interpret-axis(it) = {
  if type(it) == content and repr(it.func()) == "symbol" {
    it = it.text
  }
  let is-inv = false
  if type(it) != str {
    assert(it in (x, y, z, xi, yi, zi))
    is-inv = it.kind == "inverse"
    if is-inv { it = it.body }
    it = it.sym
  }
  return (it, is-inv)
}

#let lookup-turn(axis, layers) = {
  let sym = twist-names.pairs()
        .find(((sym, axis-layers)) => {
          axis-layers == (axis, layers)
        }).first()
  (
    kind: "variable",
    sym: sym,
    axis: axis,
    layers: layers,
  )
}

#let reflect-alg(axis, alg) = {
  alg = subs(alg)
  let (axis, is-inv) = interpret-axis(axis)
  algebra.walk(post: it => {
    if "axis" in it {
      let new-axis = it.axis
      if lower(it.axis) == lower(axis) {
        new-axis = flip-axis(new-axis)
      }
      inv(it + lookup-turn(new-axis, it.layers))
    } else {
      it
    }
  }, alg)
}
#let refl(axis, it) = (
  kind: "function",
  sym: $upright(display(axis))"-refl"$,
  args: (it,),
  eval: reflect-alg(axis, it),
  simplifies: true,
)

#let alg = c(R, L, U, D, F, B, r, l, u, d, f, b)
/ Reflections: $display(refl(xi, alg)) = display(expand(refl(x, alg)))$
#assert.eq(eval-alg(refl(x, R)), eval-alg(inv(L)))
#assert.eq(eval-alg(refl(x, inv(R))), eval-alg(L))
#assert.eq(eval-alg(refl(x, inv(U))), eval-alg(U))




#let rotate-alg(axis, alg) = {
  let (axis, is-inv) = interpret-axis(axis)
  let dict = twists.at(axis)
  if is-inv {
    dict = dict.pairs().map(array.rev).to-dict()
  }
  algebra.walk(post: it => {
    if "axis" in it {
       let new-axis = dict.at(it.axis)
       it + lookup-turn(new-axis, it.layers)
    } else { it }
  }, alg)
}
#let rot(axis, it) = (
  kind: "function",
  sym: $upright(display(axis))"-rot"$,
  args: (it,),
  eval: rotate-alg(axis, it),
  simplifies: true,
)
#let rot2(axis, it) = (
  kind: "function",
  sym: $upright(display(axis))^2"-rot"$,
  args: (it,),
  eval: rotate-alg(axis, rotate-alg(axis, it)),
  simplifies: true,
)
#let alg = c(R, L, U, D, F, B, r, l, u, d, f, b)
/ Rotations: $display(rot(x, alg)) = display(expand(rot(x, alg)))$
#assert.eq(eval-alg(rot(x, R)), eval-alg(R))
#assert.eq(eval-alg(rot(x, F)), eval-alg(U))
#assert.eq(eval-alg(rot(xi, Ui)), eval-alg(Fi))
#assert.eq(eval-alg(rot(y, F)), eval-alg(L))
#assert.eq(eval-alg(rot(zi, B)), eval-alg(B))


#let formula(alg, ..args) = {
  if type(alg) == array { alg = alg.first() }
  show: math.equation
  $display(alg)$
  let it = alg
  for arg in args.pos() {
    if arg in ([], ([],)) {
      $\ $
      continue
    }
    if algebra.is-expr(it) and it.kind == "variable" { $:=&$ } else { $=&$ }
    if type(arg) == function {
      it = arg(it)
    } else if type(arg) == array {
      for f in arg { it = f(it) }
    } else {
      panic(arg)
    }
    $display(it)$
  }
}

=== Some identities:

$
  #display(con(X, con(Y, Z)))
  = #display(con(con(X, Y), con(X, Z)))
  = #display(con(c(X, Y), Z))
$
