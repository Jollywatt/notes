#import "@local/notes:0.1.0"
#show: notes.style

#let normal(mean, cov) = $cal(N)(mean, cov)$
#let mean(it) = $mu_it$
#let std(it) = $sigma_it$
#let KL(from, to) = $"KL"(from : to)$
#set math.vec(delim: "[")
#set math.mat(delim: "[")

= Fisher information metric on the space of Gaussians

Consider the space of univariate Gaussian distributions parametrised by $(mu, sigma) in RR times (0, oo)$.
The @kl-div-between-gaussians[Gaussian Kullback--Leibler divergence] from $(mu, sigma)$ to $(mean(1), std(1))$ is:
$
	K(mu_1, sigma_1) := KL(normal(mu, sigma^2), normal(mean(1), std(1)^2))
	= log std(1)/sigma + ((mu - mean(1))^2 + sigma^2 - std(1)^2)/(2std(1)^2)
$
This has a global minimum when the points $(mu, sigma)$ and $(mean(1), std(1))$ coincide, $K(mu, sigma) = 0$.
We can show this because, at this point, the gradient vanishes:
$
nabla K(mu, sigma) = lr(vec((partial K)/(partial mu), (partial K)/(partial sigma))|)_((sigma, mu)) = vec(0, 0)
$
and the Hessian (matrix of second derivatives) is positive definite:
$
nabla^2 K(mu, sigma) = lr(mat(
	(partial^2 K)/(partial mu^2), (partial^2 K)/(partial mu partial sigma);
	(partial^2 K)/(partial sigma partial mu), (partial^2 K)/(partial sigma^2)
)|)_((mu, sigma)) = mat(
	1/sigma^2, 0;
	0, 2/sigma^2,
)
$
An equivalent way to write this is as a metric tensor
$
g = (dif mu^2 + 2 dif sigma^2)/sigma^2
$
so that $g(arrow(u), arrow(v)) = arrow(u)^T (nabla^2 K) arrow(v)$ for any vectors $arrow(u), arrow(v) in RR^2$.

Under a change of coordinates $mu = sqrt(2) x, sigma = y$, the metric $g$ is (twice) the metric of the @poincare-half-plane[Poincaré half-plane] model of hyperbolic space.