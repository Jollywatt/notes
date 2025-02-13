### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 9a3d846c-91f2-11ef-17b5-a7cf2fc76b70
md"""
# Matrix-by-matrix derivatives

For a function ``f : \mathbb R^{n\times m} \to \mathbb R^{a\times b}``, the derivative each of the ``a\times b`` output components has a scalar derivative for each of the ``n\times m`` input components.

Thus, the derivative ``∂f(X)/∂X`` is a rank-``4`` tensorial object with ``n\times m\times a\times b`` degrees of freedom.

One way (not the only way!) to write this object is as a block matrix:
```math
\frac{∂ f(X)}{∂ X} = 
\begin{bmatrix}
\left[\frac{∂f_{ij}(X)}{∂X_{11}}\right]_{ij}
& \cdots &
\left[\frac{∂f_{ij}(X)}{∂X_{1m}}\right]_{ij} \\
\vdots & \ddots & \vdots \\
\left[\frac{∂f_{ij}(X)}{∂X_{n1}}\right]_{ij}
& \cdots &
\left[\frac{∂f_{ij}(X)}{∂X_{nm}}\right]_{ij} \\
\end{bmatrix}
```
where each submatrix is
```math
\left[\frac{∂f_{ij}(X)}{∂X_{kl}}\right]_{ij} =
\begin{bmatrix}
\frac{∂f_{11}(X)}{∂X_{kl}}
& \cdots &
\frac{∂f_{1b}(X)}{∂X_{kl}} \\
\vdots & \ddots & \vdots \\
\frac{∂f_{a1}(X)}{∂X_{kl}}
& \cdots &
\frac{∂f_{ab}(X)}{∂X_{kl}} \\
\end{bmatrix}
```
"""

# ╔═╡ 77bfc30b-f009-4462-bc6c-07b81aa45da4
md"""
A simple Julia implementation of this matrix-matrix derivative:
"""

# ╔═╡ bb7dfe74-bec2-4dc6-9df5-718cbd4da954
onehot(A, I) = CartesianIndices(A) .== CartesianIndex(I)

# ╔═╡ eb5e4c7f-4bf5-41ff-880c-3c12d299a0ce
onehot(rand(2,3), (1, 2))

# ╔═╡ 4b878bbf-ab4a-499f-8c2b-bb1687299cac
function ∂ij(f, X, I, eps=1e-8)
	ε = onehot(X, I)*eps
	(f(X + ε) - f(X))/eps
end

# ╔═╡ f15954fe-d1a9-4a7c-a945-89c5728f2802
∂(f, X, eps=1e-8) = hvcat(size(X, 1), (∂ij(f, X, I)' for I in CartesianIndices(X))...)'

# ╔═╡ 884e5460-7bf7-413a-948c-53fd7b88e07b
md"""
## Examples
"""

# ╔═╡ 9214d0e9-b6ca-456f-87b4-e617f9b0447d
f(X) = X^2

# ╔═╡ 9a1a3919-a7b3-4efd-9cc1-7d39f4e65b0d
X0 = [1 2; 0 1]

# ╔═╡ a9e118fa-0fca-4457-a35c-a50a6296072a
∂ij(f, X0, (2,1))

# ╔═╡ ec8c93fe-4064-4a2b-8482-1cf13151823c
∂(f, X0)

# ╔═╡ Cell order:
# ╟─9a3d846c-91f2-11ef-17b5-a7cf2fc76b70
# ╟─77bfc30b-f009-4462-bc6c-07b81aa45da4
# ╠═bb7dfe74-bec2-4dc6-9df5-718cbd4da954
# ╠═eb5e4c7f-4bf5-41ff-880c-3c12d299a0ce
# ╠═4b878bbf-ab4a-499f-8c2b-bb1687299cac
# ╠═f15954fe-d1a9-4a7c-a945-89c5728f2802
# ╟─884e5460-7bf7-413a-948c-53fd7b88e07b
# ╠═9214d0e9-b6ca-456f-87b4-e617f9b0447d
# ╠═9a1a3919-a7b3-4efd-9cc1-7d39f4e65b0d
# ╠═a9e118fa-0fca-4457-a35c-a50a6296072a
# ╠═ec8c93fe-4064-4a2b-8482-1cf13151823c
