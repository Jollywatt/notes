### A Pluto.jl notebook ###
# v0.20.3

#> [frontmatter]
#> title = "Simple forward/reverse overloading autodiff"

using Markdown
using InteractiveUtils

# ╔═╡ cf3a3089-f22a-4bdd-8005-ca0839e87855
include("partials.note.jl")

# ╔═╡ a5aec48a-a3c2-496b-b7fb-233a3637d959
md"""
# Unified forward/reverse autodiff

This notebook points out the similarities of forward- and reverse-mode automatic differentiation by implementing them both with a single functorial construction.

Compare this to the [implementation using dual and codual numbers](https://jollywatt.github.io/notes/overloading-autodiff).
"""

# ╔═╡ 8325cac2-950e-4d2b-955b-c57a47126ab6
md"""
As before, we load some partial derivative rules for some elementary functions.
"""

# ╔═╡ eafdebbb-7f85-416d-aebe-54bbf36e39e6
md"""
## Type for tracking derivative data
"""

# ╔═╡ 855d6743-f6bf-49ef-9c64-daf9d18f9d95
md"""
With forward-mode, we used dual numbers in which the _primal_ value is paired with another number (the _epsilon_ or _tangent_ part).
Reverse-mode used a “codual” number, where the primal value is paired with a _callback_ which increments the value of the relevant gradient.

We can view a number (forward mode) and a callback (reverse mode) both as linear operators.
Thus, we can represent both dual and codual types with a pairing of a **pr**imal value together with a linear **op**erator.
Call this a `Prop` for want of a better name.


"""

# ╔═╡ e8b5b27e-bda9-11ef-32f4-19ea12987b49
struct Prop{X,O}
	primal::X
	operator::O
end

# ╔═╡ 03e87b3e-c96a-435a-bd4f-5d23ebea9f1c
primal(a::Prop) = a.primal

# ╔═╡ 0dfd92c2-1fd7-4ce4-b059-1d9628197f50
operator(a::Prop) = a.operator

# ╔═╡ 788ee2e5-e16f-4d49-9050-0449485dac1c
md"""
To make code cleaner, we can implement an interface so that any value `x` of a type  other that `Prop` is regarded as representing a constant with zero derivative, or `Prop(x, ZeroOperator())`.
"""

# ╔═╡ a7ac75f8-9834-4cf7-bc30-6cd58d60c769
primal(a) = a

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

# ╔═╡ 6a4a5aaf-c3f2-44a1-97cf-52df8a6f0271
operator(a) = ZeroOperator()

# ╔═╡ fc6e63b3-de69-4fee-834e-435d23666fc9
md"""
## The `lift` functor

Just as before, we define a higher-order function `lift` which maps scalar functions to functions on our special number type which tracks derivatives (in this case, `Prop`).

!!! definition
	Define the lift of a function ``f`` by
	```math
	\texttt{lift}(f)(\langle x_1, A_1 \rangle, ..., \langle x_n, A_n \rangle)
	= \left\langle f(x_1, ..., x_n), \sum_{i=1}^n \frac{∂f}{∂x_i} A_i \right\rangle
	```
	where ``\langle x, A \rangle`` denotes `Prop(x, A)`.
"""

# ╔═╡ 983400d7-982c-4f09-b641-4221c37d4a22
md"""
In forward-mode, the “linear operator” given by `operator(::Prop)` is simply a scalar.

In reverse-mode, the linear operator is a closure or function which increments a specific gradient value (by writing to a lookup table, for example).

We want addition and scalar multiplication to be defined for the linear operators used in the `Prop` type (so that `sum(∂f.*operator.(x))` works).
Numbers already implement this, but not closures, so define a `LinearOperator` wrapper.
"""

# ╔═╡ 575a557c-a14a-4a2f-85e6-4811224672ec
begin
	struct LinearOperator{T}
		x::T
	end
	(L::LinearOperator)(a) = L.x(a)
	Base.:*(a, L::LinearOperator) = LinearOperator(x -> L(a*x))
	Base.:+(L::LinearOperator, M::LinearOperator) = LinearOperator(x -> L(x) + M(x))
end

