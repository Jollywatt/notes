### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ ff45f17b-bee5-4a05-beee-fa6dfad449be
using Test

# ╔═╡ 4b9472c2-3c5e-44a7-89c9-3b6cd4e663e6
md"""
# Hyperbolic geometries, their metrics, and maps between them

"""

# ╔═╡ 47e6c027-669a-46d2-81eb-19fd83c76898
md"""
## Manifolds and metrics
"""

# ╔═╡ 7c07e3f1-9cc3-4cc4-a161-4b2df78a844e
md"""
### Hyperboloid, ``(λ, θ)``
```math
g = dλ^2 + \sinh^2 λ \, dθ^2
```
"""

# ╔═╡ 68689ff5-d575-4646-9409-d6b779a00e44
g_λθ((λ, θ), (uλ, uθ), (vλ, vθ)) = uλ*vλ + sinh(λ)^2*uθ*vθ

# ╔═╡ b8fdb85f-d0be-47af-a6a2-173bdb746b87
md"""
### Hyperbolic 3-space, ``(x, y, z)``

In ``ℝ^3``, define a hyperbolic metric
```math
g = dx^2 + dy^2 - dz^2
```
"""

# ╔═╡ 54d61557-4873-4387-b7d7-53608b6504e2
g_xyz((x, y, z), (ux, uy, uz), (vx, vy, vz)) = ux*vx + uy*vy - uz*vz

# ╔═╡ 3d340e8f-ab0e-42c0-ab05-5302501285ac
md"""
### Hyperbolic 3-space, ``(ρ, θ, z)``

```math
g = dρ^2 + ρ^2 dθ^2 - dz^2
```
"""

# ╔═╡ 47a71842-21e0-4f17-aa84-573d89b9cc20
g_ρθz((ρ, θ, z), (uρ, uθ, uz), (vρ, vθ, vz)) = uρ*vρ + ρ^2*uθ*vθ - uz*vz

# ╔═╡ 4b8dc37a-27ea-4e57-807a-81bc4788a305
md"""
### Hyperbolic disk, ``(r, θ)``
"""

# ╔═╡ 94262d5c-80ea-42e0-8c5e-a366849127da
g_rθ((r, θ), (ur, uθ), (vr, vθ)) = 4(ur*vr + r^2*uθ*vθ)/(1 - r^2)^2

# ╔═╡ 385d0309-4f8a-49a3-884b-829d5bb49e9c
md"""
### Poincaré disk, ``ζ``

The Poincaré disk is the unit disk ``\{ζ ∈ ℂ \mid |ζ| < 1\}`` equipped with the metric:
```math
\begin{align*}
g_ζ
	&= \frac{4 \, dζ dζ^*}{(1 - ζ ζ^*)^2}
	= 4\frac{dx^2 + dy^2}{(1 - x^2 - y^2)^2} \\
g_ζ(u, v)
	&= 4\frac{u_x v_x + u_y v_y}{(1 - x^2 - y^2)^2}
	= 4 \frac{ℜ(uv^*)}{(1 - x^2 - y^2)^2}
\end{align*}
```
where ``ζ = x + yi`` and ``u = u_x + u_yi`` and ``v = v_x + v_yi``.
"""

