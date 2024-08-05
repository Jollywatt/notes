### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 958f9db2-cf60-11ef-2720-6f48cb33dc43
begin
	using Pkg
	Pkg.activate(Base.current_project())
	using Combinatorics
	using LinearAlgebra: I, qr
	using GeometricAlgebra
	using PlutoUI, PlutoTest
end

# ╔═╡ 9f4d0ec3-365b-4bff-8852-27a834e0fa32
md"""
# The rotor of best fit

Geometric algebra affords an elegant formula for finding a rotor ``R`` which maps a given basis ``\{e_i\}`` onto a given transformed basis ``\{f_i\}`` where ``f_i = R e_i \tilde{R}``. The formula is
```math
R \propto S \coloneqq 1 + f_i e^i + (f_{i_2} ∧ f_{i_1})(e^{i_1} ∧ e^{i_2}) + (f_{i_3} ∧ f_{i_2} ∧ f_{i_1})(e^{i_1} ∧ e^{i_2} ∧ e^{i_3}) + \cdots
```
where ``\{e^i\}`` is a [reciprocal basis](https://jollywatt.github.io/notes/reciprocal-basis) to ``\{e_i\}``.

Note that this formula can still be applied if there are only ``m < n`` basis vectors in ``n`` ambient dimensions.
In this case, the original rotor ``R`` cannot always be recovered exactly, but its projection/restriction to the ``m``-dimensional subalgebra over ``\operatorname{span}\{e_i\}`` can be (up to an overall sign).
"""

# ╔═╡ 8a25b129-e756-429d-b977-dd24b72d0e20
md"## Setting up a basis and rotor"

# ╔═╡ 6eeed6ee-ec40-4e1e-8751-4917e6f3f2b2
@bind dim Slider(1:10, show_value=true)

# ╔═╡ e4193aeb-9d28-466c-b046-b0629d8ccc72
@bind m Slider(1:dim, show_value=true)

# ╔═╡ 85d60c7a-b956-4a75-b158-49039db244d6
md"Create a random basis of ``1``-vectors:"

# ╔═╡ f903d164-6fdb-4aad-b20c-c989b57637be
E = randn(dim,m)

# ╔═╡ 44553ad7-32de-468f-9012-8f7cdc11bc06
e = Multivector{dim,1}.(eachcol(E))

# ╔═╡ 2efe50dd-4b78-4c65-8c6f-94acc7726b3a
E_pseudoinv = inv(qr(E))[1:m,:]

# ╔═╡ f6b84abf-8c58-4fa4-bbf8-940d0d131788
md"And its reciprocal basis:"

# ╔═╡ 13848298-1ed9-47d0-bbe7-3bdcc1782957
ē = Multivector{dim,1}.(eachrow(E_pseudoinv))

# ╔═╡ 6db75706-b369-4c28-a800-718d69b0c8af
md"Check that the basis and its reciprocal indeed satisfy ``e^i e_j = δ^i_j``:"

# ╔═╡ a19b5ba9-f504-44f0-baa3-f16d57aeda92
@test [e[i]⊙ē[j] for i=1:m, j=1:m] ≈ I

# ╔═╡ 0c520115-ed1a-4b8e-9471-b813e77f1701
md"Create a random rotor to transform this basis:"

# ╔═╡ 27fac430-0517-4fef-aefe-a64f522e6d4e
R = exp(10*Multivector{dim,2}(randn(ncomponents(dim, 2))))

# ╔═╡ 0593fc49-0246-48b3-bd5b-13a1d34173a1
md"Create the transformed basis:"

# ╔═╡ f61a4758-b38b-4ade-953d-4bea65042c4c
f = sandwich_prod.(R, e)

# ╔═╡ bd0f01f1-e33a-48cd-b305-0d7c29e2e23f
md"## Finding the rotor of best fit"

# ╔═╡ ef6a772c-4d2d-4d65-ae58-1dfa31e8d645
md"Implement the magic formula to find the rotor of best fit:"