# ╔═╡ 790f7252-7ee2-4e06-8373-1bbe5e891398
lift(f) = function(x...)
	y = f(primal.(x)...)
	∂f = ∂(f, primal.(x)...)
	A = sum(∂f.*operator.(x))
	Prop(y, A)
end

# ╔═╡ 232163eb-369f-4699-99e6-21309517cc27
md"""
Now we can treat callbacks as vectors: scaling them is the same as pre-scaling the inputs, and adding them is the same as calling them in series.
"""

# ╔═╡ ef133164-bcde-4703-82dc-b5f2617b9364
md"""
## Operator overloading

Just as with dual and codual numbers, we add methods to elementary functions to make them compatible with the `Prop` type.
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

# ╔═╡ 7a5c58d1-5456-4ac9-9fb2-fc7d56b2ab79
let a = LinearOperator(t -> (println("That makes $t."); t))
	b = 6*a
	c = a + b
	c(7)
end

# ╔═╡ be307943-58e3-4582-97be-295e7b4ab444
md"""
## Evaluating derivatives

Define a test function to differentiate:
"""

# ╔═╡ a2fcecf0-4928-4fd6-beb7-0ca4bbcd4a21
a, b = 5, 3; f(a, b) = a*b + sin(a)

# ╔═╡ e568c32a-4be4-48dc-aef5-5997d57c0557
md"""
### Forward-mode

We can evaluate one directional derivative like so:
"""

# ╔═╡ 14bd6d6e-cb9d-4c98-bcbb-96ffc452dcfc
let (a, b) = Prop.((a, b), (1, 0))
	f(a, b)
end

# ╔═╡ 75f409f1-f937-4dd9-a6e1-df7f557f3329
md"""
### Vectorized forward-mode

To obtain the entire gradient, we can evaluate multiple directional derivatives in a vectorized fashion like so:
"""

# ╔═╡ 8a63340b-b44c-4b8b-a9ac-59629c2c879c
let (a, b) = Prop.((a, b), ([1, 0], [0, 1]))
	f(a, b)
end

# ╔═╡ bccb8b0c-1597-465f-9bd0-59bbb80b95ac
md"""
This method is memory-heavy because we allocate an entire vector of partial derivatives for each operation.
"""

# ╔═╡ 0e752a46-5d5f-4104-a39a-79115168b39e
md"""
### Vectorized reverse-mode

This is almost identical to performing vectorized forward-mode, except that we propagate closures instead of vectors.

The forward pass builds up a chain of callbacks, and to perform the reverse pass, we call the final callback.
"""

# ╔═╡ d26ea4b2-33f6-4afe-b511-0fef49e4630e
let (a, b) = Prop.((a, b), LinearOperator.((x -> [x, 0], x -> [0, x])))
	y = f(a, b)
	y.primal, y.operator(1)
end

# ╔═╡ a7ebd5fe-ddfd-400c-aa45-ab13cb909b4a
md"""
Just like for the vectorized forward-mode, this method still ends up allocating a vector of partial derivatives for each lifted function — now it just happens during the reverse pass.
"""

# ╔═╡ f8cc2efb-ff19-4c8f-bce1-e70915eee05a
md"""
### Reverse-mode with shared state

To optimise memory usage, instead of propagating derivatives by passing vectors between callbacks, we can instead just write the derivatives to a shared space in memory.

