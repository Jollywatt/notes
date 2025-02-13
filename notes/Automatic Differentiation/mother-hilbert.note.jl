### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ de6606b3-55ee-4729-bcfe-65e5f54074ee
using Test, PlutoUI

# ╔═╡ 33a9588e-414b-4bbd-931d-cd4508fafecb
md"""
# Hilbert spaces, adjoints, and automatic differentiation

This note aims to address some curiosities we have about reverse-mode autodiff and the concomitant theory involving adjoint operators.
1. If reverse-mode [computes the _adjoint_](https://jollywatt.github.io/notes/reverse-mode-inner-product) of the derivative operator, _which_ adjoint is this? What is its associated inner product?
2. Can we derive adjoints of linear functions programmatically?
3. What happens if we use different adjoints by changing the underlying inner product? Does reverse-mode still work?

This document gradually presents the theory and implementation required to answer these questions by way of demonstration.
"""

# ╔═╡ 8a8582b6-cda3-4386-80a6-1eef5cd8407d
PlutoUI.TableOfContents(depth=4)

# ╔═╡ 197769f1-3f92-4665-bc57-04f0cd523ef4
md"""
## A universal inner product space

We would like to turn every type (numbers, arrays, tuples, structs, and so on) into an _inner product space_ or _Hilbert space_.
This means we need to implement
- multiplication of any instance by scalars;
- addition between any two instances of the same type; and
- an inner product between any two instances of the same type.

Below is a (partial) implementation for this mother Hilbert space, with `*̂` for scalar multiplication, `+̂` for addition, and `ip(A, B)` as the ambient inner product.
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
This works for most of what we care about: numbers, arrays, tuples and named tuples, and simple structs.
Let’s try it out:
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
### A standard basis for everything

It's very convenient if we can easily retrieve standard basis vectors for an arbitrary type, so that any instance can be decomposed as a linear combination of basis elements with the help of the ambient inner product.

This is done with `basis(T)`, which returns a `dim(T)`-length vector of instances of type `T`, such that any instance can be given as a linear combination of these (using `*̂` and `+̂`).

!!! warning
	As implemented, the dimension must be known from the type. This doesn't work for non-statically sized arrays, which we ignore from now on...
"""

# ╔═╡ 65f69622-c3f5-43c1-8ebe-3ad236bd39f6
begin
	dim(::Type{<:Number}) = 1
	dim(T::Type) = sum(dim, fieldtypes(T); init=0)
end

# ╔═╡ dd137f90-9e7f-451b-9970-a93531aa466a
md"""
We'll need an equivalent of `zero(T)` that also works recursively on composite types:
"""

# ╔═╡ 0fe50f38-b787-4195-865f-e8ca9a57b40b
begin
	_zero(T::Type{<:Number}) = zero(T)
	_zero(T::Type) = construct(T, _zero.(fieldtypes(T)))
	_zero(x) = _zero(typeof(x))
end

# ╔═╡ 50b28562-78da-4538-8354-9189dff0daeb
basis(T::Type{<:Number}) = (one(T),)

# ╔═╡ b691968d-8099-4755-8de3-eba92a621ad8
function basis(T::Type)::Vector{T}
	fielddims = dim.(fieldtypes(T))
	map(1:dim(T)) do i
		field = findfirst(>=(i), cumsum(fielddims))
		subbasis = basis(fieldtype(T, field))
		j = fielddims[field] + i - cumsum(fielddims)[field]
		el = ntuple(fieldcount(T)) do field′
			field′ == field ? subbasis[j] : _zero(fieldtype(T, field′))
		end
		construct(T, el)
	end
end

# ╔═╡ d21f5c8f-b29c-465c-9cdb-f85842063277
md"""
Now to try it out:
"""

# ╔═╡ f9eb2ef8-cf23-45e5-b875-c535eb9a8db9
basis(typeof((1, true, (2.0, 3))))

# ╔═╡ 180ae0be-4400-4daf-85c7-7ac92f528139
basis(Tuple{Point{Int},Float64,NTuple{3,Int}})