# ╔═╡ f713e371-b52e-4497-9fa7-bcd3888c8988
∧(a...) = reduce(wedge, a, init=1)

# ╔═╡ b475a80f-f3ce-4b58-81f2-1ab57e9d710d
function fitrotor(a, b)
	m = length(a)
	sum(∧(reverse(b[I])...)*∧(a[I]...) for I in powerset(1:m))
end

# ╔═╡ 10d56323-6ec7-49a6-b151-31e2e8be369d
md"Test that this actually works, and we can recover a rotor which sends ``e_i`` to ``f_i``:"

# ╔═╡ 697a3407-4bda-47fe-8177-558b052319be
S = fitrotor(ē, f)

# ╔═╡ c32226b4-2c0e-44ad-8622-9d1b020acc05
md"Normalise ``S`` to make it an actual rotor:"

# ╔═╡ f3d24a34-047d-4eb4-ad28-a621b1abc3b7
function normalize(R)
	R /= sqrt(R⊙~R)
	R*sign(scalar(R))
end

# ╔═╡ 32812e82-fb7a-4db1-90b6-23d95204778e
Ŝ = normalize(S)

# ╔═╡ 9488ddc2-ad00-41d6-b18f-6f6b9ebe17b2
md"## Test the recovered rotor maps ``e_i \mapsto f_i``"

# ╔═╡ ca06c9cd-d9ce-4c6f-92f5-76efcfb677ac
itworks = all(sandwich_prod.(Ŝ, e) .≈ f)

# ╔═╡ 32d3c4ae-b629-4a62-b3f8-20d7b72cc5d6
itworks ? md"It works! 🎉" : md"Doesn't work... 😦"

# ╔═╡ b7668818-fe23-45fa-8261-0e8ba98545ca
md"## Test the original rotor is recovered exactly "

# ╔═╡ d4754ea6-3a82-4a08-9abe-c79b810bcc82
md"""
If the rotor is uniquely defined by ``\{e_i\} \mapsto \{f_i\}``, then ``R`` should be recovered exactly via:
```math
S = 2^m \langle R \rangle R
```
I'm guessing this holds when ``m \ge n - 1``.
"""

# ╔═╡ 3b68948f-136f-4d05-a19c-27604265ba61
fullydetermined = S ≈ 2^m*scalar(R)*R

# ╔═╡ f11b3d5c-5832-48a5-b63b-711d73d7f1be
md"""
In this case, the $dim-dimensional rotor ``R`` is $(fullydetermined ? "" : Markdown.Bold("not "))fully determined by the image of the $m-basis ``\{e_i\}``.
"""

# ╔═╡ 92369f5d-a802-4a2c-8aa0-ddb303951312
md"## Test the restriction of the rotor is recovered"

# ╔═╡ bac2af0d-88b3-48e7-b3d2-2b79ca99d48e
"""
Given (possibly linearly dependent) basis vectors, construct the blade that spans them.
"""
function spanningblade(vv)
	A = 1
	for v in vv
		Av = A ∧ v
		Av ≈ 0 && continue
		A = Av
	end
	A
end

# ╔═╡ 270d6d4b-6c05-4210-aa53-86371488a5c3
A = spanningblade([e; f])

# ╔═╡ 21c38855-6dad-4f4a-ba97-940c1ffa7f8e
@test all(@. isapprox([e; f] ∧ A, 0, atol=1e-10))

# ╔═╡ 6d82ce06-05c4-4bd3-855e-76d1671d70f3
"""
	proj(A, B)
Project a multivector `B` into the subalgebra defined by a blade `A`.
"""
proj(A, B) = let A = rdual(A)
	inv(A)⨼(A∧B)
end

# ╔═╡ 5d7a0c7f-1c02-459c-b37a-6c585902a906
@test Ŝ ≈ proj(A, Ŝ)

# ╔═╡ 9abd6d72-f44a-46cd-8bd1-cba14b300a5e
@test S ≈ proj(A, S)

