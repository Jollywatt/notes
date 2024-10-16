#import "@local/notes:0.1.0"
#show: notes.style

= Variance of a sum of random variables

#let var(it) = $"Var"[it]$
#let avg(it) = $lr(angle.l it angle.r)$

Let $X$ and $Y$ be random variables.
$ var(X) := avg((X - avg(X))^2) = avg(X^2) - avg(X)^2 $

Then:
$
var(X + Y)
	&= avg((X + Y)^2) - avg(X + Y)^2 \
	&= avg(X^2 + 2 X Y + Y^2) - (avg(X)^2 + 2avg(X)avg(Y) + avg(Y)^2) \
	&= var(X) + var(Y) + 2(avg(X Y) - avg(X)avg(Y))
$

Now, if the random variables $X$ and $Y$ are independent in the sense that $rho(X, Y) = rho(X)rho(Y)$, then the expected value of their product is the product of their expected values.
$
avg(X Y)
	= integral X Y rho(X, Y) dif X dif Y
	= integral X rho(X) dif X integral Y rho(Y) dif Y
	= avg(X) avg(Y)
$

Hence
$ #rect(stroke: green, $X perp Y ==> var(X + Y) = var(X) + var(Y)$) $
where $X perp Y <==> rho(X, Y) = rho(X) rho(Y)$.
