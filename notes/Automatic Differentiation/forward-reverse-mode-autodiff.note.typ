#import "@local/notes:0.1.0"
#show: notes.style

#let dwrt(var) = $diff/(diff var)$ // derivative with respect to
#let terminal = $star$
#let fmtnone(x) = if x == none { terminal } else { x }

#let program-box(it) = align(center,
	block(stroke: luma(80%), inset: 0.5em, it)
)

#let get-dependents(program) = program.pairs().map( ((var, obj)) => {
	let deps = program.pairs()
		.filter( ((var2, (_, df))) => var in df.keys())
		.map(o => o.first())
	(var, deps)
}).to-dict()

#let get-inputs(program) = program.pairs().filter( ((k, (fn, _))) => fn == none ).map(o => o.first())
#let get-outputs(program) = get-dependents(program).pairs().filter( ((k, v)) => v.len() == 0 ).map(o => o.first())

#let joinlines(lines) = program-box($ #lines.join($\ $) $)

#let get-steps(program) = {
	program.pairs().map( ((var, (fn, _))) => {
		$var &:= fmtnone(fn)$
	})
}

#let show-program(program) = {
	show: program-box
	show: math.equation.with(block: true)
	let lines = get-steps(program)
		.zip(get-dependents(program).values())
		.map( ((step, deps)) => $step && ~~> #fmtnone(deps.join($, $))$)
		.join($\ $)
	$ lines $
}


#let inline-program(program) = {
	let inputs = get-inputs(program).join($, $)
	let outputs = get-outputs(program)
	let substitute(it) = program.keys().fold(it, (acc, var) => {
		let (fn, _) = program.at(var)
		if fn == none { return acc }
		show var: fn
		acc
	})
	let vec(..args) = {
		let a = args.pos()
		if a.len() == 1 { a.at(0) }
		else { math.vec(..a) }
	}
	$
	#vec(..outputs.map(var => $var(inputs)$))  := #vec(..outputs.map(substitute))
	$
}

#let show-forward-mode(program) = {
	show: program-box
	show: math.equation.with(block: true)
	program.pairs().map(((name, (_, dfn))) => {
		let rhs = dfn.pairs()
			.map(((var, der)) => $der dif var$)
			.join($op(+)$)
		$dif name &:= fmtnone(rhs)$
	}).join($\ $)
}

#let show-reverse-mode(program) = {
	show: program-box
	show: math.equation.with(block: true)
	let deps = get-dependents(program)
	program.pairs().rev().map(((name, o)) => {
		let rhs = deps.at(name).map(var => {
			let (_, dfn) = program.at(var)
			dfn.at(name)
			$op(diff var)$
		}).join($op(+)$)
		$diff name &:= fmtnone(rhs)$
	}).join($\ $)
}

#let acronym(short, long) = context {
	let c = counter("acronym"+repr(short))
	if c.get().at(0) == 0 [#long (#short)]
	else [#short]
	c.update(1)
}

#let SSA = acronym[SSA][Single Simple Assignment]

= Forward and Reverse Mode Automatic Differentiation

#let program = (
	x: (none, (:)),
	y: (none, (:)),
	a: ($x y$, (x: $y$, y: $x$)),
	b: ($sin x$, (x: $cos x$)),
	f: ($a + b$, (a: $$, b: $$)),
	// g: ($sqrt(b)$, (b: $1/(2sqrt(b))$))
)

Suppose you have simple program #inline-program(program) which you wish to differentiate.

First, transform the expression into #SSA form, where each step is a single atomic operation whose derivative is known.

#show-program(program)

The notation $alpha ~~> beta$ means the value of $alpha$ is directly referenced by $beta$ below.
We write $alpha = terminal$ to indicate that $alpha$ is a free input, and $alpha ~~> terminal$ if it is a final output.



== Forward mode

The forward mode derivative program is formed simply by finding the differential of each step.

#show-forward-mode(program)

For any given $dif x$ and $dif y$, we can directly compute $dif z$.
For example, if $(dif x, dif y) = (1, 0)$, then $dif z$ evaluates to $diff z slash diff x$.
To find $diff z slash diff y$, we need to evaluate the forward pass again, with $(dif x, dif y) = (0, 1)$.

Forward mode requires *one evaluation* of the program *per input* variable.


=== Implementing forward mode


#let show-forward-program(program) = {
	let lines = program.pairs().map(((name, (fn, dfn))) => {
		let rhs = dfn.pairs()
			.map(((var, der)) => $der dif var$).join($op(+)$)
		if fn == none { return }
		(
			$name &:= fn$,
			$dif name &:= fmtnone(rhs)$,
		)
	}).join()
	let inputs = get-inputs(program)
	let outputs = get-outputs(program)
	inputs = $(#inputs.join($, $) semi #inputs.map(var => $dif var$).join($, $))$
	outputs = $(#outputs.join($, $) semi #outputs.map(var => $dif var$).join($, $))$
	show: program-box
	set align(left)
	block[
		#`function` #inputs `{` \
			$ #lines.join($\ $) $
		`}` $-> outputs$
	]
}

In practice, functions can be evaluated in forward mode efficiently by simply interweaving the normal program statements with their differentials.
#show-forward-program(program)
This function computes both #get-outputs(program).map(var => $var$).join[, ] and the differential #get-outputs(program).map(var => $dif var$).join[, ] in one pass.

== Reverse mode

The reverse mode is slightly more confusing: from the #SSA form, starting from bottom to top, find the _derivative operator_ $dwrt(alpha)$ of each variable $alpha ~~> beta_1, ..., beta_k$  using the chain rule to write it in terms of the affected variables:
$
dwrt(alpha) = (diff beta_1)/(diff alpha) dwrt(beta_1) + dots.c + (diff beta_k)/(diff alpha) dwrt(beta_2)
$
Then, write $diff alpha$ in place of $dwrt(alpha)$, and view it as a real variable instead of an operator.

#show-reverse-mode(program)

Then, to find $dwrt(x) z(x, y)$, we assign $diff z = 1$ and substitute from top to bottom to obtain $diff x$ and $diff y$.

We set $diff z = 1$ because, when viewed as an operator applied to the function in question, $dwrt(z) z(x, y) = 1$.
The final values $diff x$ are then interpreted as $dwrt(x) z(x, y)$.

Reverse mode requires *one evaluation* of the program *per output* variable.

=== Implementing reverse mode


#let show-reverse-program(program) = {
	let steps = get-steps(program)
	show: program-box
	let lines = program.pairs().map( ((var, (fn, dfn))) => {
		let deps = dfn.keys()
		if fn == none { return }
		$var, cal(B)_var &= cal(J)(fn; #deps.join($, $))$
	}).filter(x => x != none).join($\ $)
	$ lines $

	line()

	let deps = get-dependents(program)
	let out = program.pairs().rev().map( ((var, (fn, dfn))) => {
		if program.at(var).at(0) == none { return }
		let lhs = dfn.keys().map(var => $overline(var)$).join($, $)
		let rhs = $cal(B)_var \(overline(var)\)$
		$lhs := rhs$
	}).filter(x => x != none).join($\ $)
	$ out $
}

#show-reverse-program(program)



= Further reading

https://rufflewind.com/2016-12-30/reverse-mode-automatic-differentiation