# ╔═╡ 848ab9e3-f253-46ae-88a5-cfa61ce4b103
md"""
It doesn't always hold that the recovered rotor ``S`` is a scalar multiple of the projection of the original rotor ``R`` onto the subalgebra spanning ``\{e_i\} \cup \{f_i\}``.
"""

# ╔═╡ 524e2b39-6f6b-4f59-9b52-c349226d6fa6
@test normalize(proj(A, R)) ≈ normalize(S)

# ╔═╡ 71309e7c-7df4-4816-be01-35c269266894
md"## Package setup"

# ╔═╡ Cell order:
# ╟─9f4d0ec3-365b-4bff-8852-27a834e0fa32
# ╟─8a25b129-e756-429d-b977-dd24b72d0e20
# ╠═6eeed6ee-ec40-4e1e-8751-4917e6f3f2b2
# ╠═e4193aeb-9d28-466c-b046-b0629d8ccc72
# ╟─85d60c7a-b956-4a75-b158-49039db244d6
# ╠═f903d164-6fdb-4aad-b20c-c989b57637be
# ╠═44553ad7-32de-468f-9012-8f7cdc11bc06
# ╠═2efe50dd-4b78-4c65-8c6f-94acc7726b3a
# ╟─f6b84abf-8c58-4fa4-bbf8-940d0d131788
# ╠═13848298-1ed9-47d0-bbe7-3bdcc1782957
# ╟─6db75706-b369-4c28-a800-718d69b0c8af
# ╠═a19b5ba9-f504-44f0-baa3-f16d57aeda92
# ╟─0c520115-ed1a-4b8e-9471-b813e77f1701
# ╠═27fac430-0517-4fef-aefe-a64f522e6d4e
# ╟─0593fc49-0246-48b3-bd5b-13a1d34173a1
# ╠═f61a4758-b38b-4ade-953d-4bea65042c4c
# ╟─bd0f01f1-e33a-48cd-b305-0d7c29e2e23f
# ╟─ef6a772c-4d2d-4d65-ae58-1dfa31e8d645
# ╠═f713e371-b52e-4497-9fa7-bcd3888c8988
# ╠═b475a80f-f3ce-4b58-81f2-1ab57e9d710d
# ╟─10d56323-6ec7-49a6-b151-31e2e8be369d
# ╠═697a3407-4bda-47fe-8177-558b052319be
# ╟─c32226b4-2c0e-44ad-8622-9d1b020acc05
# ╠═f3d24a34-047d-4eb4-ad28-a621b1abc3b7
# ╠═32812e82-fb7a-4db1-90b6-23d95204778e
# ╟─9488ddc2-ad00-41d6-b18f-6f6b9ebe17b2
# ╠═ca06c9cd-d9ce-4c6f-92f5-76efcfb677ac
# ╟─32d3c4ae-b629-4a62-b3f8-20d7b72cc5d6
# ╟─b7668818-fe23-45fa-8261-0e8ba98545ca
# ╟─d4754ea6-3a82-4a08-9abe-c79b810bcc82
# ╠═3b68948f-136f-4d05-a19c-27604265ba61
# ╟─f11b3d5c-5832-48a5-b63b-711d73d7f1be
# ╟─92369f5d-a802-4a2c-8aa0-ddb303951312
# ╠═bac2af0d-88b3-48e7-b3d2-2b79ca99d48e
# ╠═270d6d4b-6c05-4210-aa53-86371488a5c3
# ╠═21c38855-6dad-4f4a-ba97-940c1ffa7f8e
# ╠═5d7a0c7f-1c02-459c-b37a-6c585902a906
# ╠═6d82ce06-05c4-4bd3-855e-76d1671d70f3
# ╠═9abd6d72-f44a-46cd-8bd1-cba14b300a5e
# ╟─848ab9e3-f253-46ae-88a5-cfa61ce4b103
# ╠═524e2b39-6f6b-4f59-9b52-c349226d6fa6
# ╟─71309e7c-7df4-4816-be01-35c269266894
# ╠═958f9db2-cf60-11ef-2720-6f48cb33dc43
