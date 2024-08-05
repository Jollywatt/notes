#let is-expr(it) = type(it) == dictionary and "kind" in it

#let one = (kind: "variable", sym: $1$, order: 1)
#let product(..args, group: false) = (kind: "product", terms: args.pos(), group: group)
#let inverse(it) = (kind: "inverse", body: it)
#let commutator(a, b) = (kind: "commutator", a: a, b: b)
#let conjugate(a, b) = (kind: "conjugate", a: a, b: b)
#let power(it, p) = (kind: "power", body: it, power: p)

#let walk(it, pre: it => it, post: it => it) = {
  if not is-expr(it) { return it }
  let f = walk.with(pre: pre, post: post)
  post(pre(it).pairs().map(((k, v)) => {
    if is-expr(v) { (k, f(v)) }
    else if type(v) == array { (k, v.map(f)) }
    else { (k, v) }
  }).to-dict())
}

#let display-node(it) = {

  let needs-parens(it) = repr(it.func()) == "sequence"
  let grp(it) = if needs-parens(it) { $(it)$ } else { it }

  if it.kind == "variable" { 
    $it.sym$
   
  } else if it.kind == "inverse" {
    $grp(it.body)'$

  } else if it.kind == "product" {
    let term = it.terms.join($thin$)
    if it.group { term = $(term)$ }
    term

  } else if it.kind == "commutator" {
    $[it.a, it.b]$

  } else if it.kind == "conjugate" {
    $chevron.l it.a: it.b chevron.r$

  } else if it.kind == "power" {
    $grp(it.body)^it.power$

  } else if it.kind == "function" {
    let fn = it.sym
    $fn(#it.args.map(i => [#i]).join($, $))$

  } else {
    let (kind, ..args) = it
    $kind(#args.values().map(it => $it$).join($, $))$
  }
}
#let display = walk.with(post: display-node)



#let simplify-pow(it, p) = {
  if p == 0 { return one }
  if p == 1 { return it }
  if it.kind == "power" {
    simplify-pow(it.body, it.power*p)

  } else if it.kind == "inverse" {
    simplify-pow(it.body, -p)
    
  } else if it.kind == "conjugate" {
    conjugate(it.a, simplify-pow(it.b, p))

  } else if it.kind == "variable" {
    if "order" in it {
      p = calc.rem-euclid(p, it.order)
      if it.order < 2*p {
        p = it.order - p  
        it = inverse(it)
      }
    }

    if p < 0 {
    p = -p
        it = inverse(it)
    }

    if p == 0 { return one }
    if p == 1 { return it }
    power(it, p)

  } else {
    power(it, p)
  }
}

#let substitute-definitions = walk.with(post: it => it.at("def", default: it))

#let simplify-node(it, ..args) = {

  if it.kind == "inverse" {
    if it.body.kind == "inverse" {
      it.body.body
    } else if it.body.kind == "power" {
      // turn inv of pow into pow of inv
      (
        kind: it.body.kind,
        body: simplify-node(inverse(it.body.body)),
        power: it.body.power,
      )
    } else if it.body.kind == "product" {
      product(
        ..it.body.terms.rev().map(inverse),
        group: it.body.group
      )
    } else if it.body.kind == "commutator" {
      commutator(it.body.b, it.body.a)
    } else if it.body.kind == "conjugate" {
      conjugate(it.body.a, inverse(it.body.b))
    } else {
      it
    }
  
  } else if it.kind == "variable" {
    it

  } else if it.kind == "product" {
    it

  } else if it.kind == "conjugate" {
    if it.a == one { it.b }
    else if it.b == one { one }
    else { it }

  } else if it.kind == "commutator" {
    if it.a == one or it.b == one { one }
    else { it }

  } else if it.kind == "power" {
    simplify-pow(it.body, it.power)

  } else if it.at("simplifies", default: false) == true {
    it.eval

  } else {
    it
  }

}
#let simplify = walk.with(pre: simplify-node)



#let expand-node(it) = {
  
  if it.kind == "conjugate" {
    product(it.a, it.b, inverse(it.a))

  } else if it.kind == "commutator" {
    product(it.a, it.b, inverse(it.a), inverse(it.b))
  
  } else if it.kind == "power" {
    let (body, power: p) = it
    if p < 0 {
      body = inverse(body)
      p = -p
    }
    product(..(body,)*p)
  
  } else if it.kind == "function" {
    it.eval

  } else {
    it
  }

}

#let flatten-product(it) = {
  if it.kind == "product" { 
    product(..it.terms.map(t => {
      if t.kind == "product" { t.terms }
      else { t }
    }).flatten())

  } else if it.kind == "inverse" {
    if it.body.kind == "product" {
      product(..it.body.terms.map(inverse).rev())

    } else {
      it
    }
    
  } else {
    it
  }
}


#let simplify-inverse(it) = {
  if it.kind == "inverse" and it.body.kind == "inverse" {
    it.body.body

  } else {
    it
  }
}

#let expand(it) = {
  it = walk(post: expand-node, it)
  it = walk(post: flatten-product, it)
  it = walk(post: simplify-inverse, it)
  it
}

#page(width: auto, height: auto, {

let (x, y, z, w) = ($x$, $y$, $z$, $w$).map(sym => (
  kind: "variable",
  sym: sym,
  order: 4,
))

// simplification
assert.eq(simplify(inverse(product(x, y))), product(inverse(y), inverse(x)))
assert.eq(simplify(inverse(commutator(x, y))), commutator(y, x))
assert.eq(simplify(inverse(conjugate(x, y))), conjugate(x, inverse(y)))
assert.eq(simplify(power(conjugate(x, y), 3)), conjugate(x, inverse(y)))

// expansion
assert.eq(expand(power(x, 3)), product(x, x, x))
assert.eq(expand(commutator(x, inverse(y))), product(x, inverse(y), inverse(x), y))
assert.eq(expand(conjugate(product(x, y), z)), product(x, y, z, inverse(y), inverse(x)))

[
#let alg = inverse(conjugate(x, commutator(conjugate(inverse(y), z), w)))

= Simplification
$ display(alg) = display(simplify(alg))$

= Expansion
$ display(alg) = display(expand(alg))$

]

// symbolic functions
[
  #let fn = (
    kind: "function",
    sym: $f$,
    args: (1, inverse(product(x, z)))
  )

  #display(simplify(fn))
]

})