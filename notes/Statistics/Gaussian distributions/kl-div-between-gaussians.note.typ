#import "@local/notes:0.1.0"
#show: notes.style

#let KL(p, q) = $"KL"(#p, #q)$
#let normal(mean, cov) = $cal(N)(mean, cov)$
#let tr(it) = $"tr"[it]$
#let ex(var, it) = $EE_var {it}$
#let (p1, p2) = ($p$, $q$)
#let (mean1, mean2) = ($mu$, $nu$)
#let (cov1, cov2) = ($Sigma$, $Lambda$)

= Kullback--Leibler divergence between multivariate Gaussians

The Kullback--Leibler divergence from distribution $p(x)$ to $q(x)$ is:
$
KL(p1, p2) = ex(p1, log(p1) - log(p2)) = integral log(p1(x)/p2(x)) p(x) dif x
$
If $p = normal(mean1, cov1)$ and $q = normal(mean2, cov2)$ are @gaussian[multivariate Gaussian distributions], then
$
log p1 &= -D/2 log tau - 1/2 log abs(cov1) - 1/2 (x - mean1)^T cov1 (x - mean1) \
log p2 &= -D/2 log tau - 1/2 log abs(cov2) - 2/2 (x - mean2)^T cov2 (x - mean2) \
$
and so
$
KL(p1, p2) = 1/2 log abs(cov1)/abs(cov2)
	- 1/2 ex(p1, (x - mean1)^T cov1^(-1) (x - mean1))
	+ 1/2 ex(p2, (x - mean2)^T cov2^(-1) (x - mean2))
$
Since the terms are scalars, they are equal to their trace, allowing us to take the covariance matrices out of the expectation value:
$
KL(p1, p2) = 1/2 log abs(cov1)/abs(cov2)
	- 1/2 tr(ex(p1, (x - mean1) (x - mean1)^T) cov1^(-1))
	+ 1/2 tr(ex(p2, (x - mean2) (x - mean2)^T) cov2^(-1))
$
In more detail each term is rewritten as follows:
$
	  &tr(ex(p1, (x - mean1)^T cov1^(-1) (x - mean1)))
\	= &ex(p1, tr((x - mean1)^T cov1^(-1) (x - mean1)))
\	= &ex(p1, tr((x - mean1) (x - mean1)^T cov1^(-1)))
\	= &tr(ex(p1, (x - mean1) (x - mean1)^T cov1^(-1)))
\	= &tr(ex(p1, (x - mean1) (x - mean1)^T ) cov1^(-1))
$

Since $ex(p1, (x - mean1) (x - mean1)^T) = cov1$ by definition, the first term becomes $tr(cov1 cov1^(-1)) = D$, while the second can be rewritten as
$
	&ex(p1, (x - mean2) (x - mean2)^T)
\	= &ex(p1, ((x - mean1) - (mean2 - mean1)) ((x - mean1) - (mean2 + mean1))^T)
\	= &ex(p1, (x - mean1) (x - mean1)^T) - (x - mean1) (mean2 - mean1) - (mean2 - mean1) (x - mean1) + (mean2 - mean1) (mean2 - mean1)^T))
\	= &cov1 + (mean1 - mean2) (mean1 - mean2)^T
$
Pulling this together,
#notes.result-box[
$
KL(p, q)
	&= 1/2 log abs(cov2)/abs(cov1) - D/2 + 1/2 tr((cov1 + (mean1 - mean2) (mean1 - mean2)^T)) cov2^(-1))
\	&= 1/2 log abs(cov2)/abs(cov1) - D/2 + 1/2 tr(cov1 cov2^(-1)) + tr((mean1 - mean2)^T cov2^(-1) (mean1 - mean2))
$
]

== Univariate case

For $D = 1$, this result becomes:
#notes.result-box[
$
KL(normal(mu, sigma^2), normal(nu, rho^2)) = log rho/sigma + (sigma^2 + (mu - nu)^2)/(2 rho^2) - 1/2
$
]