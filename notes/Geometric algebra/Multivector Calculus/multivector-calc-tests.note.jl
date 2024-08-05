### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 9d0428d8-acba-4587-a6aa-72ce1b014798
begin
	using Pkg
	Pkg.activate(Base.current_project())
	using Test, Random, PlutoUI, PlutoLinks
end

# ╔═╡ 79264c96-07c4-42ff-a0ba-a95733899ad0
@revise using GeometricAlgebra

# ╔═╡ f564b092-8d3b-11ed-0326-2316e4aa6baf
md"""
# Multivector calculus identities

Some numerically-verified identities involving the multivector derivative.
"""

# ╔═╡ fae21770-34c9-47c1-b20c-12678c1fc733
# numerically test the following identities for all these algebras
sigs = [
	(1:5)...
	Cl.(0:5,1)
	Cl(2,2)
	Cl(2,3)
	Cl(4,4)
]

# ╔═╡ 995e986b-e157-418d-9bbd-ec0094937369
md"""
### ``∂_X X``
For a multivector ``X``, 
```math
∂_X X = \dim X
```
where ``\dim X`` is the dimension of the vector subspace over which ``X`` is taken.

For example,
```math
∂_𝒖 𝒖 = n
```
for an ``n``-dimensional ``1``-vector ``𝒖``, and
```math
∂_A A = 2^n
```
for a general multivector in ``n`` dimensions.
"""

# ╔═╡ 288b3720-cb61-4f10-8086-192392b8db7c
for sig in sigs
	dim = dimension(sig)
	for k in [0:dim; [0:2:dim, 0:dim]]
		v = basis(dim, k)
		@test sum(@. v/v) == length(v)
	end
end

# ╔═╡ ba12264e-da85-4c22-9bf1-151e8cf5124a
md"## Identities of the form ``∂_A B A``"

# ╔═╡ 54b97688-8660-4cdc-8393-4efef6fdbcb7
md"""
From the [general formula](https://jaw213.user.srcf.net/notes/number-of-commuting-blades) we know that ``∂_A B A \propto B`` when ``A`` is a ``k``-vector and ``B`` is a ``q``-vector, with the constant of proportionality given by `∂aba_factor(n, k, q)`.
"""

# ╔═╡ bc3214ce-3173-4e95-804a-8c14dd21c879
∂aba_factor(n, k, q) = let w = sum(binomial(q, m)binomial(n - q, k - m) for m in 0:2:min(k, q))
	a = 2w - binomial(n, k)
	iseven(k*q) ? a : -a
end

# ╔═╡ 94781655-9028-4bff-9e9b-bbb8f0a6e1ad
l = 0:10

# ╔═╡ 5e750ad3-3b16-4d2f-a42b-6210c178a592
md"""

### ``∂_𝒖 𝒗 𝒖``

For ``n``-dimensional vectors ``𝒖`` and ``𝒗``:

```math
∂_𝒖 𝒗 𝒖 = (2 - n) 𝒗
```

"""

# ╔═╡ aa9ce050-a0a2-4930-9f4a-4553cc937d33
@test all(@. ∂aba_factor(l, 1, 1) == 2 - l)

# ╔═╡ f96ce736-966f-47a7-a8fb-64cc18cbd8f3
md"""

### ``∂_𝒖 A𝒖``

For an ``n``-dimensional ``1``-vector ``𝒖`` and ``k``-vector ``A``:

```math
∂_𝒖 A 𝒖 = (n - 2k)A^⋆
```

"""

