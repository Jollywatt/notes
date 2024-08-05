### A Pluto.jl notebook ###
# v0.20.5

using Markdown
using InteractiveUtils

# ╔═╡ 4f3a9940-f846-40c2-bfe7-1fc69c42b11e
begin
	using Pkg
	Pkg.activate(temp=true)
	Pkg.add(url="https://github.com/Jollywatt/GeometricAlgebra.jl")
	Pkg.add(["Mooncake", "Plots"])
end

# ╔═╡ d8eb66b5-4bf9-4516-98ea-ccd90c581627
using GeometricAlgebra, Mooncake

# ╔═╡ aa6ec2e2-31b5-4dc3-b11f-e1007d24fa0f
using Plots

# ╔═╡ 803c5ac1-837a-4ea2-82ca-1e5a885ec9c5
md"""
# Backprop for a GA-based NN in Julia

We use [GeometricAlgebra.jl](https://github.com/Jollywatt/GeometricAlgebra.jl) and [Mooncake.jl](https://github.com/compintell/Mooncake.jl) for automatic differentiation.
"""

# ╔═╡ d685ef1c-f3d8-4add-9b91-c1ec0e0dfb5d
md"""
A simple "sandwich product" densely connected layer:
"""

# ╔═╡ 53b98188-63bf-4283-a353-ce1f416eb189
function sandwich_matmul(A, x)
	@assert axes(A, 2) == axes(x, 1)
	y = zeros(eltype(x), axes(A, 1))
	for i in axes(A, 1)
		for j in axes(A, 2)
			y[i] += sandwich_prod(A[i,j], x[j])
		end
		y[i] /= sqrt(1 + abs(y[i]⊙y[i])) # an ad-hoc normalisation
	end
	y		
end

# ╔═╡ ff860481-a95a-4b0a-9d6d-66ede50bbe97
begin
	struct Dense{W<:AbstractMatrix,B}
		weight::W
		bias::B
	end
	function (layer::Dense)(input::AbstractVector)
		sandwich_matmul(layer.weight, input) .+ layer.bias
	end
end

# ╔═╡ 7ee1692a-e120-4160-955c-37e7d12a8c8e
function randlayer((indim, outdim)::Pair)
	weighttype = Multivector{3,0:2:3,Vector{Float32}}
	biastype = Multivector{3,1,Vector{Float32}}
	Dense(randn(weighttype, outdim, indim), randn(biastype, outdim))
end

# ╔═╡ 66200986-7693-4c4e-ba9d-988ef5113ddf
md"""
`Chain` represents a composition of layers:
"""

# ╔═╡ e0d0e8b7-a8ff-4e66-932f-593419a4f2a5
begin
	struct Chain{L}
		layers::L
	end
	(c::Chain)(input) = foldl((x, f) -> f(x), c.layers; init=input)
end

# ╔═╡ 78a20796-e9bf-4291-843a-403fbc785f81
md"""
## Making a small model

Let's implement a simple dense network with ``2`` hidden layers with layer sizes ``1 \to 5 \to 7 \to 1``.
The input and output to the network is a vector in ``\mathbb{R}^3``.
Each layer's weights are even multivectors ``R`` in ``Cl(3)`` which act on input vectors via the sandwich product ``u \mapsto R u \tilde R + b`` with some bias ``b \in \mathbb{R}^3``.

"""

# ╔═╡ ced4b1b0-ab6c-4a8f-a5dc-a409f8ddf5d7
chain = Chain([randlayer(1 => 5), randlayer(5 => 7), randlayer(7 => 1)])

# ╔═╡ b08ff07b-0cf0-4bde-a133-ae9bb8198906
applymodel(chain::Chain, input::Multivector) = first(chain([input]))::Multivector

# ╔═╡ b2cf52a0-eae6-4510-b496-680a1f645de5
md"""
### _Inference:_ evaluating the model on input
"""

# ╔═╡ fbab63fa-efb8-445f-a312-9a9667c263ea
inference(input::Multivector) = applymodel(chain, input)

# ╔═╡ 6f0a98a1-9bde-40f5-825f-4e313e2262ee
inference(Multivector{3,1}(1.0, 0, 0))

# ╔═╡ bb69ea7e-15cf-4fc5-9c3c-8967fead2083
md"""
### _Loss:_ parameters as input, training data fixed

We want to find the gradient of the loss ``\mathcal{L}(\theta)`` with respect to model parameters ``\theta``, fixing the testing data ``X`` and training data ``Y``.
In our case, each piece of training data ``x`` is a vector which is rotated to ``y = R x \tilde R`` by some target rotor ``R`` which we want our model to approximate.
"""

# ╔═╡ c3bc1fed-6865-4cd1-b0de-c85f48fd5ce6
X = randn(Multivector{3,1}, 100)

# ╔═╡ ad82d2a6-c9d5-4510-a661-105b2967bf7b
target_rotor = exp(Multivector{3,2}(pi/4, 0, 0))

# ╔═╡ 7ebca646-bcba-4a23-a257-6f44070e32dc
Y = sandwich_prod.(target_rotor, X)

# ╔═╡ cbb32d1c-a037-4a01-b5db-222638ab9644
function loss(chain::Chain)
	Ŷ = [applymodel(chain, x) for x in X]
	sum(scalar, (Y .- Ŷ).^2)/length(X)
end

# ╔═╡ 15e05768-274b-4da4-b7ad-abb9b434e064
md"""
### Automatically differentiating the loss

With Mooncake, you first compute the derivative "rule" (this is slow but happens once) and then evaluate it on some input (this is fast and works on different inputs of the same type).
"""

# ╔═╡ 981a4299-0c53-453a-886d-da684090a122
rule = Mooncake.build_rrule(loss, chain)

