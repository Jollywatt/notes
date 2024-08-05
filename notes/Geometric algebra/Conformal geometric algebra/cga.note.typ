#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let up = math.op("up")
#set math.cancel(stroke: red)

#let inc(it) = $text(#gray, iota(text(#black, it)))$
#let (eo, eoo) = ($e_0$, $e_oo$)
#let IE = $II_n$

#let details = env.with(accent: teal.transparentize(60%))[Detail]

= Conformal Geometric Algebra

The conformal model in $RR^n$ is $Cl(n + 1, 1)$ with basis vectors
$
	e_i^2 = 1 "for" 1 <= i <= n "and" e_plus.minus^2 = plus.minus 1
$
where we additionally may define
$
	eoo := alpha (e_+ + e_-) quad "and" quad eo := beta (e_+ - e_-)
$
for $alpha, beta in RR$ from which it follows $eoo^2 = eo^2 = 0$ and $eoo dot eo = 2 alpha beta$.

== Inclusion map $Cl(n) -> Cl(n + 1, 1)$

Let $iota : Cl(n) -> Cl(n + 1, 1)$ be the inclusion map induced by identifying sending $e_i |-> e_i$ in each algebra.

#details[
We can often forget about this map and simply understand that any element $a in Cl(n)$ also belongs in $Cl(n + 1, 1)$.
In this note, I'll still write it, but in a subtle shade, like $inc(a) in Cl(n + 1, 1)$.
]

== Lifting map $RR^n -> Cl(n + 1, 1)$

Define the "upwards" lift
$
up(x) &:= gamma eo + inc(x) + delta x^2 eoo \
&= inc(x) + (alpha delta x^2 + beta gamma) e_+ + (alpha delta x^2 - beta gamma) e_-
$
where $gamma, delta in RR$ so that
$ up(x)^2 = x^2 + 2 gamma delta x^2 eo dot eoo = x^2 (1 + 4 alpha beta gamma delta) = 0 $
vanishes when $alpha beta gamma delta = -1 slash 4$.

In particular, this implies $gamma eo dot eoo = 2 alpha beta gamma = -1/(2delta)$.

#env(accent: teal.transparentize(60%))[Detail][
We fix the coefficient of $x$ as unity in the expression for $up(x)$ because it is desirable to have the property that $up(x) dot e_i = x dot e_i$ for all $i$.
That is, we would like $(up(x) lcont IE) lcont IE^(-1) = inc(x)$.
This means the $up$ map does no scaling --- it just adds on some bits involving $eo$ and $eoo$.
]

*Distance from inner product.* We can see from
$
	up(x) dot up(y)
	&= (gamma eo + x + delta x^2 eoo) dot (gamma eo + y + delta y^2 eoo) \
	&= gamma^2 cancel(eo^2) + gamma cancel(eo dot y) + gamma delta y^2 eo dot eoo \
	&op(+) gamma cancel(x dot eo) + x dot y + delta y^2 cancel(x dot eoo) \
	&op(+) gamma delta x^2 eoo dot eo + delta x^2 cancel(eoo dot y) + delta^2 x^2 y^2 cancel(eoo^2)  \
	&= -1/2 (x^2 + y^2) + x dot y
	= -1/2 (x - y)^2
$
using $eoo dot eo = -1/(2 gamma delta)$ that the Euclidean distance between points is given by:
$
	norm(x - y) = sqrt(-2 up(x) dot up(y))
$

== Rotors

Numerical tests for these formulas are in @cga-conventions[this notebook on CGA conventions].

*Euclidean rotations.*
If $R in "Pin"(n)$ then

$
	up(R x rev(R)) = inc(R) up(x) inc(rev(R))
$ 
where $inc(R) in inc("Pin"(n)) subset "Pin"(n + 1, 1)$.

*Translations.*
If $v in inc(RR^n)$ is a displacement vector and $kappa = eoo dot up(0)$, then the motor
$
	T(v) = exp(1/(2 kappa) v eoo) = 1 + 1/(2 kappa) v eoo
$
is a translation acting as
$
	T(v) up(x) = up(x + v) T(v)
$
for any point $x in inc(RR^n)$.

*Dilations.*
The dilation rotor
$
	S(s) := exp((ln s)/(2 eta) eoo wedge eo) = cosh((ln s)/2) + sinh((ln s)/2) (eoo wedge eo)/eta
$
where $eta = eoo dot eo$ transforms points $x in RR^n$ as
$
	S(s) up(x) = 1/s up(s x) S(s)
$
where $s in RR$ is a dilation factor.

== Interpretation of $1$-vectors

- *Planes.*
	Let $a = inc(n) + ell eoo$ for some $n in RR^n$ and $ell in RR$.
	By probing,
	$
	a dot up(x)
		&= (inc(n) + ell eoo) dot (gamma eo + inc(x) + delta x^2 eoo) \
		&= n dot x + ell gamma eoo dot eo \
		&= n dot x - ell/(2 delta)
	$
	which vanishes when $hat(n) dot x = ell/(2norm(n)delta)$, describing the plane with normal $hat(n)$ a distance $ell (2norm(n)delta)^(-1)$ from the origin.

- *Dual spheres.*
	Let $a = up(b) plus.minus rho^2 delta eoo$.
	By probing,
	$
	a dot up(x)
	&= up(b) dot up(x) plus.minus rho^2 delta eoo dot up(x) \
	&= -1/2 norm(b - x)^2 plus.minus rho^2 gamma delta eoo dot eo \
	&= -1/2 norm(b - x)^2 minus.plus 1/2 rho^2 \
	$
	which vanishes when $norm(b - x)^2 = minus.plus rho^2$.
	When $plus.minus$ is in the $-$ case, this $a$ describes a dual sphere of radius $rho$, and in the $+$ case, the sphere contains no real points --- it is imaginary, having an "imaginary" radius of $rho$.

	Note that
	$
	a^2 = 2lambda up(b) dot eoo = 2 lambda gamma eo dot eoo = -lambda/delta
	$
	so the square-radius of a dual sphere is obtained with $lambda = -a^2 delta$ or $rho^2 = a^2 delta$.