### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ d22d1886-f2c9-485b-a2b9-57394db401f2
using LinearAlgebra: I

# ╔═╡ 0511aa0d-18bd-4bc4-9ee8-202dcaf92844
md"""
# Solving for reciprocal bases

Demonstration of how to compute the [reciprocal basis](https://jollywatt.github.io/notes/reciprocal-basis) of a basis with respect to a given bilinar form.
"""

# ╔═╡ 1c469e3b-d4ae-4779-9b74-fac145674991
md"### Basis"

# ╔═╡ 530ce41c-cf6b-11ef-27e3-7b232c04ad97
n = 5 # dimension

# ╔═╡ d3e7715f-2a33-416d-ad89-738076149ee7
E = randn(n, n)

# ╔═╡ 4b3dd74d-6bc3-4bd2-83e4-841063b40328
e = eachcol(E)

# ╔═╡ 5e1f6918-dfb3-4e54-af08-6d7f86a58c79
md"### Bilinear form"

# ╔═╡ f2c75782-b934-441b-89cb-5917a53a2225
A = I + randn(n, n)

# ╔═╡ 1c5c38bc-bd51-448b-a8aa-4c606a882ced
u ⋅ v = u'A*v

# ╔═╡ f98f72fe-9c1c-4648-9049-db475652862f
all(A[i,j] == (1:n .== i)⋅(1:n .== j) for i=1:n, j=1:n)

# ╔═╡ dedd72e7-95ff-4676-88ce-e80041d2bf5c
md"### Gram matrix"

# ╔═╡ 30057b2e-487c-464a-82cd-d27b18aec0ea
G = E'A*E

# ╔═╡ 96aa671d-50b0-454a-88fb-3095d9fb8677
all(G[i,j] == e[i]⋅e[j] for i=1:n, j=1:n)

# ╔═╡ fe90ec41-82fa-4df6-b0b7-9c3c9f9acc62
md"### Reciproal basis"

# ╔═╡ fe71b82d-bdc3-4893-970a-97bfd624f429
Ē = E*inv(G)

# ╔═╡ 867bd52a-db96-4c45-b70d-450d9534da03
ē = eachcol(Ē)

# ╔═╡ 4bf09201-8843-4cc3-9c2e-a1bf1074af90
md"Testing that `e` and `ē` form a biorthogonal system:"

# ╔═╡ 4aab97f1-888a-4614-b9a9-f1cbf53a5b2c
E'A*Ē ≈ I

# ╔═╡ a049cc29-0e9e-464d-9ac4-b241d0e8781c
all(≈(e[i]⋅ē[j], I[i,j], atol=sqrt(eps())) for i=1:n, j=1:n)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "ac1187e548c6ab173ac57d4e72da1620216bce54"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"
"""

# ╔═╡ Cell order:
# ╟─0511aa0d-18bd-4bc4-9ee8-202dcaf92844
# ╠═d22d1886-f2c9-485b-a2b9-57394db401f2
# ╟─1c469e3b-d4ae-4779-9b74-fac145674991
# ╠═530ce41c-cf6b-11ef-27e3-7b232c04ad97
# ╠═d3e7715f-2a33-416d-ad89-738076149ee7
# ╠═4b3dd74d-6bc3-4bd2-83e4-841063b40328
# ╟─5e1f6918-dfb3-4e54-af08-6d7f86a58c79
# ╠═f2c75782-b934-441b-89cb-5917a53a2225
# ╠═1c5c38bc-bd51-448b-a8aa-4c606a882ced
# ╠═f98f72fe-9c1c-4648-9049-db475652862f
# ╟─dedd72e7-95ff-4676-88ce-e80041d2bf5c
# ╠═30057b2e-487c-464a-82cd-d27b18aec0ea
# ╠═96aa671d-50b0-454a-88fb-3095d9fb8677
# ╟─fe90ec41-82fa-4df6-b0b7-9c3c9f9acc62
# ╠═fe71b82d-bdc3-4893-970a-97bfd624f429
# ╠═867bd52a-db96-4c45-b70d-450d9534da03
# ╟─4bf09201-8843-4cc3-9c2e-a1bf1074af90
# ╠═4aab97f1-888a-4614-b9a9-f1cbf53a5b2c
# ╠═a049cc29-0e9e-464d-9ac4-b241d0e8781c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
