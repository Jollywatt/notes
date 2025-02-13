using CSV, DataFrames, DataFramesMeta

using Test
using Memoize

@memoize function getraw()
	df = mapcols(CSV.read("algorithm-steps.csv", DataFrame, types=String)) do col
		@. eval(Meta.parse(col))
	end
end



"""
Test that the number of steps required is a function of
the dimension and grade only; not the signature.
"""
function dependson()
	df = getraw()
	rhs = @chain df begin
		@groupby :n :k
		@combine :minsteps = minimum(:steps)
	end
	df = leftjoin(df, rhs, on = [:n, :k])
	@test df.steps == df.minsteps
end

"""
Test that the number of steps for a general multivector with
dimension `n` and grades `0:n` is `2^cld(n, 2)`.

Tests all signatures ``Cl(p, q, 0)``, ``p + q <= 10``.
"""
function fullmvs()
	df = @chain getraw() begin
		@subset @byrow :k == 0:(:n)
		@groupby :n
		@combine :steps = unique(:steps)
		@transform @byrow :pred = 2^cld(:n, 2)
	end
	@test df.steps == df.pred
end

"""
Test that the number of steps for an even multivector with
dimension `n` and grades `0:2:n` is `2^fld(n, 2)`.

Tests all signatures ``Cl(p, q, 0)``, ``p + q <= 10``.
"""
function evenmvs()
	df = @chain getraw() begin
		@subset @byrow :k == 0:2:(:n)
		@groupby :n
		@combine :steps = unique(:steps)
		@transform @byrow :pred = 2^fld(:n, 2)
	end
	@test df.steps == df.pred
end

"""
Test that the number of steps for an odd multivector with
dimension `n` and grades `1:2:n` is `2^cld(n, 2)`.

Tests all signatures ``Cl(p, q, 0)``, ``p + q <= 10``.
"""
function oddmvs()
	df = @chain getraw() begin
		@subset @byrow :k == 1:2:(:n)
		@groupby :n
		@combine :steps = unique(:steps)
		@transform @byrow :pred = 2^cld(:n, 2)
	end
	@test df.steps == df.pred
end

"""
Test that the number of steps for scalars is 1, and for
pseudoscalars and (pseudo)vectors is 2.

Tests all signatures ``Cl(p, q, 0)``, ``p + q <= 10``.
"""
function scalarsquaremvs()
	df = @chain getraw() begin
		@subset @byrow :k in (0, 1, :n - 1, :n)
		@transform @byrow :pred = :k == 0 ? 1 : 2
	end
	@test df.steps == df.pred
end
