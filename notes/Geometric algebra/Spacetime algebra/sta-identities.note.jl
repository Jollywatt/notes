### A Pluto.jl notebook ###
# v0.20.20

#> [frontmatter]
#> title = "Spacetime algebra identities"

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 41233f52-34f3-11ef-0c90-a1e34bea294d
# ╠═╡ show_logs = false
begin
	import Pkg
	# Pkg.add.(["OffsetArrays", "PlutoUI"])
	# Pkg.develop(url="/Users/josephwilson/Documents/GeometricAlgebra.jl")
	Pkg.activate("..")

	using Test, PlutoUI
	using OffsetArrays: OffsetVector
	using GeometricAlgebra
end

# ╔═╡ 5aefc3f4-b947-41e4-af2a-71694b65779d
md"""
# Spacetime algebra identities

This file contains tests for various simple algebraic identities in the spacetime algebra, which hold in either spacetime sign convention.
"""

# ╔═╡ 1faaf237-3950-40c0-a415-90875b50f328
md"""
## Setup code
"""

# ╔═╡ f3a341c2-cdf8-47b3-a06d-e48aee5f5fe6
PlutoUI.TableOfContents()

# ╔═╡ 781b4737-7e82-4b28-a762-b92f0b71326d
sta_style = BasisDisplayStyle(4, indices=0:3, prefix="γ", Dict(
	2 => [1 .+ i for i in [[0,1], [0,2], [0,3], [2,3], [3,1], [1,2]]]
));

# ╔═╡ d809e31e-6c18-42fb-b655-ce5070b2a4af
md"""
Spacetime algebra metric signature:
"""

# ╔═╡ aef33fa6-4c42-4cda-840d-9485207e1cfd
slider = @bind STA Slider([Cl("+---"), Cl("-+++")], show_value=true)

# ╔═╡ 849e2f37-3cfe-4c32-ad18-0e08ded93a6b
GeometricAlgebra.BASIS_DISPLAY_STYLES[STA] = sta_style;

# ╔═╡ 7ed2f6fd-81b0-4dfe-92bd-02a292006170
md"""
## Definitions

- Define the spacetime basis vectors ``\gamma_\mu`` and ``\gamma^\mu = \gamma_\mu^{-1}``.
- Define the pseudoscalar ``I = \gamma_0, \gamma_1, \gamma_2, \gamma_3``.
- Define the relative basis vectors ``\sigma_i \coloneqq \gamma_i \gamma^0``.
"""

# ╔═╡ f9c6908d-96bf-4bdb-9e51-8bddbb646cec
γ = OffsetVector(basis(STA, 1), 0:3);

# ╔═╡ 9f29c2f1-ec7d-458d-85d5-e7825551c630
σ = [γ[i]*inv(γ[0]) for i=1:3];

# ╔═╡ 6a496a09-dfa5-4660-87a6-0da8be23e500
I = prod(γ);

# ╔═╡ 62849dcd-8028-416c-a3d6-952922853d75
md"""
Then:
```math
\begin{align}
\sigma_i^2 &= 1 \\
I &= \sigma_1 \sigma_2 \sigma_3 = \sigma^1 \sigma^2 \sigma^3 \\
I &= \gamma_0 \gamma_1 \gamma_2 \gamma_3 = -\gamma^0 \gamma^1 \gamma^2 \gamma^3 \\
\end{align}
```
"""

# ╔═╡ e04f66df-b714-42fd-8e0e-0cb69ab81648
begin
	@test all(σ[i]^2 == 1 for i=1:3)
	@test I == prod(σ) == prod(inv.(σ))
	@test I == prod(γ) == -prod(inv.(γ))
end

# ╔═╡ 5833bb59-547e-4a0f-b55f-210459d8a4a8
md"""
## Bivector commutator and vector cross product

For any relative vectors ``u`` and ``v``:
```math
\langle u v \rangle_2 = (u \times v)I
= \frac12(u v - v u)
```
"""

