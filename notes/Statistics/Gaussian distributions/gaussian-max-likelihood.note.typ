#import "@local/notes:0.1.0"
#show: notes.style

#let xv = $arrow(x)$
#let cov = $Sigma$
#let mean = $arrow(mu)$

#show <result>: it => box(it, fill: green.lighten(95%), stroke: green, inset: 5pt)

= Maximising likelihood for multivariate Gaussian distributions

When you find the mean of some data, what you are really doing is finding a parameter which _maximises the likelihood_.

For instance, assume some points ${xv_1, ..., xv_N} subset RR^d$ are normally distributed.
The conditional probability of the data is
$
P(xv_i | mean, cov) = product_(i=1)^N 1/sqrt(tau^d det cov) exp(-1/2 (xv_i - mean)^T cov^(-1) (xv_i - mean))
$
which is also the _likelihood_ of the parameters $mean$ and $cov$.
It is often easiler to manipulate the logarithm of the likelihood:
$
log P = -1/2 log(tau^d det cov) - 1/2 sum_(i=1)^N (xv_i - mean)^T cov^(-1) (xv_i - mean)
$

== Fitting $mean$ to data

To find the mean $mean$ which maximises the likelihood, note that $log P$ is quadratic in $mean$, so the maximum occurs at the unique point where its derivative vanishes.

Consider the differential $delta log P$ induced by $mean -> mean + delta mean$:
$
delta log P
	&= 1/2 sum_(i=1)^N [
		(delta mean)^T cov^(-1) (xv_i - mean) +
		(xv_i - mean)^T cov^(-1) delta mean
	] \
	&= sum_(i=1)^N [(xv_i - mean)^T cov^(-1)] delta mean \
	&= [sum_(i=1)^N xv_i - N mean]^T cov^(-1) delta mean
$
If the likelihood is at a local maximum, then $delta log P$ must vanish for any $delta mean$.
This holds when:
$
mean = 1/N sum_(i=1)^N xv_i
$ <result>

== Fitting $cov$ to data

To find the covariance matrix $cov$ which maximises the likelihood, consider the differential likelihood induced by $cov -> cov + delta cov$.

$
delta log P = -N/2 (delta det cov)/(det cov) - 1/2 sum_(i=1)^N (xv_i - mean)^T delta (cov^(-1)) (xv_i - mean)
$

Use the identities
$
	delta det A &= tr[A^(-1) delta A] det A
\	delta (cov^(-1)) &= cov^(-2) delta cov = delta cov #h(2pt) cov^(-2)
$
and take the trace to obtain
$
tr[delta log P] = -N/2 tr[cov^(-1) delta cov]
- 1/2 sum_(i=1)^N tr[(xv - mean)(xv - mean)^T cov^(-2) delta cov]
$
where we use the cyclic property of the trace in the last term.

If the likelihood is at a local maximum, then it vanishes for any $delta cov$.
Since $delta cov$ is arbitrary, this scalar equality between trace implies equality between the matrices themselves:
$
-2 delta log P = - N cov^(-1) delta cov + sum_(i=1)^N (xv - mean)(xv - mean)^T cov^(-2) delta cov
$
This vanishes when the covariance matrix is given by:
$
cov = 1/N sum_(i=1)^N (xv - mean)(xv - mean)^T
$ <result>