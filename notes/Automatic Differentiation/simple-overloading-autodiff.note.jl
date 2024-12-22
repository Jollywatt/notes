### A Pluto.jl notebook ###
# v0.20.3

#> [frontmatter]
#> title = "Simple forward/reverse overloading autodiff"

using Markdown
using InteractiveUtils

# ╔═╡ c9afba79-377b-4e87-85e1-9adbe86feb53
using Test

# ╔═╡ cf3a3089-f22a-4bdd-8005-ca0839e87855
include("partials.note.jl")

# ╔═╡ a5aec48a-a3c2-496b-b7fb-233a3637d959
md"""
# Forward- and reverse-mode automatic differentiation by operator overloading

This is a minimal, pedagogical automatic differentiation implementation using operator overloading.
Both forward- and reverse-mode are supported.

Compare this to the [tape-based implementation](https://jollywatt.github.io/notes/simple-tape-autodiff).
"""

# ╔═╡ 24c4c2f5-7fc1-47f1-b3ad-2fe50505e585
md"""
To begin, we define the partial derivatives of a few elementary functions.
This is done with the `∂` function.

!!! definition
	For a function ``f``, define the tuple of partial derivatives as
	```math
	∂(f, x_1, ..., x_n) := \left(\frac{∂f}{∂x_1}, ..., \frac{∂f}{∂x_n}\right)
	```
	where the derivatives are evaluated at ``(x_1, ..., x_n)``.

Here, we load some methods for the `∂` function defined in [this Julia file](https://jollywatt.github.io/notes/partials).
"""

# ╔═╡ e9fe864c-f677-4221-8da5-677bf5b5248a
md"""
We can check these are correct numerically:
"""

# ╔═╡ eafdebbb-7f85-416d-aebe-54bbf36e39e6
md"""
## Types for tracking derivative data

We define some types used to propagate derivatives in both forward- and reverse-mode.
Forward-mode uses [dual numbers](https://en.wikipedia.org/wiki/Dual_number), and reverse-mode uses codual numbers, in which the tangent part is a callback.
"""

# ╔═╡ 427a1337-c28d-4f24-9076-52c358f1f893
md"""
### Dual numbers for forward-mode
"""

# ╔═╡ e8b5b27e-bda9-11ef-32f4-19ea12987b49
struct Dual{T,dT}
	x::T
	dx::dT
end

# ╔═╡ 03e87b3e-c96a-435a-bd4f-5d23ebea9f1c
primal(a::Dual) = a.x

# ╔═╡ 8c1c788e-1f01-44a5-9e8d-faf46f8ca90d
tangent(a::Dual) = a.dx

# ╔═╡ 92c73763-8dcb-407f-ba00-89423cf2de1e
md"""
### Codual numbers for reverse-mode
"""

# ╔═╡ 1c8a1db6-2970-48ce-b285-5e8ffcd4b946
struct CoDual{T}
	x::T
	back::Function
end

# ╔═╡ 76f9c5a6-71a6-42dc-8781-6e6eda7a1951
primal(a::CoDual) = a.x

# ╔═╡ c957ce5f-030e-4fb1-9eab-a2f8e49aafa0
cotangent(a::CoDual, x) = a.back(x)

# ╔═╡ fc6e63b3-de69-4fee-834e-435d23666fc9
md"""
## Function application on (co)dual numbers
We now define higher-order functions that lift scalar functions to functions that operate on our `Dual` and `CoDual` types.
"""

# ╔═╡ 651f93c1-2184-4374-82f3-2350e3672d48
md"""
## Differentiating composite functions

Suppose we have the function ``f(a, b) = a b + \sin(a)`` which we wish to differentiate.
"""

# ╔═╡ 61afbb00-95ce-45bb-9a58-01741df61cdf
md"""
### Forward mode

Suppose we have the function ``f(a, b) = a b + \sin(a)`` which we wish to differentiate.
"""

# ╔═╡ 55ce1766-d7b9-4041-8ab4-7a35d361c549
md"""
The lifted version of this function is:
"""

# ╔═╡ c3c8f31b-9ed1-4b28-bfd0-f87ec389b8db
md"""
Here are the `Dual` variables which differentiate in the ``(\dot a, \dot b) = (1, 0)`` direction:
"""

# ╔═╡ 75a7db34-d152-4720-a7c9-1cf2e7779108
md"""
Calling the lifted function on these produces the primal value and the directional derivative.
"""

# ╔═╡ 6cd4fad4-f873-4e23-b0e1-de2a7a4bf9fc
md"""
To compute the full gradient ``∇f``, we take a directional derivative with respect to each input.
This can be paralised by making the tangent components for each input vectors.
"""

