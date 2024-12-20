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
# The simplest operator overloading forward- and reverse-mode automatic differentiation implementation you could possibly come up with

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
struct Prop{X,O<:Function}
	primal::X
	operator::O
end

# ╔═╡ 03e87b3e-c96a-435a-bd4f-5d23ebea9f1c
primal(a::Prop) = a.primal

# ╔═╡ a7ac75f8-9834-4cf7-bc30-6cd58d60c769
primal(a::Number) = a

# ╔═╡ fe7f8fa6-9981-4be9-96ab-9f82abcb6961
md"""
### Operators for forward- and reverse-mode

Here is where the magic happens.
We now initialise some `Prop`s with specific linear operators which make them perform forward- or reverse-mode autodiff when passed to `lift`ed functions.
"""

# ╔═╡ e71013f4-6a85-4dfd-bf10-50bd897ebc09
md"""
For forward mode, the ``i``th input variable becomes a `Prop` whose operator picks out the ``i``th value in a given vector.
This vector will contain the input derivatives ``[ẋ_1, ..., ẋ_n]`` which are supplied to the forward-mode derivative ``D f [x_1, ..., x_n](ẋ_1, ..., ẋ_n)``, so that the ``i``th input picks out ``ẋ_i``.
"""

# ╔═╡ b3a4f280-2fed-4ebd-b193-c42a08fc7e0a
pickout(i) = ẋ -> ẋ[i]

# ╔═╡ 6d6e7a5f-7206-4612-b650-4f28ca61e0bb
forward_vars(values) = Prop.(values, pickout.(eachindex(values)))

# ╔═╡ 2fa838a9-6264-43c6-8cc2-ab7fef31a573
md"""
For reverse mode, the ``i``th input variable becomes a `Prop` whose operator inserts a given value into the ``i``th component of a zero vector.
The given value will contain the output derivative ``ȳ_i`` which is supplied to the reverse-mode derivative ``D f[x_1, ..., x_n]^* (ȳ_1, ..., ȳ_m)``.
"""

# ╔═╡ 79090ad4-bffb-4c89-ab09-b287ee9e4746
md"""
!!! note
	It is a cute fact that the operator `pickout` is _adjoint_ to `putat` in the sense that
	```math
	\langle \texttt{pickout}_i \, \vec x, y\rangle = \langle \vec x, \texttt{putat}_i \,y\rangle
	```
	for the standard inner product. Here, ``\dim \vec x = n`` and ``\texttt{putat}_i \, y`` is really `putat(i, n)(y)`.

We can verify the adjoint relation with some tests:
"""

# ╔═╡ fc6e63b3-de69-4fee-834e-435d23666fc9
md"""
## The `lift` functor

Now define a higher-order function `lift` which maps scalar functions to functions on `Prop`s.
The function `lift(f)` accepts `Prop`s as input and returns a `Prop` containing the primal value `f(x)` and a linear operator encoding the derivative of `f`.

!!! definition
	If ``f(x)`` is a function's value at the primal ``x``, then the lifted function is
	```math
	\texttt{lift}(f)(\texttt{Prop}(x, A)) = \texttt{Prop}(f(x), t \mapsto \textstyle\frac{∂f}{∂x} A(t)).
	```
	If ``f(x_1, ..., x_n)``, then
	```math
	\texttt{lift}(f)(\texttt{Prop}(x_1, A_1), ..., \texttt{Prop}(x_n, A_n)) =
	\texttt{Prop}\left(f(x_1, ..., x_n), ξ \mapsto \textstyle \sum_i \frac{∂f}{∂x_i} A_i(ξ)\right).
	```
"""

# ╔═╡ 790f7252-7ee2-4e06-8373-1bbe5e891398
lift(f) = function(x...)
	y = f(primal.(x)...)
	I = findall(xᵢ -> xᵢ isa Prop, x)
	isempty(I) && return y
	∂f = ∂(f, primal.(x)...)
	A = a -> sum(∂f[i]*x[i].operator(a) for i in I)
	Prop(y, A)
end

# ╔═╡ 106bb1fa-12c0-4ef0-ae0b-d964bfb03046
md"""
In the implementation, any arguments which are not a `Prop` (such as plain `Number`s) are omitted from the sum. (If all terms are omitted, the plain primal value is returned instead of a `Prop`.)

"""

# ╔═╡ b9b90a74-504b-4f6f-b9fa-77ae2aa5d2e0
md"""
!!! warning
	Technically, this `lift` function only performs reverse-mode, building up a chain of callbacks. When used with forward-mode variables, the callbacks can be evaluated eagerly, resulting effectively in a forward pass. This implementation, however, performs both lazily.
"""

# ╔═╡ 651f93c1-2184-4374-82f3-2350e3672d48
md"""
### `lift`ing composite functions

Suppose we have the function ``f(a, b) = a b + \sin(a)`` which we wish to differentiate.
"""

# ╔═╡ 0404b71b-ef92-4950-b5c7-94cce17b2870
md"""
Picking some primal values for our function:
"""