# ╔═╡ 1da71fc8-8c9b-491f-a6f5-9f0cec88f212
md"""
### A reciprocal basis

It's also useful to have a reciprocal basis ``\{\overline{e}_i\}`` by defined by ``\langle \overline{e}_i, e_j \rangle = \delta_{ij}``, which holds even if the normal basis ``\{e_i\}`` is not orthogonal (as it is with respect to our default inner product `ip`).

We can solve for the reciprocal basis vectors explicitly:
```math
\begin{bmatrix}
\overline e_1 \\
\vdots \\
\overline e_n \\
\end{bmatrix} = \begin{bmatrix}
\langle e_1, e_1 \rangle & \cdots & \langle e_1, e_n \rangle \\
\vdots & \ddots & \vdots \\
\langle e_n, e_1 \rangle & \cdots & \langle e_n, e_n \rangle \\
\end{bmatrix}^{-1}
\begin{bmatrix}
e_1 \\
\vdots \\
e_n \\
\end{bmatrix}
```
"""

# ╔═╡ 3b994eb0-23f3-4b47-8f1d-6e42757bd714
function dualbasis(T; ip=ip)::Vector{T}
	es = basis(T)
	A = [ip(eᵢ, eⱼ) for eᵢ in es, eⱼ in es]
	[reduce(+̂, coeffs.*̂es) for coeffs in eachcol(inv(A))]
end

# ╔═╡ beb0cb3b-d9e8-4cf5-b6c5-fbcead46903c
function testdualbasis(T)
	e = basis(T)
	ē = dualbasis(T)
	for i in 1:dim(T), j in 1:dim(T)
		@test ip(e[i], ē[j]) == (i == j)
	end
end

# ╔═╡ 499f40a8-796f-4120-a326-ce872f6acf7a
md"""
!!! info
	Reciprocal basis pairs ``\{e_i\}`` and ``\{\overline e_i\}`` are useful in particular because
	```math
	x = \sum_i \langle x, e_i \rangle \overline e_i
	```
	for all ``x``, even if the basis is not orthonormal.

"""

# ╔═╡ c2633e84-c799-4e21-8bd1-9d71f2eb79ab
md"""
### Taking duals of values

One final useful operation to define is the _dual_ ``x^*`` of a value ``x`` (with respect to a specified inner product), defined as the linear operator satisfying ``e_i^* = ē_i`` for a dual bases ``\{e_i\}`` and ``\{ē_i\}``.

Its action on a value ``x`` is therefore
```math
x^* = \sum_i \langle x, e_i \rangle \overline e_i^* = \sum_i \langle x, e_i \rangle e_i
```

"""

# ╔═╡ 36d04f8c-47a1-41ea-8572-39ef39141895
dual(x; ip) = reduce(+̂, ip(x, eᵢ)*̂eᵢ for eᵢ in basis(typeof(x)))

# ╔═╡ 2d8f2983-007b-49ad-9e9c-d26acd6a6cea
md"""
## Deriving adjoints of linear functions

Now that everything is a Hilbert space with a standard basis at hand, we can easily compute the adjoint of any linear function.

From the defining relation
```math
\langle A(x), y \rangle = \langle x, A^T(y) \rangle
```
we can solve for the adjoint
```math
A^T(y) = \sum_i \langle \overline e_i, A^T(y) \rangle e_i
= \sum_i \langle A(\overline e_i), y \rangle e_i
```
where the basis ``\{\overline e_i\}`` is dual to ``\{e_i\}``.

We implement the adjoint `Aᵀ = adj(A, X₁, ..., Xₙ)` using a higher-order function `adj` which accepts the linear function `A(::X₁, ..., ::Xₙ)` along with its domain (each argument type).
"""

# ╔═╡ b9d094e1-d6ea-4818-90c6-27471622b0be
"""
	adj(f, X₁, ..., Xₙ; ip)

Adjoint of a linear function `f(::X₁, ..., ::Xₙ)` with respect to the inner product `ip`. Does not check that `f` is indeed linear.
"""
function adj(f, X...; ip=ip)
	X = Tuple{X...} # treat n-ary functions as unary functions of a n-tuple
	e, ē = basis(X), dualbasis(X; ip)
	y -> reduce(+̂, ip(f(ē[i]...), y)*̂e[i] for i in 1:dim(X))
