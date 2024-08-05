### A Pluto.jl notebook ###
# v0.20.5

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

# ╔═╡ 5c43be10-d0d2-4af1-93e7-351ff579b008
begin
	using Pkg
	Pkg.activate(".")
	using PlutoUI
	using GeometricAlgebra.MiniCAS
end

# ╔═╡ 7a13847d-c6cc-484c-aa09-eb9744301d36
md"""
# Single-term identities in geometric algebra

There are various identities in geometric algebra that involve combinations of the wedge product and contractions, ``∧``, ``\rfloor`` and ``\lfloor``, with only one term on either side.
Example 2-product identities are
```math
\begin{align}
a ∧ (b ∧ c) &= (a ∧ b) ∧ c \\
a \rfloor (b \lfloor c) &= (a \rfloor b) \lfloor c \\
(a \lfloor b) \lfloor c &= a \lfloor (b ∧ c) \\
a \rfloor (b \rfloor c) &= (a ∧ b) \rfloor c
\end{align}
```
and more interesting examples can be found when multivectors are repeated:
```math
\begin{align}
((a \rfloor x) \rfloor b) \rfloor x &= (a \rfloor x) ∧ (b \rfloor x) \\
\end{align}
```
This notebook show how you can algorithmically find all such ``n``-product identites for a sequence of ``n`` (possibly repeated) multivectors.
"""

# ╔═╡ 09350a28-c956-4082-9716-f047a39c4522
md"""
## Encoding binary expressions

First, we need a way to define non-associative binary expression trees such as ``((xx)x)`` or ``(x(xx)(x(xx)))``.
"""

# ╔═╡ 80829c52-146c-11f0-06a4-4149083dd0fd
function encode(dirs, ops, symbols)
	isempty(dirs) && return Expr(:call, ops[1], symbols[1], symbols[2])
	if dirs[1]
		Expr(:call, ops[1], encode(dirs[2:end], ops[2:end], symbols[1:end-1]), symbols[end])
	else
		Expr(:call, ops[end], symbols[1], encode(dirs[2:end], ops[1:end-1], symbols[2:end]))
	end
end

# ╔═╡ c5c73dcc-d987-41c7-9ce3-27de476ec0b4
@bind n Slider(1:8, show_value=true)

# ╔═╡ 4a00f80f-1466-41c2-9ba6-5efb502553f8
symbols = Symbol.('a' .+ (0:n))

# ╔═╡ 034eddde-ecf5-428e-94ae-6e69c0d1deb1
@bind i Slider(0:2^(n - 1) - 1)

# ╔═╡ 9675b866-1834-4403-8364-08d517032da4
dirs = 1 .== digits(i, base=2, pad=n - 1)

# ╔═╡ 735bf3df-cbb8-45f0-a763-568fc84cad2b
@bind k Slider(0:3^n - 1)

# ╔═╡ bbe38da3-3d33-4a22-b2b1-54468e8e3c2e
ops = (:∧, :⨼, :⨽)[1 .+ digits(k, base=3, pad=n)]

# ╔═╡ 56c621bc-aa61-4176-b192-abc3a7cbcf41
encode(dirs, ops, symbols)

# ╔═╡ a7c68205-d329-4801-b210-cdc99fbb9702
encode(dirs, ops, [Dict(:k => 1) for k in symbols])

# ╔═╡ b1ff63e1-6227-405d-9c6c-c3fe1b80fa69
a ∧ b = a + b

# ╔═╡ 0db35e54-0396-4fea-bc77-18fe8a0783c9
a ⨼ b = b - a

# ╔═╡ 57750cf8-40fe-4de4-ba54-040dceff26da
a ⨽ b = a - b

# ╔═╡ 9d4820b8-158f-426e-b33d-973ae5762826
expr = encode(dirs, ops, variable.(symbols))

# ╔═╡ a080d372-c2c9-4985-bcc1-8a509936f38d
toexpr(eval(expr), stable=true)

# ╔═╡ ccf64569-3523-4350-94ac-a037d8ab0f52
function identities(symbols::Symbol...)
	n = length(symbols) - 1
	vars = variable.(symbols)
	exprmap = Dict{Expr,Vector{Expr}}()
	for i in 0:2(n - 1) - 1
		dirs = 1 .== digits(i, base=2, pad=n - 1)
		for k in 0:3^n - 1
			ops = (:∧, :⨼, :⨽)[1 .+ digits(k, base=3, pad=n)]
			expr = toexpr(encode(dirs, ops, vars))
			key = toexpr(eval(expr), stable=true)
			if key ∉ keys(exprmap)
				exprmap[key] = []
			end
			push!(exprmap[key], expr)
		end
	end
	exprmap
end

# ╔═╡ 57e67213-5c98-4dde-a0af-2d828dd428ec
identities(:a, :b, :c)

# ╔═╡ 66ce279d-b53c-45b4-9b74-2fd3ad625aa2


# ╔═╡ da211f42-f7a5-4f2c-b67a-28b607866d03


# ╔═╡ c7dd12fd-a224-4cfa-b7cd-d5754d1ce0e3
md"""
# Imports
"""

# ╔═╡ Cell order:
# ╟─7a13847d-c6cc-484c-aa09-eb9744301d36
# ╟─09350a28-c956-4082-9716-f047a39c4522
# ╟─80829c52-146c-11f0-06a4-4149083dd0fd
# ╠═9675b866-1834-4403-8364-08d517032da4
# ╠═bbe38da3-3d33-4a22-b2b1-54468e8e3c2e
# ╠═4a00f80f-1466-41c2-9ba6-5efb502553f8
# ╠═c5c73dcc-d987-41c7-9ce3-27de476ec0b4
# ╠═034eddde-ecf5-428e-94ae-6e69c0d1deb1
# ╠═735bf3df-cbb8-45f0-a763-568fc84cad2b
# ╠═56c621bc-aa61-4176-b192-abc3a7cbcf41
# ╠═57e67213-5c98-4dde-a0af-2d828dd428ec
# ╠═a7c68205-d329-4801-b210-cdc99fbb9702
# ╠═b1ff63e1-6227-405d-9c6c-c3fe1b80fa69
# ╠═0db35e54-0396-4fea-bc77-18fe8a0783c9
# ╠═57750cf8-40fe-4de4-ba54-040dceff26da
# ╠═9d4820b8-158f-426e-b33d-973ae5762826
# ╠═a080d372-c2c9-4985-bcc1-8a509936f38d
# ╠═ccf64569-3523-4350-94ac-a037d8ab0f52
# ╠═66ce279d-b53c-45b4-9b74-2fd3ad625aa2
# ╠═da211f42-f7a5-4f2c-b67a-28b607866d03
# ╟─c7dd12fd-a224-4cfa-b7cd-d5754d1ce0e3
# ╠═5c43be10-d0d2-4af1-93e7-351ff579b008
