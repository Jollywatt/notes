#import "@local/notes:0.1.0"
#show: notes.style

#let KL(from, to) = $"KL"(from : to)$
#let normal(mean, cov) = $cal(N)(mean, cov)$
#let metric(a, b) = $lr(angle.l #a, #b angle.r)$

#let labeq(eqn, lab) ={
	set math.equation(numbering: "(1)")
	[#eqn #lab]
}

= The hyperbolic space of univariate Gaussians

An interesting relationship exists between the space of univariate Gaussian distributions $(mu, sigma) in RR times (0, oo)$ and hyperbolic geometry.
This relationship can be seen with the following steps:

+
	There is a natural notion of "distance" from one distribution to another, the _Kullback--Leibler divergence_ $KL(p, q)$, although this is not strictly a distance metric because $KL(p, q) != KL(q, p)$ in general.
	The @kl-div-between-gaussians[divergence between two univariate Gaussians] has the explicit form:
	$
	KL(normal(mu, sigma^2), normal(nu, rho^2)) = log rho/sigma + (sigma^2 + (mu - nu)^2)/(2 rho^2) - 1/2
	$

+
	The divergence from $p$ to $q$ is zero when $p = q$, and positive otherwise. Thus, the first derivatives of $KL(p, q)$ with respect to the parameters of $p$ vanish at the point $p = q$, but the second derivatives are positive.
	These positive second derivatives from a symmetric positive-definite matrix.
	This defines a metric tensor, known as the _Fisher information metric_, on the space of distributions.
	For Gaussians, @fisher-info-metric-for-gaussians[this works out to be]
	$
	metric(arrow(u), arrow(v)) = arrow(u)^T mat(
		1/sigma^2, 0;
		0, 2/sigma^2,
	) arrow(v)
	$
	where $arrow(u) = (u_mu, u_sigma)$ and $arrow(v) = (v_mu, v_sigma)$ are displacement vectors for the parameters.
	In the style of differential geometry, this is equivalently written as
	#labeq($
	g = dif s^2 = (dif mu^2 + 2 dif sigma^2)/sigma^2
	$, <metric>)
	where $g (arrow(u), arrow(v)) = metric(arrow(u), arrow(v))$.

+
	@metric is related to the metric of the @poincare-half-plane[Poincaré half-plane] ${(x,y) | y > 0}$ with $mu = sqrt(2) x, sigma = y$:
	$
	(dif mu^2 + 2 dif sigma^2)/sigma^2 = 2 ((dif x^2 + dif y^2)/y^2)
	$

+
	The Poincaré half-plane can be isometrically mapped to the Poincaré unit disk and then to the upper sheet of a hyperboloid.

	+
		The mapping from the half plane to the unit disk is given by
		$
		z |-> i ((z - i)/(z + i))
		quad <==> quad
		vec(x, y) |-> 1/(x^2 + (y + 1)^2) vec(2x, x^2 + y^2 - 1)
		$
		where $z = x + i y$.
		#import "@preview/cetz:0.3.1"
		#align(center, cetz.canvas({
			let num(i) = numbering("I", i)
			import cetz.draw: *
			arc((1,0), radius: 1, start: 0deg, stop: 180deg)
			line((-2,0), (+2,0))
			line((0,0), (0,+2))
			content(( 45deg, 1.4), num(1))
			content((135deg, 1.4), num(2))
			content((135deg, 0.5), num(3))
			content(( 45deg, 0.5), num(4))
			circle((0,0), radius: 3pt, fill: eastern, stroke: none)

			content((2.5,0), $|->$)

			translate(x: 4)
			circle((0,0), radius: 1)
			line((-1,0), (+1,0))
			line((0,-1), (0,+1))
			range(4).map(i => {
				content((i*90deg + 45deg, 0.6), num(i + 1))
			}).join()
			circle((0,0), radius: 3pt, fill: eastern, stroke: none)
		}))
		See @poincare-plane-to-disk[this Desmos plot] for a more detailed visualisation of this mapping.
		The Jacobian is:
		$
		dif z |-> (-2 dif z)/(z + i)^2
		$

	+
		The mapping from the unit disk to the upper hyperboloid is given by