# ╔═╡ 35dc6b19-d6a9-419c-a005-1faf7470e424
begin
	import LinearAlgebra: cross
	function cross(a::Multivector{Sig,2}, b::Multivector{Sig,2}) where Sig
		grade(a*b, 2)/I
	end
end

# ╔═╡ aaf8ca22-b504-4607-9ea5-eebce7e11998
for _ in 1:100
	u, v = randn(3), randn(3)
	U, V = u'σ, v'σ
	@test grade(U*V, 2) == cross(u, v)'σ*I
	@test cross(U, V) == cross(u, v)'σ
	@test grade(U*V, 2) == (U*V - V*U)/2
end

# ╔═╡ ac132f38-bb49-45fe-9ba5-e799903693f4
md"""
## (Anti-)commutative decompositions

A multivector ``X`` can be decomposed into parts which commute or anti-commute with an invertible reference multivector ``a`` with scalar square.

```math
X_\pm = \frac12(X \pm a X a^{-1}) \implies X_\pm a = \pm a X_\pm
```
"""

# ╔═╡ 5d86c720-7f35-40b9-9059-50985f0293ab
proj(X, a) = grade((X + a*X/a)/2, grade(X))

# ╔═╡ f1d03b6c-08fe-44de-948e-5c3a160c3ecf
rej(X, a) = grade((X - a*X/a)/2, grade(X))

# ╔═╡ 469e8b6f-4e10-45de-a115-52b8febe834e
for _ in 1:100
	X = Multivector{STA,0:4}(randn(16))
	for a in [
		randn(4)'γ # spacetime vector
		randn(3)'σ # relative vector
	]
		X₊, X₋ = proj(X, a), rej(X, a)
		@test X₊ + X₋ ≈ X  atol=1e-10
		@test X₊*a ≈ +a*X₊
		@test X₋*a ≈ -a*X₋ atol=1e-10
	end
end

# ╔═╡ b6461e6d-938b-4a54-afc0-b209be95356d
md"""
## Lorentz boosts

If ``\tanh\vec{\alpha} = \vec{\beta} = \vec{v}/c``, then
```math
e^\vec{\alpha} = \gamma(1 + \vec{\beta})
```
where ``\gamma = \cosh\alpha = (1 - \beta^2)^{-1/2}``.
"""

# ╔═╡ 5f467d33-0672-47b9-81d3-baf6dd108a27
for _ in 1:100
	β = rand() # relativistic velocity
	α = atanh(β) # rapidity
	λ = cosh(α) # lorentz factor
	
	# boost direction
	n = randn(3)'σ
	n /= sqrt(n⊙n)
	@test n^2 ≈ 1

	β⃗ = β*n
	α⃗ = α*n

	@test exp(α⃗) ≈ λ*(1 + β⃗)
end

# ╔═╡ 80db37fa-39c4-4dde-9e0d-277d476f2a7e
md"""
### Boost versor properties

```math
\begin{align}
\mathtt{B}_ζ[x_\perp + x_\parallel] &= x_\perp + (\cosh ζ + e_0 \sinh ζ) x_\parallel
\\ &= x_\perp + x_\parallel \cosh ζ + e_0 (x_\parallel ⋅ \sinh ζ)
\\
\mathtt{B}_ζ[e_0] &= e_0 \cosh ζ + \sinh ζ
\end{align}
```
Note that ``\sinh ζ`` is a vector but ``\cosh ζ`` is a scalar!
"""

# ╔═╡ 1d12c2fa-8961-4c7e-9e70-40f55f51a4db
boost(ζ) = exp(2\γ[0]∧ζ)

# ╔═╡ 9239a19b-a7b1-4af0-8977-c5f540d5d51a
boost(ζ, X) = sandwich_prod(boost(ζ), X)

# ╔═╡ 9b840fb8-63f4-460d-8e07-a36af7445efe
slider

