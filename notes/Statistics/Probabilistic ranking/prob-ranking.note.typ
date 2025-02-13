#import "@local/notes:0.1.0"
#show: notes.style

#let normal = $cal(N)$
#let data = $cal(D)$
#let win = $y$
#let wins = $arrow(y)$
#let skill = $w$
#let skills = $arrow(w)$
#let perf = $w$
#let perfs = $arrow(t)$
#let prob = $upright(P)$
#let sign = math.op("sign")

= Probabilistic ranking

== Scenario

Suppose there are $P$ players and $G$ games, where each game is between any two (distinct) players.
For the $g$th game, played between players $A_g$ and $B_g$, the game outcome is:
$
win_g = cases(+1 "if" A_g "wins", -1 "if" B_g "wins")
$

== Model

We wish to model $wins$ by
$
y_g = sign(t_g), quad t_g ~ normal(w_A_g - w_B_g, 1)
$
where to each player $p in {1, ..., P}$ we assign a _skill_ $skill_p in RR$.

Given this model, the probability of the outcomes given the players' skills is:
$
prob(wins | skills) &= product_(g=1)^G prob(win_g | skills) \
prob(win_g | skills) &= integral prob(win_g | t_g) prob(t_g | skill_A_g, skill_B_g) dif t_g \
	prob(win_g | t_g) &= cases(1 "if" win_g = sign(t_g), 0 "otherwise") \
prob(t_g | skill_A_g, skill_B_g) &= normal(t_g | skill_A_g - skill_B_g, 1)
$
We can roll the last three equations into one:
$
prob(win_g | skills)
	&= integral_0^oo normal(y_g t_g | skill_A_g - skill_B_g, 1) dif t_g 
	= Phi(win_g (skill_A_g - skill_B_g))
$
where $Phi(x) = integral_(-oo)^x normal(x | 0, 1) dif x$, leading to the final likelihood:
$
prob(wins | skills) = product_(g=1)^G Phi(win_g (skill_A_g - skill_B_g))
$

== Posterior

The posterior is
$
prob(skills | wins) prop P(wins | skills) P(skills) = normal(wins | mu_0, Sigma_0) product_(g=1)^G Phi(win_g (skill_A_g - skill_B_g))
$
for a prior $P(skills) = normal(wins | mu_0, Sigma_0)$.
This is hard to sample from.

= Gibbs sampling

== Introducing performance differences, $perfs$

$
prob(skills | wins) = integral prob(skills, perfs | wins) prob(perfs | wins) dif perfs
$




=== Conditioning on one player's skill, $skill_p$

#let otherskill = $arrow(skill)^complement$

$
prob(skill_p | wins, otherskill_p)
	&prop prob(wins | skill_p, otherskill_p) prob(skill_p | otherskill_p)
	= prob(wins | skills) prob(skill_p)
$

$
prob(skills | wins) = integral prob(skills | wins, skill_p) prob(skill_p | wins) dif skill_p
$

=== Conditioning on one game's performance difference, $t_g$

$
prob(skills | wins) = integral prob(skills | wins, t_g) prob(t_g | wins) dif t_g
$

$
prob(skills | wins, t_g) = normal(t_g | y_g (skill_A_g - skill_B_g))
, quad
prob(t_g | wins) = cases(1 " if " sign t_g = y_g, 0 " otherwise")
$

== Derivative of likelihood

$
delta log P(y | w)
	&= sum_(j = 1)^G normal(y_j (w_A_j - w_B_j)) y_j (delta w_A_j - delta w_B_j) \
	&= sum_(i = 1)^P sum_(j = 1)^G y_j xi_(i j) normal(y_j (w_A_j - w_B_j)) delta w_i \
	&= delta w^T A y
$
where
$
	xi_(i j) = cases(
		+1& "if" i = A_j,
		-1& "if" i = B_j,
		 0& "otherwise",
	)
$

$
	A = [xi_(i j) normal(y_j (w_A_j - w_B_j))]_(i j)
$

