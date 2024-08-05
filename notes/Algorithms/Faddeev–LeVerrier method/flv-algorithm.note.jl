using Test
using LinearAlgebra: I, tr, det

"""
Fadeev–LeVerrier algorithm

Given an ``n × n`` matrix `A`, return a named tuple with

- `inv`, the inverse matrix
- `det`, the determinant
- `c`, the coefficients of the characteristic polynomial ``χ(t) = Σ c[k] t^k``
"""
function fadeevleverrier(A::Matrix{T}) where T
	n = size(A, 1)
	c = ones(T, n + 1)
	N = zero(A)
	for k in reverse(0:n - 1)
		N = A*N + c[begin + k+1]*I
		c[begin + k] = tr(A*N)/(k - n)
	end
	(; inv = -N/c[1], det = (-1)^n*c[1], c)
end

function inplaceflv(A::Matrix)
	n = size(A, 1)
	c = 1
	N = zero(A)
	for k in 1:n - 1
		N -= c*I
		N *= A
		c = tr(N)/k
	end
	N -= c*I
	c = tr(N*A)/n
	N/c
end

function test()
	@testset "Fadeev-LeVerrier for n = $n" for n = 1:10
		for _ = 1:50
			A = 5randn(n,n)
			flv = fadeevleverrier(A)
			@test A*flv.inv ≈ I
			@test det(A) ≈ flv.det
			flv = inplaceflv(A)
			@test A*flv ≈ I
		end
	end
	nothing
end