# ╔═╡ 440ad4cd-8d2b-4c78-a2a6-af4c5c8d8286
@test all(@. ∂aba_factor(l, 1, l') == (l - 2l')*(-1)^l')

# ╔═╡ 3ece708f-37a5-4f63-88fc-f169643434a4
md"""
### ``∂_\sigma 𝒖 \sigma``

For an ``n``-dimensional bivectors ``\sigma`` and ``1``-vector ``𝒖``:
```math
∂_\sigma 𝒖 \sigma = \left[\binom{n - 2}{2} - 1\right] 𝒖
```

"""

# ╔═╡ 7b5b4a62-8135-41c9-a481-856cd28dfc24
@test all(@. ∂aba_factor(l, 2, 1) == binomial(l - 2, 2) - 1)

# ╔═╡ af5e83a5-2d45-4b02-96d4-ef5f277550d4
md"""
### ``∂_\sigma \rho \sigma``

For ``n``-dimensional bivectors ``\sigma`` and ``\rho``:
```math
∂_\sigma \rho \sigma = \left[\binom{n - 4}{2} - 2\right] \rho
```

"""

# ╔═╡ 5cb4e41e-cf85-423d-985b-e3481e6bb994
@test all(@. ∂aba_factor(l, 2, 2) == binomial(l - 4, 2) - 2)

# ╔═╡ ed6b7351-4632-41ba-a0ac-707408bbd2e4
md"""
### ``∂_\sigma T \sigma``

For an ``n``-dimensional bivectors ``\sigma`` and trivector ``T``:
```math
∂_\sigma T \sigma = \left[\binom{n - 6}{2} - 3\right] T
```
"""

# ╔═╡ 48483cbe-fc5f-4896-809b-5d834e4e4a38
@test all(@. ∂aba_factor(l, 2, 3) == binomial(l - 6, 2) - 3)

# ╔═╡ 4cfc39b5-653b-468f-b239-dc904a707102
md"""
### ``∂_\sigma A \sigma``

For an ``n``-dimensional bivectors ``\sigma`` and ``k``-vector ``A``:
```math
∂_\sigma A \sigma = \left[\binom{n - 2k}{2} - k\right] A
```

"""

# ╔═╡ 6a175cf5-f86b-4ee1-a425-9d2edbe4726a
@test all(@. ∂aba_factor(l, 2, l') == binomial(l - 2l', 2) - l')

# ╔═╡ 940123c5-b046-4701-9aab-0ef48a6350b5
md"""
### ``∂_T 𝒖 T``

For a trivector ``T`` and ``1``-vector ``𝒖``:
```math
∂_T 𝒖 T = \left[\binom{n - 1}{2} - \binom{n - 1}{3}\right] 𝒖
= -\frac{1}{6} (n - 1)(n - 2)(n - 6) 𝒖
```
"""

# ╔═╡ 41f4d805-ce09-445c-8091-381569b7df36
@test all(@. ∂aba_factor(l, 3, 1) == binomial(l - 1, 2) - binomial(l - 1, 3))

# ╔═╡ 23d1e8bd-8df9-4bbf-9ed7-ef7355a17e98
md"""
### ``∂_T \sigma T``

For a trivector ``T`` and bivector ``\sigma``:
```math
∂_T \sigma T = \left[1 - \binom{n - 2}{2} + \binom{n - 3}{3}\right]\sigma
= \frac{1}{6}(n - 9)(n - 4)(n - 2) \sigma
```
"""

# ╔═╡ ea33468a-10c8-4807-861d-014db690d565
@test all(@. ∂aba_factor(l, 3, 2) == 1 - binomial(l - 2, 2) + binomial(l - 3, 3))

# ╔═╡ 5b61c572-ded6-44ec-a367-5ec747ce67dc
md"""
### ``∂_X A X``

For general multivectors ``A`` and ``X``:
```math
∂_X A X = \sum_I e^I A e_I = 2^n \begin{cases}
\langle A \rangle_0 & \text{$n$ even} \\
\langle A \rangle_{0,n} & \text{$n$ odd} \\
\end{cases}
```
"""

# ╔═╡ 1553d0da-0da4-47ce-8bcb-78576dccdcee
md"""
### ``∂_X R X``

For an even multivector ``R`` and general multivector ``X``:
```math
∂_X R X = \sum_I e^I R e_I = 2^n \langle R \rangle_0
```
"""

# ╔═╡ 1a922294-7f5c-4d94-af5f-df0998088614
md"""
---

#### Utilities
"""

# ╔═╡ 85b6ad16-387b-4475-9ff0-04d4dfcb4736
GeometricAlgebra.use_symbolic_optim(sig) = dimension(sig) < 8

# ╔═╡ 433942e1-3081-4eda-a22e-e83922cccf94
PlutoUI.TableOfContents()

# ╔═╡ 9d4afdf0-b8b3-4387-9000-6e551a30125b
function Random.randn(rng::AbstractRNG, T::Type{<:Multivector})
	T(randn(rng, ncomponents(T)))
end

# ╔═╡ b36e375e-ffdd-416d-a7fa-bccac606e29c
for sig in sigs
	dim = dimension(sig)
	v = basis(sig, 1)
	u = randn(Multivector{sig,1})
	@test sum(v.*u./v) ≈ (2 - dim)u
end

# ╔═╡ 2c37be39-82db-45fa-a1d2-7cca8bf27552
for sig in sigs
	dim = dimension(sig)
	for k in 1:dim
		v = basis(sig)
		A = randn(Multivector{sig,k})
		@test sum(v.*A./v) ≈ (dim - 2k)involution(A) atol=1e-10
	end
end

# ╔═╡ 1191ecab-7b8f-413a-92cc-b8115f611d56
for sig in sigs
	dim = dimension(sig)
	dim >= 2 || continue
	v = basis(sig, 2)
	u = randn(Multivector{sig,1})
	@test sum(v.*u./v) ≈ (binomial(dim - 2, 2) - 1)u atol=1e-10
end

# ╔═╡ 4c49f812-f60b-4552-bae9-4ab3c3bcede4
for sig in sigs
	dim = dimension(sig)
	dim >= 2 || continue
	v = basis(sig, 2)
	u = randn(Multivector{sig,2})
	@test sum(v.*u./v) ≈ (binomial(dim - 4, 2) - 2)u
end

# ╔═╡ c7bdfa09-04b5-4c24-9add-d530f68fbc38
for sig in sigs
	dim = dimension(sig)
	dim >= 2 || continue
	v = basis(sig, 2)
	T = randn(Multivector{sig,3})
	@test sum(v.*T./v) ≈ (binomial(dim - 6, 2) - 3)T atol=1e-10
end

# ╔═╡ 2b4757f7-7f0d-4862-8dd1-2b19ba21a1df
for sig in sigs
	dim = dimension(sig)
	dim >= 2 || continue
	for k in 1:dim
		v = basis(sig, 2)
		A = randn(Multivector{sig,k})
		@test sum(v.*A./v) ≈ (binomial(dim - 2k, 2) - k)A atol=1e-10
	end
end

# ╔═╡ 6e913a23-9b9f-4c75-87e2-0e09eefa7961
for sig in sigs
	dim = dimension(sig)
	dim >= 3 || continue
	v = basis(sig, 3)
	u = randn(Multivector{sig,1})
	@test sum(v.*u./v) ≈ (binomial(dim - 1, 2) - binomial(dim - 1, 3))u atol=1e-10
end

# ╔═╡ d19facea-f28b-4170-9feb-74d54b61f062
for sig in sigs
	dim = dimension(sig)
	dim >= 3 || continue
	v = basis(sig, 3)
	A = randn(Multivector{sig,2})
	@test sum(v.*A./v) ≈ (1 - binomial(dim - 2, 2) + binomial(dim - 3, 3))A atol=1e-10
end

# ╔═╡ cfb0e668-ac22-4a35-ad49-dbdccf287aa8
for sig in sigs
	dim = dimension(sig)
	v = basis(sig, :all)
	A = randn(Multivector{sig,0:dim})
	if iseven(dim)
		@test sum(v.*A./v) ≈ 2^dim*grade(A, 0)
	else
		@test sum(v.*A./v) ≈ 2^dim*grade(A, 0:dim:dim)
	end
end

# ╔═╡ bd83e721-9225-42c0-9d1b-e598f8ef0257
for sig in sigs
	dim = dimension(sig)
	v = basis(sig, :all)
	R = randn(Multivector{sig,0:2:dim})
	@test sum(v.*R./v) ≈ 2^dim*grade(R, 0)
end

# ╔═╡ 611b0e53-e7df-4d28-ac4c-a22bb4e49c7b
"""
	find_multiplier(sig, p, q)

Numerically compute the coefficient ``k`` in
```math
∂_X A X = k A
```
where ``X`` is of grade ``p`` and ``A`` is of grade ``q`` in the algebra with metric signature `sig`.
"""
function find_multiplier(sig, diff_k, middle_k)
	dim = dimension(sig)
	diff_k <= dim || return NaN
	middle_k <= dim || return NaN
	v = basis(sig, diff_k)
	u = randn(Multivector{sig,middle_k})
	λ = scalar(sum(v.*u./v)/u)
end

# ╔═╡ Cell order:
# ╟─f564b092-8d3b-11ed-0326-2316e4aa6baf
# ╠═fae21770-34c9-47c1-b20c-12678c1fc733
# ╟─995e986b-e157-418d-9bbd-ec0094937369
# ╠═288b3720-cb61-4f10-8086-192392b8db7c
# ╟─ba12264e-da85-4c22-9bf1-151e8cf5124a
# ╟─54b97688-8660-4cdc-8393-4efef6fdbcb7
# ╠═bc3214ce-3173-4e95-804a-8c14dd21c879
# ╠═94781655-9028-4bff-9e9b-bbb8f0a6e1ad
# ╟─5e750ad3-3b16-4d2f-a42b-6210c178a592
# ╠═b36e375e-ffdd-416d-a7fa-bccac606e29c
# ╠═aa9ce050-a0a2-4930-9f4a-4553cc937d33
# ╟─f96ce736-966f-47a7-a8fb-64cc18cbd8f3
# ╠═2c37be39-82db-45fa-a1d2-7cca8bf27552
# ╠═440ad4cd-8d2b-4c78-a2a6-af4c5c8d8286
# ╟─3ece708f-37a5-4f63-88fc-f169643434a4
# ╠═1191ecab-7b8f-413a-92cc-b8115f611d56
# ╠═7b5b4a62-8135-41c9-a481-856cd28dfc24
# ╟─af5e83a5-2d45-4b02-96d4-ef5f277550d4
# ╠═4c49f812-f60b-4552-bae9-4ab3c3bcede4
# ╠═5cb4e41e-cf85-423d-985b-e3481e6bb994
# ╟─ed6b7351-4632-41ba-a0ac-707408bbd2e4
# ╠═c7bdfa09-04b5-4c24-9add-d530f68fbc38
# ╠═48483cbe-fc5f-4896-809b-5d834e4e4a38
# ╟─4cfc39b5-653b-468f-b239-dc904a707102
# ╠═2b4757f7-7f0d-4862-8dd1-2b19ba21a1df
# ╠═6a175cf5-f86b-4ee1-a425-9d2edbe4726a
# ╟─940123c5-b046-4701-9aab-0ef48a6350b5
# ╠═6e913a23-9b9f-4c75-87e2-0e09eefa7961
# ╠═41f4d805-ce09-445c-8091-381569b7df36
# ╟─23d1e8bd-8df9-4bbf-9ed7-ef7355a17e98
# ╠═d19facea-f28b-4170-9feb-74d54b61f062
# ╠═ea33468a-10c8-4807-861d-014db690d565
# ╟─5b61c572-ded6-44ec-a367-5ec747ce67dc
# ╠═cfb0e668-ac22-4a35-ad49-dbdccf287aa8
# ╟─1553d0da-0da4-47ce-8bcb-78576dccdcee
# ╠═bd83e721-9225-42c0-9d1b-e598f8ef0257
# ╟─1a922294-7f5c-4d94-af5f-df0998088614
# ╠═9d0428d8-acba-4587-a6aa-72ce1b014798
# ╠═79264c96-07c4-42ff-a0ba-a95733899ad0
# ╠═85b6ad16-387b-4475-9ff0-04d4dfcb4736
# ╠═433942e1-3081-4eda-a22e-e83922cccf94
# ╠═9d4afdf0-b8b3-4387-9000-6e551a30125b
# ╟─611b0e53-e7df-4d28-ac4c-a22bb4e49c7b