end

# ╔═╡ 19816db5-8b0b-434c-a25a-4a3e10c4656b
md"(The inner product `ip` is passed as a keyword argument so we can change it later...)"

# ╔═╡ 47a13810-c49c-4df7-b5e8-9dd3f57ad069
md"""
Here is an example showing that ``(a, b) \mapsto a + b`` and ``z \mapsto (z, z)`` are adjoint:
"""

# ╔═╡ 4d5048cd-9161-443b-bb03-9b046a6596e3
adj(+, Int, Int)(7)

# ╔═╡ 3a116278-8627-49e4-ae03-919be53cbd0f
adj(t -> (t, t), Float64)((2.0, 0.5))

# ╔═╡ 2cce9e24-84a0-4d96-aa10-ac0816e9d6d9
md"""
Here is a more complex example of a linear function ``A``:
"""

# ╔═╡ 37aa86c4-68d4-487a-a7d1-091957600dfc
A((a, b)::Pair, p::Point{Float64}) = (a - b, p.x + p.y)

# ╔═╡ e7edb93f-b106-4521-9900-eea6c9e56015
Aᵀ = adj(A, Pair{Int,Int}, Point{Float64})

# ╔═╡ c9121d8a-1092-4351-b9fd-8cc068f70f32
md"""
We can verify that this adjoint ``A^T`` is correct by checking that
```math
\langle A(x), y \rangle = \langle x, A^T(y) \rangle
```
for all ``x`` and ``y`` (though we need only check for all pairs of basis elements).
"""

# ╔═╡ 36db975f-da35-442c-ac0b-b12708e18291
"""
	test_adjoint(f, X₁, ..., Xₙ; ip)

Test that the adjoint of a linear function `f(::X₁, ..., ::Xₙ)` is correct with respect to the inner product `ip`.
"""
function test_adjoint(f, X...; ip=ip)
	fᵀ = adj(f, X...; ip)
	Y = only(Base.return_types(f, Tuple{X...}))
	for x in basis(Tuple{X...}), y in basis(Y)
		@test ip(f(x...), y) == ip(x, fᵀ(y))
	end
end

# ╔═╡ 889bd98b-d638-4395-8585-b3d1c6bad524
test_adjoint(+, Int, Int)

# ╔═╡ bdaf1a04-3975-468e-8ce3-abdfb8b1ea15
test_adjoint(A, Pair{Int,Int}, Point{Float64})

# ╔═╡ 6d681664-2d25-44a1-98c8-c7767015d1e1
md"""
### Choosing different inner products

What happens if we form our Hilbert space with a different inner product? We get different adjoints.

Let's make a second inner product that differs for the `Tuple` types: the first entry gets a minus sign.
"""

# ╔═╡ 492fa9b1-910d-4bf5-af1d-6471fa56338d
ip′(a, b) = ip(a, b)

# ╔═╡ 13fca4dd-8e79-44b4-85bf-df7aee2b2703
ip′((a1, a2)::Pair, (b1, b2)::Pair) = 2ip′(a1, b1) - 3ip′(a2, b2)

# ╔═╡ c5a160ee-3e77-4252-a42f-ceddf467cc71
ip′((a1, a...)::T, (b1, b...)::T) where T<:Tuple = -ip′(a1, b1) + ip(a, b)

# ╔═╡ c16764e2-5228-45d9-9e46-d2de280b5e77
dualbasis(Tuple{Point{Int},Float64,NTuple{3,Int}}; ip=ip′)

# ╔═╡ 848a34e4-e9ed-496d-be71-0a0adf6d015e
md"""
We should check that both inner products have some of the expected properties:
"""