# ╔═╡ db2cf396-d2fa-4f06-923d-c2ebdb5b7e55
for _ in 1:100
	ζ = randn(3)'γ[1:3]
	x = randn(3)'γ[1:3]
	x_proj = (x⋅ζ)∧inv(ζ)
	x_rej = (x∧ζ)⋅inv(ζ)
	@test boost(ζ, x_rej) ≈ x_rej
	if STA == Cl("-+++")
		@test boost(ζ, x_proj) ≈ x_proj*cosh(ζ) + γ[0]*(x_proj⊙sinh(ζ))
		@test boost(ζ, x_proj) ≈ (cosh(ζ) + γ[0]*sinh(ζ))*x_proj
		@test boost(ζ, γ[0]) ≈ γ[0]cosh(ζ) + sinh(ζ)
	else
		@test boost(ζ, x_proj) ≈ x_proj*cos(ζ) + γ[0]*(x_proj⊙sin(ζ))
		@test boost(ζ, x_proj) ≈ (cos(ζ) + γ[0]*sin(ζ))*x_proj
		@test boost(ζ, γ[0]) ≈ γ[0]cos(ζ) - sin(ζ)
	end
end

# ╔═╡ 52ff3022-153b-45b3-baf8-907aef598cc2
md"""
### Lorentz boost of bivector

If ``\psi = \exp(\vec{\alpha}/2)`` defines a boost, then:
```math
F' = \psi F \tilde{\psi} = [E_+ + \gamma(E_- - \beta \times B_-)] + [B_+ + \gamma(B_- + \beta \times E_-)] I
```
where ``\vec{\beta} = \tanh \vec{\alpha}``.
"""

# ╔═╡ db6d4721-bfac-4f04-beb8-f0b8d555553c
for _ in 1:100
	F = Multivector{STA,2}(randn(6))

	E = grade((F⋅γ[0])/γ[0], 2)
	B = grade((F∧γ[0])/γ[0]/I, 2)
	@test F ≈ E + B*I

	β = rand() # relativistic velocity
	α = atanh(β) # rapidity
	λ = cosh(α) # lorentz factor
	
	# boost direction
	n = randn(3)'σ
	n /= sqrt(n⊙n)
	@test n^2 ≈ 1

	E₊, E₋ = proj(E, n), rej(E, n)
	B₊, B₋ = proj(B, n), rej(B, n)
	
	β⃗ = β*n
	α⃗ = α*n

	ψ = exp(α⃗/2)
	F′ = ψ*F*~ψ
	
	@test F′ ≈ (E₊ + λ*(E₋ - cross(β⃗, B₋))) + (B₊ + λ*(B₋ + cross(β⃗, E₋)))*I
end

# ╔═╡ 78e9bb4e-bd41-4a04-a6f3-0f84a9f12ef0
md"""
### Change of spacetime split

A spacetime bivector decomposes with respect to the choice of time ``\gamma_0`` as ``F = E + B I`` where
```math
\begin{align}
E &= (F \cdot \gamma_0) \gamma^0 \\
BI &= (F \wedge \gamma_0) \gamma^0 \\
\end{align}
```
For a different choice of time, ``\bar{\gamma}_0 = \psi \gamma_0 \tilde{\psi} = \psi^2 \gamma_0 = \gamma (1 + \vec{\beta})\gamma_0``, we have ``F = \bar{E} + \bar{B} I`` where
```math
\begin{align}
\bar{E} &= E_\parallel + B_\perp I + (E_\perp - B_\perp I)[1 + \vec{\beta}]^{-1} \\
\bar{B}I &= E_\perp + B_\parallel I - (E_\perp - B_\perp I)[1 + \vec{\beta}]^{-1} \\
\bar{E} &= E_\parallel + E_\perp [1 + \vec{\beta}]^{-1} + B_\perp I (1 - [1 + \vec{\beta}]^{-1}) \\
\bar{B}I &= B_\parallel I + B_\perp I [1 + \vec{\beta}]^{-1} + E_\perp (1 - [1 + \vec{\beta}]^{-1}) \\
\end{align}
```
"""

