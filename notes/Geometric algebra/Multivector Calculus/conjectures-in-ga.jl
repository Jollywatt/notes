### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 9d0428d8-acba-4587-a6aa-72ce1b014798
begin
	using Pkg
	Pkg.activate()
	using GeometricAlgebra, Test, Random
end

# ╔═╡ 85b6ad16-387b-4475-9ff0-04d4dfcb4736
GeometricAlgebra.use_symbolic_optim(sig) = false

# ╔═╡ 254b75b6-6a61-4ce0-a917-cff8393e0837
Random.rand(rng::AbstractRNG, ::Random.SamplerType{T}) where {T<:Multivector{Sig,K}} where {Sig,K} = T(rand(rng, ncomponents(T)))

# ╔═╡ 9d4afdf0-b8b3-4387-9000-6e551a30125b
Random.randn(rng::AbstractRNG, T::Type{Multivector{Sig,K}}) where {Sig,K} = T(randn(rng, ncomponents(T)))

# ╔═╡ f564b092-8d3b-11ed-0326-2316e4aa6baf
md"""
# Multivector calculus identities
"""

# ╔═╡ f96ce736-966f-47a7-a8fb-64cc18cbd8f3
md"""

### Conjecture 1

For an ``n``-dimensional ``k``-vector ``A``:

```math
∂_𝒖 A𝒖 = (n - 2k)A^⋆
```

"""

# ╔═╡ 408584aa-6d7f-453e-80fa-d8afa2ef1756
function test1(sig, k)
	v = basis(sig)
	A = randn(Multivector{sig,k})
	sum(@. v*A*v) ≈ (dimension(sig) - 2k)involution(A)
end

# ╔═╡ 2c37be39-82db-45fa-a1d2-7cca8bf27552
for dim in 1:5, k in 1:dim
	@test test1(dim, k)
end

# ╔═╡ a0591852-274d-4654-a4cc-bb59f3413a79
md"""
### Conjecture 2

```math
∂_M𝒖M = 2^{n - 1}𝒖
```

"""

# ╔═╡ 10d57de6-0efc-43f1-8ce0-0153cd9ffe9e
M = basis(6, :all)

# ╔═╡ 3e62c99a-037f-4451-84c0-697a9a253a70
[dim => let M = basis(dim, :all)
	scalar(sum(M .* M))
end for dim in 0:8]

# ╔═╡ e820a787-6d22-477b-9bca-6e220ceaa1a9
function ident2(sig)
	n = dimension(sig)
	u = randn(Multivector{sig,1})
	M = basis(sig, :all)

	@test sum(M .* u .* M) ≈ 2^(n - 2)*involution(u)
end

# ╔═╡ 8aa85921-a554-4ba3-8d08-94ff5fa2587a
for dim in 1:8
	@test ident2(dim)
end

# ╔═╡ 2e8667d0-9564-4d35-87f2-a4a2ba25e5a5
md"""

## Rotor recovery

"""

# ╔═╡ 52f98b02-6e47-4c9e-912b-6604049b49b5
begin
	R = exp(10rand(Multivector{3,2}))
	v = basis(3)

	R′ = 1 + sum(R.*v.*~R.*v)
	R′ /= sqrt(R′⊙~R′)

	[R, R′]
end

# ╔═╡ e41de6b7-e24a-4fa1-9a54-4274f7b891fe
R*Multivector{3,1}([1, 2, 3])*~R

# ╔═╡ 37b874a1-6215-4b8b-98f7-9c77960b1cae
R′*Multivector{3,1}([1, 2, 3])*~R′

# ╔═╡ Cell order:
# ╠═9d0428d8-acba-4587-a6aa-72ce1b014798
# ╠═85b6ad16-387b-4475-9ff0-04d4dfcb4736
# ╠═254b75b6-6a61-4ce0-a917-cff8393e0837
# ╠═9d4afdf0-b8b3-4387-9000-6e551a30125b
# ╠═f564b092-8d3b-11ed-0326-2316e4aa6baf
# ╟─f96ce736-966f-47a7-a8fb-64cc18cbd8f3
# ╠═408584aa-6d7f-453e-80fa-d8afa2ef1756
# ╠═2c37be39-82db-45fa-a1d2-7cca8bf27552
# ╠═a0591852-274d-4654-a4cc-bb59f3413a79
# ╠═10d57de6-0efc-43f1-8ce0-0153cd9ffe9e
# ╠═3e62c99a-037f-4451-84c0-697a9a253a70
# ╠═e820a787-6d22-477b-9bca-6e220ceaa1a9
# ╠═8aa85921-a554-4ba3-8d08-94ff5fa2587a
# ╠═2e8667d0-9564-4d35-87f2-a4a2ba25e5a5
# ╠═52f98b02-6e47-4c9e-912b-6604049b49b5
# ╠═e41de6b7-e24a-4fa1-9a54-4274f7b891fe
# ╠═37b874a1-6215-4b8b-98f7-9c77960b1cae
