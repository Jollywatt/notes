### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ de6606b3-55ee-4729-bcfe-65e5f54074ee
using Test

# ╔═╡ 197769f1-3f92-4665-bc57-04f0cd523ef4
md"""
# A universal inner product space

We would like to turn every type (numbers, arrays, tuples, structs, and so on) into an _inner product_ or _Hilbert_ space, so that we can:
- multiply any instance by a scalar;
- add any two instances of the same type; and
- take an inner product between any two instances of the same type.

This “mother” Hilbert space shall have `*̂` for scalar multiplication, `+̂` for addition, and `ip(A, B)` as its inner product.

Below is an implementation.
"""

# ╔═╡ d7ce956b-3b2c-4277-8873-59aa69ad5c61
begin
	construct(::Type{<:Tuple}, fields) = Tuple(fields)
	construct(T::Type{<:NamedTuple}, fields) = T(fields)
	construct(T::Type, fields) = T(fields...)
end

# ╔═╡ fabfe2d4-3c92-44f0-88e1-e91f6b1334a0
begin
	(a::T +̂ b::T) where T<:Union{Number,AbstractArray} = a + b
	(a::T +̂ b::T) where T = construct(T, getfield(a, f) +̂ getfield(b, f) for f in fieldnames(T))
end

# ╔═╡ 344f7670-6b26-4332-b4de-32ae9fc88744
begin
	a::Number *̂ b::Union{Number,AbstractArray} = a*b
	(a::Number *̂ b::T) where T  = construct(T, a *̂ getfield(b, f) for f in fieldnames(T))
end

# ╔═╡ 5149a35b-2cfa-4637-b793-749ba7688123
begin
	ip(a::T, b::T) where T<:Union{Number,AbstractArray} = a'b
	ip(a::T, b::T) where T = sum(ip(getfield(a, f), getfield(b, f)) for f in fieldnames(T); init=false)
end

# ╔═╡ f6e2d09d-d15d-43e8-8abd-82d783091eac
md"""
Let's try it out:
"""

# ╔═╡ 8e01bafc-7c93-4e7e-8a23-c23fde2a8848
struct Point{T}
	x::T
	y::T
end

# ╔═╡ cddb7dd8-6340-4f87-9749-f24c7a61da3f
@testset begin
	@test 2*̂[1 2] == [2 4]
	@test 6*̂(1.0, 7) === (6.0, 42)
	@test 10*̂Point(1, 2) === Point(10, 20)
	@test 100*̂(origin=Point(1, 0), radius=5) === (origin=Point(100, 0), radius=500)
	
	@test [1 2] +̂ [3 4] == [4 6]
	@test (1 => 0.0) +̂ (0 => 2.0) === (1 => 2.0)
	@test Point(1, 2) +̂ Point(3, 4) === Point(4, 6)
	@test (o=Point(1, 0), r=5) +̂ (o=Point(5, 3), r=10) === (o=Point(6, 3), r=15)

	@test ip(6, 7) === 42
	@test ip((1, 0), (1, 1)) === 1
	@test ip(Point(2, 3), Point(3, 4)) === 18
	@test ip((1, 2 => 3), (1, 2 => 3)) === 1 + 4 + 9
end;

# ╔═╡ 101df9af-1baa-4c7d-923a-28d8b21628df
md"""
## A standard basis for everything

It's very convenient if we can easily retrieve the standard basis vectors for an arbitrary type.

This is done with `basis(T)`, which returns a `dim(T)`-length vector of instances of type `T`, such that any instance can be given as a linear combination of these (using `*̂` and `+̂`).
"""

# ╔═╡ 65f69622-c3f5-43c1-8ebe-3ad236bd39f6
begin
	dim(::Type{<:Number}) = 1
	dim(T::Type) = sum(dim, fieldtypes(T))
end

# ╔═╡ dd137f90-9e7f-451b-9970-a93531aa466a
md"""
We'll need an equivalent of `zero(T)` that also works on composite types:
"""

# ╔═╡ 0fe50f38-b787-4195-865f-e8ca9a57b40b
begin
	_zero(T::Type{<:Number}) = zero(T)
	_zero(T::Type) = construct(T, _zero.(fieldtypes(T)))
end

