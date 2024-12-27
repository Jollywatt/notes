### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 9454189e-6168-48bb-bed0-2af2e6b32488
md"""
# A toy autodiff implementation

## Representing programs in SSA form

We assume programs are provided in static single assignment (SSA) form.
These can be visualised as directed acyclic graphs (DAGs), where nodes are single function calls, ingoing edges are input variables, and outgoing edges are return values. Edges are labelled with variable names.

We represent a program as vector of triples `(ins, fn, outs)`, where `ins`/`outs` are input/output variables or ingoing/outgoing edges and `fn` is the function to call.

For example, the SSA expression `a = x + y` corresponds to the triple ``((x, y), +, a)``, modelled as:
"""

# ╔═╡ d4c40cd9-734a-4208-ba4b-992bd242f9d8
md"""
A program is then a series of these steps:
"""

# ╔═╡ 3396f34e-760a-4a5b-8495-44435c57d40e
md"""
For readability, variables are always named.
Programs are run by evaluating each step top-to-bottom, storing the new variables in a local scope.

The program's inputs are any undefined variables, and the return values are any unused variables.
"""

# ╔═╡ 37a34041-510d-48fb-9c6f-0302e8c1ab97
md"""
## Forward mode

The basic ingredients for differentiating programs in forward mode are the derivatives of basic functions and a composition rule for applying these to composite programs.

### Pushforward rules for basic functions

The _pushforward_ of a function is its directional derivative or Jacobian–vector product at a given point in a given direction.

Here are some pushforwards of some simple functions:
"""

# ╔═╡ e2dad971-693a-416e-ae93-5bafae2b0dbf
begin
	pushforward(::typeof(*), (x, y), (dx, dy)) = dx*y + x*dy
	pushforward(::typeof(sin), (x,), (dx,)) = cos(x)*dx
	pushforward(::typeof(+), (x, y), (dx, dy)) = dx + dy
end

# ╔═╡ 8757e3cb-2113-4b27-b49c-044f1ef34b00
md"""
Forward mode maps a SSA expression ``y = f(x)`` to ``(y, \mathrm dy) = F\{f\}(x, \mathrm dx)`` where the pushforward ``F\{f\}`` computes the function value and its differential in one call.
"""

# ╔═╡ 28c349c0-59eb-455b-9cae-b2ca06646687
md"""
To differentiate an entire program, we simply interleave the pushforward steps with the primal steps:
"""

# ╔═╡ 995b4843-120c-40c7-9546-a4ffc3f69f80
md"""
A simple optimisation we can do is fuse the primal and pushforward steps together, like so:
"""

# ╔═╡ dbad0e65-c0c0-4022-a4f4-f11349e9860f
md"""
Now the forward derivative program looks like this:
"""

# ╔═╡ 53782355-f328-47ed-96b0-17ad3c74ea0f
md"""
## Reverse mode

Like for forward mode, the ingredients for reverse mode are the derivatives of basic functions and a composition rule.

### Basic pullbacks

The _pullback_ ``R\{f\}`` of a function is the adjoint operator of the pushforward ``F\{f\}``, in the sense that
```math
\langle ∂y, F\{f\}(x, \mathrm d x) ⟩ = \langle R\{f\}(x, ∂y), \mathrm d x ⟩
```
for an inner product ``\langle \phantom{x}, \phantom{x} \rangle``.
"""

# ╔═╡ bbe63911-c896-4651-a98d-5b14229a3349
begin
	pullback(::typeof(*), (x, y), (z̄,)) = (z̄*y, x*z̄)
	pullback(::typeof(sin), (x,), (ȳ,)) = cos(x)*ȳ
	pullback(::typeof(+), (x, y), (z̄,)) = (z̄, z̄)
end

# ╔═╡ 56bfc3ac-0d2e-4a11-90b5-4a9bbdacd363
md"""
Reverse mode maps an SSA expression ``y = f(x)`` to ``∂x = R\{f\}(x, ∂y)``.
"""

# ╔═╡ 0f1eca56-0b7b-4689-8042-e6bc2ef91eb3
md"""
To differentiate an entire program, we need to run the primal steps first before running the reverse mode steps in reverse order.
"""

# ╔═╡ f7070625-3d47-4ec3-bf38-5e80c3d96091
md"""
# Utilities
"""

