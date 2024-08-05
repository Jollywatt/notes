#import "@local/notes:0.1.0"
#show: notes.style

#import "@local/common:0.1.0": *

#set page(width: 20cm)

#let (eo, eoo) = ($cal(o)$, $oo$)

#let trans(p, ..args) = {
	if args.pos().len() == 1 { $trans(#p)[#args.pos().at(0)]$ }
	else { $mono(T)_#p$ }
}

#show math.equation.where(block: true): box.with(width: 100%)

#let (ipns, opns) = ("ipns", "opns").map(math.op)
#let up = math.op("up")

#show math.frac: it => {
	if it.num == [1] and it.denom == [2] { math.inline(it) } else { it }
}

= Summary of CGA blade IPNS and OPNS

@cga-ipns-opns[See here for the derivation.]


#table(
	columns: (auto, 1fr, 1fr),
	align: (right, left, left),
	stroke: none,
	$X$, $opns$, $ipns$,
	table.hline(),

	$bold(E) eoo$,
	${eoo}$,
	${eoo}$,

	$trans(bold(p), bold(E))$,
	$nothing$,
	${up(p + u) | u lcont bold(E) = 0} union {eoo}$,

	$trans(bold(p), eo wedge bold(E) wedge eoo)$,
	${up(p + u) | u wedge bold(E) = 0 } union {eoo}$,
	$nothing$,

	$trans(bold(p), (eo + 1/2 r^2 eoo) wedge bold(E))$,
	${up(p + u) | u wedge bold(E) = 0, u^2 = r^2 }$,
	${up(p + u) | u lcont bold(E) = 0, u^2 = -r^2 }$,

	$trans(bold(p), (eo - 1/2 r^2 eoo) wedge bold(E))$,
	${up(p + u) | u wedge bold(E) = 0, u^2 = -r^2 }$,
	${up(p + u) | u lcont bold(E) = 0, u^2 = + r^2 }$,

	$trans(bold(p), eo wedge bold(E))$,
	${up(p)}$,
	${up(p)}$,
)

If we assume the base space is Euclidean, so that $u^2 > 0$ and $u^2 = 0 <==> 0$, then the table simplifies slightly:


#table(
	columns: (auto, 1fr, 1fr),
	align: (right, left, left),
	stroke: none,
	$X$, $opns$, $ipns$,
	table.hline(),

	$bold(E) eoo$,
	${eoo}$,
	${eoo}$,

	$trans(bold(p), bold(E))$,
	$nothing$,
	${up(p + u) | u lcont bold(E) = 0} union {eoo}$,

	$trans(bold(p), eo wedge bold(E) wedge eoo)$,
	${up(p + u) | u wedge bold(E) = 0 } union {eoo}$,
	$nothing$,

	$trans(bold(p), (eo + 1/2 r^2 eoo) wedge bold(E))$,
	${up(p + u) | u wedge bold(E) = 0, u^2 = r^2 }$,
	$nothing$,

	$trans(bold(p), (eo - 1/2 r^2 eoo) wedge bold(E))$,
	$nothing$,
	${up(p + u) | u lcont bold(E) = 0, u^2 = + r^2 }$,

	$trans(bold(p), eo wedge bold(E))$,
	${up(p)}$,
	${up(p)}$,
)