# ╔═╡ 7949c7b1-7233-403c-8567-1549718d46ca
g_ζ(ζ, u, v) = 4real(u'v)/(1 - abs2(ζ))^2

# ╔═╡ c348ab01-4d75-4c6c-b9c2-c70696eb0071
md"""
### Poincaré half-plane, ``ξ``

The Poincaré half-plane is the upper half of the complex plane ``\{ξ ∈ ℂ \mid ℑ(ξ) > 0 \}`` equipped with the metric:
```math
g_ξ = \frac{dξ dξ^*}{ℑ(ξ)^2}
```
which, if ``u = u_x + u_yi`` and ``v = v_x + v_yi``, is the same as:
```math
g_ξ(u, v) = \frac{u_x v_x + u_y v_y}{ℑ(ξ)^2}
	= \frac{ℜ(u v^*)}{ℑ(ξ)^2}
```
"""

# ╔═╡ a6cf47e9-72f0-41cc-b0a3-8c0dab4da131
g_ξ(ξ, u, v) = real(u'v)/imag(ξ)^2

# ╔═╡ bcc2bc62-6772-489a-8ffa-54a919930a43
md"""
### Space of univariate Gaussians, ``(μ, σ)``

The parameter space ``(μ, σ) ∈ ℝ × (0, ∞)`` of Gaussian distributions can be equipped with the [Fisher Information metric](https://jollywatt.github.io/notes/fisher-info-metric-for-gaussians).
"""

# ╔═╡ c3e2a6fa-b560-45a0-b7b8-addb794fe56b
g_μσ((μ, σ), (uμ, uσ), (vμ, vσ)) = (uμ*vμ + 2uσ*vσ)/2σ^2

# ╔═╡ c21fc52a-96f9-43d1-9493-3469588f09e6
md"""
## Coordinate maps and their Jacobians
"""

# ╔═╡ a492c2af-b3e9-4e2b-94c8-b9b2e6f1ba11
md"""
### ``(λ, θ) ↦ (x, y, z)``
"""

# ╔═╡ 138772fd-1fb9-40dd-9b9f-8141a279e867
λθ_xyz((λ, θ)) = [cos(θ)sinh(λ), sin(θ)sinh(λ), cosh(λ)]

# ╔═╡ 6ad5c351-de9f-4284-a475-fd0e63889319
dλθ_dxyz((λ, θ)) = [
	cos(θ)cosh(λ) -sin(θ)sinh(λ)
	sin(θ)cosh(λ) cos(θ)sinh(λ)
	sinh(λ) 0
]

# ╔═╡ e77501e7-c5af-4123-82cc-9bda536fb5a9
xyz_λθ((x, y, z)) = [cos(θ)sinh(λ), sin(θ)sinh(λ), cosh(λ)]

# ╔═╡ 88af3571-2406-4bc9-b237-cdc491746221
md"""
### ``(x, y, z) ↦ (ρ, θ, z)``
"""

# ╔═╡ 7fe5f8cb-8f8d-4ace-bc07-5801e48df1dd
xyz_ρθz((x, y, z)) = [sqrt(x^2 + y^2), atan(y, x), z]

# ╔═╡ e9f4ae7b-3c52-4e29-8426-c0d4778aab28
dxyz_dρθz((x, y, z)) = let r = hypot(x, y)
	[
		x/r y/r 0
		-y/r^2 x/r^2 0
		0 0 1
	]
end

# ╔═╡ 4b6df6ec-a7ea-4cf3-a676-b8cf48444d60
md"""
### ``(λ, θ) ↦ (ρ, θ, z)``
"""

# ╔═╡ bd8f2bad-5d9b-4196-a9ce-072f3ae90221
λθ_ρθz((λ, θ)) = [sinh(λ), θ, cosh(λ)]

# ╔═╡ b866beb2-dfd1-48d1-80d2-49aee8e59288
dλθ_dρθz((λ, θ)) = [
	cosh(λ) 0
	0 1
	sinh(λ) 0
]

# ╔═╡ 462a5bdd-2e4e-46ca-80f2-ea05d9290efa
md"""
### ``(ρ, θ, z) ↦ (r, θ)``

Projection from the hyperboloid onto the unit disk.
"""

# ╔═╡ 402aab2c-f0a6-4d65-982e-1ed2fff3f690
html"""
<img src="https://www.researchgate.net/publication/291808218/figure/fig4/AS:614351295766528@1523484171279/A-pattern-in-the-hyperboloid-model-Common-Sphere-Hyperboloid-Bilinear-form-px-y-x-0.png" width="400"/>
"""

# ╔═╡ deac25e2-7217-43af-b224-004e6e0f7834
ρθz_rθ((ρ, θ, z)) = [ρ/(z + 1), θ]

# ╔═╡ 78f4387d-894b-4f09-95d1-910599c9f5aa
dρθz_drθ((ρ, θ, z)) = [
	1/(z + 1) 0 -ρ/(z + 1)^2
	0 1 0
]

# ╔═╡ 93ee3bcc-007e-429d-a80b-ab0595746821
md"""
### ``(λ, θ) ↦ (r, θ)``
"""

# ╔═╡ cca9da0e-5d9e-4bc2-9ad8-a91c88fd7996
λθ_rθ((λ, θ)) = [sinh(λ)/(cosh(λ) + 1), θ]

# ╔═╡ 691ac5f8-b005-465b-9653-3f8a31fbd7ea
for _ in 1:100
	λθ = rand(2).*[1, 2pi]
	@test λθ_rθ(λθ) ≈ ρθz_rθ(λθ_ρθz(λθ))
end

# ╔═╡ 224eccfc-b0a8-4c07-89a9-06d5e84c298c
md"""
### ``(r, θ) ↦ (λ, θ)``
"""

# ╔═╡ 63bcc231-ebf4-4737-bfd7-8e960246f5ca
rθ_λθ((r, θ)) = [log((1 + r)/(1 - r)), θ]

# ╔═╡ a036b518-0588-476f-ad08-293ab1437f15
for _ in 1:100
	rθ = rand(2).*[1, 2pi]
	@test λθ_rθ(rθ_λθ(rθ)) ≈ rθ
end

# ╔═╡ fdd5a5a6-806f-4a7e-a7a1-aec49e380043
md"""
### ``(r, θ) ↦ (ρ, θ, z)``
"""

# ╔═╡ a2d53bbf-676a-470f-98f8-d514a86319da
rθ_ρθz((r, θ)) = [2r/(r^2 - 1), θ, 2/(r^2 - 1) - 1]

# ╔═╡ 2ec17e91-7ff3-4296-a465-10feec727d55
drθ_dρθz((r, θ)) = [
	-2(r^2 + 1)/(r^2 - 1)^2 0
	0 1
	-4r/(r^2 - 1)^2 0
]	

# ╔═╡ b604d70c-3fcd-4c15-91c8-4164b37c87a5
# test that rθ_ρθz and ρθz_rθ (restricted to the upper hyperboloid) are inverses
for _ in 1:100
	rθ = randn(2)
	@test ρθz_rθ(rθ_ρθz(rθ)) ≈ rθ
	ρθz = rθ_ρθz(rθ)
	@test rθ_ρθz(ρθz_rθ(ρθz)) ≈ ρθz
end

# ╔═╡ 695510c7-7d45-434e-9dbf-947209d421ab
md"""
### ``(r, θ) ↦ ζ ∈ ℂ``
"""

# ╔═╡ 0adbcaf0-4af5-473c-9b39-688e86d4be8c
rθ_ζ((r, θ)) = r*cis(θ)

# ╔═╡ be6c6ccc-862f-4ec0-9a9f-6e1b277e73d3
drθ_dζ((r, θ)) = [cis(θ) im*r*cis(θ)]

# ╔═╡ 7e6baaaf-1d37-4b8e-9e98-538f756c7c46
md"""
### ``ζ ↦ ξ``
"""

# ╔═╡ ac9ab91b-9bb1-475f-9d63-0a0a2da1141a
ζ_ξ(ζ) = (ζ + im)/(ζ - im)/im

# ╔═╡ 0543869a-c5b7-4795-a895-925fc9ca19e1
dζ_dξ(ζ) = 2/(ζ - im)^2

# ╔═╡ 6563ccf8-3f90-4372-bba0-b1a275ed0f4c
md"""
### ``ξ ↦ ζ``

Mapping from Poincaré half-plane to Poincaré unit disk.
See [this Desmos plot](https://jollywatt.github.io/notes/poincare-plane-to-disk).
"""

# ╔═╡ 2d9ac221-41b8-43eb-8102-e412d49db4c5
ξ_ζ(ζ) = im*(ζ - im)/(ζ + im)

# ╔═╡ d896a775-1a4d-4fc5-919b-869497342c0a
dξ_dζ(ζ) = 2/(ζ + im)^2

# ╔═╡ 7fca662b-2f87-491c-a2f3-f44339868966
# test that ζ_ξ and ξ_ζ are inverses
for _ in 1:100
	ξ = randn() + rand()im
	@test ζ_ξ(ξ_ζ(ξ)) ≈ ξ
	ζ = randn(ComplexF64)
	@test ξ_ζ(ζ_ξ(ζ)) ≈ ζ
end

# ╔═╡ f55effe8-cd0b-4122-9860-22e7f9257c6c
md"""
### ``ξ ↦ (μ, σ)``
"""

# ╔═╡ 27424c60-9844-4f6f-b7b6-40c169444069
ξ_μσ(ξ) = [sqrt(2)real(ξ), imag(ξ)]

# ╔═╡ 5b3479e0-b6ac-4e15-941b-302f98b39ebc
dξ_dμσ(ξ, u) = [sqrt(2)real(u), imag(u)]

# ╔═╡ 4bc7c9c7-7480-447c-81e4-020906bd1bea
md"""
### ``(λ, θ) ↦ (μ, σ)``
"""

# ╔═╡ 2fbdfbbc-3e07-42b9-ba2e-c0188ab8b798
λθ_μσ((λ, θ)) = let α = inv(1 + im*cis(θ)tanh(λ/2))
	[-2sqrt(2)imag(α), 2real(α) - 1]
end

# ╔═╡ 0b0ba1db-a7d1-4772-9424-f2ed634f3603
dλθ_dμσ(λθ, u) = begin
	ρθz = λθ_ρθz(λθ)
	rθ = ρθz_rθ(ρθz)
	ζ = rθ_ζ(rθ)
	ξ = ζ_ξ(ζ)
	dξ_dμσ(ξ, (dζ_dξ(ζ)drθ_dζ(rθ)dρθz_drθ(ρθz)dλθ_dρθz(λθ)u)[])
end

# ╔═╡ 9f938241-b063-4e87-91ad-5407187acd94
md"""
## Imports and utilities
"""

# ╔═╡ 878ef059-3baa-405a-904a-6e2165b6b667
ε = 1e-10

# ╔═╡ 3906eda3-b6ad-4853-a52f-ca2ab5ee57d6
# test Jacobian and metric preservation of λθ_xyz
for _ in 1:100
	λθ, u, v = eachcol(rand(2,3).*[1, 2pi])
	@test λθ_xyz(λθ + ε*u) ≈ λθ_xyz(λθ) + ε*dλθ_dxyz(λθ)u
	@test g_λθ(λθ, u, v) ≈ g_xyz(λθ_xyz(λθ), dλθ_dxyz(λθ)u, dλθ_dxyz(λθ)v)
end

# ╔═╡ c8fe0482-d622-408f-8031-1dce9af7374d
# test Jacobian and metric preservation of xyz_ρθz
for _ in 1:100
	a, u, v = eachcol(randn(3,3))
	@test xyz_ρθz(a + ε*u) ≈ xyz_ρθz(a) + ε*dxyz_dρθz(a)u
	@test g_xyz(a, u, v) ≈ g_ρθz(xyz_ρθz(a), dxyz_dρθz(a)u, dxyz_dρθz(a)v)
end

# ╔═╡ 262446dd-8dc5-4d34-ab52-0d46f55faf9d
# test Jacobian and metric preservation of λθ_ρθz
for _ in 1:100
	λθ, u, v = eachcol(rand(2, 3).*[1, 2pi])
	@test λθ_ρθz(λθ + ε*u) ≈ λθ_ρθz(λθ) + ε*dλθ_dρθz(λθ)u
	@test g_λθ(λθ, u, v) ≈ g_ρθz(λθ_ρθz(λθ), dλθ_dρθz(λθ)u, dλθ_dρθz(λθ)v)
end

# ╔═╡ 1995996a-65a1-4b8b-90c8-7d102bb23bc1
# test Jacobian and metric preservation of ρθz_rθ
for _ in 1:100
	rθ, u0, v0 = eachcol(rand(2,3).*[1, 2pi])
	ρθz = rθ_ρθz(rθ)
	J = drθ_dρθz(rθ)
	u, v = J*u0, J*v0
	@test ρθz_rθ(ρθz + ε*u) ≈ ρθz_rθ(ρθz) + ε*dρθz_drθ(ρθz)*u
	@test g_ρθz(ρθz, u, v) ≈ g_rθ(ρθz_rθ(ρθz), dρθz_drθ(ρθz)u, dρθz_drθ(ρθz)v)
end

# ╔═╡ 3a48fb2a-5c3f-4300-b43e-c1f334f717fa
# test Jacobian and metric preservation of rθ_ρθz
for _ in 1:100
	rθ, u, v = eachcol(rand(2, 3).*[1, 2pi])
	@test rθ_ρθz(rθ + ε*u) ≈ rθ_ρθz(rθ) + ε*drθ_dρθz(rθ)u
	@test g_rθ(rθ, u, v) ≈ g_ρθz(rθ_ρθz(rθ), drθ_dρθz(rθ)u, drθ_dρθz(rθ)v)
end

# ╔═╡ 58b1400f-8827-48a7-8896-ab3b7f5f8c09
# test Jacobian and metric preservation of rθ_ζ
for _ in 1:100
	rθ = [rand(), 2pi*rand()]
	u, v = eachcol(rand(2, 2))
	@test rθ_ζ(rθ + ε*u) ≈ rθ_ζ(rθ) + ε*(drθ_dζ(rθ)u)[]
	@test g_rθ(rθ, u, v) ≈ g_ζ(rθ_ζ(rθ), drθ_dζ(rθ)u, drθ_dζ(rθ)v)
end

# ╔═╡ 27f6936e-2974-4e01-8266-9561b5e532db
# test Jacobian and metric preservation of ζ_ξ
for _ in 1:100
	z = rand()cis(2pi*rand()) # random point in disk
	u, v = randn(ComplexF64, 2)
	@test ζ_ξ(z + ε*u) ≈ ζ_ξ(z) + ε*dζ_dξ(z)u
	@test g_ζ(z, u, v) ≈ g_ξ(ζ_ξ(z), dζ_dξ(z)u, dζ_dξ(z)v)
end

# ╔═╡ ecc68cec-b30f-485b-8b4c-5b83f282a5bc
# test Jacobian and metric preservation of ξ_ζ
for _ in 1:100
	ζ, u, v = randn(ComplexF64, 3)
	@test ξ_ζ(ζ + ε*u) ≈ ξ_ζ(ζ) + ε*dξ_dζ(ζ)u
	@test g_ξ(ζ, u, v) ≈ g_ζ(ξ_ζ(ζ), dξ_dζ(ζ)u, dξ_dζ(ζ)v)
end

# ╔═╡ 819f79e4-9fb6-42eb-8291-1cc91e4fad99
# test Jacobian and metric transformation rule of ξ_μσ
for _ in 1:100
	ξ = randn() + rand()im
	u, v = rand(ComplexF64, 2)
	@test ξ_μσ(ξ + ε*u) ≈ ξ_μσ(ξ) + ε*dξ_dμσ(ξ, u)
	@test g_ξ(ξ, u, v) ≈ g_μσ(ξ_μσ(ξ), dξ_dμσ(ξ, u), dξ_dμσ(ξ, v))
end

# ╔═╡ 31a0f653-f5ff-4384-9578-876d37c06359
for _ in 1:100
	λθ = [randn(), 2pi*rand()]
	u, v = eachcol(rand(2, 2))
	@test λθ_μσ(λθ + ε*u) ≈ λθ_μσ(λθ) + ε*dλθ_dμσ(λθ, u)
	@test g_λθ(λθ, u, v) ≈ g_μσ(λθ_μσ(λθ), dλθ_dμσ(λθ, u), dλθ_dμσ(λθ, v))
end

# ╔═╡ 97d7cdbd-6cd4-4d3a-b82d-93ec395ceb57
f ⨟ g = x -> g(f(x))

# ╔═╡ d747dfd7-ef2c-4fa8-996f-ee931dd9adc6
for _ in 1:100
	λθ = rand(2).*[1, 2pi]
	@test λθ_μσ(λθ) ≈ (λθ_ρθz ⨟ ρθz_rθ ⨟ rθ_ζ ⨟ ζ_ξ ⨟ ξ_μσ)(λθ)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
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
# ╟─4b9472c2-3c5e-44a7-89c9-3b6cd4e663e6
# ╟─47e6c027-669a-46d2-81eb-19fd83c76898
# ╟─7c07e3f1-9cc3-4cc4-a161-4b2df78a844e
# ╠═68689ff5-d575-4646-9409-d6b779a00e44
# ╟─b8fdb85f-d0be-47af-a6a2-173bdb746b87
# ╠═54d61557-4873-4387-b7d7-53608b6504e2
# ╟─3d340e8f-ab0e-42c0-ab05-5302501285ac
# ╠═47a71842-21e0-4f17-aa84-573d89b9cc20
# ╟─4b8dc37a-27ea-4e57-807a-81bc4788a305
# ╠═94262d5c-80ea-42e0-8c5e-a366849127da
# ╟─385d0309-4f8a-49a3-884b-829d5bb49e9c
# ╠═7949c7b1-7233-403c-8567-1549718d46ca
# ╟─c348ab01-4d75-4c6c-b9c2-c70696eb0071
# ╠═a6cf47e9-72f0-41cc-b0a3-8c0dab4da131
# ╟─bcc2bc62-6772-489a-8ffa-54a919930a43
# ╠═c3e2a6fa-b560-45a0-b7b8-addb794fe56b
# ╟─c21fc52a-96f9-43d1-9493-3469588f09e6
# ╟─a492c2af-b3e9-4e2b-94c8-b9b2e6f1ba11
# ╠═138772fd-1fb9-40dd-9b9f-8141a279e867
# ╠═6ad5c351-de9f-4284-a475-fd0e63889319
# ╠═3906eda3-b6ad-4853-a52f-ca2ab5ee57d6
# ╠═e77501e7-c5af-4123-82cc-9bda536fb5a9
# ╟─88af3571-2406-4bc9-b237-cdc491746221
# ╠═7fe5f8cb-8f8d-4ace-bc07-5801e48df1dd
# ╠═e9f4ae7b-3c52-4e29-8426-c0d4778aab28
# ╠═c8fe0482-d622-408f-8031-1dce9af7374d
# ╟─4b6df6ec-a7ea-4cf3-a676-b8cf48444d60
# ╠═bd8f2bad-5d9b-4196-a9ce-072f3ae90221
# ╠═b866beb2-dfd1-48d1-80d2-49aee8e59288
# ╠═262446dd-8dc5-4d34-ab52-0d46f55faf9d
# ╟─462a5bdd-2e4e-46ca-80f2-ea05d9290efa
# ╟─402aab2c-f0a6-4d65-982e-1ed2fff3f690
# ╠═deac25e2-7217-43af-b224-004e6e0f7834
# ╠═78f4387d-894b-4f09-95d1-910599c9f5aa
# ╠═1995996a-65a1-4b8b-90c8-7d102bb23bc1
# ╠═93ee3bcc-007e-429d-a80b-ab0595746821
# ╠═cca9da0e-5d9e-4bc2-9ad8-a91c88fd7996
# ╠═691ac5f8-b005-465b-9653-3f8a31fbd7ea
# ╟─224eccfc-b0a8-4c07-89a9-06d5e84c298c
# ╠═63bcc231-ebf4-4737-bfd7-8e960246f5ca
# ╠═a036b518-0588-476f-ad08-293ab1437f15
# ╟─fdd5a5a6-806f-4a7e-a7a1-aec49e380043
# ╠═a2d53bbf-676a-470f-98f8-d514a86319da
# ╠═2ec17e91-7ff3-4296-a465-10feec727d55
# ╠═3a48fb2a-5c3f-4300-b43e-c1f334f717fa
# ╠═b604d70c-3fcd-4c15-91c8-4164b37c87a5
# ╟─695510c7-7d45-434e-9dbf-947209d421ab
# ╠═0adbcaf0-4af5-473c-9b39-688e86d4be8c
# ╠═be6c6ccc-862f-4ec0-9a9f-6e1b277e73d3
# ╠═58b1400f-8827-48a7-8896-ab3b7f5f8c09
# ╟─7e6baaaf-1d37-4b8e-9e98-538f756c7c46
# ╠═ac9ab91b-9bb1-475f-9d63-0a0a2da1141a
# ╠═0543869a-c5b7-4795-a895-925fc9ca19e1
# ╠═27f6936e-2974-4e01-8266-9561b5e532db
# ╟─6563ccf8-3f90-4372-bba0-b1a275ed0f4c
# ╠═2d9ac221-41b8-43eb-8102-e412d49db4c5
# ╠═d896a775-1a4d-4fc5-919b-869497342c0a
# ╠═ecc68cec-b30f-485b-8b4c-5b83f282a5bc
# ╠═7fca662b-2f87-491c-a2f3-f44339868966
# ╟─f55effe8-cd0b-4122-9860-22e7f9257c6c
# ╠═27424c60-9844-4f6f-b7b6-40c169444069
# ╠═5b3479e0-b6ac-4e15-941b-302f98b39ebc
# ╠═819f79e4-9fb6-42eb-8291-1cc91e4fad99
# ╟─4bc7c9c7-7480-447c-81e4-020906bd1bea
# ╠═2fbdfbbc-3e07-42b9-ba2e-c0188ab8b798
# ╠═d747dfd7-ef2c-4fa8-996f-ee931dd9adc6
# ╠═0b0ba1db-a7d1-4772-9424-f2ed634f3603
# ╠═31a0f653-f5ff-4384-9578-876d37c06359
# ╟─9f938241-b063-4e87-91ad-5407187acd94
# ╠═ff45f17b-bee5-4a05-beee-fa6dfad449be
# ╠═878ef059-3baa-405a-904a-6e2165b6b667
# ╠═97d7cdbd-6cd4-4d3a-b82d-93ec395ceb57
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