# ╔═╡ 5252ae96-fb57-4224-9e4c-57e066b56c20
function test_ip(ip, X)
	es = basis(X)
	for x in es, y in es, z in es
		@test ip(x, x) != 0
		@test ip(x, y) === ip(y, x)
		for λ in (-1, 0, 1, 5)
			@test ip(λ*̂x, y) === λ*ip(x, y) === ip(x, λ*̂y)
		end
		@test ip(x +̂ y, z) === ip(x, z) + ip(y, z)
		@test ip(x, y +̂ z) === ip(x, y) + ip(x, z)
	end
	a = reduce(+̂, rand(-5:5, length(es)).*̂es)
	@test a === reduce(+̂, ip(a, eᵢ)/ip(eᵢ, eᵢ)*̂eᵢ for eᵢ in es)
end

# ╔═╡ f8e7b3c5-266f-4e34-a4e0-82f7484862c6
test_ip.((ip, ip′), Pair{Int,Int})

# ╔═╡ c10c3a4b-fef0-4fe1-8e39-ccc46c9e2e8f
md"See how the inner products differ..."

# ╔═╡ fb3ebf88-6206-4f02-860d-6952cdc5313b
ip(1 => 2, 3 => 4), ip′(1 => 2, 3 => 4)

# ╔═╡ 06bca717-6858-4a6c-9e55-4a5491bef21f
ip((1, 2, 3), (4, 5, 6)), ip′((1, 2, 3), (4, 5, 6))

# ╔═╡ 86ae5f44-5a29-42d6-9426-3af86bc1a895
md"...and how they affect the adjoints of our test function ``f``:"

# ╔═╡ 5acc972e-1358-4cd2-b562-b378cadd266f
adj(A, Pair{Float64,Float64}, Point{Float64})((1.0, 1.0))

# ╔═╡ 17535316-5261-4409-8823-283d3135a168
adj(A, Pair{Float64,Float64}, Point{Float64}; ip=ip′)((1.0, 1.0))

# ╔═╡ 2658a6b3-e48c-4b4a-9ccb-afa06d4cc435
md"""
Indeed, both adjoints are still correct with respect to the appropriate inner product:
"""

# ╔═╡ cbd7d143-ddfa-4e8e-b665-18fc384f9f7a
for ip in (ip, ip′)
	test_adjoint(A, Pair{Float64,Float64}, Point{Float64}; ip=ip)
end

# ╔═╡ d24a859a-9c42-4dd9-981c-fc9ed8a6783b
md"""
## Application to automatic differentiation

How is this Hilbert space with its inner product relevant to autodiff?
It is relevant because, whether knowlingly or not, we have to compute the adjoint when we write down `rrules`.

What happens to our `rrule`s when we change the inner product of our ambient Hilbert space?

### Autodiff MWE

This section gives a recap and demo on how `frules` and `rrules` work.

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
	pushforward(x) = _zero(x)
	pullback(x, arg) = nothing
end

# ╔═╡ 30c4fe7c-cc7a-4361-a1c9-f3cca4beda8b
md"""
Then, implementing autodiff is (basically) just a matter of defining _forward rules_ and _reverse rules_ for sufficiently many elementary functions.
"""

# ╔═╡ 844089a9-89bb-4026-9f8d-aed213d11842
md"""
#### Forward rules

Here is the usual way you would impliment the forward rule for ``(a, b) \mapsto ab``.
"""

# ╔═╡ 29884061-d826-4f69-b72e-f8e6fbbc4d2d
function frule(::typeof(*), a, b)
	y = primal(a)*primal(b)
	ẏ = pushforward(a)*primal(b) + primal(a)*pushforward(b)
	Dual(y, ẏ)
end

# ╔═╡ f18e3edc-7303-4104-965b-aec6fe76318d
md"To evaluate ``∂(ab)/∂a`` at ``(a, b) = (5, 3)``, we can do:"

# ╔═╡ ad3fb313-a018-4817-a0b5-35c7e7f10473
md"""
And a second pass for ``∂(ab)/∂b``:
"""

# ╔═╡ a397eabd-ba53-4917-8d7b-c02d203a86e3
md"""
#### Reverse rules

