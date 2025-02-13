#import "@local/notes:0.1.0"
#show: notes.style

#let dwrt(var) = $diff/(diff var)$ // derivative with respect to
#let terminal = $star$
#let fmtnone(x) = if x == none { terminal } else { x }

#let forward(..args) = $cal(F){#args.pos().join($, $)}$
#let reverse(..args) = $cal(R){#args.pos().join($, $)}$

#let dirder(fn, val) = $DD fn [val]$

#let program-box(it) = align(center,
	block(stroke: luma(80%), inset: 0.5em, it)
)

#let braceblock(head: none, ..args, tail: none) = {
	$head \{$
	pad(left: 2em, y: -.25em, args.pos().join[\ ])
	$\} tail$
}



/* program analysis */

#let get-dependents(program) = program.pairs().map( ((var, obj)) => {
	let deps = program.pairs()
		.filter( ((var2, (_, df))) => var in df.keys())
		.map(o => o.first())
	(var, deps)
}).to-dict()

#let get-inputs(program) = for (k, (fn, _)) in program {
	if fn == none { (k,) }
}
#let get-outputs(program) = for (k, deps) in get-dependents(program) {
	if deps == () { (k,) }
}
#let get-body(program) = {
	program.pairs().filter( ((var, (fn, _))) => fn != none)
}

#let show-steps(lines) = program-box($ #lines.join($\ $) $)

#let get-steps(program, inputs: true) = {
	let steps = program.pairs()
	if not inputs {
		steps = steps.filter( ((var, (fn, _))) => fn != none)
	}
	steps.map( ((var, (fn, _))) => {
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


#let show-inline-program(program) = {
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

#let get-forward(program) = {
	program.pairs().map(((name, (_, dfn))) => {
		let rhs = dfn.pairs()
			.map(((var, der)) => $der dif var$)
			.join($op(+)$)
		$dif name &:= fmtnone(rhs)$
	})
}

#let get-reverse(program, inputs: true) = {
	let deps = get-dependents(program) 
	let steps = program.pairs().rev().map(((name, o)) => {
		let rhs = deps.at(name).map(var => {
			let (_, dfn) = program.at(var)
			dfn.at(name)
			$op(diff var)$
		}).join($op(+)$)
		(name, rhs)
	})
	if not inputs {
		steps = steps.filter( ((var, rhs)) => rhs != none)
	}
	steps.map(((var, rhs)) => $diff var &:= fmtnone(rhs)$)
}

#let acronym(short, long) = context {
	let c = counter("acronym"+repr(short))
	if c.get().at(0) == 0 [#long (#short)]
	else [#short]
	c.update(1)
}

#let SSA = acronym[SSA][Static Single Assignment]

= Forward and Reverse Mode Automatic Differentiation

#let program = (
	x: (none, (:)),
	y: (none, (:)),
	a: ($x y$, (x: $y$, y: $x$)),
	b: ($sin x$, (x: $cos x$)),
	f: ($a + b$, (a: $$, b: $$)),
	// g: ($a sqrt(b)$, (a: $sqrt(b)$, b: $a/(2sqrt(b))$))
)

Suppose you have simple program #show-inline-program(program) which you wish to differentiate.

First, transform the expression into #SSA form, where each step is a single atomic operation whose derivative is known.

#show-program(program)

The notation $alpha ~~> beta$ means the value of $alpha$ is directly referenced by $beta$ below.
We write $alpha = terminal$ to indicate that $alpha$ is a free input, and $alpha ~~> terminal$ if it is a final output.



== Forward mode

The forward mode derivative program is formed simply by finding the differential of each step.

#show-steps(get-forward(program))

