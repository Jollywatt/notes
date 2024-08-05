#import "@local/notes:0.1.0"
#import "@local/common:0.1.0": *
#show: notes.style

#import "@preview/cetz:0.3.4"

= Dypin Cyclides

See @dupin-cyclide-3d-plot.

== Parametric form

$
x &= (d(c - a cos u cos v) + b^2 cos u)/m \
y &= (b sin u (a - d cos v))/m \
z &= (b sin v (c cos u - d))/m \
m &= a - c cos u cos v \
a &= sqrt(b^2 + c^2) \
u, v &in [0, tau)
$

=== Interpretations

Given $b$, $c$, $d$:
	- $b$ is the major radius
	- $c$ is related to eccentricity; $c = 0$ is a circle
	- $d$ is the average thickness

The radius of a channelling sphere is $r = c/b x$

== Lie Sphere Geometry

With @lie-sphere-geometry, a Dupin cyclide is the OPNS of:
$
mono(T)_(t e_0) [(n_0 + 1/2 rho^2 n_oo) wedge (lambda e_1 + e_0) wedge e_2]
$
#table(
	columns: 2,
	[Parametric form], [OPNS form],
	$b$, $rho$,
	$c$, $1 slash sqrt(lambda^2 - 1)$,
	$sqrt(1 + 1 slash c^2)$, $lambda$,
	$d$, $t$,
)

$

m &= c/b = 1/sqrt(lambda^2 - 1)
$