# ╔═╡ e6ca7d06-e0e5-4b12-8eef-268b2151e77c
for _ in 1:100
	F = Multivector{STA,2}(randn(6))
	
	E = grade((F⋅γ[0])/γ[0], 2)
	B = grade((F∧γ[0])/γ[0]/I, 2)
	@test F ≈ E + B*I

	β = rand() # relativistic velocity
	α = atanh(β) # rapidity
	λ = cosh(α) # lorentz factor
	
	# boost direction
	n = randn(3)'σ
	n /= sqrt(n⊙n)
	@test n^2 ≈ 1
	
	E₊, E₋ = proj(E, n), rej(E, n)
	B₊, B₋ = proj(B, n), rej(B, n)

	β⃗ = β*n
	α⃗ = α*n

	ψ = exp(α⃗/2)
	γ̄ = ψ.*γ.*~ψ

	Ē = grade((F⋅γ̄[0])/γ̄[0], 2)
	B̄ = grade((F∧γ̄[0])/γ̄[0]/I, 2)

	κ = inv(1 + β⃗)
	@test Ē   ≈ E₊ + B₋*I + (E₋ - B₋*I)*κ
	@test B̄*I ≈ E₋ + B₊*I - (E₋ - B₋*I)*κ

	@test Ē   ≈ E₊   + E₋  *κ + B₋*I*(1 - κ)
	@test B̄*I ≈ B₊*I + B₋*I*κ + E₋  *(1 - κ)
end

# ╔═╡ 60e3c04a-28fa-40ea-a430-28e8d9a0b132
md"""
### Unboosting blades

Let ``\mathtt{B}_ζ`` denote a boost with rapidity vector ``ζ ∈ ℝ^n``
```math
\mathtt{B}_ζ = e^{\frac12γ_0ζ},
\qquad
\mathtt{B}_ζ[X] = e^{\frac12γ_0ζ} X e^{\frac12ζγ_0}.
```
"""

# ╔═╡ 35857b0f-0435-4d64-ad0c-23af04af21a2
md"""
If ``x = \vec x + x_0 e_0`` is a spacelike vector, ``x^2 > 0``, then
```math
x = \mathtt{B}_{ζ \hat n}\big[\|x\| \hat n\big]
```
where ``\|x\| = \sqrt{x^2}`` and ``\hat n = \vec x/\|\vec x\|`` and ``\zeta = \operatorname{arctanh}(x_0/\|\vec x\|)``.
"""

# ╔═╡ 0e9ad5ea-cfb0-4808-9b34-532adcd2759e
slider

# ╔═╡ 4dc372b6-9c85-4905-bed9-9714715f019d
for _ in 1:100
	x⃗ = randn(3)'γ[1:3]
	norm = √abs(x⃗⊙x⃗)
	x₀ = rand((+1,-1))rand()norm
	x = x⃗ + x₀*γ[0]
	if STA == Cl("-+++")
		ζ = atanh(x₀/norm)
		@test x⊙x > 0
	else
		ζ = -atanh(x₀/norm)
		@test x⊙x < 0
	end
	n̂ = x⃗/norm
	@test boost(ζ*n̂, √abs(x⊙x)*n̂) ≈ x
end

# ╔═╡ 9e81075e-706a-4e17-aa2d-a04311b501ba
md"""
If ``X = \mathtt{B}_ζ[E]`` is a spacelike blade (a boosted Euclidean blade ``E`` with rapidity vector ``ζ``) then
```math
\begin{align}
μ &= \frac12(γ_0 + \widehat{X} γ_0 X^{-1}) \\
ζ' &= \text{arctanh}\left(\frac{(μ∧γ_0)⋅γ_0}{μ⋅γ_0}\right) \\
E' &= \mathtt{B}_{-ζ'}[X]
\end{align}
```
satisfies ``X = \mathtt{B}_ζ[E] = \mathtt{B}_{ζ'}[E']``.
"""

# ╔═╡ d51e74de-4a48-44ce-922f-1c16919f55fa
ζ₀ = randn(3)'γ[1:3];

