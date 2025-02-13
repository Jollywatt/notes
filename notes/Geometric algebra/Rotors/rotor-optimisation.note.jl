### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 74e7ff02-97a0-11ef-1599-2d165c71af12
begin
	using Pkg
	Pkg.develop(url="https://github.com/jollywatt/geometricalgebra.jl")
	Pkg.add(["Plots", "Mooncake"])
	using GeometricAlgebra
	using Mooncake
	using Plots, Test
end

# ╔═╡ 3a4beb90-7ef4-435c-a760-e814fda50b2f
md"""
This notebook shows a simple application of gradient descent to optimise a rotor with respect to a scalar-valued loss function.
"""

# ╔═╡ d95c6473-32cc-4760-b0ec-05daeebd6ea7
md"""

# Rotor optimisation problem statement

Consider a set of ``N`` points ``r_i \in \mathbb{R}^3`` which are transformed by an unknown rotor ``R^\star`` to the points ``R^\star r_i \tilde{R^\star}``.

We observe the "shadows" of each point, that is, the projections of each point in the ``xy``-plane, given by the bivector ``\pi = e_1 e_2``.

Find the rotor ``R^\star`` given the points ``r_i`` and their shadows ``p_i = (R^\star r_i \tilde{R^\star}) \cdot \pi \, \pi^{-1}``.
"""

# ╔═╡ fbc13ba8-bf9c-4105-854d-8583f379bf67
N = 5 # number of points

# ╔═╡ 7a8008a5-f3bd-4a8a-a92a-9e04aba25519
r = Multivector{3,1}.(eachcol(randn(3, N))) # array of points

# ╔═╡ 7933ded8-5591-4907-ad81-39d4ac0e2f7b
R_star = exp(10*Multivector{3,2}(randn(3))) # target multivector

# ╔═╡ c16073d8-d9f2-445e-8b55-084ed216b572
plane = Multivector{3,2}([1,0,0])

# ╔═╡ 6fb427a9-5372-493e-bb43-0697bf36315e
p = @. sandwich_prod(R_star, r)⋅plane⋅inv(plane) # array of point shadows

# ╔═╡ 77a5bbd2-7c09-4201-9e8d-9ff678b031c0
md"""
## Loss function

Define a scalar loss function to measure the mean squared distance between points' projections in the ``xy``-plane and their target shadow points.

```math
{\cal L}(R) = \frac1N \sum_{i=1}^N \left( (R \, r_i \tilde{R})⋅\pi \; \pi^{-1} - p_i \right)^2
```

The change in loss ``δ{\cal L}`` induced by a change ``\delta R`` in the rotor is:
```math
δ{\cal L}(R, δR) = \frac4N \sum_{i=1}^N \left( (R \, r_i \tilde{R})⋅\pi \; \pi^{-1} - p_i \right) ⋅ \left\langle δR \, r_i \tilde{R} \right\rangle_1
```

Using ``δ{\cal L}`` we can optimise ``{\cal L}`` by gradient descent.
"""

# ╔═╡ 1368a403-7f26-494d-8c9d-48de60e1f4ef
loss(R) = N\sum(
	scalar((sandwich_prod(R, r[i])⋅plane⋅inv(plane) - p[i])^2)
	for i in 1:N
)

# ╔═╡ 7c359b61-05c2-4e12-b225-6a5d87247c9f
δloss(R, δR) = N\4sum(
	(sandwich_prod(R, r[i])⋅plane⋅inv(plane) - p[i]) ⊙ grade(δR*r[i]*~R, 1)
	for i in 1:N
)

# ╔═╡ ad961c0a-0ff8-4ea8-8109-d7165c635cae
# run numerical tests to check derivative is correct
let ϵ = 1e-7
	for i in 1:600
		R = Multivector{3,0:2:2}(randn(4))
		δR = Multivector{3,0:2:2}(randn(4))
		@test δloss(R, δR) ≈ (loss(R + ϵ*δR) - loss(R))/ϵ atol=1e-3
	end
end

# ╔═╡ eefcce8b-0e71-40b4-b3c6-bd0f92073197
md"""
### Gradient of the loss function

Given the directional derivative `δloss(R, δR)`, we can obtain the gradient `∇loss(R)` as
```math
\nabla {\cal L}(R) = \sum_{I} e_I \, \delta {\cal L}(R, e_I)
```
where ``\{e_I\} = \{1, e_{23}, e_{31}, e_{12}\}`` are basis blades spanning the rotor supspace. 
"""