# ╔═╡ 476e1c35-3cd7-44c6-b85a-81ef1f2040b7
l, ∇ = Mooncake.value_and_gradient!!(rule, loss, chain)

# ╔═╡ 25cae207-55a9-4c4c-bb8f-9c8bd7fb2007
md"""
The value of the loss is `l` and the gradient is `∇`.
Remember that `layers` is a `Chain` struct containing many `Dense` structs, each containing a matrix of `Multivector`s (which in turn contain vectors of components).
In order to differentiate with respect to each component of each `Multivector` in each `Dense` layer in the `Chain`, Mooncake creates a deeply nested `Tangent` object.
It requires a little work to traverse this nested gradient object in order to update the model parameters.
"""

# ╔═╡ 55d4885a-7af1-4344-9098-83ce54eb196b
md"""
For example, the gradient with respect to the components of the multivector in the ``(6,4)`` position in the ``2``nd layer's weight matrix is:
"""

# ╔═╡ 1364203d-ba3a-4788-8af0-6e00ba2699bd
∇[2].fields.layers[2].fields.weight[6,4].fields.comps
#   ^ Chain          ^ Dense            ^ Multivector

# ╔═╡ ea22d976-087e-45fa-86d2-f1a7b7ccf6f7
md"""
### Gradient descent

To apply a gradient descent step, you need to go over all the components in the gradient and add them to the components in your model.
"""

# ╔═╡ 307a8288-9e9a-4bd6-9ac3-05a99a1a8284
function step!(chain; stepsize)
	l, ∇ = Mooncake.value_and_gradient!!(rule, loss, chain)
	for i in eachindex(chain.layers)
		layer = chain.layers[i]
		∇layer = ∇[2].fields.layers[i]
		for j in eachindex(chain.layers[i].weight)
			comps = layer.weight[j].comps
			∇comps = ∇layer.fields.weight[j].fields.comps
			comps .+= -∇comps*stepsize
		end
	end
end

# ╔═╡ f2599bdc-47e8-420d-aeb4-6db5c90cdf40
function train(chain; stepsize, steps)
	losses = Float64[]
	for _ in 1:steps
		push!(losses, loss(chain))
		step!(chain; stepsize)
	end
	losses
end

# ╔═╡ eaef5b82-5da0-4f0b-8d67-23c8a6195af0
losses = let c = Chain([randlayer(1 => 5), randlayer(5 => 7), randlayer(7 => 1)])
	train(c; stepsize=1e-2, steps=200)
end

# ╔═╡ 17065efb-4c7f-40e9-958b-360464024142
plot(losses, label=nothing, xlabel="steps", ylabel="loss")

# ╔═╡ 225565ca-3d94-4882-be63-ef37e16a5f53
md"""
It works! 🥂
"""

# ╔═╡ 2bbaf384-8f9f-4f97-bc4b-5b5948a861be
HTML("<br>"^30)

# ╔═╡ Cell order:
# ╟─803c5ac1-837a-4ea2-82ca-1e5a885ec9c5
# ╠═d8eb66b5-4bf9-4516-98ea-ccd90c581627
# ╟─d685ef1c-f3d8-4add-9b91-c1ec0e0dfb5d
# ╠═ff860481-a95a-4b0a-9d6d-66ede50bbe97
# ╠═53b98188-63bf-4283-a353-ce1f416eb189
# ╠═7ee1692a-e120-4160-955c-37e7d12a8c8e
# ╟─66200986-7693-4c4e-ba9d-988ef5113ddf
# ╠═e0d0e8b7-a8ff-4e66-932f-593419a4f2a5
# ╟─78a20796-e9bf-4291-843a-403fbc785f81
# ╠═ced4b1b0-ab6c-4a8f-a5dc-a409f8ddf5d7
# ╠═b08ff07b-0cf0-4bde-a133-ae9bb8198906
# ╟─b2cf52a0-eae6-4510-b496-680a1f645de5
# ╠═fbab63fa-efb8-445f-a312-9a9667c263ea
# ╠═6f0a98a1-9bde-40f5-825f-4e313e2262ee
# ╟─bb69ea7e-15cf-4fc5-9c3c-8967fead2083
# ╠═c3bc1fed-6865-4cd1-b0de-c85f48fd5ce6
# ╠═7ebca646-bcba-4a23-a257-6f44070e32dc
# ╠═ad82d2a6-c9d5-4510-a661-105b2967bf7b
# ╠═cbb32d1c-a037-4a01-b5db-222638ab9644
# ╟─15e05768-274b-4da4-b7ad-abb9b434e064
# ╠═981a4299-0c53-453a-886d-da684090a122
# ╠═476e1c35-3cd7-44c6-b85a-81ef1f2040b7
# ╟─25cae207-55a9-4c4c-bb8f-9c8bd7fb2007
# ╟─55d4885a-7af1-4344-9098-83ce54eb196b
# ╠═1364203d-ba3a-4788-8af0-6e00ba2699bd
# ╟─ea22d976-087e-45fa-86d2-f1a7b7ccf6f7
# ╠═307a8288-9e9a-4bd6-9ac3-05a99a1a8284
# ╠═f2599bdc-47e8-420d-aeb4-6db5c90cdf40
# ╠═eaef5b82-5da0-4f0b-8d67-23c8a6195af0
# ╠═aa6ec2e2-31b5-4dc3-b11f-e1007d24fa0f
# ╠═17065efb-4c7f-40e9-958b-360464024142
# ╟─225565ca-3d94-4882-be63-ef37e16a5f53
# ╟─2bbaf384-8f9f-4f97-bc4b-5b5948a861be
# ╠═4f3a9940-f846-40c2-bfe7-1fc69c42b11e
