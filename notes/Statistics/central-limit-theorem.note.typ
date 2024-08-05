#import "@local/notes:0.1.0"
#show: notes.style

#let mgf(X, t) = $M_#X (#t)$
#let avg(it) = $lr(angle.l it angle.r)$
#let normal = $cal(N)$
#let order(it) = $cal(O)(#it)$

= Central limit theorem


#let result(it) = align(center, box(stroke: green, outset: 0.5em, fill: green.lighten(90%), it))

Let $(X_1, ..., X_N)$ be independent and identically distributed random variables with mean $mu$ and variance $sigma^2$.

#result($
	1/Z sum_(i = 1)^N X_i -->^d normal(mu, sigma^2/N)
$)

In other words, their mean converges in distribution to a normal distribution with standard deviation $sigma/sqrt(N)$.

*Proof*. We are interested in the distribution of the mean $I := 1/N sum_(i = 1)^N X_i$, regarded as a random variable itself.
Define standardised variables $Z_i = (X_i - mu)/sigma$ so that $avg(Z_i) = 0$ and $avg(Z_i^2) = 1$.
Define $xi_N := 1/sqrt(N) sum_(i = 1)^N Z_i$.
We will show that $xi_N --> normal(0, 1)$ as $N --> oo$ by showing that $xi$ has the same moment-generating function as the standard normal distribution.

$
mgf(xi_N, t)
	&= avg(exp t/sqrt(N) sum_i Z_i)
\	&= avg(product_i exp t/sqrt(N) Z_i)
\	&= product_i avg(exp t/sqrt(N) Z_i)
\	&= avg(exp t/sqrt(N) Z_1)^N
\	&= (1 + t/sqrt(N) avg(Z_1) + t^2/(2N) avg(Z_1^2) + dots.c)^N
\	&= (1 + t^2/(2N) + order(N^(-3/2)))^N
$

Therefore, in the limit, $lim_(N -> oo) mgf(xi_N, t) = exp(t^2/2)$, which is the moment-generating function for $normal(0, 1)$.

Finally, note that $
xi = 1/sqrt(N) sum_i Z_i = 1/(sigma sqrt(N)) sum_i (X_i - mu)
= sqrt(N)/sigma (1/N sum_i X_i) - (N mu)/(sigma sqrt(N))
= sqrt(N)/sigma (I - mu)
$
which implies that $I = sigma/sqrt(N) xi + mu tilde normal(mu, sigma^2/N)$.