# ╔═╡ f8cc2efb-ff19-4c8f-bce1-e70915eee05a
md"""
### Reverse mode

Reverse-mode is similar, except that we use the `codual` functor instead.
"""

# ╔═╡ 2667ac0b-c94a-4d9c-be0c-cc54237bf6a9
md"""
We also need to setup some memory for the `CoDual` callbacks to write to during the reverse pass.
"""

# ╔═╡ 40cf450c-76e2-492d-a7a0-14a8e05fe033
md"""
Now, we only need to call the output operator once to compute the full gradient.
"""

# ╔═╡ 28424ef1-dc02-4ba4-b11f-1bece1e91499
md"""
## Making the code more generic

The functions `dual(f)` and `codual(f)` assume that its inputs `x` are all instances of `Dual` or `CoDual`, respectively.

For this to work on other types (for example, constants given as plain `Number`s), we need to define `primal` and `tangent` on other types.
"""

# ╔═╡ a7ac75f8-9834-4cf7-bc30-6cd58d60c769
primal(a) = a

# ╔═╡ f6b1c226-b632-4a3d-a138-ac0a15d5ac66
md"""
Anything that is not a (co)dual is treated as a constant with no derivative.
For dual numbers, the additive identity to use is clear:
"""

# ╔═╡ 787fad68-3259-4ca2-a0fb-f372694be2aa
tangent(a) = zero(a)

# ╔═╡ a34ab926-15ad-414e-9558-158763a66a6f
md"""
However, for codual numbers, we don't know what additive identity to use, because the `back` function could return an array of unspecified size, for example.

Instead, we can define a singleton `ZeroTangent()` which acts as an additive identity for everything.
"""

# ╔═╡ aba756e2-c09f-49cd-a265-eee767d5fe31
begin
	struct ZeroTangent end
	Base.:*(a, ::ZeroTangent) = ZeroTangent()
	Base.:*(::ZeroTangent, a) = ZeroTangent()
	Base.:+(a, ::ZeroTangent) = a
	Base.:+(::ZeroTangent, a) = a
	Base.:+(::ZeroTangent, ::ZeroTangent) = ZeroTangent()
end

# ╔═╡ 790f7252-7ee2-4e06-8373-1bbe5e891398
dual(f) = function(x...)
	y = f(primal.(x)...)
	∂f = ∂(f, primal.(x)...)
	ẏ = sum(∂f .* tangent.(x))
	Dual(y, ẏ)
end

# ╔═╡ 7fac0358-44a7-4050-a356-618306115487
cotangent(a, x) = ZeroTangent()

# ╔═╡ 638f247b-4b09-4160-bcd1-e0f91faa38d2
codual(f) = function(x...)
	y = f(primal.(x)...)
	∂f = ∂(f, primal.(x)...)
	ȳ = t -> for (∂fᵢ, xᵢ) in zip(∂f, x)
		cotangent(xᵢ, ∂fᵢ*t)
	end
	CoDual(y, ȳ)
end

# ╔═╡ d6b48c67-b09a-44a5-970f-5111c3f07453
md"""
Now, lifted functions work on non-(co)dual types.
"""

# ╔═╡ 0404b71b-ef92-4950-b5c7-94cce17b2870
md"""
Picking some primal values for our function:
"""

# ╔═╡ ef133164-bcde-4703-82dc-b5f2617b9364
md"""
## Operator overloading

The finishing touch is to define (co)dualised methods for the all the relevant elementary functions.
Each method must simply redirect its arguments to the lifted function.
"""

# ╔═╡ 390c6c7d-cd27-4da8-982d-a92e35c83f1f
Base.sin(a::Dual) = dual(sin)(a)

# ╔═╡ 9a6dedbd-68cd-4f80-8595-a099c1f2dc28
Base.sin(a::CoDual) = codual(sin)(a)

# ╔═╡ 1eca4129-917a-4373-a064-7cf64bdef17d
md"""
A simple macro can help with writing method definitions for many elementary functions:
"""

# ╔═╡ a73a45a0-2cfa-4692-afdf-2e1e7a8e0911
macro lift(expr)
	fn, args... = expr.args
	varnames, types = zip(getfield.(args, :args)...)

	stmts = Expr[]
	for (dualtype, wrapper) in [:Dual => :dual, :CoDual => :codual]
		if length(args) > 1
			types′ = [:(Union{$dualtype{<:$T},$T}) for T in types]
		else
			types′ = [:($dualtype{<:$T}) for T in types]
		end
		sig = [:($var::$T) for (var, T) in zip(varnames, types′) ]
		stmt = :( $fn($(sig...)) = $wrapper($fn)($(varnames...)) )
		push!(stmts, stmt)
	end
	:(begin $(stmts...) end)
