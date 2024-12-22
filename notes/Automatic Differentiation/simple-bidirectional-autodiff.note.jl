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
# Bidirectional-mode autodiff

This notebook describes a minimal implementation of automatic differentiation which uses a single functor construction to perform both forward- and reverse-mode passes.
I think it's really neat.

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

# ╔═╡ 15f96b0e-32c7-41f8-abb0-8e7f751f57a1
md"""
## Type for representing linear operators
"""

# ╔═╡ e5cc4210-9433-42f7-81ee-77d6d23bd836
struct LinearOperator{T}
	x::T
end

# ╔═╡ 575a557c-a14a-4a2f-85e6-4811224672ec
begin
	const LinFunc = LinearOperator{<:Function}
	(L::LinearOperator{})(a) = L.x*a
	(L::LinFunc)(a) = L.x(a)
	Base.:*(a, L::LinearOperator) = LinearOperator(a*L.x)
	Base.:*(a, L::LinFunc) = LinearOperator(x -> L(a*x))
	Base.:+(L::LinearOperator, M::LinearOperator) = LinearOperator(L.x + M.x)
	Base.:+(L::LinFunc, M::LinFunc) = LinearOperator(x -> L(x) + M(x))
end

# ╔═╡ 66cb59f3-6978-4112-8b3e-9f649c5300cf
begin
	struct ZeroOperator end
	(::ZeroOperator)(x) = zero(x)
	Base.:*(::Any, ::ZeroOperator) = ZeroOperator()
	Base.:*(::ZeroOperator, ::Any) = ZeroOperator()
	Base.:+(a, ::ZeroOperator) = a
	Base.:+(::ZeroOperator, a) = a
	Base.:+(::ZeroOperator, ::ZeroOperator) = ZeroOperator()
end

# ╔═╡ eafdebbb-7f85-416d-aebe-54bbf36e39e6
md"""
## Type for tracking derivative data
"""

# ╔═╡ 855d6743-f6bf-49ef-9c64-daf9d18f9d95
md"""
Next, introduce a type that represents a **pr**imal value together with a linear **op**erator, called `Prop` for want of a better name.
The primal field holds a normal value (i.e., not a derivative) and the linear operator encodes derivative information.
"""

# ╔═╡ e8b5b27e-bda9-11ef-32f4-19ea12987b49
struct Prop{X,O}
	primal::X
	operator::O
end

# ╔═╡ 03e87b3e-c96a-435a-bd4f-5d23ebea9f1c
primal(a::Prop) = a.primal

# ╔═╡ a7ac75f8-9834-4cf7-bc30-6cd58d60c769
primal(a::Number) = a

# ╔═╡ 0dfd92c2-1fd7-4ce4-b059-1d9628197f50
operator(a::Prop) = a.operator

# ╔═╡ 6a4a5aaf-c3f2-44a1-97cf-52df8a6f0271
operator(a) = ZeroOperator()

# ╔═╡ fc6e63b3-de69-4fee-834e-435d23666fc9
md"""
## The `lift` functor

Now define a higher-order function `lift` which maps scalar functions to functions on `Prop`s.
The function `lift(f)` accepts `Prop`s as input and returns a `Prop` containing the primal value `f(x)` and a linear operator encoding the derivative of `f`.

!!! definition
	Define the lift of a function ``f`` by
	```math
	\texttt{lift}(f)(\langle x_1, A_1 \rangle, ..., \langle x_n, A_n \rangle)
	= \left\langle f(x_1, ..., x_n), \sum_{i=1}^n \frac{∂f}{∂x_i} A_i \right\rangle
	```
	where ``\langle x, A \rangle`` denotes `Prop(x, A)`.
"""

# ╔═╡ 790f7252-7ee2-4e06-8373-1bbe5e891398
lift(f) = function(x...)
	y = f(primal.(x)...)
	∂f = ∂(f, primal.(x)...)
	A = sum(∂f.*operator.(x))
	Prop(y, A)
end

# ╔═╡ 106bb1fa-12c0-4ef0-ae0b-d964bfb03046
md"""
In the implementation, any arguments which are not a `Prop` (such as plain `Number`s) are omitted from the sum. (If all terms are omitted, the plain primal value is returned instead of a `Prop`.)

"""

# ╔═╡ 61afbb00-95ce-45bb-9a58-01741df61cdf
md"""
### Forward mode
"""

# ╔═╡ 6cd4fad4-f873-4e23-b0e1-de2a7a4bf9fc
md"""
To compute the full gradient ``∇f``, call the operator once for each input variable:
"""

# ╔═╡ f8cc2efb-ff19-4c8f-bce1-e70915eee05a
md"""
### Reverse mode

Reverse-mode is similar, except we use `Prop`s with reverse-mode operators instead.
"""

# ╔═╡ ef133164-bcde-4703-82dc-b5f2617b9364
md"""
## Operator overloading

The finishing touch is to define `Prop` methods for the all the relevant elementary functions.
Each method must simply redirect its arguments to the `lift`ed function.
"""

# ╔═╡ 1eca4129-917a-4373-a064-7cf64bdef17d
md"""
A simple macro can help with writing method definitions for many elementary functions:
"""

# ╔═╡ a73a45a0-2cfa-4692-afdf-2e1e7a8e0911
macro lift(expr)
	fn, args... = expr.args
	varnames, types = zip(getfield.(args, :args)...)
	if length(args) > 1
		types = [:(Union{Prop{<:$T},$T}) for T in types]
	else
		types = [:(Prop{<:$T}) for T in types]
	end
	sig = [:($var::$T) for (var, T) in zip(varnames, types) ]
	
	:( $fn($(sig...)) = lift($fn)($(varnames...)) )
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
			ẋ = i .== 1:length(x)
			x′ = x .+ ε*ẋ
			∂fᵢ = (f(x′...) - f(x...))/ε
			@test ∂fᵢ ≈ ∂f[i] rtol=1e-10
		end
	end
