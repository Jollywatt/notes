#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#let ((eo, eoo), (Xeo, Xeoo)) = if false {
	// Leo's old notation
	(($cal(o)$, $oo$), ($X_cal(o)$, $X_oo$))
} else {
	// Joan's preferred notation
	(($n_0$, $n_oo$), ($X_0$, $X_oo$))
}


#show enum: it => {
	show math.equation.where(block: true): box.with(width: 100%)
	it
}

#let eqnum(body) = {
	set math.equation(numbering: "(1)")
	body
}

#let casebox(body) = box(body, outset: .4em, fill: yellow.lighten(50%)) + linebreak()
#let result(body) = text(green.darken(20%), body)
#let span(..args) = $op("span"){#args.pos().join($, $)}$

#let trans(p, ..args) = {
	if args.pos().len() == 1 { $trans(#p)[#args.pos().at(0)]$ }
	else { $mono(T)_#p$ }
}

= Classification of $1$-vectors in @cga[CGA]

_See also the @cga-blade-classification[classification of general blades]._

Consider a nonzero vector $X$ in a @cga[conformal geometric algebra] $Cl(n + 1, 1) tilde.equiv RR^(n + 2)$, assuming a basis ${eo, e_1, ..., e_n, eoo}$ where $eo^2 = eoo^2 = 0$ and $eo dot eoo = -1$.

#notes.result-box[
	*Result.* Any vector is of the form
#eqnum[$
X prop cases(
	eo + bold(p) + 1/2 (bold(p)^2 plus.minus r^2) eoo,
	bold(hat(n)) + d eoo,
	eoo
)
$ <general-vector>]
where $prop$ means equal up to a nonzero scale factor, $bold(p) in RR^n$ is a point, $r > 0$ is a radius, $bold(hat(n))$ is a unit normal vector in $RR^n$ and $d in RR$ is a distance.
]

_Proof._
A general nonzero vector is of the form
$ X = Xeo eo + bold(p) + Xeoo eoo $
where $Xeo, Xeoo in RR$ and $bold(p) in span(e_1, ..., e_n) tilde.equiv RR^n$ is a vector in the base space.

#set enum(full: true)

+ *Case $Xeo != 0$.* The normalised form $hat(X) = X slash Xeo$ is
	// $ hat(X) = eo + bold(p) + 1/2 (bold(p)^2 plus.minus r^2) eoo, quad hat(X)^2 = minus.plus r^2 $
	// where $p |-> bold(p) slash Xeo$ has been rescaled and we choose $plus.minus r^2 = 2 Xeoo slash Xeo - bold(p)^2$.
	$ hat(X) = eo + bold(p) + Xeoo eoo, quad hat(X)^2 = minus.plus r^2 $
	where $bold(p)$ and $Xeoo$ have been rescaled.
	+ *Case $Xeoo < 1/2 bold(p)^2$.* There is some $r > 0$ such that $Xeoo = 1/2 bold(p)^2 - 1/2 r^2$.
		$ hat(X) = eo + bold(p) + 1/2 (bold(p)^2 - r^2) eoo, quad hat(X)^2 = r^2 > 0 $
	+ *Case $Xeoo = 1/2 bold(p)^2$.*
		$ hat(X) = eo + bold(p) + 1/2 bold(p)^2 eoo, quad hat(X)^2 = 0 $
	+ *Case $Xeoo > 1/2 bold(p)^2$.* There is some $r > 0$ such that $Xeoo = 1/2 bold(p)^2 + 1/2 r^2$.
		$ hat(X) = eo + bold(p) + 1/2 (bold(p)^2 + r^2) eoo, quad hat(X)^2 = r^2 < 0 $

+ *Case $Xeo = 0$.*
	$ X = bold(p) + Xeoo eoo, quad X^2 = bold(p)^2 > 0 $
	+ *Case $norm(bold(p)) != 0$.* The normalised form $hat(X) = X slash norm(bold(p))$ is
		$ hat(X) = bold(hat(n)) + d eoo, quad hat(X)^2 = bold(hat(n))^2 = 1 > 0 $
		where $bold(hat(n)) := bold(p) slash norm(bold(p))$ and $d := Xeoo slash norm(bold(p))$.
	+ *Case $norm(bold(p)) = 0$.* Over a nondegenerate base space, this implies $p = 0$ so that
		$ hat(X) = eoo, quad hat(X)^2 = 0 $
		where $hat(X) = X slash X_oo$.
		#h(1fr)#sym.qed