# ╔═╡ 50b28562-78da-4538-8354-9189dff0daeb
basis(T::Type{<:Number}) = (one(T),)

# ╔═╡ b691968d-8099-4755-8de3-eba92a621ad8
function basis(T::Type)
	basis_elements = T[]
	dims = dim.(fieldtypes(T))
	for i in 1:dim(T)
		field = findfirst(>=(i), cumsum(dims))
		subbasis = basis(fieldtype(T, field))
		j = dims[field] + i - cumsum(dims)[field]
		el = ntuple(fieldcount(T)) do field′
			field′ == field ? subbasis[j] : _zero(fieldtype(T, field′))
		end
		push!(basis_elements, construct(T, el))
	end
	basis_elements
end

# ╔═╡ d21f5c8f-b29c-465c-9cdb-f85842063277
md"""
Now to try it out:
"""

# ╔═╡ f9eb2ef8-cf23-45e5-b875-c535eb9a8db9
basis(typeof((1, true, (2.0, 3))))

# ╔═╡ 180ae0be-4400-4daf-85c7-7ac92f528139
basis(Tuple{Point{Int},Float64,NTuple{3,Int}})

# ╔═╡ 406ebb2c-c3fa-451b-8231-b5538f552982
let b = basis(Tuple{Point{Int},Float64,NTuple{3,Int}})
	@test all(isone, ip.(b, b))
end

# ╔═╡ 2d8f2983-007b-49ad-9e9c-d26acd6a6cea
md"""
## Deriving adjoints of linear functions

Now that everything is a Hilbert space with a standard basis at hand, we can easily compute the adjoint of any linear function.

From the defining relation
```math
\langle f(x), y \rangle = \langle x, f^T(y) \rangle
```
and the fact that ``x = \sum_i \frac{\langle x, e_i \rangle}{\langle e_i, e_i \rangle} e_i`` for a basis ``\{e_i\}``, we can solve for the adjoint:
```math
f^T(y) = \sum_{i} \frac{\langle f(e_i), y \rangle}{\langle e_i, e_i \rangle} e_i
```

Our implementation of the adjoint `fᵀ = adj(f, X)` is with a higher-order function `adj` accepting a linear function `f(::X)` and its domain `X`.
"""

# ╔═╡ b9d094e1-d6ea-4818-90c6-27471622b0be
adj(f, X; ip=ip) = y -> reduce(+̂, ip(f(eᵢ), y)ip(eᵢ, eᵢ)*̂eᵢ for eᵢ in basis(X))

# ╔═╡ 19816db5-8b0b-434c-a25a-4a3e10c4656b
md"The inner product is passed as a keyword argument so we change it later..."

# ╔═╡ 47a13810-c49c-4df7-b5e8-9dd3f57ad069
md"""
Here are some clasic examples:
"""

# ╔═╡ b05995f4-78ca-4bd9-8032-5796ddcd6292
adj(splat(+), Tuple{Int,Int})(7)

# ╔═╡ 3a116278-8627-49e4-ae03-919be53cbd0f
adj(t -> (t, t), Float64)((2.0, 0.5))

# ╔═╡ 2cce9e24-84a0-4d96-aa10-ac0816e9d6d9
md"""
Here is a more complex example of a linear function ``A``:
"""

# ╔═╡ 37aa86c4-68d4-487a-a7d1-091957600dfc
A((r, p)::Pair{Int,Point{Int}}) = (-r, p.x + p.y)

# ╔═╡ e7edb93f-b106-4521-9900-eea6c9e56015
Aᵀ = adj(A, Pair{Int,Point{Int}})

# ╔═╡ c9121d8a-1092-4351-b9fd-8cc068f70f32
md"""
We can verify its adjoint ``A^T`` is correct by checking that
```math
\langle A(x), y \rangle = \langle x, A^T(y) \rangle
```
for all linearly independent ``x`` and ``y``.
"""

# ╔═╡ 702d6210-e54c-4c5b-b3db-5c080a180947
for x in basis(Pair{Int,Point{Int}}), y in basis(Tuple{Int,Int})
	@test ip(A(x), y) === ip(x, Aᵀ(y))
end