# ╔═╡ a26edc9b-0b30-4ecc-bb70-40c0e3231993
begin
	toexpr(x::Symbol) = x
	toexpr(xs::Tuple) = :(($(toexpr.(xs)...),))
	
	wrap_tuple(a) = tuple(a)
	wrap_tuple(a::Tuple) = a
	
	unwrap_tuple(x) = x
	unwrap_tuple(x::Tuple) = length(x) == 1 ? x[1] : x
	
	flatten(x::Symbol) = x
	flatten(xs) = reduce(vcat, map(flatten, xs))
	
	substitute(vars, x::Symbol) = vars[x]
	substitute(vars, x::Tuple) = substitute.(Ref(vars), x)
	
	substitute!(vars, val, x::Symbol) = vars[x] = get(vars, x, zero(val)) + val
	substitute!(vars, val, x::Tuple) = substitute!.(Ref(vars), val, x)

	recurse(fn, x::Symbol) = fn(x)
	recurse(fn, xs::Tuple) = recurse.(fn, xs)
end

# ╔═╡ f5d6e418-fd77-4bbd-9fa6-0164ba697bb8
get_vars(program) = flatten(getfield.(program, :x)), flatten(getfield.(program, :y))

# ╔═╡ 71339e00-99b6-4ab1-a875-c5b81c07d0f6
outputs(program) = let (xs, ys) = get_vars(program)
	setdiff(ys, xs)
end

# ╔═╡ 942fb8c1-0609-4f83-b8e3-e2d30c6ac2fb
function eval_program(program; args...)
	vars = Dict{Symbol,Any}(pairs(args))
	for step in program
		vals = step.f(substitute(vars, step.x)...)
		substitute!(vars, vals, step.y)
	end
	Tuple(k => vars[k] for k in outputs(program))
end

# ╔═╡ dd2eb286-9e9f-4ee2-8249-2fea40570137
nicetuple(x) = wrap_tuple(unwrap_tuple.(x))

# ╔═╡ b4454e07-1e66-4f9c-9419-c06372d77b91
struct ProgramStep
	f
	x::Tuple
	y::Tuple
	label
	ProgramStep(f, x, y; label=nothing) = new(f, nicetuple(x), nicetuple(y), label)
end

# ╔═╡ ab709caf-063e-4a02-9dd7-68ec038a1f86
ProgramStep(+, (:x, :y), :a)

# ╔═╡ 75301025-57a6-4009-9037-04b177a3da6f
program = ProgramStep[
	(:x, :y) => (*) => :a
	:x => sin => :b
	(:a, :b) => (+) => :f
]

# ╔═╡ c7e50f28-634e-4a7f-be32-55c9405fddd6
eval_program(program, x=1, y=8)

# ╔═╡ a3858acb-fc8e-43d2-b752-baabb9509477
forward_diff(steps::Vector{ProgramStep}) = vec(permutedims([steps forward_diff.(steps)]))

# ╔═╡ e5496e1f-2e66-4d4c-b4f9-414aae849e05
reverse_diff(steps::Vector{ProgramStep}) = [
	program
	reverse(reverse_diff.(program))
]

# ╔═╡ c34560d9-9014-4bfe-b602-2a364277763e
Base.convert(::Type{ProgramStep}, (x, (f, y))::Pair) = ProgramStep(f, x, y)

# ╔═╡ 92f67dfb-a107-4786-be0a-bff0e3080fdf
function Base.show(io::IO, step::ProgramStep)
	label = something(step.label, nameof(step.f))
	print(io, :($(toexpr(unwrap_tuple(step.y))) := $label($(toexpr.(step.x)...))))
end

# ╔═╡ 983b1fcd-72d7-4d66-ae2f-2e728bc4bc2d
prefix(pre, xs) = recurse(xs) do x
	Symbol("$pre$x")
end

# ╔═╡ 7e9e7fbb-1c6c-41c1-a425-56e632c3f9b6
forward_diff(step::ProgramStep) = ProgramStep(
	(x, dx) -> pushforward(step.f, x, dx),
	(step.x, prefix(:d, step.x)),
	prefix(:d, step.y),
	label=:(F{$(step.f)}) # give the pushforward a prettier name
)

# ╔═╡ 6d326523-ddef-4bda-8f2d-2fed52d5be74
fprogram = forward_diff(program)

