#import "@local/notes:0.1.0"

#show: notes.style


#let grade(it) = $lr(angle.l it angle.r)$

= Spacetime algebra without reference to a metric signature

Define spacetime basis vectors by $|gamma_mu^2| = 1$ and $gamma_0^2 = -gamma_i^2$.
Define reciprocal basis vectors by $gamma^mu := gamma_mu^(-1)$.
Define the pseudoscalar $I := gamma_0 gamma_1 gamma_2 gamma_3$.

Define relative vectors $sigma_i := gamma_i gamma^0$ so that $
sigma_i^2
	&= gamma_i gamma^0 gamma_i gamma^0 \
	&= -(gamma_i)^2(gamma^0)^2 \
	&= -gamma_i^2(gamma_0^2)^(-1) \
	&= -gamma_i^2(-gamma_i^2)^(-1)
	= 1
$ and $
sigma_1 sigma_2 sigma_3
	&= gamma_1 gamma^0 gamma_2 gamma^0 gamma_3 gamma^0 \
	&= gamma^0 gamma_1 gamma_2 gamma_3 gamma^0 gamma^0 \
	&= gamma_0 gamma_1 gamma_2 gamma_3 gamma_0 gamma^0 \
	&= gamma_0 gamma_1 gamma_2 gamma_3
	= I
$

Define $sigma^i = sigma_i^(-1)$ and find $sigma^i = gamma_0 gamma^i$ so that $sigma_i sigma^i = gamma_i gamma^0 gamma_0 gamma^i = 1$.

== Relation to vector cross product

If $times$ is the $RR^3$ cross product, then for $arrow(E) = E^i sigma_i$ and $arrow(B) = B^i sigma_i$ we have $
grade(arrow(E) arrow(B))_2
	&= sum_(i,j) E^i B^j grade(sigma_i sigma_j)_2 \
	&= sum_(i != j) E^i B^j sigma_i sigma_j \
	&= sum_(i != j) E^i B^j sigma^k I epsilon_(i j k)
	&= (arrow(E) times arrow(B)) I
$