For example, this helper function allocates a single vector to hold derivatives and creates `Prop` variables whose callbacks write to this shared vector.
"""

# ╔═╡ 4227b15c-d56e-4494-85be-0b029769758c
function reverse_vars(x)
	grads = zeros(length(x))
	incrementor(i) = function(t)
		grads[i] += t
		ZeroOperator() # dummy return value; we only care about side effects now
	end
	grads, [Prop(x[i], LinearOperator(incrementor(i))) for i in 1:length(x)]
end

# ╔═╡ b7244ebe-8a4f-4508-be82-54a2f88c31de
let (grads, (a, b)) = reverse_vars([5, 3])
	z = a*b
	z.operator(1)
	z.primal, grads
end

# ╔═╡ 098c521d-0ab4-4399-8c36-8bc6258d8fc7
md"""
We can wrap this up in a single function for performing reverse mode autodiff:
"""

# ╔═╡ c5df75cc-184c-4030-8bd2-3b32c5f318ae
function reverse_diff(ȳ, f, x...)
	grads, x̄ = reverse_vars(x)
	out = f(x̄...)
	out.operator(ȳ)
	out.primal, grads
end

# ╔═╡ 231354d8-d603-44a1-aca9-577e5b69faff
reverse_diff(1, f, 5, 3)

# ╔═╡ 002784c3-a11f-439a-82be-6b01c69cff2b
md"""
Now you can build up more complex functions and perform forward- and reverse-mode audodiff!
"""

# ╔═╡ 73a5eedf-a945-4cb9-8635-233686b810bc
g(A, B, C, D) = -sqrt(A + D^2) + log(B)cos(π*C - A/sqrt(D))

# ╔═╡ cf72d1a5-84c8-4963-8833-d1345510d2a3
reverse_diff(1, g, 1, 2, 3, 4)

# ╔═╡ Cell order:
# ╟─a5aec48a-a3c2-496b-b7fb-233a3637d959
# ╟─8325cac2-950e-4d2b-955b-c57a47126ab6
# ╠═cf3a3089-f22a-4bdd-8005-ca0839e87855
# ╟─eafdebbb-7f85-416d-aebe-54bbf36e39e6
# ╟─855d6743-f6bf-49ef-9c64-daf9d18f9d95
# ╠═e8b5b27e-bda9-11ef-32f4-19ea12987b49
# ╠═03e87b3e-c96a-435a-bd4f-5d23ebea9f1c
# ╠═0dfd92c2-1fd7-4ce4-b059-1d9628197f50
# ╟─788ee2e5-e16f-4d49-9050-0449485dac1c
# ╠═a7ac75f8-9834-4cf7-bc30-6cd58d60c769
# ╠═6a4a5aaf-c3f2-44a1-97cf-52df8a6f0271
# ╠═66cb59f3-6978-4112-8b3e-9f649c5300cf
# ╟─fc6e63b3-de69-4fee-834e-435d23666fc9
# ╠═790f7252-7ee2-4e06-8373-1bbe5e891398
# ╟─983400d7-982c-4f09-b641-4221c37d4a22
# ╠═575a557c-a14a-4a2f-85e6-4811224672ec
# ╟─232163eb-369f-4699-99e6-21309517cc27
# ╠═7a5c58d1-5456-4ac9-9fb2-fc7d56b2ab79
# ╟─ef133164-bcde-4703-82dc-b5f2617b9364
# ╠═a73a45a0-2cfa-4692-afdf-2e1e7a8e0911
# ╠═a5e82415-35b4-437f-845c-0bbd72d663c4
# ╟─be307943-58e3-4582-97be-295e7b4ab444
# ╠═a2fcecf0-4928-4fd6-beb7-0ca4bbcd4a21
# ╟─e568c32a-4be4-48dc-aef5-5997d57c0557
# ╠═14bd6d6e-cb9d-4c98-bcbb-96ffc452dcfc
# ╟─75f409f1-f937-4dd9-a6e1-df7f557f3329
# ╠═8a63340b-b44c-4b8b-a9ac-59629c2c879c
# ╟─bccb8b0c-1597-465f-9bd0-59bbb80b95ac
# ╟─0e752a46-5d5f-4104-a39a-79115168b39e
# ╠═d26ea4b2-33f6-4afe-b511-0fef49e4630e
# ╟─a7ebd5fe-ddfd-400c-aa45-ab13cb909b4a
# ╟─f8cc2efb-ff19-4c8f-bce1-e70915eee05a
# ╠═4227b15c-d56e-4494-85be-0b029769758c
# ╠═b7244ebe-8a4f-4508-be82-54a2f88c31de
# ╟─098c521d-0ab4-4399-8c36-8bc6258d8fc7
# ╠═c5df75cc-184c-4030-8bd2-3b32c5f318ae
# ╠═231354d8-d603-44a1-aca9-577e5b69faff
# ╟─002784c3-a11f-439a-82be-6b01c69cff2b
# ╠═73a5eedf-a945-4cb9-8635-233686b810bc
# ╠═cf72d1a5-84c8-4963-8833-d1345510d2a3
