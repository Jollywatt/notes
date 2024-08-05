#import "@local/notes:0.1.0"
#show: notes.style

#let aside(body) = {
	set text(luma(80%))
	body
}

#let g(a,b) = grid(columns: (50%, 1fr), a,b)


= What is a random variable?

== $sigma$-algebras

Let $Omega$ be a set.

A subset $Sigma subset.eq 2^Omega$ of the powerset of $Omega$ is a *$sigma$-algebra* if $Sigma$:
+ #g[contains $Omega$][$Omega in Sigma$]
+ #g[is closed under complements][$m in Sigma <==> m^complement in Sigma$]
+ #g[is closed under unions][$m, n in Sigma ==> m union n in Sigma$]

#aside[
It follows that $Sigma$ is closed under intersections; $m, n in Sigma ==> m inter n in Sigma$.
]

== Measures

Let $Omega$ be a set and $Sigma$ be a $sigma$-algebra over $Omega$.

A function $mu : Sigma -> [0, oo)$ is called a *measure* if $mu$:
+ #g[is non-negative][$mu(m) >= 0$]
+ #g[additivity][$mu(m union n) = mu(m) + mu(n)$]

#aside[It follows from $mu(m + nothing) = mu(m)$ that $mu(nothing) = 0$.]

== Random variables

Let $mu$ be a measure on the $sigma$-algebra $Sigma$ over $Omega$.
A *random variable* is a function $ X : Omega -> Omega' $
which induces another measure $mu'$ on the $sigma$-algebra $Sigma'$ over $Omega'$.

The new $sigma$-algebra is defined by $Sigma' = {X(m) | m in Sigma} subset.eq 2^Omega'$ and the new measure by $mu'(m) = mu(X^(-1)(m))$ where $X^(-1) (m) = {n in Omega | X(n) in m}$ is the preimage.