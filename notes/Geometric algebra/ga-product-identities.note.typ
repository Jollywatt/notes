#import "@local/notes:0.1.0"
#show: notes.style

#let lcon = math.op(sym.floor.r)
#let rcon = math.op(sym.floor.l)
#let wedge = math.and

= Identities involving products in geometric algebra

In the formulae below, let $u$ be a $1$-vector and let ${A, B, C}$ be general multivectors.



Vector products @wilson2022[lemma 10]:
$
u lcon A &= 1/2 (u A - A^star u) \
u wedge A &= 1/2 (u A + A^star u) \
$

Vector contraction anti-derivations @wilson2022[corollary 1]:
$
u lcon (A B) = (u lcon A) B + A^star (u lcon B) \
u lcon (A wedge B) = (u lcon A) wedge B + A^star wedge (u lcon B) \
$


Double contractions @wilson2022[lemma 14]:
$
(A rcon B) rcon C &= A rcon (B wedge C) \
A lcon (B lcon C) &= (A wedge B) lcon C \
$


Contraction associativity @wilson2022[lemma 15]:
$ (A lcon B) rcon C = A lcon (B rcon C) $


