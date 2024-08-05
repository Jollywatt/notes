### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 0a57536c-de6e-11ef-1920-71d04e909ec9
begin
	using Pkg
	Pkg.activate(Base.current_project())
	using GeometricAlgebra
	using Test
end

# ╔═╡ a6f0cfa2-56d6-4906-bc6b-624f733e6f94
md"""
# Number of (anti)commuting blades

Let $A \in G$ be an $n$-dimensional $q$-blade.
Define
```math
C^\pm_{nkq} := \dim \mathrm{Z}^\pm_A (\langle G\rangle_k)
```
to be the number of linearly independent $k$-blades that (anti)commute with $A$.
"""

# ╔═╡ e062d135-ae06-4fb2-b2ab-5353dcaf8ae0
md"We can calculate this by brute-force checking every basis blade:"

# ╔═╡ ce71f5d0-f721-46f8-8f93-a4d6fe213f37
function C_empirical(op, n, k, q)
	A = first(basis(n, q))
	sum(A*B ≈ op(B*A) for B in basis(n, k))
end

# ╔═╡ 436b1e25-fdc9-4d70-98e4-dc73c10341e9
md"""
We can also use [the following formula](https://jaw213.user.srcf.net/notes/number-of-commuting-blades):
```math
\begin{align}
C^\pm_{nkq} &= \begin{cases}
W_{nkq} & \text{if $(-1)^{kq} = \pm1$} \\ 
\binom{n}{k} - W_{nkq} & \text{otherwise}
\end{cases} \\
W_{nkq} &= \sum_\text{$m$ even} \binom{q}{m} \binom{n - q}{k - m}
\end{align}
```
"""

# ╔═╡ f6a0815c-6230-45e2-b3e2-2b8fbfb1ed62
W(n, k, q) = sum(binomial(q, m)binomial(n - q, k - m) for m in 0:2:min(k, q))

# ╔═╡ 5689bba5-554d-409a-b304-56eb182e36d3
C(op, n, k, q) = (-1)^(k*q) == op(1) ? W(n, k, q) : binomial(n, k) - W(n, k, q)

# ╔═╡ d974ee5d-2b49-47a0-9db7-6775f3b25fad
md"## Numerical verification"

# ╔═╡ c4c50c58-4c17-410d-8de9-67f28952beda
for n in 0:12
	for k in 0:n, q in 0:n
		@test C_empirical(+, n, k, q) == C(+, n, k, q)
	end
end

# ╔═╡ 91dd5f24-b7f8-4d28-881b-9e55e5bb0676
md"# Imports"

# ╔═╡ Cell order:
# ╟─a6f0cfa2-56d6-4906-bc6b-624f733e6f94
# ╟─e062d135-ae06-4fb2-b2ab-5353dcaf8ae0
# ╠═ce71f5d0-f721-46f8-8f93-a4d6fe213f37
# ╟─436b1e25-fdc9-4d70-98e4-dc73c10341e9
# ╠═5689bba5-554d-409a-b304-56eb182e36d3
# ╠═f6a0815c-6230-45e2-b3e2-2b8fbfb1ed62
# ╟─d974ee5d-2b49-47a0-9db7-6775f3b25fad
# ╠═c4c50c58-4c17-410d-8de9-67f28952beda
# ╟─91dd5f24-b7f8-4d28-881b-9e55e5bb0676
# ╠═0a57536c-de6e-11ef-1920-71d04e909ec9
