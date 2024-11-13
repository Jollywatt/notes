### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 91666359-97c1-4338-9a81-74476ee5253f
begin
	using Pkg
	Pkg.add(url="https://github.com/jollywatt/geometricalgebra.jl")
	using GeometricAlgebra
end

# ╔═╡ a57e314e-d6da-4ce0-a42e-b7748aef6962
using Plots

# ╔═╡ 1417bafe-c28b-48ba-a7fd-d0b4720f6c54
@basis Cl(2,1)

# ╔═╡ c1eb9f19-2436-4a41-9861-82e642ac6eb4
function hyperboloid_to_disk(a)
	b = a + v3
	b/scalar_prod(b, -v3) - v3
end

# ╔═╡ 88274c0c-2cc8-4907-a16b-b8b7dca7ef19
hyperboloid_to_disk(2v3 + v1)

# ╔═╡ d14bedd4-3dfd-4671-90b5-0d0ff36f9dfc
disk_to_complex(a) = a.comps[1] + a.comps[2]im

# ╔═╡ e7072279-32a3-46cc-8217-537c077322a5
disk_to_halfplane(z::Complex) = -im*(im*z - 1)/(im*z + 1)

# ╔═╡ b97ad324-c50f-4bd1-bfd9-ccd5a7ee0dcf
disk_to_halfplane(a::Multivector) = disk_to_halfplane(disk_to_complex(a))

# ╔═╡ eae9b4e6-b8b8-424d-bbd1-b2cc7486b5f2
R2 = let σ = 5*v13
	exp(σ/2)
end

# ╔═╡ 3101cd2e-7c06-4cc5-99a0-4014be419c7a
R1 = let σ = 4*v13
	exp(σ/2)
end

# ╔═╡ bf4a0b03-c03c-4ec2-a3ad-f1c07caab8ba
ξ = 0

# ╔═╡ c24f5abe-d028-4b86-b2b7-ea3ed37f3c9d
halfplane_to_μσ(z) = (μ=sqrt(2)*real(z), σ=imag(z))

# ╔═╡ 1b0efd23-cb15-4911-8feb-aa1326f7c95f
to_μσ = halfplane_to_μσ∘disk_to_halfplane∘hyperboloid_to_disk

# ╔═╡ 8572302b-c9fe-4e80-afbe-56020721fa96
U1 = to_μσ(sandwich_prod(R1, v3))

# ╔═╡ 1d339897-1a7b-4783-a250-52db9a1cfc6d
U2 = to_μσ(sandwich_prod(R2, v3))

# ╔═╡ d6ead317-ef85-4433-888c-b6799658f284
KL((μ1, σ1), (μ2, σ2)) = log(σ2/σ1) + (σ1^2 - σ2^2 + (µ1 - µ2)^2)/(2σ2^2)

# ╔═╡ 22a559b3-b968-4f56-a7d8-f5e326122eec
KL(U1, U2)

# ╔═╡ 0e9d6e94-f3c7-4980-ac29-92906cee09af
t = range(-2, 2, length=200)

# ╔═╡ 3e2d9dda-52e0-4318-b0a5-b631e8228d05
begin
	scatter(@. to_μσ(sandwich_prod(exp(-t*(v13+v23)), v1 + 1.4v3)))
	ylims!(0, 3)
	xlims!(-3, 3)
end

# ╔═╡ e8513129-1541-4cc2-b8f0-25ca33658e6c
to_μσ(v3)

# ╔═╡ Cell order:
# ╠═91666359-97c1-4338-9a81-74476ee5253f
# ╠═1417bafe-c28b-48ba-a7fd-d0b4720f6c54
# ╠═c1eb9f19-2436-4a41-9861-82e642ac6eb4
# ╠═88274c0c-2cc8-4907-a16b-b8b7dca7ef19
# ╠═d14bedd4-3dfd-4671-90b5-0d0ff36f9dfc
# ╠═e7072279-32a3-46cc-8217-537c077322a5
# ╠═b97ad324-c50f-4bd1-bfd9-ccd5a7ee0dcf
# ╠═eae9b4e6-b8b8-424d-bbd1-b2cc7486b5f2
# ╠═3101cd2e-7c06-4cc5-99a0-4014be419c7a
# ╠═22a559b3-b968-4f56-a7d8-f5e326122eec
# ╠═bf4a0b03-c03c-4ec2-a3ad-f1c07caab8ba
# ╠═c24f5abe-d028-4b86-b2b7-ea3ed37f3c9d
# ╠═1b0efd23-cb15-4911-8feb-aa1326f7c95f
# ╠═8572302b-c9fe-4e80-afbe-56020721fa96
# ╠═1d339897-1a7b-4783-a250-52db9a1cfc6d
# ╠═d6ead317-ef85-4433-888c-b6799658f284
# ╠═a57e314e-d6da-4ce0-a42e-b7748aef6962
# ╠═0e9d6e94-f3c7-4980-ac29-92906cee09af
# ╠═3e2d9dda-52e0-4318-b0a5-b631e8228d05
# ╠═e8513129-1541-4cc2-b8f0-25ca33658e6c
