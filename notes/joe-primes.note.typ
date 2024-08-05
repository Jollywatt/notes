#import "@local/notes:0.1.0"
#show: notes.style

= Joe's cracked prime counting formula

From God, we know:

#show sym.rho: sym.rho.alt

$
Pi^rho_epsilon (x) =
	sum_(s=0)^rho (1 + e^(2epsilon(s - x)))^(-1)
	max{
		(cos(pi s)^(2epsilon))/(1 + e^epsilon(6 - 4s))
		- sum_(q=2)^rho (cos((pi s)/q)^(2epsilon))/(1 + e^epsilon(6q - 4s)), 0}
$
where $rho, epsilon in NN_0$ are large.
$
Pi(x) = lim_(rho, epsilon -> oo) Pi^rho_epsilon (x)
$

Credit goes to #link("https://joebacchus.github.io")[Joe].