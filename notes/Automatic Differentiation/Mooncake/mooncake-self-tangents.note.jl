### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 83237bc4-cde6-11ef-1ccf-097bcdd9f8b4
begin
	using Pkg
	Pkg.activate(@__DIR__)
	Pkg.add(
		url="https://github.com/compintell/Mooncake.jl.git",
		rev="wct/tangent-interface-docs",
	)
	Pkg.add(["Random", "JET", "AllocCheck"])
	using Mooncake, Random, JET, AllocCheck
	import LinearAlgebra: norm
end

# ╔═╡ 7259ce23-7537-454f-b9c6-9cacf0852c4f
md"""
# [Mooncake.jl](https://compintell.github.io/Mooncake.jl/) tangent interface

This document contains some comments for the documentation for Mooncake's "tangent interface" in [this PR](https://github.com/compintell/Mooncake.jl/pull/434).
"""

# ╔═╡ a8c99ab2-ce66-4001-a7b2-cbf039f59afa
rng = MersenneTwister(1)

# ╔═╡ 35dcb401-aae2-41a3-8d33-97fbd9bb01c5
md"""
## Default tangent behaviour

Suppose I have a type `SomeVector` which describes a vector space ``V``.
Instances of this type behave like vectors and can be added and scaled.

"""

# ╔═╡ 05ed76dc-d33a-4fcd-9e40-7a00ba8e9a74
maketype(T::Symbol) = quote
	struct $T{V}
		vector::V
	end
	Base.:+(a::$T, b::$T) = $T(a.vector + b.vector)
	Base.:-(a::$T) = $T(-b.vector)
	Base.:-(a::$T, b::$T) = a + (-b)
	Base.:*(a, b::$T) = $T(a * b.vector)
	Base.:*(a::$T, b) = $T(a.vector * b)
	norm(a::$T) = norm(a.vector)
	Base.copy(a::$T) = SomeVector(copy(a.vector))
end

# ╔═╡ ae694815-cb0a-49db-8cdf-d1040305efcc
eval(maketype(:SomeVector))

# ╔═╡ 8aab11e0-fa01-406d-8936-165e4754112b
md"Mooncake can differentiate functions of this type, such as ``f : V \times V \to V = (a, b) \mapsto a \|a + b\|``."

# ╔═╡ fbe92f39-864e-40c7-9fd7-45ee257ccfcc
f(a, b) = a*norm(a + b)

# ╔═╡ ce702017-7776-449c-b215-1192a74eb8dc
grads = let
	a, b = SomeVector([1., 2.]), SomeVector([3., 4.])
	rule = build_rrule(f, a, b)
	ȳ = Tangent((; vector = [1., 0.]))
	y, grads = value_and_pullback!!(rule, ȳ, f, a, b)
	grads
end

# ╔═╡ c65ceb99-62d5-4ede-ada5-b1200e59014e
md"Notice infinitesimal displacements of `SomeVector` values are automatically prescribed a specific tangent type:"

# ╔═╡ 04b9a329-181d-448f-a8f3-713bb64c8b2d
typeof(grads[2])

# ╔═╡ ddd5bc35-17ac-4353-8e3c-d8427815f282
md"""
However, since there is a natural association between the vector space ``V`` and its tangent space, ``𝕋V ≅ V``, we can treat them as living in the same space.
This allows us to add tangents to primals, useful when performing gradient descent, for example.

We would like [Mooncake.jl](https://compintell.github.io/Mooncake.jl/) to use our own vector space type as its own `tangent_type`, as this would allow us to use our type's usual vector space operations between tangents and primals.
"""

# ╔═╡ f6bd7577-f113-4a7f-b42c-2ba6978b4bf3
md"""
## Overloading the tagnent type

Let's define another custom type which forms a vector space.
We will try to make this type self-tangential by implementing the "tangent interface" for this type.
"""

# ╔═╡ 6b786ae8-0a6b-4310-bd3b-c21a2435c817
eval(maketype(:SelfTangent))