A typical reverse rule for ``(a, b) \mapsto ab`` looks like:
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
The reverse pass usually requires a bit more setup: gradients are stored in a _shared state_ `grads` which is mutated in the pullback closure `pb!`.
"""

# ╔═╡ f7bb2b9e-7900-4a93-b6f2-bd1336d2020b
md"""
We can wrap this setup in a function:
"""

# ╔═╡ e4ef1efd-f0f6-4d7a-8e1c-e7e5449101fc
md"""
This is now generalised to arbitrary functions `f(x...)::Y` for which an `rrule` method is applicable.
The arguments `x...` are allowed to be composite types instead of just scalars; hence we've used `_zero` and `+̂` instead of `zero` and `+`.
"""

# ╔═╡ bd49df06-cb16-4148-ad6f-ab0c572ee748
md"""
### Deriving rules from the directional derivative ``\mathrm D f[x]``

The `frule` and `rrule` methods are the same in that they both do the following:
1. compute the primal `y`;
1. implement a linear operator related to the function's Jacobian or directional derivative, ``\mathrm D f[x]``.

!!! definition
	For a function ``f: X \to Y`` between vector spaces:
	```math
	\mathrm D f [x](\dot x) := \lim_{ε \to 0} \frac{f(x + ε ẋ) - f(x)}{ε} = \sum_i \frac{∂f}{∂x_i} ẋ_i
	```

In the case of forward-mode, the derivative operator is both defined _and_ evaluated in one step --- the `frule` computes ``\dot y = \mathrm D f[x](\dot x)``, the directional derivative (or Jacobian-vector product).

In reverse-mode, the _adjoint_ directional derivative ``\mathrm D f[x]^*`` is returned, not evaluated (it is evaluated later in the reverse pass).

So to implement generic `frule` and `rrule` methods for a function ``f``, we need only define the directional derivative operator ``\mathrm D f[x]`` for a function ``f``. We can derive the rest, since we can take adjoints automatically.

Let’s implement ``\mathrm D f[x_1, ..., x_n]`` as `D(f, x₁, ..., xₙ)` for a few elementary functions:
"""

# ╔═╡ 85a616b9-d2ae-4432-85b9-f23a30123bbf
begin
	D(::typeof(+), a, b) = (ȧ, ḃ) -> ȧ + ḃ
	D(::typeof(*), a, b) = (ȧ, ḃ) -> ȧ*b + a*ḃ
	D(::typeof(^), a, p::Integer) = (ȧ, _) -> p*a^(p - 1)*ȧ
	D(::typeof(^), a, p) = (ȧ, ṗ) -> p*a^(p - 1)*ȧ + log(a)*a^p*ṗ
	D(::typeof(sin), a) = ȧ -> cos(a)ȧ
	D(::typeof(tuple), x...) = (ẋ...) -> ẋ
	D(::typeof(getfield), a, i) = (ȧ, _) -> getfield(ȧ, i)
	D(::typeof(getindex), a, i::Integer) = (ȧ, _) -> getindex(ȧ, i)
end

# ╔═╡ 306e9a40-fab1-43fc-8ead-4752af76251b
md"""
Julia has a few function wrapper types, which have rather neat derivative rules:
"""

# ╔═╡ 08bafe7b-dcf5-4b8c-9154-a1f4ab693b07
begin
	D(f::ComposedFunction, x...) = D(f.outer, f.inner(x...))∘D(f.inner, x...)
	D(f::Base.Fix1, x) = Base.Fix1(D(f.f, f.x, x), zero(f.x))
	D(f::Base.Fix2, x) = Base.Fix2(D(f.f, x, f.x), zero(f.x))
	D(f::Base.Splat, x) = splat(D(f.f, x...))
end

# ╔═╡ d3d40b18-e667-42e8-a15c-bae538af0f07
md"""
#### Generic forward/reverse rules