end;

# ╔═╡ a2fcecf0-4928-4fd6-beb7-0ca4bbcd4a21
a, b = 5, 3; f(a, b) = a*b + sin(a)

# ╔═╡ 1b5098d4-9a38-4687-a259-339e8dc39037
a⃑, b⃑ = Prop.([a, b], ([1, 0], [0, 1]))

# ╔═╡ 8e20f9c0-113b-479f-9f33-1318c75dc0c0
f(a⃑, b⃑)

# ╔═╡ 4227b15c-d56e-4494-85be-0b029769758c
function reverse_vars(x)
	grads = zeros(length(x))
	incrementor(i) = function(t)
		grads[i] += t
		ZeroOperator()
	end
	grads, [Prop(x[i], LinearOperator(incrementor(i))) for i in 1:length(x)]
end

# ╔═╡ c5df75cc-184c-4030-8bd2-3b32c5f318ae
function reverse_diff(ȳ, f, x...)
	grads, x̄ = reverse_vars(x)
	out = f(x̄...)
	out.operator(ȳ)
	out.primal, grads
end

# ╔═╡ 231354d8-d603-44a1-aca9-577e5b69faff
reverse_diff(1, f, 5, 3)

# ╔═╡ b7244ebe-8a4f-4508-be82-54a2f88c31de
let (grads, (a, b)) = reverse_vars([5, 3])
	z = a*b
	z.operator(1)
	grads
end

# ╔═╡ 002784c3-a11f-439a-82be-6b01c69cff2b
md"""
Now you can build up more complex functions and perform forward- and reverse-mode audodiff!
"""

# ╔═╡ 73a5eedf-a945-4cb9-8635-233686b810bc
g(A, B, C, D) = -sqrt(A + D^2) + log(B)cos(π*C - A/sqrt(D))

# ╔═╡ cf72d1a5-84c8-4963-8833-d1345510d2a3
reverse_diff(1, g, 1, 2, 3, 4)

# ╔═╡ 47e0c822-e2c1-4677-9d64-1cda8accf237
md"""
## Composite data types
"""

# ╔═╡ 93ecf9cc-0ccf-4960-b8fb-9dd62cd24900
(Prop(10, LinearOperator(i -> [[0, 0, 0], i]))^2).operator(2)

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
# ╟─e9fe864c-f677-4221-8da5-677bf5b5248a
# ╟─c5cf6e53-510d-4d42-9c39-33012d9771ad
# ╟─c9afba79-377b-4e87-85e1-9adbe86feb53
# ╟─15f96b0e-32c7-41f8-abb0-8e7f751f57a1
# ╠═e5cc4210-9433-42f7-81ee-77d6d23bd836
# ╠═575a557c-a14a-4a2f-85e6-4811224672ec
# ╠═66cb59f3-6978-4112-8b3e-9f649c5300cf
# ╟─eafdebbb-7f85-416d-aebe-54bbf36e39e6
# ╟─855d6743-f6bf-49ef-9c64-daf9d18f9d95
# ╠═e8b5b27e-bda9-11ef-32f4-19ea12987b49
# ╠═03e87b3e-c96a-435a-bd4f-5d23ebea9f1c
# ╠═a7ac75f8-9834-4cf7-bc30-6cd58d60c769
# ╠═0dfd92c2-1fd7-4ce4-b059-1d9628197f50
# ╠═6a4a5aaf-c3f2-44a1-97cf-52df8a6f0271
# ╟─fc6e63b3-de69-4fee-834e-435d23666fc9
# ╠═790f7252-7ee2-4e06-8373-1bbe5e891398
# ╟─106bb1fa-12c0-4ef0-ae0b-d964bfb03046
# ╠═61afbb00-95ce-45bb-9a58-01741df61cdf
# ╠═a2fcecf0-4928-4fd6-beb7-0ca4bbcd4a21
# ╠═1b5098d4-9a38-4687-a259-339e8dc39037
# ╠═8e20f9c0-113b-479f-9f33-1318c75dc0c0
# ╟─6cd4fad4-f873-4e23-b0e1-de2a7a4bf9fc
# ╟─f8cc2efb-ff19-4c8f-bce1-e70915eee05a
# ╠═4227b15c-d56e-4494-85be-0b029769758c
# ╠═c5df75cc-184c-4030-8bd2-3b32c5f318ae
# ╠═231354d8-d603-44a1-aca9-577e5b69faff
# ╠═b7244ebe-8a4f-4508-be82-54a2f88c31de
# ╟─ef133164-bcde-4703-82dc-b5f2617b9364
# ╟─1eca4129-917a-4373-a064-7cf64bdef17d
# ╠═a73a45a0-2cfa-4692-afdf-2e1e7a8e0911
# ╠═a5e82415-35b4-437f-845c-0bbd72d663c4
# ╟─002784c3-a11f-439a-82be-6b01c69cff2b
# ╠═73a5eedf-a945-4cb9-8635-233686b810bc
# ╠═cf72d1a5-84c8-4963-8833-d1345510d2a3
# ╟─47e0c822-e2c1-4677-9d64-1cda8accf237
# ╠═93ecf9cc-0ccf-4960-b8fb-9dd62cd24900
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