# ╔═╡ 6d681664-2d25-44a1-98c8-c7767015d1e1
md"""
## Choosing different inner products

What happens if we form our Hilbert space with a different inner product? We get different adjoints.

Let's make a second inner product that differs for the `Tuple` types: the first entry gets a minus sign.
"""

# ╔═╡ 492fa9b1-910d-4bf5-af1d-6471fa56338d
ip′(a, b) = ip(a, b)

# ╔═╡ c5a160ee-3e77-4252-a42f-ceddf467cc71
ip′((a1, a...)::T, (b1, b...)::T) where T<:Tuple = -a1*b1 + ip(a, b)

# ╔═╡ 2ed7d077-092b-4a95-a070-fdf0c341a00b
md"""
Compare the adjoints of ``(a \Rightarrow b) \mapsto a + b`` with respect to these two inner products.
"""

# ╔═╡ 126792d4-aab1-4c6d-80e4-edcff03816f9
adj(splat(+), Tuple{Int,Int})(7)

# ╔═╡ 4e6208dd-3d3f-4bc5-9545-c5bd554b4691
adj(splat(+), Tuple{Int,Int}; ip=ip′)(7)

# ╔═╡ 9dd689d1-0a2d-4d23-b9cf-abb977ab3519
md"""
We can verify that this second adjoint still obeys the defining relation ``\langle A(x), y \rangle = \langle x, A^T(y) \rangle``:
"""

# ╔═╡ 20639667-4cbc-48a2-9da0-720a982ab9df
let A = splat(+), Aᵀ = adj(A, Tuple{Int,Int}; ip=ip′)
	for x in basis(Tuple{Int,Int}), y in basis(Int)
		@test ip′(A(x), y) === ip′(x, Aᵀ(y))
	end
end

# ╔═╡ d24a859a-9c42-4dd9-981c-fc9ed8a6783b
md"""
## Application to automatic differentiation

How is this Hilbert space relevant to autodiff?

The essence of forward- and reverse-mode autodiff are the types `Dual` and `CoDual` which associate primal values with their tangents as they propagate through the forward or reverse pass, respectively.

(`CoDual` is not named in the sense of [Mooncake.jl](https://compintell.github.io/Mooncake.jl/), but rather in a [categorical sense](https://higherlogics.blogspot.com/2020/05/dualcodual-numbers-for-forwardreverse.html).)

!!! details
	In actual source-to-source implementations, primals and tangents are not necessarily stored together in a struct, to allow better memory management and performance — but the principle is no different.

"""

# ╔═╡ 1f2b76d1-38a6-4882-bb07-fa65e31dd748
begin
	struct Dual{T}
		primal::T
		pushforward::T
	end
	primal(x::Dual) = x.primal
	pushforward(x::Dual) = x.pushforward
end

# ╔═╡ 3d5dc992-d3c6-4bfb-be9b-b5da8ee140e3
begin
	struct CoDual{T,F}
		primal::T
		pullback::F
	end
	primal(x::CoDual) = x.primal
	pullback(x::CoDual, arg) = x.pullback(arg)
end

# ╔═╡ eea8588f-16f8-43f2-a791-09cdd3145e8e
md"""
For completeness, we can treat all other types as primal values with trivial tangents.
"""

# ╔═╡ 4210c5af-c7c1-4307-b430-b9d9b25d07f9
begin
	primal(x) = x
	pushforward(x) = zero(x)
	pullback(x, arg) = nothing
end

# ╔═╡ 30c4fe7c-cc7a-4361-a1c9-f3cca4beda8b
md"""
Then, implementing autodiff is just a matter of defining _forward rules_ and _reverse rules_ for sufficiently many elementary functions.
"""

# ╔═╡ 844089a9-89bb-4026-9f8d-aed213d11842
md"""
### Forward rules
"""

# ╔═╡ 41bbe0ba-6ff3-4e2b-98da-3a116d1cc806
md"Let's just write one rule for ``(a, b) \mapsto ab``."

# ╔═╡ 29884061-d826-4f69-b72e-f8e6fbbc4d2d
function frule(::typeof(*), a, b)
	y = primal(a)*primal(b)
	ẏ = pushforward(a)*primal(b) + primal(a)*pushforward(b)
	Dual(y, ẏ)
end

