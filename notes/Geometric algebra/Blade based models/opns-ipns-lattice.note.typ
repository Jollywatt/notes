#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let up = math.op("up")
#let antiwedge = math.or
#let (opns, ipns) = ("O", "I").map(math.bb)
#let (meet, join) = ("meet", "join").map(math.mono)
#let dual(it) = $it^star$

#let x = $bold(x)$


= Lattice structure for $opns$/$ipns$

#let map = (
  ((opns, join, opns), $opns(A wedge B)$, $ipns(dual(A) antiwedge dual(B))$),
  ((opns, join, ipns), $opns(A wedge dual(B))$, $ipns(A lcont B)$),
  ((ipns, join, opns), $opns(dual(A) wedge B)$, $ipns(A rcont B)$),
  ((ipns, join, ipns), $opns(dual(A) wedge dual(B))$, $ipns(A antiwedge B)$),

  ((opns, meet, opns), $opns(A antiwedge B)$, $ipns(dual(A) wedge dual(B))$),
  ((opns, meet, ipns), $opns(A rcont B)$, $ipns(dual(A) wedge B)$),
  ((ipns, meet, opns), $opns(A lcont B)$, $ipns(A wedge dual(B))$),
  ((ipns, meet, ipns), $opns(dual(A) antiwedge dual(B))$, $ipns(A wedge B)$),
)


#set table(
  align: center,
  inset: 1em,
  columns: (auto, 1fr, 1fr),
  stroke: none,
)

#let multable(op, fill) = table(
  op, table.vline(), $opns(B)$, $ipns(B)$, table.hline(),
  $opns(A)$,
  table.cell(x: 0, y: 2, $ipns(A)$),

  ..map
    .filter((((_, o, _), ..)) => o == op)
    .map((((l, _, r), o, i)) => {
      table.cell(
        x: 1 + (opns, ipns).position(i => i == r),
        y: 1 + (opns, ipns).position(i => i == l),
        // $ #o = #i $
        fill(o, i, l, r)
      )
    })
)

#set grid(columns: (1fr, auto, 1fr), align: (right, center, left), gutter: 0.6em)

#multable(join, (op, ip, ..) => grid($op$, $=$, $ip$))
#multable(meet, (op, ip, ..) => grid($op$, $=$, $ip$))

#pagebreak()
== Without explicit duals
#multable(join, (op, ip, l, r) => if ipns in (l, r) { ip } else { op })
#multable(meet, (op, ip, l, r) => if opns in (l, r) { op } else { ip })


#pagebreak()


*Proof.*
$
  opns(A) join ipns(B)
  &= opns(A) join opns(dual(B)) &
  &= opns(A wedge dual(B)) &
  &= ipns(A lcont B) \
  ipns(A) meet opns(B)
  &= ipns(A) meet ipns(dual(B)) &
  &= ipns(A wedge dual(B)) &
  &= opns(A lcont B) \
$