#let lastvar = program.keys().last()
For any given $dif x$ and $dif y$, we can directly compute $dif lastvar$.
For example, if $(dif x, dif y) = (1, 0)$, then $dif lastvar$ evaluates to $diff lastvar slash diff x$.
To find $diff lastvar slash diff y$, we need to evaluate the forward pass again, with $(dif x, dif y) = (0, 1)$.

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
	let args = $(#inputs.join($, $) semi #inputs.map(var => $dif var$).join($, $))$
	let returns = $(#outputs.join($, $) semi #outputs.map(var => $dif var$).join($, $))$
	show: program-box
	set align(left)
	braceblock(
		head: $"function" args space$,
		..lines,
		tail: $-> returns$
	)
}

In practice, functions can be evaluated in forward mode efficiently by simply interweaving the normal program statements with their differentials.
#show-forward-program(program)
This function computes both #get-outputs(program).map(var => $var$).join[, ] and the differential #get-outputs(program).map(var => $dif var$).join[, ] in one pass.

=== Forward mode functor


The essence of forward mode differentiation is the functor
$
forward(f)(x, dif x) = (f(x), dirder(f, x)(dif x))
$
where $dirder(f, x)(dif x)$ is the directional derivative of $f$ at $x$ in the $dif x$ direction, or
$
dirder(f, x)(dif x) := lim_(epsilon -> 0) (f(x + epsilon dif x) - f(x))/epsilon
$
where we assume the domain of $f$ is a vector space.

This functor has a simple composition law
$
forward(g compose f) &= forward(g) compose forward(f) \
forward(g compose f)(x, dif x)
	&= (g(f(x)), dirder(g, f(x))(dirder(f, x)(dif x)))
$
which makes it easy to find the derivative of larger programs.

#let func(inputs, outputs, steps, prefix: none) = {
	show: block.with(inset: .3em)
	align(left)[
		$prefix (#inputs.join($, $)) |-> {$ \
		#pad(left: 2em, $ #steps.join($\ $) $)
		$} -> (#outputs.join($, $))$
	]
}



$
forward(func(
	#get-inputs(program),
	#get-outputs(program),
	#get-steps(program, inputs: false),
)) = func(
	#(get-inputs(program) + get-inputs(program).map(var => $dif var$)),
	#(get-outputs(program) + get-outputs(program).map(var => $dif var$)),
	#get-body(program).map( ((var, (fn, dfn))) => {
		$
		(var, dif var) &:=
		forward(fn)(#dfn.keys().join($, $), #dfn.keys().map(var => $dif var$).join($, $)) = 
		(fn, #dfn.pairs().map( ((var, der)) => $ der dif var $).join($+$))
		$
	}),
)
$


== Reverse mode

The reverse mode is slightly more confusing: from the #SSA form, starting from bottom to top, find the _derivative operator_ $dwrt(alpha)$ for each variable $alpha ~~> beta_1, ..., beta_k$  using the chain rule to write it in terms of the variables it affects:
$
dwrt(alpha) = (diff beta_1)/(diff alpha) dwrt(beta_1) + dots.c + (diff beta_k)/(diff alpha) dwrt(beta_2)
$
Then, write $diff alpha$ in place of $dwrt(alpha)$, and view it as a real variable instead of an operator.

#show-steps(get-reverse(program))

Then, to find $dwrt(x) lastvar(x, y)$, we assign $diff lastvar = 1$ and substitute from top to bottom to obtain $diff x$ and $diff y$.

We set $diff lastvar = 1$ because, when viewed as an operator applied to the function in question, $dwrt(lastvar) lastvar(x, y) = 1$.
The final value of $diff x$ is then $dwrt(x) lastvar(x, y)$.

Reverse mode requires *one evaluation* of the program *per output* variable.

=== Implementing reverse mode

We can write the reverse mode derivative program by including both the normal steps and the derivative steps.
However, this time the steps can't all be run at once because the derivative steps run in reverse order, so must be run after all the normal steps.
Therefore, we put the derivative steps in a callback function $JJ$ so they can be run later, after the current function and any following functions have been run.

#let show-reverse-program(program) = {
	let inputs = get-inputs(program)
	let outputs = get-outputs(program)
	let args = $(#inputs.join($, $))$
	let returns = $(#outputs.join($, $) semi #inputs.map(var => $diff var$).join($, $))$
	show: program-box
	set align(left)
	braceblock(
		head: $"function" args space $,
		..get-steps(program, inputs: false),
		braceblock(
			head: $JJ &:= (#outputs.map(var => $diff var$).join($, $)) |-> $,
			..get-reverse(program, inputs: false),
			tail: $-> (#inputs.map(var => $diff var$).join($, $))$,
		),
		tail: $-> (#outputs.join($, $), JJ)$
	)
}

#show-reverse-program(program)


=== Reverse mode functor

The essence of reverse mode differentiation is the functor
$ reverse(f)(x) = (f(x), dirder(f, x)^*) $
where $diff f |-> dirder(f, x)^*(diff f)$ is the adjoint operator of $dif x |-> dirder(f, x)(dif x)$, satisfying

#let ip(left, right) = $lr(angle.l left, right angle.r)$
$
ip(dirder(f, x)^*(diff f), dif x) = ip(diff f, dirder(f, x)(dif x))
$
for some inner product $ip(quad, quad)$.

This functor has the composition law
$
reverse(g compose f)(x) = (g(f(x)), dirder(f, x)^* compose dirder(g, f(x))^*)
$


= Graphs

#let get-next-layer(program, vars) = {
	program.pairs().filter( ((var, (_, dfn))) => {
		vars.any(var => var in dfn)	
	}).to-dict().keys()
}

#let get-layers(program) = {
	let inputs = get-inputs(program)
	let layer = inputs
	let layers = ()
	while layer.len() > 0 {
		layers.push(layer)
		layer = get-next-layer(program, layer)
	}
	layers
}

#import "@preview/fletcher:0.5.2": diagram, node, edge

#let layers = get-layers(program)

#let flow-diagram(program, inputs, outputs) = {
	set align(center)
	diagram(
		// node-fill: luma(90%),
		// node-outset: 5pt,
		spacing: (20pt, 50pt),
		for (l, layer) in layers.enumerate() {
			for (v, var) in layer.enumerate() {
				let (fn, dfn) = program.at(var)
				let lhs = if inputs.at(var) != none { $inputs.at(var) = $ }
				node((l, v - layer.len()/2), $ lhs outputs.at(var) $, name: var)
				for var2 in dfn.keys() {
					edge(label(var2), "-|>", label(var))
				}
			}
		}
	)
}

Program flow can be visualised like this:
#flow-diagram(
	program,
	program.pairs().map( ((var, (fn, dfn))) => (var, fn)).to-dict(),
	program.pairs().map( ((var, (fn, dfn))) => (var, var)).to-dict(),
)

The forward mode program has the same flow:

#flow-diagram(
	program,
	program.pairs().map( ((var, (fn, dfn))) => (var, if fn != none { forward(fn) })).to-dict(),
	program.pairs().map( ((var, (fn, dfn))) => (var, $(var, dif var)$)).to-dict(),
)

The reverse mode program, however, propagates derivatives backwards, as if all the arrows are reversed.



= Further reading

https://rufflewind.com/2016-12-30/reverse-mode-automatic-differentiation