# ╔═╡ f1f9cfdc-18a4-4119-884a-270f8ce9a430
SelfTangent([1., 2.])*10 + SelfTangent([0., -1.])

# ╔═╡ 07f31cdf-f694-43bb-a5e3-cb1b4356103e
md"""
## Tangent interface
"""

# ╔═╡ aee1252d-562b-4317-9561-9883808b1624
Mooncake.tangent_type(::Type{SelfTangent{V}}) where V = SelfTangent{tangent_type(V)}

# ╔═╡ ec5f7dfd-ff80-4cfc-9239-348afd6df4f7
Mooncake.zero_tangent(a::SelfTangent) = SelfTangent(zero_tangent(a.vector))

# ╔═╡ 20f5c013-b8d0-495c-b069-395617351cbb
Mooncake.randn_tangent(rng::AbstractRNG, a::SelfTangent) =
	SelfTangent(randn_tangent(rng, a.vector))

# ╔═╡ d1bf07ba-bacf-4e8f-a53b-babe6c2302c0
function Mooncake.increment!!(a::T, b::T) where T<:SelfTangent
	SelfTangent(increment!!(a.vector, b.vector))
end

# ╔═╡ a373c15d-5f2f-4703-92b8-f2369244b7d0
function Mooncake.set_to_zero!!(a::SelfTangent)
	SelfTangent(set_to_zero!!(a.vector))
end

# ╔═╡ 4564ef03-603f-4164-960a-900444280652
Mooncake._add_to_primal(a::SelfTangent, b::SelfTangent, unsafe::Bool) =
	SelfTangent(_add_to_primal(a.vector, b.vector))

# ╔═╡ 310db143-f7ce-4db3-9e42-854923085677
Mooncake._diff(a::SelfTangent, b::SelfTangent) =
	SelfTangent(_diff(a.vector, b.vector))

# ╔═╡ 8bcac566-d740-4692-b9ca-2c1142c97a80
Mooncake._dot(a::SelfTangent, b::SelfTangent) = _dot(a.vector, b.vector)

# ╔═╡ ccb3ceb2-b75d-4241-9a37-2fc7abb3fbe7
Mooncake._scale(a::Float64, b::SelfTangent) = SelfTangent(_scale(a, b.vector))

# ╔═╡ 27ebf7d0-8c9b-4390-aadf-b7e16111fd59
Mooncake.TestUtils.populate_address_map!(m::Mooncake.TestUtils.AddressMap, a::SelfTangent, b::SelfTangent) =
	Mooncake.TestUtils.populate_address_map!(m, a.vector, b.vector)

# ╔═╡ cd7dd7f0-74d3-4c8f-85ef-5d830d51b4af
Mooncake.TestUtils.test_tangent_interface(rng, SelfTangent([1., 2.]))

# ╔═╡ 35b9d05f-046c-4a25-952a-9aaecab7af08
md"""
## Tangent splitting
"""

# ╔═╡ e9e5f26f-1f73-45cf-9937-e809d095f436
Mooncake.fdata_type(::Type{SelfTangent{V}}) where V =
	fdata_type(V) == NoFData ? NoFData : SelfTangent{fdata_type(V)}

# ╔═╡ 572f6bb0-d7a2-48da-8817-06ee6fb9b997
Mooncake.rdata_type(::Type{SelfTangent{V}}) where V =
	rdata_type(V) == NoRData ? NoRData : SelfTangent{rdata_type(V)}

# ╔═╡ 104dfd7d-3be9-4557-92a9-62ad8e32767a
Mooncake.fdata(a::SelfTangent) =
	fdata(a.vector) == NoFData() ? NoFData() : SelfTangent(fdata(a.vector))

# ╔═╡ 47cced71-02d1-46be-9fbd-f2b9dd30107c
Mooncake.rdata(a::SelfTangent) =
	rdata(a.vector) == NoRData() ? NoRData() : SelfTangent(rdata(a.vector))

