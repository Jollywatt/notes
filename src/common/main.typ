#let wedge = sym.and
#let lcont = math.op(sym.floor.r)
#let rcont = math.op(sym.floor.l)
#let rev(X) = math.tilde(X)
#let revsign(k) = $frak(s)_#k$
#let grade(X, k) = $lr(angle.l #X angle.r)_#k$
#let Cl = math.italic("Cl")

#let proj(obj, vec) = $obj^(parallel vec)$
#let rej(obj, vec) = $obj^(perp vec)$

#let cen(op, onto, ..el) = {
	$upright(Z)^op_onto$
	if el.pos().len() > 0 { $(#el.pos().join($, $))$ }
}

#let env(kind, body, accent: green) = {
	figure(
		supplement: kind,
		block(width: 100%, inset: 1em, stroke: accent, fill: accent.transparentize(80%))[
			#set align(left)
			*#kind.* #body
		],
	)
}

#let proof(body) = block(width: 100%)[
	*Proof.*
	#body
	#sym.qed
]

#let eqnum(it) = {
	set math.equation(numbering: "(1)")
	it
}

#let der(f, x, u) = $DD #f [#x] (#u)$
#let ip(left, right) = $lr(angle.l left, right angle.r)$