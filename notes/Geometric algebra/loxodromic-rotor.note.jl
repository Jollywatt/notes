### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ f72a34fe-df2f-11ef-2ed5-79d340c4978a
begin
	using Pkg
	Pkg.activate(Base.current_project())
	using GeometricAlgebra
	using Test
	using PlutoUI
end

# ╔═╡ 06f69267-a3eb-4bf7-98ac-ee3b9540ea70
@basis Cl(1,3)

# ╔═╡ 2e8ea2fe-8d82-4173-b0e0-35e76e143d94


# ╔═╡ 68087944-f13e-477c-9838-816170cab8dc
x = v12

# ╔═╡ ea3f7418-6946-464f-87b8-9b155e3538c9
y = v34

# ╔═╡ 2602d69b-b2cb-4ea3-be92-a6d70e9d4ab2
R = (1 - v12/v13)*(1 - v23/v34)/2

# ╔═╡ a14a3642-1ae7-4935-86ce-1b3e27abce06
R*x*~R

# ╔═╡ Cell order:
# ╠═f72a34fe-df2f-11ef-2ed5-79d340c4978a
# ╠═06f69267-a3eb-4bf7-98ac-ee3b9540ea70
# ╠═2e8ea2fe-8d82-4173-b0e0-35e76e143d94
# ╠═68087944-f13e-477c-9838-816170cab8dc
# ╠═ea3f7418-6946-464f-87b8-9b155e3538c9
# ╠═2602d69b-b2cb-4ea3-be92-a6d70e9d4ab2
# ╠═a14a3642-1ae7-4935-86ce-1b3e27abce06