# ╔═╡ f346bdb5-6de7-434d-8e9d-3cfcc4c64d4a
Mooncake.tangent_type(T::Type{<:SelfTangent}, ::Type{NoRData}) = T

# ╔═╡ 00ef3b51-7d15-435a-88aa-a83b57a318f2
Mooncake.tangent_type(::Type{NoFData}, T::Type{<:SelfTangent}) = T

# ╔═╡ df037b47-16c0-4ec0-8dce-f3b408dd8620
md"""
!!! warning
	The following three methods are not specified in the interface docs, but were necessary to implement in order to make `test_tangent_splitting` pass.
"""

# ╔═╡ f98c74d8-ba3c-4ad5-9cff-d1881bab6f71
## NOT PART OF THE INTERFACE
Mooncake._get_fdata_field(f::SelfTangent, name) = getfield(f, name)

# ╔═╡ 8a035611-3f89-4098-ac40-546a60a4cdb7
## NOT PART OF THE INTERFACE
Mooncake.tangent(f::SelfTangent, ::NoRData) = f

# ╔═╡ 01031655-65e4-4dbe-b8cd-cab98af342f3
## NOT PART OF THE INTERFACE
Mooncake.tangent(::NoFData, r::SelfTangent) = r

# ╔═╡ 43584338-031b-460e-948a-12697a4f1a0c
Mooncake.TestUtils.test_tangent_splitting(rng, SelfTangent(ones(3)))

# ╔═╡ 16c27933-3192-4bf4-affd-55a0976d6200
md"""
## Rule–type interactions
"""

# ╔═╡ d63afee2-c419-47a8-a238-c4c24bfefc96
Mooncake.TestUtils.test_rule_and_type_interactions(rng, SelfTangent(ones(3)))

# ╔═╡ e5551647-5f89-4356-8377-54c4e2cdb76c
md"""
I believe these errors are due to this method:
"""

# ╔═╡ ab832ab5-407c-4198-b6f1-bec31c0aac70
culprit = methods(rdata_type, Tuple{Tuple{<:Tuple}})

# ╔═╡ 3b4957fe-096c-4ef8-baf8-5db49f5f2619
md"""
The culprit method is being incorrectly called instead of this newer method defined for my type:
"""

# ╔═╡ 8c17ba9b-698b-4848-ba04-8b4196a8f752
mine = methods(rdata_type, Tuple{Type{SelfTangent{Vector{Float64}}}})

# ╔═╡ b9f4a90f-2f8e-4847-8026-649403c24e4e
md"""
This is because `rdata_type` is being called from within the `@generated` function `culprit` which was compiled in an older world age than `mine`:
"""

# ╔═╡ 3306ae26-6363-4cb2-8356-2d448c13b30d
@assert only(culprit).primary_world < only(mine).primary_world

# ╔═╡ e28e7c35-f836-4d46-b1c1-4f2ff981137d
md"""
## Differentiating `SelfTangent`

The tangent interface is not completely satisfied for the `SelfTangent` type, and `rrule`s can fail.
"""

# ╔═╡ f4b34129-2ea3-463f-bd11-cc439093a1df
a, b = SelfTangent([1., 2., 3.]), SelfTangent([4., 5., 6.])

# ╔═╡ 56f424e2-b3b6-467e-96c6-e30b3b99484e
rule = build_rrule(f, a, b)

# ╔═╡ 6314617a-3577-40cb-9296-56a1e6e8fb58
ȳ = SelfTangent([1., 0., 0.])

# ╔═╡ dbf5027b-0e0f-4389-8ae6-91676f799a17
value_and_pullback!!(rule, ȳ, f, a, b)

