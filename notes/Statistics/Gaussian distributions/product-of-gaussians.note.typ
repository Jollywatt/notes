#import "@local/notes:0.1.0"
#show: notes.style

#let normal(mean, cov) = $cal(N)(mean, cov)$

#let mean = $bold(mu)$
#let cov = $bold(Sigma)$

= Product of Gaussian probability density functions

#block(width: 100%, stroke: green, fill: green.lighten(95%), radius: 5pt, inset: 1em)[
The product of two Gaussian PDFs is an unnormalised Gaussian:
$
	normal(mean_1, cov_1)normal(mean_2, cov_2) prop 
	normal((cov_1 + cov_2)^(-1)(cov_1 mean_2 + cov_2 mean_1), (cov_1^(-1) + cov_2^(-1))^(-1))
$
// $
// 	product_(i=1)^N normal(mean_i, cov_i) =
// 	normal((sum_(i=1)^N cov_i^(-1))^(-1) (sum_(i=1)^N cov_i^(-1) mean_i), (sum_(i=1)^N cov_i^(-1))^(-1))
// $
For many Gaussians:
$
	normal(mean_1, cov_1)normal(mean_2, cov_2) dots.c normal(mean_N, cov_N) &prop
	normal(cov (cov_1^(-1) mean_1 + dots.c + cov_N^(-1) mean_N), cov) \
	"where" cov &= (cov_1^(-1) + dots.c + cov_N^(-1))^(-1)
$
In other words, precisions are summed and means weighted by precisions are summed.
$
	cov^(-1) = cov_1^(-1) + cov_2^(-1)
	quad "and" quad
	cov^(-1) mean = cov_1^(-1) mean_1 + cov_2^(-1) mean_2.
$
]

The $D$-dimensional Gaussian pdf with mean vector $mean$ and covariance matrix $cov$ is

$
normal(mean, cov) := 1/sqrt(tau^D det(cov)) exp(-1/2 (x - mean)^T cov^(-1) (x - mean))
$


Consider the product of two $D$-dimensional Gaussians:

#let both = $cal(N)_(1 2) $
$
both := normal(mean_1, cov_1)normal(mean_2, cov_2) prop
	// 1/sqrt(tau^(M + N) det(cov_1) det(cov_2))
	exp(-1/2(x - mean_1)^T cov_1^(-1) (x - mean_1) - 1/2(x - mean_2)^T cov_2^(-1) (x - mean_2))
$

The result is also a Gaussian.
To find the resulting mean $mean$ and covariance matrix $cov$, rearrange the exponent as

$
// -2 log( normal(mean_1, cov_1)normal(mean_2, cov_2) )
-2 log(both)
	&= (x - mean_1)^T cov_1^(-1) (x - mean_1) + (x - mean_2)^T cov_2^(-1) (x - mean_2) + c \
	&= x^T (cov_1^(-1) + cov_2^(-1)) x - x^T [cov_1^(-1) mean_1 + cov_2^(-1) mean_2] - [mean_1^T cov_1^(-1) + mean_2^T cov_2^(-1)] x + c
$

where $c$ is constant with respect to $x$.
Then compare this to the exponent of a single Gaussian:

$
-2 log( normal(mean, cov) )
	&= (x - mean)^T cov^(-1) (x - mean) \
	&= x^T cov^(-1) x - x^T cov^(-1) mean + mean^T cov^(-1) x + c
$

By equating coefficients of $x$, we see that the resulting mean and covariance matrix are

$
cov &= (cov_1^(-1) + cov_2^(-1))^(-1) \
mean &= cov (cov_1^(-1) mean_1 + cov_2^(-1) mean_2) \
	&= (cov_1 + cov_2)^(-1) (cov_1 mean_2 + cov_2 mean_1)
$

The last line follows from the fact that covariance matrices are symmetric, so $cov_1 cov_2 cov_1^(-1) = cov_2$ and similarly for $1 <-> 2$.
