using Printf
using GLMakie

const neighbours = [
	CartesianIndex(0, +1)
	CartesianIndex(0, -1)
	CartesianIndex(+1, 0)
	CartesianIndex(-1, 0)
]

function energy(m, C)
	E = 0
	for I in CartesianIndices(m)
		m[I] || continue
		for Δ in neighbours
			if get(m, I + Δ, false)
				E += 1
			end
		end
	end
	E += C*sum(m)
	return E
end



function main(N=100)
	o = Observable(reshape((1:N^2) .< fld(N^2, 2), N, N))

	fig = Figure()
	ax = Axis(fig[1,1])

	T = Slider(fig[1,2], range = logrange(0.01, 10, length=200), horizontal = false, startvalue = 0)
	C = Slider(fig[2,1], range = range(-10, 10, length=201), horizontal = true, startvalue = 0)
	label = Label(fig[0, :], "Parameters", fontsize = 30)

	plot!(ax, o)
	display(fig)

	indices = eachindex(o[])
	i = 0
	while true
		m = o[]

		E = -Inf
		for _ in 1:100
			i = rand(indices)
			m[i] ⊻= true
			E′ = energy(m, C.value[])
			α = exp((E′ - E)/T.value[])
			if rand() < α # accept
				E = E′
			else # reject (and undo)
				m[i] ⊻= true
			end
		end

		label.text[] = replace(@sprintf("T = %.5f, C = %+.5f", T.value[], C.value[]), '-'=>'−')

		o[] = m
		sleep(0.001)

		i += 1
	end
end

