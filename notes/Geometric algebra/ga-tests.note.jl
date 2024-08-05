### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ f5e0b560-1093-11f0-2e12-4faef19f5aa2
begin
	using Pkg
	Pkg.activate(".")
	using GeometricAlgebra, Test, Typst_jll
end

# ╔═╡ 66845ea3-a85b-4488-82e2-6683980b59f9
sigs = [Cl(p,q) for p in 0:2 for q in 0:2 if p + q > 0]

# ╔═╡ c07b6326-357f-4801-8e31-e7f74b71ee61
for sig in sigs
	A, B = randn(Multivector{sig,0:dimension(sig)}, 2)
	u = randn(Multivector{sig,1})
	@test u∧(A*B) ≈ (u∧A)*B - involution(A)*(u⨼B)
	@test u∧(A*B) ≈ (u⨼A)*B + involution(A)*(u∧B)
	@test u⨼(A*B) ≈ (u∧A)*B - involution(A)*(u∧B)
	@test u⨼(A*B) ≈ (u⨼A)*B + involution(A)*(u⨼B)

	if dimension(sig) >= 2
		a, b, c, d = randn(Multivector{sig,1}, 4)
		@test (a∧b)⋅(c∧d) ≈ (a⋅d)*(b⋅c) - (a⋅c)*(b⋅d)
	end
end

# ╔═╡ 1df05690-1462-4275-9cd1-69b5e7306672
for sig in sigs
	A, B = randn(Multivector{sig,0:dimension(sig)}, 2)
	I = basis(sig,dimension(sig),1)
	@test (I*A)∧B ≈ I*(A ⨽ B)
	@test A∧(B*I) ≈ (A ⨼ B)*I
end

# ╔═╡ a4a1d7bd-3a1c-4d50-a6aa-3aa5eec34889
for sig in sigs
	dimension(sig) >= 2 || continue
	a, b, c, d = randn(Multivector{sig,1}, 4)
	@test (a∧b)⋅(c∧d) ≈ (a⋅d)*(b⋅c) - (a⋅c)*(b⋅d)
end

# ╔═╡ bbf9fe09-f27e-4c8d-a617-60bd9fc75813
struct TypstSource
	src::String
end

# ╔═╡ a4aff13f-e988-4e2c-8e76-1ce3ae3b2483
function Base.show(io::IO, ::MIME"image/svg+xml", typ::TypstSource)
	cmd = pipeline(`$(Typst_jll.typst()) compile --format svg - -`, stdin=IOBuffer(typ.src))
	write(io, read(cmd))
end

# ╔═╡ 739dfd15-887b-4022-bfcd-46455a37fea9
macro typ_str(body)
	TypstSource("""
	#set page(width: 18cm, height: auto, margin: 5pt, fill: none)
	#set text(size: 13pt)
	#let involution(it) = \$it^star\$
	#let lcont = math.op(math.floor.r)
	#let rcont = math.op(math.floor.l)
	$body
	""")
end

# ╔═╡ 6875e5e2-c013-4271-be39-a3d2a6672fbe
typ"""
$
u ∧(A B) &= (u ∧ A) B - involution(A)(u lcont B) \
u ∧(A B) &= (u lcont A) B + involution(A)(u∧B) \
u lcont (A B) &= (u ∧ A) B - involution(A)(u∧B) \
u lcont (A B) &= (u lcont A) B + involution(A)(u lcont B) \
$
"""

# ╔═╡ e4d61f5a-5e56-4833-9928-a885f009a10b
typ"""
$
(I A) ∧ B &= I (A rcont B) \
A ∧ (B I) &= (A lcont B) I \
$
"""

# ╔═╡ d70e9deb-cf29-4bd2-a4e6-fd7662a0f97c
typ"""
$
(a∧b)⋅(c∧d) = (a⋅d)(b⋅c) - (a⋅c)(b⋅d)
$
"""

# ╔═╡ d4f95d08-9558-4daf-a4fd-f950139ddf31
typ"#v(10cm)"

# ╔═╡ Cell order:
# ╠═f5e0b560-1093-11f0-2e12-4faef19f5aa2
# ╠═66845ea3-a85b-4488-82e2-6683980b59f9
# ╟─6875e5e2-c013-4271-be39-a3d2a6672fbe
# ╠═c07b6326-357f-4801-8e31-e7f74b71ee61
# ╟─e4d61f5a-5e56-4833-9928-a885f009a10b
# ╠═1df05690-1462-4275-9cd1-69b5e7306672
# ╟─d70e9deb-cf29-4bd2-a4e6-fd7662a0f97c
# ╠═a4a1d7bd-3a1c-4d50-a6aa-3aa5eec34889
# ╠═d4f95d08-9558-4daf-a4fd-f950139ddf31
# ╠═bbf9fe09-f27e-4c8d-a617-60bd9fc75813
# ╠═a4aff13f-e988-4e2c-8e76-1ce3ae3b2483
# ╠═739dfd15-887b-4022-bfcd-46455a37fea9
