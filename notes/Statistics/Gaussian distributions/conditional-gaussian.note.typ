#import "@local/notes:0.1.0"
#show: notes.style

#let normal(mean, cov) = $cal(N)(mean, cov)$

#let mean = $bold(mu)$
#let cov = $Sigma$
#let val = $bold(x)$

#set math.vec(delim: "[")
#set math.mat(delim: "[")

#show sym.Sigma: math.italic

= Conditional Gaussian

Let $bold(x) tilde normal(mean, cov)$ be a normally distributed vector in $RR^D$.
Suppose the space $RR^D = RR^m plus.circle RR^n$ is split in two and write:
$
val &= vec(val_1, val_2), & quad
mean &= vec(mean_1, mean_2), & quad
cov &= mat(cov_1, R; R^T, cov_2)
$
Then, $val_1$ given $val_2$ is distributed as:
#notes.result-box(
	$
	val_1 | val_2 tilde normal(mean_1 + R cov_2^(-1) (val_2 - mean_2), cov_1 - R cov_2 R^T)
	$
)

*Proof.*
The conditional distribution $P(val_1 | val_2) = P(val_1, val_2) slash P(val_2)$ is also Gaussian, as it is the product of two exponentials of quadratic forms.
To fully specify a Gaussian distribution, we need only find the leading coefficients of $x$ that appear in the exponent (as mentioned in @gaussian).
$
Q(val_1) 
	&:= -2 ln P(val_1 | val_2) \
	&= -2 ln P(val_1, val_2) + 2ln P(val_2) \
	&=
		vec(val_1 - mean_1, val_2 - mean_2)^T
		mat(cov_1, R; R^T, cov_2)^(-1)
		vec(val_1 - mean_1, val_2 - mean_2)
		+ "constant"
$
The constant is independent on $val_1$, but may depend on $val_2$.
Using results from @rasmussen2008[A.3], the inverse of the block matrix is of the form
$
mat(cov_1, R; R^T, cov_2)^(-1)
&= mat(tilde(cov)_1, tilde(R); tilde(R)^T, tilde(cov)_2)
quad "where" cases(
	tilde(cov)_1 &= (cov_1 - R cov_2 R^T)^(-1),
	tilde(R) &= -tilde(cov)_1 R cov_2^(-1),
	tilde(R)^T &= -cov_2^(-1) R^T tilde(cov)_1,
	tilde(cov)_2 &= "not important"
)
$
Using this, we may expand the quadratic form in $val_1$ as
$
Q(val_1) &= (val_1 - mean_1)^T tilde(cov)_1 (val_1 - mean_1)
	+ val_1^T tilde(R)^T (val_2 - mean_2)
	+ (val_2 - mean_2)^T tilde(R) val_1
	+ "constant" \
	&= val_1^T underbrace(tilde(cov)_1, cov^(-1)) val_1
	- val^T underbrace([tilde(cov)_1 mean_1 - tilde(R)^T (val_2 - mean_2)], cov^(-1) mean)
	- underbrace([mean_1^T tilde(cov)_1 - (val_2 - mean_2)^T tilde(R)], mean^T cov^(-1)) val_1
$
The underbraces show the @gaussian[corresponding coefficients for a standard Gaussian], $normal(mean, cov)$.
The resulting mean and covariance matrix are therefore
$
cov &= tilde(cov)_1^(-1) \
mean &= tilde(cov)_1^(-1) (tilde(cov)_1 mean_1 - tilde(R)^T (val_2 - mean_2)) \
$
which, using the fact that $cov_2^(-1) R^T = R cov_2^(-1)$ is symmetric, can be expressed in terms of the original block matrix components as:
$
cov &= cov_1 - R cov_2 R^T \
mean &= mean_1 + R cov_2^(-1) (val_2 - mean_2) \
$