# ╔═╡ 10bc9787-8034-4c3d-95d6-3d1317942d12
forward_diff_fused(step::ProgramStep) = ProgramStep(
	(x, dx) -> (step.f(x...), pushforward(step.f, x, dx)),
	(step.x, prefix(:d, step.x)),
	(step.y, prefix(:d, step.y)),
	label=:(F{$(step.f)})
)

# ╔═╡ 8ab22cb1-7d21-45ec-9fd4-a8597e46e16c
fprogram_fused = forward_diff_fused.(program)

# ╔═╡ 387865ba-f029-4cc9-a8e5-5b58845c8d8e
eval_program(fprogram_fused, x=10, y=2, dx=1, dy=0)

# ╔═╡ 496a36dc-0c2c-45bb-a818-0615186a9093
reverse_diff(step::ProgramStep) = ProgramStep(
	(x, ∂y) -> pullback(step.f, x, ∂y),
	(step.x, prefix(:∂, step.y)),
	prefix(:∂, step.x),
	label=:(R{$(step.f)})
)

# ╔═╡ 3e0152a5-7a2f-4bf3-add8-b29af69f44d3
rprogram = reverse_diff(program)

# ╔═╡ 473818b5-4f9e-4fca-bfc4-09796559e20b
eval_program(rprogram, x=1, y=2, ∂f=1)

# ╔═╡ Cell order:
# ╟─9454189e-6168-48bb-bed0-2af2e6b32488
# ╠═ab709caf-063e-4a02-9dd7-68ec038a1f86
# ╟─d4c40cd9-734a-4208-ba4b-992bd242f9d8
# ╠═75301025-57a6-4009-9037-04b177a3da6f
# ╟─3396f34e-760a-4a5b-8495-44435c57d40e
# ╠═c7e50f28-634e-4a7f-be32-55c9405fddd6
# ╟─37a34041-510d-48fb-9c6f-0302e8c1ab97
# ╠═e2dad971-693a-416e-ae93-5bafae2b0dbf
# ╟─8757e3cb-2113-4b27-b49c-044f1ef34b00
# ╠═7e9e7fbb-1c6c-41c1-a425-56e632c3f9b6
# ╟─28c349c0-59eb-455b-9cae-b2ca06646687
# ╠═a3858acb-fc8e-43d2-b752-baabb9509477
# ╠═6d326523-ddef-4bda-8f2d-2fed52d5be74
# ╟─995b4843-120c-40c7-9546-a4ffc3f69f80
# ╠═10bc9787-8034-4c3d-95d6-3d1317942d12
# ╟─dbad0e65-c0c0-4022-a4f4-f11349e9860f
# ╠═8ab22cb1-7d21-45ec-9fd4-a8597e46e16c
# ╠═387865ba-f029-4cc9-a8e5-5b58845c8d8e
# ╟─53782355-f328-47ed-96b0-17ad3c74ea0f
# ╠═bbe63911-c896-4651-a98d-5b14229a3349
# ╟─56bfc3ac-0d2e-4a11-90b5-4a9bbdacd363
# ╠═496a36dc-0c2c-45bb-a818-0615186a9093
# ╟─0f1eca56-0b7b-4689-8042-e6bc2ef91eb3
# ╠═e5496e1f-2e66-4d4c-b4f9-414aae849e05
# ╠═3e0152a5-7a2f-4bf3-add8-b29af69f44d3
# ╠═473818b5-4f9e-4fca-bfc4-09796559e20b
# ╟─f7070625-3d47-4ec3-bf38-5e80c3d96091
# ╠═b4454e07-1e66-4f9c-9419-c06372d77b91
# ╠═c34560d9-9014-4bfe-b602-2a364277763e
# ╠═f5d6e418-fd77-4bbd-9fa6-0164ba697bb8
# ╠═71339e00-99b6-4ab1-a875-c5b81c07d0f6
# ╠═942fb8c1-0609-4f83-b8e3-e2d30c6ac2fb
# ╠═92f67dfb-a107-4786-be0a-bff0e3080fdf
# ╠═dd2eb286-9e9f-4ee2-8249-2fea40570137
# ╠═a26edc9b-0b30-4ecc-bb70-40c0e3231993
# ╠═983b1fcd-72d7-4d66-ae2f-2e728bc4bc2d
