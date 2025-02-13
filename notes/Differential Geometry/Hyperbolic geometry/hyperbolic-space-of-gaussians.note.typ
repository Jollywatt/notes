#import "@local/notes:0.1.0"
#show: notes.style

#let KL(from, to) = $"KL"(from : to)$
#let normal(mean, cov) = $cal(N)(mean, cov)$
#let metric(a, b) = $lr(angle.l #a, #b angle.r)$

#set math.vec(delim: "[")

#let labeq(eqn, lab) ={
	set math.equation(numbering: i => [(#i)], supplement: none)
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
	The space of univariate Gaussian distributions equipped with the metric @metric scaled by half, $g slash 2$, is isometric to hyperbolic 2-space.
	In particular, it is isometric to one sheet of the unit hyperboloid embedded in $RR^3$ with the metric $"diag"(+1, +1, -1)$.

	The isometry is most easily expressed by factoring it into a sequence of isometries between various spaces.
	The table below shows how to move from $(lambda, theta)$ coordinates parametrising the upper sheet of the unit hyperboloid $z^2 = x^2 + y^2 + 1$ to $(mu, sigma)$ coordinates.

	#table(
		columns: (auto, auto, 1fr),
		align: (center + horizon, center + horizon, left),
		inset: 10pt,
		..([System], [Metric], [Description]).map(strong),
		$ vec(lambda, theta) $,
		$ dif lambda^2 + sinh^2 lambda dif theta^2 $,
		[Surface of hyperboloid with rapidity $lambda$],
		$ vec(x, y, z) = vec(cos theta sinh lambda, sin theta sinh lambda, cosh lambda) $,
		$ dif x^2 + dif y^2 - dif z^2 $,
		[Cartesian hyperbolic 3-space],
		$ vec(rho, theta, z) = vec(sinh lambda, theta, cosh lambda) $,
		$ dif rho^2 + rho^2 dif theta^2 - dif z^2 $,
		[Cylindrical hyperbolic 3-space],
		$ vec(r, theta) = vec(rho/(z + 1), theta) $,
		$ 4(dif r^2 + r^2 dif theta^2)/(1 - r^2)^2 $,
		[Polar coordinates on hyperbolic unit disk],
		$ zeta = r e^(i theta) $,
		$ (4 dif zeta dif zeta^*)/(1 - zeta zeta^*)^2 $,
		[Poincaré disk],
		$ xi = 1/i ((zeta + i)/(zeta - i)) $,
		$ (dif xi dif xi^*)/Im(xi)^2 $,
		[Poincaré half-plane],
		$ vec(mu, sigma) = vec(sqrt(2) Re(xi), Im(xi)) $,
		$ (dif mu^2 + 2 dif sigma^2)/(2sigma^2) $,
		[Parameter space of univariate Gaussians with the associated @fisher-info-metric-for-gaussians[Fisher Information metric] multiplied by $1/2$],
	)

	See @hyperbolic-isometries for numerical verifications of the relationships above.