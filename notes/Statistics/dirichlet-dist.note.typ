#import "@local/notes:0.1.0"
#show: notes.style

#let eqnum(it) = {
	set math.equation(numbering: "(1)")
	it
}

= The Dirichlet distribution

The multinomial distribution answers the question:
#quote[
	What is the probability of obtaining a particular set of counts $bold(c) = (c_1, ..., c_k) in NN_0^k$ from repeated draws from a categorical distribution $bold(beta) = (beta_1, ..., beta_k) in [0, 1]^k$?
]
The answer is:
$
"Multinomial"(bold(c) | bold(beta))
	= (sum_i c_i)!/(product_i c_i !) product_i beta_i^c_i
	= (c_1 + dots.c + c_k)!/(c_1 ! dots.c c_k !) beta_1^c_1 dots.c beta_k^c_k
$
The Dirichlet distribution asks the opposite question:
#quote[
	What is the probability that a particular categorical distribution is responsible for a given set of counts?
]
The answer is:
#eqnum[$
"Dirichlet"(bold(beta) | bold(alpha))
	= Gamma(sum_i alpha_i)/(product_i Gamma(alpha_i)) product_i beta_i^(alpha_i - 1)
$ <dirichlet>]
Note that these equations are equal with $alpha_i = c_i + 1$. The difference between the distributions is in the interpretation, and in that $alpha_i$ is not assumed to be integral.

== Mean

The expectation value of $bold(beta)$ can be computed for each component.
$
EE{beta_i}
	&= integral_0^1 beta_i Pr(beta_i | bold(beta)_([i]), bold(alpha)) dif beta_i
	&= integral_Delta beta_i "Dirichlet"(bold(beta) | bold(alpha)) dif bold(beta)
$
The integral $integral_Delta$ is taken over the simplex $sum_i beta_i = 1$. Substituting @dirichlet yeilds
#eqnum[$
EE{beta_i}
	&= Gamma(sum_j alpha_j)/(product_j Gamma(alpha_j)) integral_Delta beta_i product_(j != i) beta_j^(alpha_j - 1) dif bold(beta)
$ <step>]
where the integrand is now proportional to @dirichlet, but with one of the shape factors offset as $alpha_i |-> alpha_i + 1$ due to the extra $beta_i$.
We can circumnavigate this integral by noting that the Dirichlet distribution is normalised to establish
$
integral_Delta "Dirichlet"(bold(beta) | alpha_1, ..., alpha_i + 1, ..., alpha_k) dif bold(beta)
	= Gamma(sum_j alpha_j + 1)/(Gamma(alpha_i + 1) product_(j!=i) Gamma(alpha_j)) integral_Delta beta_i product_(j != i) beta_j^(alpha_j - 1) dif bold(beta) = 1
$
which, substituted into @step, gives
$
EE{beta_i} = Gamma(sum_j alpha_j)/(product_j Gamma(alpha_j)) (Gamma(alpha_i + 1) product_(j!=i) Gamma(alpha_j))/Gamma(sum_j alpha_j + 1) = Gamma(alpha_i + 1)/Gamma(alpha_i) Gamma(sum_j alpha_j)/Gamma(sum_j alpha_j + 1) = alpha_i/(sum_j alpha_j) =: alpha_i/alpha_0
$

#notes.result-box[
For $bold(beta) in "Dirichlet"(bold(alpha))$, the mean of a component $beta_i$ is
	$ EE{beta_i} = alpha_i/alpha_0 $
where $alpha_0 = sum_i alpha_i$.
]