# ╔═╡ 3c737d35-ccf9-4e41-bf8b-6f0ecc105019
a, b = 5, 2

# ╔═╡ b4340e13-04e7-464c-b51e-6830ed50b30d
md"""
We can manually construct `lift(f)` by writing it in terms of lifted versions of elementary functions.
"""

# ╔═╡ e3b2b3b5-0f3e-494e-afec-09684936467a
md"""
To run the forward-mode derivative program, we declare some forward-mode variables and pass them to `lift`ed function calls.
"""

# ╔═╡ 61afbb00-95ce-45bb-9a58-01741df61cdf
md"""
### Forward mode

Now we can bring everything together and actually compute derivatives.
First, lift each primal input value into a `Prop` with a forward-mode operator:
"""

# ╔═╡ 1b5098d4-9a38-4687-a259-339e8dc39037
a⃑, b⃑ = forward_vars([a, b])

# ╔═╡ 75a7db34-d152-4720-a7c9-1cf2e7779108
md"""
Calling the lifted function on these produces the primal value and a callback which computes the directional derivative of ``f`` in a given direction.
"""

# ╔═╡ 534f9d8b-782d-4cc5-bf86-b15d63b9a1f8
md"""
For example, to compute ``∂f/∂a``, we supply ``(\delta a, \delta b) = (1, 0)`` to the forward-mode operator:
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

# ╔═╡ 40cf450c-76e2-492d-a7a0-14a8e05fe033
md"""
Now, we only need to call the output operator once to compute the full gradient.
"""

# ╔═╡ ef133164-bcde-4703-82dc-b5f2617b9364
md"""
## Operator overloading

The finishing touch is to define `Prop` methods for the all the relevant elementary functions.
Each method must simply redirect its arguments to the `lift`ed function.
"""

# ╔═╡ 461fc25d-a20a-4a6b-b4c4-fda5f1589aeb
begin
	Base.:*(a::Union{Prop,Number}, b::Union{Prop,Number}) = lift(*)(a, b)
	Base.:+(a::Union{Prop,Number}, b::Union{Prop,Number}) = lift(+)(a, b)
	Base.sin(a::Prop) = lift(sin)(a)
end

# ╔═╡ 2b86df11-8fa3-4ecf-b89d-6004757866e3
md"""
Now we can use normal operators and functions with the `Prop` types.
"""

# ╔═╡ 8729d6a8-fb40-42cf-8c03-7c9c1e4256d7
md"""
Recall that our test function `f(a, b)` was defined using normal operators.
It now works on `Prop`s!
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

# ╔═╡ 914ab345-b6fe-43ee-8481-02d38d58da39
putat(i, n) = ȳᵢ -> ȳᵢ*(i .== 1:n)

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
			ẋ = putat(i, length(x))(1)
			x′ = x .+ ε*ẋ
			∂fᵢ = (f(x′...) - f(x...))/ε
			@test ∂fᵢ ≈ ∂f[i] rtol=1e-10
		end
	end
end;

# ╔═╡ a532a96f-693b-45f0-a2f3-752f06b021b1
reverse_vars(values) = Prop.(values, putat.(eachindex(values), length(values)))

# ╔═╡ 1713dc62-c13e-4505-9b84-15880e860171
a⃐, b⃐ = reverse_vars([a, b])

# ╔═╡ 397b3264-66e1-4120-be5e-3bfca0652db2
for _ in 1:100
	n = rand(1:10)
	i = rand(1:n)
	x⃗ = rand(n)
	y = rand()
	@test pickout(i)(x⃗)'y === x⃗'putat(i, n)(y)
end

# ╔═╡ 74d4f88f-f1b4-4bd8-a8ec-25c2912c8f59
f(a, b) = a*b + sin(a)

# ╔═╡ b8273745-6fac-4a56-9467-73799c555dcb
f(a, b)

# ╔═╡ 7bc26d17-2433-4d36-a723-dd2ad9e9a8c7
f(a⃐, b⃐).operator(1)

# ╔═╡ c4ec055c-5a3d-40f4-beca-e845a414b1fd
(+′, *′, sin′) = (lift(+), lift(*), lift(sin));

# ╔═╡ 66554ad9-c095-4d16-ba42-5166dd142066
f′(a, b) = a*′b +′ sin′(a)

# ╔═╡ d40ba902-8d04-4d1e-a28d-a535713e3b85
f′(a, b)

# ╔═╡ 5d53eb59-d611-43b0-8e82-d8f0bea2f091
y⃑ = f′(a⃑, b⃑)

# ╔═╡ e4b89483-6067-4609-b801-337c483e9c30
y⃑.operator([1, 0])

# ╔═╡ dae17a71-615d-4ef8-8bce-726971e29cd9
y⃑.operator.([[1, 0], [0, 1]])

# ╔═╡ 220bbf25-4c7e-4150-ac1b-0f7df90a3915
f′(a⃐, b⃐).operator(1)

# ╔═╡ 9892aeeb-4a4e-42a6-9c79-94f34dca1b2f
a⃑ + 8*b⃑