# ╔═╡ 34e17266-44f5-4997-9757-0af42f6ab02e
∇loss_manual(R) = let M = Multivector{3,0:2:2}
	δR = M.([i .== 1:4 for i in 1:4])
	M(δloss.(R, δR))
end

# ╔═╡ 15a32897-26fa-40f5-a58e-efb171819b19
md"""
### Automatically differentiating the loss function

We can use [Mooncake.jl](https://compintell.github.io/Mooncake.jl/) to compute the gradient directly using reverse mode automatic differentation.
"""

# ╔═╡ b8a51f0c-4d45-484c-b1e9-09467637089f
rule = build_rrule(loss, R_star)

# ╔═╡ 5a4168f4-1df4-4111-8937-706ec5f35479
∇loss_auto(R) = let (value, grad) = value_and_gradient!!(rule, loss, R)
	typeof(R)(grad[2].fields.comps.fields.data.tangent)
end

# ╔═╡ 723f08d2-c522-4883-93d5-35097347bb95
# check that hand-written and autodiff gradients agree
for _ in 1:100
	R = typeof(R_star)(randn(ncomponents(R_star)))
	@test ∇loss_auto(R) ≈ ∇loss_manual(R)
end

# ╔═╡ 3757144f-7f3c-4481-b1bf-edfc08a1ebee
md"""

## Gradient descent

Knowing the directional derivative of ``{\cal L}(R)``, we can form the gradient of ``{\cal L}`` as
```math
\partial {\cal L}(R) = \sum_I e_I \, \delta {\cal L}(R, e_I)
```
which is the even multivector which maximises ``\frac{\mathrm{d}}{\mathrm{d}\varepsilon} {\cal L}\left(R + \varepsilon\,\partial {\cal L}(R)\right)``.
"""

# ╔═╡ 18d5e36a-bf96-4bdc-a5c0-bb1822ec693a
function train(R; stepsize=0.08, iterations=50)
	losses = Float64[]
	for i in 1:iterations
		push!(losses, loss(R))
		δR = -stepsize*∇loss_auto(R)
		R += δR
	end
	(final_rotor=R, final_loss=last(losses), losses)
end

# ╔═╡ 32c8d7a7-a164-43b8-beed-123201a54f2d
R = exp(10*Multivector{3,2}(randn(3))) # random initial guess

# ╔═╡ 7ceb6e16-f47e-4440-bdb9-11d280932904
results = train(R)

# ╔═╡ afb23268-d58d-457f-a80c-fc45563e4cf1
log(results.final_loss)

# ╔═╡ c5430978-88e0-4d42-a74e-e7c256a0dab7
begin
	plot(results.losses, label="training loss", yaxis=:log10)
	xlabel!("steps")
	ylims!(1e-6, 1e1)
end

# ╔═╡ Cell order:
# ╟─3a4beb90-7ef4-435c-a760-e814fda50b2f
# ╠═74e7ff02-97a0-11ef-1599-2d165c71af12
# ╟─d95c6473-32cc-4760-b0ec-05daeebd6ea7
# ╠═fbc13ba8-bf9c-4105-854d-8583f379bf67
# ╠═7a8008a5-f3bd-4a8a-a92a-9e04aba25519
# ╠═7933ded8-5591-4907-ad81-39d4ac0e2f7b
# ╠═c16073d8-d9f2-445e-8b55-084ed216b572
# ╠═6fb427a9-5372-493e-bb43-0697bf36315e
# ╟─77a5bbd2-7c09-4201-9e8d-9ff678b031c0
# ╠═1368a403-7f26-494d-8c9d-48de60e1f4ef
# ╠═7c359b61-05c2-4e12-b225-6a5d87247c9f
# ╠═ad961c0a-0ff8-4ea8-8109-d7165c635cae
# ╟─eefcce8b-0e71-40b4-b3c6-bd0f92073197
# ╠═34e17266-44f5-4997-9757-0af42f6ab02e
# ╟─15a32897-26fa-40f5-a58e-efb171819b19
# ╠═b8a51f0c-4d45-484c-b1e9-09467637089f
# ╠═5a4168f4-1df4-4111-8937-706ec5f35479
# ╠═723f08d2-c522-4883-93d5-35097347bb95
# ╟─3757144f-7f3c-4481-b1bf-edfc08a1ebee
# ╠═18d5e36a-bf96-4bdc-a5c0-bb1822ec693a
# ╠═32c8d7a7-a164-43b8-beed-123201a54f2d
# ╠═7ceb6e16-f47e-4440-bdb9-11d280932904
# ╠═afb23268-d58d-457f-a80c-fc45563e4cf1
# ╠═c5430978-88e0-4d42-a74e-e7c256a0dab7
