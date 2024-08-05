#import "@local/notes:0.1.0"
#show: notes.style

#let sec(num) = strong(sym.section + [#num)])

#import "@local/common:0.1.0": *

= Charles Gunn's master's thesis @gunn2011

#sec[2.2.1] Defines determinant of a linear map $f : V -> V$ as $Delta({bold(v)_i}) := alpha$ such that the exterior power $f(bold(v)_1) wedge dots.c wedge f(bold(v)_n) = alpha bold(I)$ but does not require that $bold(I) = bold(v)_1 wedge dots.c wedge bold(v)_n$.

Uses this to establish a *canonical isomorphism* between $V$ and $wedge.big^(n - 1) V^*$.

#sec[2.2.3.1] Defines the adjoint of a linear map $f : V -> V^*$ by forming the $(n - 1)$th exterior power $wedge.big^(n - 1) f : wedge.big^(n - 1) V -> wedge.big^(n - 1) V^*$ and using the canonical isomorphism above to map this to $f : V^* -> V$.

This is interesting, because it is a *metric independent definition of the adjoint*.

#sec[2.3] Introduces the Poincaré isomorphism $bold(J) : PP(wedge.big V) -> PP(wedge.big V^*)$ and seems to imply that it is canonical and metric independent, but doesn't say or show this.

Surely there are many such isomorphisms? Why this one?