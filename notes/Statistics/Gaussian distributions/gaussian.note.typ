#import "@local/notes:0.1.0"
#show: notes.style

#let normal(mean, cov) = $cal(N)(mean, cov)$

#let mean = $bold(mu)$
#let cov = $bold(Sigma)$

= Multivariate Gaussian distributions

#notes.result-box[
The $D$-dimensional Gaussian pdf with mean vector $mean$ and covariance matrix $cov$ is

$
normal(mean, cov) := 1/sqrt(tau^D det(cov)) exp(-1/2 (x - mean)^T cov^(-1) (x - mean))
$
]

A Gaussian's parameters are fully specified by the coefficients of $x$ in the exponent.
$
-2 ln normal(mean, cov)
	&= (x - mean)^T cov^(-1) (x - mean) + "constant" \
	&= x^T cov^(-1) x - x^T cov^(-1) mean - mean^T cov^(-1) x + "constant" \
$