end

# ╔═╡ a5e82415-35b4-437f-845c-0bbd72d663c4
begin
	@lift Base.:+(a::Number, b::Number)
	@lift Base.:-(a::Number)
	@lift Base.:-(a::Number, b::Number)
	@lift Base.:*(a::Number, b::Number)
	@lift Base.:/(a::Number, b::Number)
	@lift Base.exp(a::Number)
	@lift Base.log(a::Number)
	@lift Base.sqrt(a::Number)
	@lift Base.sin(a::Number)
	@lift Base.cos(a::Number)
	@lift Base.:^(a::Number, b::Number)
end

# ╔═╡ 2f724018-2253-4676-92b9-0a192564453b
∂(sin, 4) ≈ cos(4)

# ╔═╡ c5cf6e53-510d-4d42-9c39-33012d9771ad
@testset begin
	ε = 1e-10
	for (f, x...) in [
		(+, 1, 2),
		(-, 4, 5),
		(*, 10, 20),
		(/, 2, 3),
		(exp, 4),
		(log, 9),
		(^, 2, 3),
		(sin, 7),
		(cos, 5)
	]
		∂f = ∂(f, x...)
		x = BigFloat.(x)
		for i in 1:length(x)
			ẋ = 1:length(x) .== i
			x′ = x .+ ε*ẋ
			∂fᵢ = (f(x′...) - f(x...))/ε
			@test ∂fᵢ ≈ ∂f[i] rtol=1e-10
		end
	end
end;

# ╔═╡ 087e447d-499b-423d-8846-8d555fb96b93
(a, b) = (5, 3); f(a, b) = a*b + sin(a)

# ╔═╡ 1b5098d4-9a38-4687-a259-339e8dc39037
a⃑, b⃑ = Dual.([a, b], [1, 0])

# ╔═╡ c4ec055c-5a3d-40f4-beca-e845a414b1fd
f_dual(a, b) = let (+, *, sin) = dual.((+, *, sin))
	a*b + sin(a)
end

# ╔═╡ 5d53eb59-d611-43b0-8e82-d8f0bea2f091
f_dual(a⃑, b⃑)

# ╔═╡ 724fb2b2-0611-4f7f-8ccb-a87eea4f30bb
let (a⃑, b⃑) = Dual.([a, b], eachcol([1 0; 0 1]))
	f_dual(a⃑, b⃑)
end

# ╔═╡ b0f09d8b-dba6-4712-8217-e67353588094
f_dual(Dual(5, 1), 3)

# ╔═╡ 4ba47bfd-ac0f-4c36-8041-5de6c6340c76
f_codual(a, b) = let (+, *, sin) = codual.((+, *, sin))
	a*b + sin(a)
end

# ╔═╡ a54df0d9-d7cc-493d-a83a-c86754d3e5d8
function reverse_vars(values)
	grads = zeros(length(values))
	grads, [CoDual(v, t -> grads[i] += t) for (i, v) in enumerate(values)]
end

# ╔═╡ 3178628d-8558-47be-a7ac-1e74fa3eee5a
let (grads, (a⃐, b⃐)) = reverse_vars([5, 3])
	f_codual(a⃐, b⃐).back(1)
	grads
end

# ╔═╡ 2b86df11-8fa3-4ecf-b89d-6004757866e3
md"""
Now we can use normal operators and functions with the `Prop` types.
"""

# ╔═╡ 8729d6a8-fb40-42cf-8c03-7c9c1e4256d7
md"""
Recall our test function `f(a, b)`, defined using normal operators.
It now works on `Dual`s!
"""

# ╔═╡ c7eb4334-6a0d-4546-9148-27a53a5d3b8d
f(Dual(5, 1), 3)

# ╔═╡ 002784c3-a11f-439a-82be-6b01c69cff2b
md"""
Now you can build up more complex functions and perform forward- and reverse-mode autodiff. 🥳
"""

# ╔═╡ 73a5eedf-a945-4cb9-8635-233686b810bc
g(A, B, C, D) = -sqrt(A + D^2) + log(B)cos(π*C - A/sqrt(D))