# ╔═╡ 002784c3-a11f-439a-82be-6b01c69cff2b
md"""
Now you can build up more complex functions and perform forward- and reverse-mode audodiff!
"""

# ╔═╡ 73a5eedf-a945-4cb9-8635-233686b810bc
g(A, B, C, D) = -sqrt(A + D^2) + log(B)cos(π*C - A/sqrt(D))

# ╔═╡ cf72d1a5-84c8-4963-8833-d1345510d2a3
A, B, C, D = reverse_vars(BigFloat[1, 2, 3, 4])

# ╔═╡ 288914f4-70d1-4c09-831a-fef131547b5a
g(A, B, C, D).operator(1)

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
# ╟─eafdebbb-7f85-416d-aebe-54bbf36e39e6
# ╟─855d6743-f6bf-49ef-9c64-daf9d18f9d95
# ╠═e8b5b27e-bda9-11ef-32f4-19ea12987b49
# ╠═03e87b3e-c96a-435a-bd4f-5d23ebea9f1c
# ╠═a7ac75f8-9834-4cf7-bc30-6cd58d60c769
# ╟─fe7f8fa6-9981-4be9-96ab-9f82abcb6961
# ╟─e71013f4-6a85-4dfd-bf10-50bd897ebc09
# ╠═b3a4f280-2fed-4ebd-b193-c42a08fc7e0a
# ╠═6d6e7a5f-7206-4612-b650-4f28ca61e0bb
# ╟─2fa838a9-6264-43c6-8cc2-ab7fef31a573
# ╠═914ab345-b6fe-43ee-8481-02d38d58da39
# ╠═a532a96f-693b-45f0-a2f3-752f06b021b1
# ╟─79090ad4-bffb-4c89-ab09-b287ee9e4746
# ╠═397b3264-66e1-4120-be5e-3bfca0652db2
# ╟─fc6e63b3-de69-4fee-834e-435d23666fc9
# ╠═790f7252-7ee2-4e06-8373-1bbe5e891398
# ╟─106bb1fa-12c0-4ef0-ae0b-d964bfb03046
# ╠═b9b90a74-504b-4f6f-b9fa-77ae2aa5d2e0
# ╟─651f93c1-2184-4374-82f3-2350e3672d48
# ╠═74d4f88f-f1b4-4bd8-a8ec-25c2912c8f59
# ╟─0404b71b-ef92-4950-b5c7-94cce17b2870
# ╠═3c737d35-ccf9-4e41-bf8b-6f0ecc105019
# ╠═b8273745-6fac-4a56-9467-73799c555dcb
# ╟─b4340e13-04e7-464c-b51e-6830ed50b30d
# ╠═c4ec055c-5a3d-40f4-beca-e845a414b1fd
# ╠═66554ad9-c095-4d16-ba42-5166dd142066
# ╠═d40ba902-8d04-4d1e-a28d-a535713e3b85
# ╟─e3b2b3b5-0f3e-494e-afec-09684936467a
# ╟─61afbb00-95ce-45bb-9a58-01741df61cdf
# ╠═1b5098d4-9a38-4687-a259-339e8dc39037
# ╟─75a7db34-d152-4720-a7c9-1cf2e7779108
# ╠═5d53eb59-d611-43b0-8e82-d8f0bea2f091
# ╟─534f9d8b-782d-4cc5-bf86-b15d63b9a1f8
# ╠═e4b89483-6067-4609-b801-337c483e9c30
# ╟─6cd4fad4-f873-4e23-b0e1-de2a7a4bf9fc
# ╠═dae17a71-615d-4ef8-8bce-726971e29cd9
# ╟─f8cc2efb-ff19-4c8f-bce1-e70915eee05a
# ╠═1713dc62-c13e-4505-9b84-15880e860171
# ╟─40cf450c-76e2-492d-a7a0-14a8e05fe033
# ╠═220bbf25-4c7e-4150-ac1b-0f7df90a3915
# ╟─ef133164-bcde-4703-82dc-b5f2617b9364
# ╠═461fc25d-a20a-4a6b-b4c4-fda5f1589aeb
# ╟─2b86df11-8fa3-4ecf-b89d-6004757866e3
# ╠═9892aeeb-4a4e-42a6-9c79-94f34dca1b2f
# ╟─8729d6a8-fb40-42cf-8c03-7c9c1e4256d7
# ╠═7bc26d17-2433-4d36-a723-dd2ad9e9a8c7
# ╟─1eca4129-917a-4373-a064-7cf64bdef17d
# ╠═a73a45a0-2cfa-4692-afdf-2e1e7a8e0911
# ╠═a5e82415-35b4-437f-845c-0bbd72d663c4
# ╟─002784c3-a11f-439a-82be-6b01c69cff2b
# ╠═73a5eedf-a945-4cb9-8635-233686b810bc
# ╠═cf72d1a5-84c8-4963-8833-d1345510d2a3
# ╠═288914f4-70d1-4c09-831a-fef131547b5a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
