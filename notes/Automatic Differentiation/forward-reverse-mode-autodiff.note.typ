#import "@local/notes:0.1.0"
#show: notes.style

#let dwrt(var) = $op(diff_var)$ // derivative with respect to
#let dwrt(var) = $diff/(diff var)$ // derivative with respect to
#let terminal = $star$
#let fmtnone(x) = if x == none { terminal } else { x }

#let program-box(it) = align(center,
	block(stroke: luma(80%), inset: 0.5em, it)
)

#let add-backlinks(program) = {
	for (i, _) in program.pairs().rev() {
		program.at(i).affects = ()
		for (j, obj) in program {
			if i in obj.df.keys() {
				program.at(i).affects.push(j)
			}
		}
	}
	program
}

#let show-program(program) = {
	let program = add-backlinks(program)

	let lines = program.pairs().map(((name, obj)) => {
		$name &= fmtnone(obj.f) && ~~> #fmtnone(obj.affects.join($, $))$
	})

	show: program-box
	$
	#lines.join($\ $)
	$
}

#let show-forward-mode(program) = {
	let lines = add-backlinks(program).pairs().map(((name, obj)) => {
		let rhs = obj.df.pairs()
			.map(((var, der)) => $der dif var$).join($op(+)$)
		$dif name &= fmtnone(rhs)$
	})
	show: program-box
	$ #lines.join($\ $) $
}

#let show-reverse-mode(program) = {
	let program = add-backlinks(program)
	let lines = program.pairs().rev().map(((name, o)) => {
		let rhs = o.affects.map(var => {
			program.at(var).df.at(name)
			$op(diff var)$
		}).join($op(+)$)
		$diff name &= fmtnone(rhs)$
	})
	show: program-box
	$ #lines.join($\ $) $
}

= Forward and Reverse Mode Automatic Differentiation

Suppose you have simple program
$z(x, y) = x y + sin x$
which you wish to differentiate.


#let program = (
	x: (
		f: none,
		df: (:),
	),
	y: (
		f: none,
		df: (:),
	),
	a: (
		f: $x y$,
		df: (x: $y$, y: $x$),
	),
	b: (
		f: $sin x$,
		df: (x: $cos x$),
	),
	z: (
		f: $a + b$,
		df: (a: $$, b: $$),
	),
)

First, transform the expression into Single Simple Assignment form, where each step is a single atomic operation whose derivative is known.

#show-program(program)

We write $alpha = terminal$ to indicate that $alpha$ is an input, or free parameter.
The notation $alpha ~~> beta$ means the value of $alpha$ is directly referenced by $beta$ below.



== Forward mode

The forward mode derivative program is formed simply by finding the differential of each step.

#show-forward-mode(program)

For any given $dif x$ and $dif y$, we can directly compute $dif z$.
For example, if $(dif x, dif y) = (1, 0)$, then $dif z$ evaluates to $diff z slash diff x$.

Forward mode requires *one evaluation* of the derivative program *per input* parameter.

== Reverse mode

The reverse mode is slightly harder: from bottom to top, find the derivative operator $dwrt(alpha)$ of the variable $alpha ~~> beta_1, ..., beta_k$ by writing it in terms of the variables it affects using the chain rule:
$
dwrt(alpha) = (diff beta_1)/(diff alpha) dwrt(beta_1) + dots.c + (diff beta_k)/(diff alpha) dwrt(beta_2)
$
Then, write $diff alpha$ in place of $dwrt(alpha)$, and view it as a real variable instead of an operator.

#show-reverse-mode(program)

Then, to find $dwrt(x) z(x, y)$, we assign $diff z = 1$ and substitute from top to bottom to obtain $dif x$ and $dif y$.

We set $diff z = 1$ because, when viewed as an operator applied to the function in question, $dwrt(z) z(x, y) = 1$.
The final values $diff x$ are then interpreted as $dwrt(x) z(x, y)$.

Reverse mode requires *one evaluation* of the derivative program *per output* parameter.