# ╔═╡ f18e3edc-7303-4104-965b-aec6fe76318d
md"For example, ``∂(ab)/∂a`` evaluated at ``(a, b) = (5, 3)`` would be:"

# ╔═╡ afacf6a7-acbf-4792-a4df-d4889b7d2f4e
let a = Dual(5, 1), b = Dual(3, 0)
	frule(*, a, b)
end

# ╔═╡ ad3fb313-a018-4817-a0b5-35c7e7f10473
md"""
And a second pass for ``∂(ab)/∂b``:
"""

# ╔═╡ f8ad3d28-a7be-48b5-a928-4a2770667e41
let a = Dual(5, 0), b = Dual(3, 1)
	frule(*, a, b)
end

# ╔═╡ a397eabd-ba53-4917-8d7b-c02d203a86e3
md"""
### Reverse rules
"""

# ╔═╡ 79d8d156-b8a2-4355-9ab7-a6b428106e10
function rrule(::typeof(*), a, b)
	y = primal(a)*primal(b)
	function pb!(ȳ)
		pullback(a, ȳ*primal(b))
		pullback(b, primal(a)*ȳ)
	end
	CoDual(y, pb!)
end

# ╔═╡ 79715cfe-daf2-4e3d-aff3-504e6b27639f
md"""
The reverse pass usually has a bit more setup: gradients are stored in a shared state `grads` which is written to by each closure `pb!`.
"""

# ╔═╡ a8b4d067-f83a-433c-a855-40800d6deb3f
let grads = zeros(2),
	a = CoDual(5, t -> grads[1] += t),
	b = CoDual(3, t -> grads[2] += t)
	y = rrule(*, a, b)
	pullback(y, 1) # perform the reverse pass
	primal(y), grads
end

# ╔═╡ 8665506d-3af2-40df-b9f5-7fa915eaf58d
md"""
### The implicit adjoint and inner product

Without even noticing, we implicitly chose a particular adjoint operation when we wrote this `rrule`.
Luckily, we chose the canonical one, which means that the forward and reverse derivatives are equal.

!!! warning
	Work in progress...
"""

# ╔═╡ 29ccee6d-6da8-4a5e-a6e6-8a6c0ff108b1
function rrule_pure(::typeof(*), a, b)
	y = primal(a)*primal(b)
	pb!(ȳ) = pullback(a, ȳ*primal(b)) +̂ pullback(b, primal(a)*ȳ)
	CoDual(y, pb!)
end

# ╔═╡ f3294361-3495-4f12-951e-5aab26a5ab33
let a = CoDual(5, t -> (-t, 0)),
	b = CoDual(3, t -> (0, t))
	y = rrule_pure(*, a, b)
	pullback(y, 1) # perform the reverse pass
	# primal(y), grads
end

# ╔═╡ 2dacd8f7-e6c0-435f-801d-59f1f01b70a4
F((a, b)) = ((ȧ, ḃ),) -> ȧ*b + a*ḃ

# ╔═╡ 927af584-f03a-4c65-96d3-b00c9507023c
R((a, b)) = ȳ -> (-ȳ*b, a*ȳ)