# ╔═╡ 1c258f88-93e6-4555-be08-9419026a85c7
md"Spacelike blade:"

# ╔═╡ 03a17100-ee7e-45cd-b4b2-bc53355ec5ab
@bind k Slider(1:3, show_value=true)

# ╔═╡ 1a6b32e6-c83c-47c5-a6fc-504a823b49f8
E₀ = wedge(randn(3, k)'γ[1:3]...)

# ╔═╡ b6d8ad33-596b-444c-9bcb-3687c8fd012c
md"Boosted spacelike blade:"

# ╔═╡ d942e2d9-197b-42d3-ba27-770fc2526634
X = boost(ζ₀, E₀);

# ╔═╡ 1c117b9d-2fbb-4615-9e7e-4088b2e12250
refl(X, u::Grade{1}) = grade(involution(X)*u*inv(X), 1)

# ╔═╡ af4165f9-06fb-40dd-9090-4530bf0b67a5
µ = 2\(γ[0] + refl(X, γ[0]));

# ╔═╡ 51e0e6b8-e88a-48a0-82dd-6a6448205f6e
@test µ⋅X ≈ 0 atol=1e-12

# ╔═╡ 338ca0c4-72d6-480a-82aa-3929e05647db
slider

# ╔═╡ 4fcf3b39-0fda-49c2-bdad-6dbf92cde737
ζ = if STA == Cl("-+++")
	atanh((µ∧γ[0])⋅inv(γ[0])/µ.comps[1])
else
	-atan((µ∧γ[0])⋅inv(γ[0])/µ.comps[1])
end

# ╔═╡ 6a3de235-b720-49d1-91fc-033cc5350e54
@test ζ⋅γ[0] == 0

# ╔═╡ 63e07fb2-4ea8-4d3d-9698-c7da3187e264
E = boost(-ζ, X);

# ╔═╡ 199582ca-e97a-4fc9-8ee2-5f077cd607e9
@test boost(ζ, γ[0]) ≈ µ/√abs(µ⊙µ)

# ╔═╡ 91661286-b5d4-4116-9c2a-5d9a4e59e9da
@test E⋅γ[0] ≈ 0 atol=1e-14

# ╔═╡ c2359b7c-cf0d-4f24-bf91-872cce918d06
@test X ≈ boost(ζ, E)

# ╔═╡ 8021bcf3-9b05-47a0-99a4-c3b037a3058b
@test ζ∧E ≈ 0 atol=1e-12

# ╔═╡ a29672bb-44cf-4fbe-b58c-f5857e5815c4
md"""
In the `-+++` signature:
```math
e^{e_0 \zeta} e_0 = e_0 \cosh(ζ) + \sinh(\zeta)
```
In the `+---` signature:
```math
e^{e_0 \zeta} e_0 = e_0 \cos(ζ) - \sin(\zeta)
```
"""

# ╔═╡ 8d312d85-1e91-450a-b301-7b2353dd187f
slider

# ╔═╡ 585bbf68-20ed-4bdd-b4ec-05d988bdef72
@test if STA == Cl("-+++")
	exp(γ[0]∧ζ)γ[0] ≈ γ[0]cosh(ζ) + sinh(ζ)
else
	exp(γ[0]∧ζ)γ[0] ≈ γ[0]cos(ζ) - sin(ζ)
end

# ╔═╡ Cell order:
# ╟─5aefc3f4-b947-41e4-af2a-71694b65779d
# ╟─1faaf237-3950-40c0-a415-90875b50f328
# ╠═41233f52-34f3-11ef-0c90-a1e34bea294d
# ╠═f3a341c2-cdf8-47b3-a06d-e48aee5f5fe6
# ╠═781b4737-7e82-4b28-a762-b92f0b71326d
# ╟─d809e31e-6c18-42fb-b655-ce5070b2a4af
# ╟─aef33fa6-4c42-4cda-840d-9485207e1cfd
# ╠═849e2f37-3cfe-4c32-ad18-0e08ded93a6b
# ╟─7ed2f6fd-81b0-4dfe-92bd-02a292006170
# ╠═f9c6908d-96bf-4bdb-9e51-8bddbb646cec
# ╠═9f29c2f1-ec7d-458d-85d5-e7825551c630
# ╠═6a496a09-dfa5-4660-87a6-0da8be23e500
# ╟─62849dcd-8028-416c-a3d6-952922853d75
# ╠═e04f66df-b714-42fd-8e0e-0cb69ab81648
# ╟─5833bb59-547e-4a0f-b55f-210459d8a4a8
# ╠═35dc6b19-d6a9-419c-a005-1faf7470e424
# ╠═aaf8ca22-b504-4607-9ea5-eebce7e11998
# ╟─ac132f38-bb49-45fe-9ba5-e799903693f4
# ╠═5d86c720-7f35-40b9-9059-50985f0293ab
# ╠═f1d03b6c-08fe-44de-948e-5c3a160c3ecf
# ╠═469e8b6f-4e10-45de-a115-52b8febe834e
# ╟─b6461e6d-938b-4a54-afc0-b209be95356d
# ╠═5f467d33-0672-47b9-81d3-baf6dd108a27
# ╟─80db37fa-39c4-4dde-9e0d-277d476f2a7e
# ╠═1d12c2fa-8961-4c7e-9e70-40f55f51a4db
# ╠═9239a19b-a7b1-4af0-8977-c5f540d5d51a
# ╟─9b840fb8-63f4-460d-8e07-a36af7445efe
# ╠═db2cf396-d2fa-4f06-923d-c2ebdb5b7e55
# ╟─52ff3022-153b-45b3-baf8-907aef598cc2
# ╠═db6d4721-bfac-4f04-beb8-f0b8d555553c
# ╟─78e9bb4e-bd41-4a04-a6f3-0f84a9f12ef0
# ╠═e6ca7d06-e0e5-4b12-8eef-268b2151e77c
# ╟─60e3c04a-28fa-40ea-a430-28e8d9a0b132
# ╟─35857b0f-0435-4d64-ad0c-23af04af21a2
# ╠═0e9ad5ea-cfb0-4808-9b34-532adcd2759e
# ╠═4dc372b6-9c85-4905-bed9-9714715f019d
# ╟─9e81075e-706a-4e17-aa2d-a04311b501ba
# ╠═d51e74de-4a48-44ce-922f-1c16919f55fa
# ╟─1c258f88-93e6-4555-be08-9419026a85c7
# ╠═03a17100-ee7e-45cd-b4b2-bc53355ec5ab
# ╠═1a6b32e6-c83c-47c5-a6fc-504a823b49f8
# ╟─b6d8ad33-596b-444c-9bcb-3687c8fd012c
# ╠═d942e2d9-197b-42d3-ba27-770fc2526634
# ╠═1c117b9d-2fbb-4615-9e7e-4088b2e12250
# ╠═af4165f9-06fb-40dd-9090-4530bf0b67a5
# ╠═51e0e6b8-e88a-48a0-82dd-6a6448205f6e
# ╟─338ca0c4-72d6-480a-82aa-3929e05647db
# ╠═4fcf3b39-0fda-49c2-bdad-6dbf92cde737
# ╠═6a3de235-b720-49d1-91fc-033cc5350e54
# ╠═63e07fb2-4ea8-4d3d-9698-c7da3187e264
# ╠═199582ca-e97a-4fc9-8ee2-5f077cd607e9
# ╠═91661286-b5d4-4116-9c2a-5d9a4e59e9da
# ╠═c2359b7c-cf0d-4f24-bf91-872cce918d06
# ╠═8021bcf3-9b05-47a0-99a4-c3b037a3058b
# ╟─a29672bb-44cf-4fbe-b58c-f5857e5815c4
# ╟─8d312d85-1e91-450a-b301-7b2353dd187f
# ╠═585bbf68-20ed-4bdd-b4ec-05d988bdef72
