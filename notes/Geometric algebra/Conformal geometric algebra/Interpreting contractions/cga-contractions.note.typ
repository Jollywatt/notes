#import "@local/notes:0.1.0"
#import "@local/common:0.1.0": *

#show: notes.style

#let box(it) = rect(stroke: 0.5pt, $it$, inset: 1em)
#let span = math.op("span")
#let up = math.op("up")
#let opns = math.mono("OPNS")
#let ipns = math.mono("IPNS")

#show math.equation: it => {
  show "A": set text(blue)
  show "B": set text(orange)
  it
}

= Contractions between direct CGA objects

Suppose $A$ and $B$ are two directly represented objects in CGA, where $A$ is of a higher grade than $B$.
For instance, $A$ might be a sphere and $B$ a point or circle, etc.
Consider their inner product:
$
  box(C := A dot B = A rcont B)
$

#emph[
  How can we characterise $C$ geometrically in terms of $A$ and $B$?
]

We can deduce immediately that:
- *The grade of $C$ is the difference of the grades of $A$ and $B$*\
  Clearly, $"gr"(C) = "gr"(A) - "gr"(B)$. Points, point pairs, circles, and spheres are grades $1$ through $4$ respectively, so the inner product between a sphere and a point is a circle, for example.
  Note that a tangent vectors and tangent planes are grades $2$ and $3$, since they are zero-radius point pairs and circles.

- *$C$ directly represents a subset of $A$*\
  From $span(C) subset.eq span(A)$ it follows that we can factorise $A = C wedge Z$ for some $Z$.
  Therefore, $up(bold(x)) wedge C = 0 ==> up(bold(x)) wedge A = 0$ so $opns(C) subset.eq opns(A)$.

- *$C$ dually represents a superset of $B$*\
  This follows because $up(bold(x)) wedge B = 0$ implies $C rcont up(bold(x)) = (A rcont B) rcont up(bold(x)) = A rcont (B wedge up(bold(x))) = 0$ (@ga-product-identities[double contraction identity]) so $opns(B) subset.eq ipns(C)$.
  
- *$C$ is invariant under reflection in $A$ or $B$*\
  First observe that $span(C) = span(A rcont B) subset.eq span(A) $ and also $span(C) inter span(B) = nothing$.
  These imply that $C A = C lcont A$ and $C B = C wedge B$ are both blades.
  The reverse of a blade is itself, up to a sign.
  This gives $C A prop A C$ and $C B prop B C$, or in other words $A C A prop C$ and $B C B prop C$.
  Geometrically, this means $C$ is invariant under reflection in both $A$ and $B$.
  Specifically, both $opns(C)$ and $ipns(C)$ are transformed into themselves on being reflected in a mirror represented by $A$ or $B$.



In the figures below, the grey object is the OPNS of $C$, and the yellow object is the IPNS.
Dashed lines denote a round with an imaginary radius.


#let fig(path) = pad(image(path), -1em)

#set text(0.8em)
#table(
  columns: (1fr, 1.2fr)*2,
  align: (horizon, left),
  stroke: none,

  [
    $
      A &: "4-round" \
      B &: "1-tangent" \
      C &: "3-tangent" \
    $
    $C$ directly represents a circle. 
  ],
  fig("sphere-point-kiss.png"),

  $
    A &: "4-round" \
    B &: "1-tangent" \
    A wedge B != 0 &: "not incident"\
    A dot B &: "imag. 3-round" \
  $,
  fig("sphere-point-miss.png"),

  $
    A &: "4-round" \
    B &: "2-tangent" \
    A wedge B = 0 &: "incident"\
    A dot B &: "2-tangent" \
  $,
  fig("sphere-vector-kiss.png"),

  $
    A &: "4-round" \
    B &: "2-tangent" \
    A wedge B!= 0 &: "not incident"\
    A dot B &: "imag. 2-round" \
  $,
  fig("sphere-vector-miss.png"),

  $
    A &: "4-round" \
    B &: "3-tangent" \
    A wedge B = 0 &: "incident"\
    A dot B &: "1-tangent" \
  $,
  fig("sphere-bivector-kiss.png"),

  $
    A &: "4-round" \
    B &: "3-tangent" \
    A wedge B!= 0 &: "not incident"\
    A dot B &: "imag. " \
  $,
  fig("sphere-bivector-miss.png"),

  $
    A &: "4-round" \
    B &: "2-round" \
    A dot B &: "2-round" \
  $,
  fig("sphere-pointpair.png"),
  $
    A &: "4-round" \
    B &: "3-round" \
    A dot B &: "1-round" \
  $,
  fig("sphere-circle.png"),

  $
    A &= "3-round" \
    B &= "1-round" \
    A dot B &= "2-tangent" \
  $,
  fig("circle-point-kiss.png"),

  $
    A &= "3-round" \
    B &= "1-round" \
    A dot B &= "2-round" \
  $,
  fig("circle-point-miss.png"),


  // $?$,
  // fig("circle-pointpair.png"),

)


*Lemma.*
If $A$ and $B$ directly represent objects that intersect, then $(A dot B)^2 = 0$ so $A dot B$ is a zero-radius round or tangent.