# ╔═╡ c49de7da-9b79-4911-aa9b-11e1e96c835d
for x in basis(Tuple{Int,Int}), y in basis(Int)
	ab = (1, 2)
	@test ip′(F(ab)(x), y) === ip′(x, R(ab)(y))
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "71d91126b5a1fb1020e1098d9d492de2a4438fd2"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"
"""

# ╔═╡ Cell order:
# ╟─de6606b3-55ee-4729-bcfe-65e5f54074ee
# ╟─197769f1-3f92-4665-bc57-04f0cd523ef4
# ╠═d7ce956b-3b2c-4277-8873-59aa69ad5c61
# ╠═fabfe2d4-3c92-44f0-88e1-e91f6b1334a0
# ╠═344f7670-6b26-4332-b4de-32ae9fc88744
# ╠═5149a35b-2cfa-4637-b793-749ba7688123
# ╟─f6e2d09d-d15d-43e8-8abd-82d783091eac
# ╠═8e01bafc-7c93-4e7e-8a23-c23fde2a8848
# ╠═cddb7dd8-6340-4f87-9749-f24c7a61da3f
# ╟─101df9af-1baa-4c7d-923a-28d8b21628df
# ╠═65f69622-c3f5-43c1-8ebe-3ad236bd39f6
# ╟─dd137f90-9e7f-451b-9970-a93531aa466a
# ╠═0fe50f38-b787-4195-865f-e8ca9a57b40b
# ╠═50b28562-78da-4538-8354-9189dff0daeb
# ╠═b691968d-8099-4755-8de3-eba92a621ad8
# ╟─d21f5c8f-b29c-465c-9cdb-f85842063277
# ╠═f9eb2ef8-cf23-45e5-b875-c535eb9a8db9
# ╠═180ae0be-4400-4daf-85c7-7ac92f528139
# ╠═406ebb2c-c3fa-451b-8231-b5538f552982
# ╟─2d8f2983-007b-49ad-9e9c-d26acd6a6cea
# ╠═b9d094e1-d6ea-4818-90c6-27471622b0be
# ╟─19816db5-8b0b-434c-a25a-4a3e10c4656b
# ╟─47a13810-c49c-4df7-b5e8-9dd3f57ad069
# ╠═b05995f4-78ca-4bd9-8032-5796ddcd6292
# ╠═3a116278-8627-49e4-ae03-919be53cbd0f
# ╟─2cce9e24-84a0-4d96-aa10-ac0816e9d6d9
# ╠═37aa86c4-68d4-487a-a7d1-091957600dfc
# ╠═e7edb93f-b106-4521-9900-eea6c9e56015
# ╟─c9121d8a-1092-4351-b9fd-8cc068f70f32
# ╠═702d6210-e54c-4c5b-b3db-5c080a180947
# ╟─6d681664-2d25-44a1-98c8-c7767015d1e1
# ╠═492fa9b1-910d-4bf5-af1d-6471fa56338d
# ╠═c5a160ee-3e77-4252-a42f-ceddf467cc71
# ╟─2ed7d077-092b-4a95-a070-fdf0c341a00b
# ╠═126792d4-aab1-4c6d-80e4-edcff03816f9
# ╠═4e6208dd-3d3f-4bc5-9545-c5bd554b4691
# ╟─9dd689d1-0a2d-4d23-b9cf-abb977ab3519
# ╠═20639667-4cbc-48a2-9da0-720a982ab9df
# ╟─d24a859a-9c42-4dd9-981c-fc9ed8a6783b
# ╠═1f2b76d1-38a6-4882-bb07-fa65e31dd748
# ╠═3d5dc992-d3c6-4bfb-be9b-b5da8ee140e3
# ╟─eea8588f-16f8-43f2-a791-09cdd3145e8e
# ╠═4210c5af-c7c1-4307-b430-b9d9b25d07f9
# ╟─30c4fe7c-cc7a-4361-a1c9-f3cca4beda8b
# ╟─844089a9-89bb-4026-9f8d-aed213d11842
# ╟─41bbe0ba-6ff3-4e2b-98da-3a116d1cc806
# ╠═29884061-d826-4f69-b72e-f8e6fbbc4d2d
# ╟─f18e3edc-7303-4104-965b-aec6fe76318d
# ╠═afacf6a7-acbf-4792-a4df-d4889b7d2f4e
# ╟─ad3fb313-a018-4817-a0b5-35c7e7f10473
# ╠═f8ad3d28-a7be-48b5-a928-4a2770667e41
# ╟─a397eabd-ba53-4917-8d7b-c02d203a86e3
# ╠═79d8d156-b8a2-4355-9ab7-a6b428106e10
# ╟─79715cfe-daf2-4e3d-aff3-504e6b27639f
# ╠═a8b4d067-f83a-433c-a855-40800d6deb3f
# ╟─8665506d-3af2-40df-b9f5-7fa915eaf58d
# ╠═29ccee6d-6da8-4a5e-a6e6-8a6c0ff108b1
# ╠═f3294361-3495-4f12-951e-5aab26a5ab33
# ╠═2dacd8f7-e6c0-435f-801d-59f1f01b70a4
# ╠═927af584-f03a-4c65-96d3-b00c9507023c
# ╠═c49de7da-9b79-4911-aa9b-11e1e96c835d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
