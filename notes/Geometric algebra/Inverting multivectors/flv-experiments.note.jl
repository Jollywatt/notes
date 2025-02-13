using CSV, DataFrames
using GeometricAlgebra

GeometricAlgebra.use_symbolic_optim(sig) = false

function faddeevleverrier(A, n)
	c = ones(eltype(A), n + 1)
	N = zero(A)
	k = n - 1
	while k >= 0
		N = A*N + c[begin + k+1]
		c[begin + k] = (A⊙N)*n/(k - n)
		k -= 1
	end
	(; inv = -N/c[1], det = (-1)^n*c[1], c)
end


Base.randn(A::Type{Multivector{Sig,K}}) where {Sig,K} = A(randn(BigFloat, ncomponents(A)))

"""
Find the minimum number of steps requred by the Faddeev–LeVerrier inverse
algorithm for a multivector by simply trying it out.
"""
function magicnumber(A::Multivector; startfrom=0)
	for n = 2 .^ (startfrom:dimension(A))
		println("Trying n = $n")
		I = faddeevleverrier(A, n).inv*A
		sum(abs2, (I - 1).comps) < 1e-10 && return n
	end
	Inf
end

"""
Find the minimum magic number for a sample of random multivectors of the
given signature and grade.
"""
magicnumber(sig, k; samples=3) = minimum(magicnumber(randn(Multivector{sig, k})) for _ in 1:samples)


"""
Find the magic numbers of multivectors in every non-degenerate geometric algebra
for the given dimensions. Homogeneous multivectors of every grade are tried, as
well as odd, even, and fully general multivectors.
"""
function allsigs(dims = 0:4; append=false)
	file = "steps-by-sig-k.csv"
	df = append ? CSV.read(file, DataFrame) : DataFrame()
	for n in dims
		for q in 0:n
			p = n - q
			ks = Any[0:n;]
			n >= 2 && push!(ks, 0:2:n)
			n >= 3 && push!(ks, 1:2:n)
			n >= 1 && push!(ks, 0:n)
			for k in ks
				steps = magicnumber(Cl(p, q), k)
				@info n (p, q) k steps
				push!(df, (; n, sig = (p, q), k, steps), promote=true)
				CSV.write("steps-by-sig-k.csv", df)
			end
		end
	end
	df
end

"""
Find the magic numbers of homogeneous, odd, even, and general multivectors in
the Euclidean geometric algebra ``Cl(n)`` of the given dimensions.
"""
function justdim(dims = 0:4; append=false)
	file = "steps-by-n-k.csv"
	df = append ? CSV.read(file, DataFrame) : DataFrame()
	for n in dims
		for k in 0:n
			steps = magicnumber(n, k, samples=2)
			@info n k steps
			push!(df, (; n, k, steps))
			CSV.write(file, df)
		end
	end
end