Equipped with ``\mathrm D f[x]``, we can write generic forward- and reverse-mode rules like this:
"""

# ╔═╡ d2715246-c1eb-409a-a7c5-3b571f1a6e66
function frule(f, x...)
	y = f(primal.(x)...) # primal result
	ẏ = D(f, primal.(x)...)(pushforward.(x)...) # apply directional derivative
	Dual(y, ẏ)
end

# ╔═╡ f2a9845f-4c2a-4d90-82d0-0acc3c0bd24d
function rrule(f, x...; ip=ip)
	y = f(primal.(x)...) # primal result 
	Dfx = D(f, primal.(x)...) # directional derivative operator...
	Dfxᵀ = adj(Dfx, typeof.(primal.(x))...; ip) # ...and its adjoint
	pb!(ȳ) = for (xᵢ, x̄ᵢ) in zip(x, Dfxᵀ(ȳ))
		pullback(xᵢ, x̄ᵢ) # propagate to arguments
	end
	CoDual(y, pb!)
end

# ╔═╡ 316b6130-9e7d-4497-8a4a-02e9211f7f03
md"""
If our functions are written in a way such that `methods(D)` are applicable, then we get the derivative for free.

For example, we can write `t::Tuple -> t[1]^2` as a composition of `Base.Fix2` functions:
"""

# ╔═╡ 1d150267-01a9-4ddc-8ead-1f77fdfab23e
md"""
To differentiate more complex functions (which don't involve branching, loops, mutation, etc), we have to apply `frule` or `rrule` functors to each node in the expression tree.
"""

# ╔═╡ 17539d7d-c7b1-4a66-a72c-bb942f7a36ba
begin
	f(a, b) = a*b + sin(b)
	frule(::typeof(f), a, b) = frule(+, frule(*, a, b), frule(sin, a))
	rrule(::typeof(f), a, b; ip) = rrule(+, rrule(*, a, b; ip), rrule(sin, a; ip); ip)
end

# ╔═╡ afacf6a7-acbf-4792-a4df-d4889b7d2f4e
let a = Dual(5, 1), b = Dual(3, 0)
	frule(*, a, b)
end

# ╔═╡ f8ad3d28-a7be-48b5-a928-4a2770667e41
let a = Dual(5, 0), b = Dual(3, 1)
	frule(*, a, b)
end

# ╔═╡ a8b4d067-f83a-433c-a855-40800d6deb3f
let a = 5, b = 3
	grads = [zero(a), zero(b)] # gradient accumulator
	∂a, ∂b = CoDual(a, Δ -> grads[1] += Δ), CoDual(b, Δ -> grads[2] += Δ)
	∂y = rrule(*, ∂a, ∂b) # apply the rule
	pullback(∂y, 1) # perform the reverse pass
	primal(∂y), Tuple(grads)
end

# ╔═╡ 1d601774-c04c-4d4d-a5d4-3709de2e4d1f
function rdiff(ȳ, f::Function, x...; ip=ip)
	grads = collect(_zero(x)) # gradient accumulator
	∂x = [CoDual(x[i], Δ -> grads[i] = grads[i] +̂ Δ) for i in eachindex(x)]
	∂y = rrule(f, ∂x...; ip) # apply the rule
	pullback(∂y, ȳ)  # perform the reverse pass
	primal(∂y), Tuple(grads)
end

# ╔═╡ 45114855-612f-468e-bea1-c8e15596adf7
rdiff(1, *, 5, 3)

# ╔═╡ c1e2b463-7823-49bb-8a14-803f9a5ed34b
let f = Base.Fix2(^, 2)∘Base.Fix2(getindex, 1)
	rdiff(1., f, (3., 5.))
end

# ╔═╡ db778465-9266-4cb0-a77f-61ae1700442d
md"Now we can differentiate:"

# ╔═╡ 4f2e80df-4b43-4348-b49c-be1f620e5808
frule(f, Dual(5, 1), Dual(3, 0))

# ╔═╡ 2fd2055a-9e34-458b-8519-091bbb5b4d7b
rdiff(1., f, 5., 3.)

# ╔═╡ db0ff294-2759-4d7d-9787-a2595309bee2
md"""
### Reverse-mode and the inner product

Now we can see what happens when we change the ambient inner product.
"""

# ╔═╡ 9ca651b2-3698-402f-bb02-3c1259de91aa
[rdiff(1, *, 2, 3; ip) for ip in (ip, ip′)]

# ╔═╡ 820d12be-cac6-4e8b-87e2-50d80a8463c3
md"Notice that the gradients “differ”."

# ╔═╡ 3fa4b20a-c2b0-4d6e-8e41-25da218c673f
[rdiff(1, getfield, (a=1, b=2, c=3), :c; ip) for ip in (ip, ip′)]

# ╔═╡ 244b04e7-0fed-4caa-a0f6-85f0da0a7b22
md"(We haven't dealt with non-differentiable types at all, so the derivative with respect to the field name is, curiously enough, an empty symbol...)"

# ╔═╡ b7b3dbde-3b49-4eba-926f-5ab8619c8d8f
md"""
Why do we get two answers for the gradient?

The proper thing to do is to take the dual of the gradient (as defined above) as the last step of reverse-mode.
"""

# ╔═╡ c2b03820-87a6-4472-99c1-398064bfedfe
function rdiff_general(args...; ip)
	y, grad = rdiff(args...; ip)
	y, dual(grad; ip)
end

# ╔═╡ 6290f291-163d-4890-96e2-88076f901745
md"Now we can verify that the results are **independent of the inner product**."

# ╔═╡ 3973ca6f-4cac-4942-a287-f56a57c63442
allequal(rdiff_general(1, getfield, (a=1, b=2, c=3), :c; ip) for ip in (ip, ip′))

# ╔═╡ ed4e17f4-4488-452e-9d41-577071615c4c
let f = Base.Fix2(^, 2)∘Base.Fix2(getindex, 2)
	allequal(rdiff_general(1., f, (3., 5.); ip) for ip in (ip, ip′))
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "37e82a0c24d9f0b9f0b6ae1ad9e0b84c3d4fe069"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─de6606b3-55ee-4729-bcfe-65e5f54074ee
# ╟─33a9588e-414b-4bbd-931d-cd4508fafecb
# ╟─8a8582b6-cda3-4386-80a6-1eef5cd8407d
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
# ╟─1da71fc8-8c9b-491f-a6f5-9f0cec88f212
# ╠═3b994eb0-23f3-4b47-8f1d-6e42757bd714
# ╠═beb0cb3b-d9e8-4cf5-b6c5-fbcead46903c
# ╠═c16764e2-5228-45d9-9e46-d2de280b5e77
# ╟─499f40a8-796f-4120-a326-ce872f6acf7a
# ╟─c2633e84-c799-4e21-8bd1-9d71f2eb79ab
# ╠═36d04f8c-47a1-41ea-8572-39ef39141895
# ╟─2d8f2983-007b-49ad-9e9c-d26acd6a6cea
# ╠═b9d094e1-d6ea-4818-90c6-27471622b0be
# ╟─19816db5-8b0b-434c-a25a-4a3e10c4656b
# ╟─47a13810-c49c-4df7-b5e8-9dd3f57ad069
# ╠═4d5048cd-9161-443b-bb03-9b046a6596e3
# ╠═3a116278-8627-49e4-ae03-919be53cbd0f
# ╟─2cce9e24-84a0-4d96-aa10-ac0816e9d6d9
# ╠═37aa86c4-68d4-487a-a7d1-091957600dfc
# ╠═e7edb93f-b106-4521-9900-eea6c9e56015
# ╟─c9121d8a-1092-4351-b9fd-8cc068f70f32
# ╠═36db975f-da35-442c-ac0b-b12708e18291
# ╠═889bd98b-d638-4395-8585-b3d1c6bad524
# ╠═bdaf1a04-3975-468e-8ce3-abdfb8b1ea15
# ╟─6d681664-2d25-44a1-98c8-c7767015d1e1
# ╠═492fa9b1-910d-4bf5-af1d-6471fa56338d
# ╠═13fca4dd-8e79-44b4-85bf-df7aee2b2703
# ╠═c5a160ee-3e77-4252-a42f-ceddf467cc71
# ╟─848a34e4-e9ed-496d-be71-0a0adf6d015e
# ╠═5252ae96-fb57-4224-9e4c-57e066b56c20
# ╠═f8e7b3c5-266f-4e34-a4e0-82f7484862c6
# ╟─c10c3a4b-fef0-4fe1-8e39-ccc46c9e2e8f
# ╠═fb3ebf88-6206-4f02-860d-6952cdc5313b
# ╠═06bca717-6858-4a6c-9e55-4a5491bef21f
# ╟─86ae5f44-5a29-42d6-9426-3af86bc1a895
# ╠═5acc972e-1358-4cd2-b562-b378cadd266f
# ╠═17535316-5261-4409-8823-283d3135a168
# ╟─2658a6b3-e48c-4b4a-9ccb-afa06d4cc435
# ╠═cbd7d143-ddfa-4e8e-b665-18fc384f9f7a
# ╟─d24a859a-9c42-4dd9-981c-fc9ed8a6783b
# ╠═1f2b76d1-38a6-4882-bb07-fa65e31dd748
# ╠═3d5dc992-d3c6-4bfb-be9b-b5da8ee140e3
# ╟─eea8588f-16f8-43f2-a791-09cdd3145e8e
# ╠═4210c5af-c7c1-4307-b430-b9d9b25d07f9
# ╟─30c4fe7c-cc7a-4361-a1c9-f3cca4beda8b
# ╟─844089a9-89bb-4026-9f8d-aed213d11842
# ╠═29884061-d826-4f69-b72e-f8e6fbbc4d2d
# ╟─f18e3edc-7303-4104-965b-aec6fe76318d
# ╠═afacf6a7-acbf-4792-a4df-d4889b7d2f4e
# ╟─ad3fb313-a018-4817-a0b5-35c7e7f10473
# ╠═f8ad3d28-a7be-48b5-a928-4a2770667e41
# ╟─a397eabd-ba53-4917-8d7b-c02d203a86e3
# ╠═79d8d156-b8a2-4355-9ab7-a6b428106e10
# ╟─79715cfe-daf2-4e3d-aff3-504e6b27639f
# ╠═a8b4d067-f83a-433c-a855-40800d6deb3f
# ╟─f7bb2b9e-7900-4a93-b6f2-bd1336d2020b
# ╠═1d601774-c04c-4d4d-a5d4-3709de2e4d1f
# ╟─e4ef1efd-f0f6-4d7a-8e1c-e7e5449101fc
# ╠═45114855-612f-468e-bea1-c8e15596adf7
# ╟─bd49df06-cb16-4148-ad6f-ab0c572ee748
# ╠═85a616b9-d2ae-4432-85b9-f23a30123bbf
# ╟─306e9a40-fab1-43fc-8ead-4752af76251b
# ╠═08bafe7b-dcf5-4b8c-9154-a1f4ab693b07
# ╟─d3d40b18-e667-42e8-a15c-bae538af0f07
# ╠═d2715246-c1eb-409a-a7c5-3b571f1a6e66
# ╠═f2a9845f-4c2a-4d90-82d0-0acc3c0bd24d
# ╟─316b6130-9e7d-4497-8a4a-02e9211f7f03
# ╠═c1e2b463-7823-49bb-8a14-803f9a5ed34b
# ╟─1d150267-01a9-4ddc-8ead-1f77fdfab23e
# ╠═17539d7d-c7b1-4a66-a72c-bb942f7a36ba
# ╟─db778465-9266-4cb0-a77f-61ae1700442d
# ╠═4f2e80df-4b43-4348-b49c-be1f620e5808
# ╠═2fd2055a-9e34-458b-8519-091bbb5b4d7b
# ╟─db0ff294-2759-4d7d-9787-a2595309bee2
# ╠═9ca651b2-3698-402f-bb02-3c1259de91aa
# ╟─820d12be-cac6-4e8b-87e2-50d80a8463c3
# ╠═3fa4b20a-c2b0-4d6e-8e41-25da218c673f
# ╟─244b04e7-0fed-4caa-a0f6-85f0da0a7b22
# ╟─b7b3dbde-3b49-4eba-926f-5ab8619c8d8f
# ╠═c2b03820-87a6-4472-99c1-398064bfedfe
# ╟─6290f291-163d-4890-96e2-88076f901745
# ╠═3973ca6f-4cac-4942-a287-f56a57c63442
# ╠═ed4e17f4-4488-452e-9d41-577071615c4c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
