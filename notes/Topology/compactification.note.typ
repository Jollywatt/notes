#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *
#show math.phi: math.phi.alt

#import "@preview/fletcher:0.5.8": diagram, node, edge

= Compactification

A compactification of $cal(X)$ is an embedding $phi : cal(X) -> cal(Z)$ where $phi(cal(X))$ is a dense subset of the compact space $cal(Z)$.

== Stone--Čech compactification

The Stone--Čech compactification $beta cal(X)$ of a topological space $cal(X)$ is the most general compact Hausdorff space.


#let fig = diagram($
  cal(X) edge("hook->", iota_cal(X)) edge("dr", ->, f, #right) &
  beta cal(X) edge("d", "-->", beta f, #left)\
  & cal(A)

$)

#grid(columns: 2, gutter: 1cm, fig, align: horizon)[
  Any continous map $f: cal(X) -> cal(A)$ where $cal(A)$ is compact Hausdorff factors *uniquely* as $f = beta f compose iota_cal(X)$.
]

=== Construction