# ╔═╡ cf72d1a5-84c8-4963-8833-d1345510d2a3
let (grads, (A, B, C, D)) = reverse_vars(BigFloat[1, 2, 3, 4])
	g(A, B, C, D).back(1)
	grads
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
# ╟─a5aec48a-a3c2-496b-b7fb-233a3637d959
# ╟─24c4c2f5-7fc1-47f1-b3ad-2fe50505e585
# ╠═cf3a3089-f22a-4bdd-8005-ca0839e87855
# ╠═2f724018-2253-4676-92b9-0a192564453b
# ╟─e9fe864c-f677-4221-8da5-677bf5b5248a
# ╟─c5cf6e53-510d-4d42-9c39-33012d9771ad
# ╟─c9afba79-377b-4e87-85e1-9adbe86feb53
# ╟─eafdebbb-7f85-416d-aebe-54bbf36e39e6
# ╟─427a1337-c28d-4f24-9076-52c358f1f893
# ╠═e8b5b27e-bda9-11ef-32f4-19ea12987b49
# ╠═03e87b3e-c96a-435a-bd4f-5d23ebea9f1c
# ╠═8c1c788e-1f01-44a5-9e8d-faf46f8ca90d
# ╟─92c73763-8dcb-407f-ba00-89423cf2de1e
# ╠═1c8a1db6-2970-48ce-b285-5e8ffcd4b946
# ╠═76f9c5a6-71a6-42dc-8781-6e6eda7a1951
# ╠═c957ce5f-030e-4fb1-9eab-a2f8e49aafa0
# ╟─fc6e63b3-de69-4fee-834e-435d23666fc9
# ╠═790f7252-7ee2-4e06-8373-1bbe5e891398
# ╠═638f247b-4b09-4160-bcd1-e0f91faa38d2
# ╟─651f93c1-2184-4374-82f3-2350e3672d48
# ╟─61afbb00-95ce-45bb-9a58-01741df61cdf
# ╠═087e447d-499b-423d-8846-8d555fb96b93
# ╟─55ce1766-d7b9-4041-8ab4-7a35d361c549
# ╠═c4ec055c-5a3d-40f4-beca-e845a414b1fd
# ╟─c3c8f31b-9ed1-4b28-bfd0-f87ec389b8db
# ╠═1b5098d4-9a38-4687-a259-339e8dc39037
# ╠═75a7db34-d152-4720-a7c9-1cf2e7779108
# ╠═5d53eb59-d611-43b0-8e82-d8f0bea2f091
# ╟─6cd4fad4-f873-4e23-b0e1-de2a7a4bf9fc
# ╠═724fb2b2-0611-4f7f-8ccb-a87eea4f30bb
# ╟─f8cc2efb-ff19-4c8f-bce1-e70915eee05a
# ╠═4ba47bfd-ac0f-4c36-8041-5de6c6340c76
# ╟─2667ac0b-c94a-4d9c-be0c-cc54237bf6a9
# ╠═a54df0d9-d7cc-493d-a83a-c86754d3e5d8
# ╟─40cf450c-76e2-492d-a7a0-14a8e05fe033
# ╠═3178628d-8558-47be-a7ac-1e74fa3eee5a
# ╟─28424ef1-dc02-4ba4-b11f-1bece1e91499
# ╠═a7ac75f8-9834-4cf7-bc30-6cd58d60c769
# ╟─f6b1c226-b632-4a3d-a138-ac0a15d5ac66
# ╠═787fad68-3259-4ca2-a0fb-f372694be2aa
# ╟─a34ab926-15ad-414e-9558-158763a66a6f
# ╠═aba756e2-c09f-49cd-a265-eee767d5fe31
# ╠═7fac0358-44a7-4050-a356-618306115487
# ╟─d6b48c67-b09a-44a5-970f-5111c3f07453
# ╠═b0f09d8b-dba6-4712-8217-e67353588094
# ╟─0404b71b-ef92-4950-b5c7-94cce17b2870
# ╟─ef133164-bcde-4703-82dc-b5f2617b9364
# ╠═390c6c7d-cd27-4da8-982d-a92e35c83f1f
# ╠═9a6dedbd-68cd-4f80-8595-a099c1f2dc28
# ╟─1eca4129-917a-4373-a064-7cf64bdef17d
# ╠═a73a45a0-2cfa-4692-afdf-2e1e7a8e0911
# ╠═a5e82415-35b4-437f-845c-0bbd72d663c4
# ╟─2b86df11-8fa3-4ecf-b89d-6004757866e3
# ╟─8729d6a8-fb40-42cf-8c03-7c9c1e4256d7
# ╠═c7eb4334-6a0d-4546-9148-27a53a5d3b8d
# ╟─002784c3-a11f-439a-82be-6b01c69cff2b
# ╠═73a5eedf-a945-4cb9-8635-233686b810bc
# ╠═cf72d1a5-84c8-4963-8833-d1345510d2a3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