# ╔═╡ Cell order:
# ╟─7259ce23-7537-454f-b9c6-9cacf0852c4f
# ╠═83237bc4-cde6-11ef-1ccf-097bcdd9f8b4
# ╠═a8c99ab2-ce66-4001-a7b2-cbf039f59afa
# ╟─35dcb401-aae2-41a3-8d33-97fbd9bb01c5
# ╠═05ed76dc-d33a-4fcd-9e40-7a00ba8e9a74
# ╠═ae694815-cb0a-49db-8cdf-d1040305efcc
# ╟─8aab11e0-fa01-406d-8936-165e4754112b
# ╠═fbe92f39-864e-40c7-9fd7-45ee257ccfcc
# ╠═ce702017-7776-449c-b215-1192a74eb8dc
# ╟─c65ceb99-62d5-4ede-ada5-b1200e59014e
# ╠═04b9a329-181d-448f-a8f3-713bb64c8b2d
# ╟─ddd5bc35-17ac-4353-8e3c-d8427815f282
# ╟─f6bd7577-f113-4a7f-b42c-2ba6978b4bf3
# ╠═6b786ae8-0a6b-4310-bd3b-c21a2435c817
# ╠═f1f9cfdc-18a4-4119-884a-270f8ce9a430
# ╟─07f31cdf-f694-43bb-a5e3-cb1b4356103e
# ╠═aee1252d-562b-4317-9561-9883808b1624
# ╠═ec5f7dfd-ff80-4cfc-9239-348afd6df4f7
# ╠═20f5c013-b8d0-495c-b069-395617351cbb
# ╠═d1bf07ba-bacf-4e8f-a53b-babe6c2302c0
# ╠═a373c15d-5f2f-4703-92b8-f2369244b7d0
# ╠═4564ef03-603f-4164-960a-900444280652
# ╠═310db143-f7ce-4db3-9e42-854923085677
# ╠═8bcac566-d740-4692-b9ca-2c1142c97a80
# ╠═ccb3ceb2-b75d-4241-9a37-2fc7abb3fbe7
# ╠═27ebf7d0-8c9b-4390-aadf-b7e16111fd59
# ╠═cd7dd7f0-74d3-4c8f-85ef-5d830d51b4af
# ╟─35b9d05f-046c-4a25-952a-9aaecab7af08
# ╠═e9e5f26f-1f73-45cf-9937-e809d095f436
# ╠═572f6bb0-d7a2-48da-8817-06ee6fb9b997
# ╠═104dfd7d-3be9-4557-92a9-62ad8e32767a
# ╠═47cced71-02d1-46be-9fbd-f2b9dd30107c
# ╠═f346bdb5-6de7-434d-8e9d-3cfcc4c64d4a
# ╠═00ef3b51-7d15-435a-88aa-a83b57a318f2
# ╟─df037b47-16c0-4ec0-8dce-f3b408dd8620
# ╠═f98c74d8-ba3c-4ad5-9cff-d1881bab6f71
# ╠═8a035611-3f89-4098-ac40-546a60a4cdb7
# ╠═01031655-65e4-4dbe-b8cd-cab98af342f3
# ╠═43584338-031b-460e-948a-12697a4f1a0c
# ╟─16c27933-3192-4bf4-affd-55a0976d6200
# ╠═d63afee2-c419-47a8-a238-c4c24bfefc96
# ╟─e5551647-5f89-4356-8377-54c4e2cdb76c
# ╠═ab832ab5-407c-4198-b6f1-bec31c0aac70
# ╟─3b4957fe-096c-4ef8-baf8-5db49f5f2619
# ╠═8c17ba9b-698b-4848-ba04-8b4196a8f752
# ╟─b9f4a90f-2f8e-4847-8026-649403c24e4e
# ╠═3306ae26-6363-4cb2-8356-2d448c13b30d
# ╟─e28e7c35-f836-4d46-b1c1-4f2ff981137d
# ╠═f4b34129-2ea3-463f-bd11-cc439093a1df
# ╠═56f424e2-b3b6-467e-96c6-e30b3b99484e
# ╠═6314617a-3577-40cb-9296-56a1e6e8fb58
# ╠═dbf5027b-0e0f-4389-8ae6-91676f799a17
