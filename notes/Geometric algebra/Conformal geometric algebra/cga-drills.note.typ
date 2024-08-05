#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let up = math.op("up")
#set math.cancel(stroke: red)
#let eb = $overline(e)$
#let nb = $overline(n)$

= Drills and exercises in CGA

#import "@preview/jumble:0.0.1"
#let hl(name, obj) = {
	let hue = calc.rem(int.from-bytes(jumble.md5(repr(name)).slice(0,2)), 360)*1deg
	text(color.hsv(hue, 100%, 70%), obj)
}

== Showing that the translation rotor translates points

#notes.result-box[
	$
		n &:= e + eb \
		nb &:= e - eb \
		F(x) &:= 1/2(x^2 n + 2x - nb)
	$
]

Let $E = n wedge nb = (e + eb) wedge (e - eb) = 2 eb e$. Note
#eqnum[$
E n &= 2 eb e (e + eb) = 2 eb e^2 - 2 e eb^2 = 2 (eb + e) = 2 n \ 
E nb &= 2 eb e (e - eb) = 2 eb e^2 + 2 e eb^2 = 2 (eb - e) = -2 nb \ 
$ <eq:E>]

Show that $R = exp(-1/2 n u)$ is a translation rotor.

$
R F(x) rev(R)
	&= (1 + 1/2 n u) 1/2 (x^2 n + 2x - nb) (1 + 1/2 u n) \
	&= 1/2 (x^2 n + 2x - nb + 1/2 x^2 cancel(n u n) + n hl(1, u x) - 1/2 n u nb) (1 + 1/2 u n) \
	&= 1/2 ([x^2 + hl(1, u x)] n + 2x hl(4, - 1/2 n u) nb - nb) (1 + 1/2 u n) \
	&= 1/2 ([x^2 + u x] n + 2x hl(4, + 1/2 u n) nb - nb \
	&#h(9.7mm) [x^2 + u x] 1/2 cancel(n u n) + hl(3, x u )n - 1/4 n u nb u n hl(6, - 1/2 nb u) n) \
	&= 1/2 ([x^2 + u x + hl(3, x u)] n + 2x + hl(6, 1/2 u) (n nb hl(6, + nb) n) + 1/4 u^2 n nb n - nb) \
	&= 1/2 ([x^2 + u x + x u] n + 2x + u (hl(7, n dot nb)) + 1/4 u^2 (hl(7, n dot nb) + hl(8, E)) hl(8, n) - nb) \
	&= 1/2 ([x^2 + u x + x u] n + 2x + hl(7, 2)u + 1/4 u^2 (hl(7, 2) + hl(8, 2)) hl(8, n) - nb) \
	&= 1/2 ([x^2 + u x + x u] n + 2(x + u) + u^2 n - nb) \
	&= 1/2 ([x^2 + u x + x u + u^2] n + 2(x + u) - nb) \
	&= 1/2 ([x + u]^2 n + 2[x + u] - nb) \
	&= F(x + u)
	
$

== The effect of $mono(T)_p$ on Euclidean vectors

#notes.result-box[
	Let $mono(T)_p := exp(1/2 oo p)$ be the translation rotor and let
	$R [X] = R X rev(R)$ denote rotor application.
]

Let $p, u in RR^n$.

$
sans(T)_p [u]
	&= (1 + 1/2 oo p) u (1 + 1/2 p oo) \
	&= u + 1/2 oo p u + 1/2 u p oo + 1/2 oo p u p oo \
	&= u + 1/2 (p u + u p) oo - 1/2 cancel(oo^2) p u p \
	&= u + (u dot p) oo
$
