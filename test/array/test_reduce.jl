using DataValues
using Base.Test

@testset "DataValueArray: Reduce" begin

srand(1)
f(x) = 5 * x
f{T<:Number}(x::DataValue{T}) = ifelse(isnull(x), DataValue{typeof(5 * x.value)}(),
                                                    DataValue(5 * x.value))

for N in (10, 2050)
    A = rand(N)
    M = rand(Bool, N)
    i = rand(1:N)
    M[i] = true
    j = rand(1:N)
    while j == i
        j = rand(1:N)
    end
    M[j] = false
    X = DataValueArray(A)
    Y = DataValueArray(A, M)
    B = A[find(x->!x, M)]

    @test isequal(mapreduce(f, +, X), DataValue(mapreduce(f, +, X.values)))
    @test isequal(mapreduce(f, +, Y), DataValue{Float64}())
    v = mapreduce(f, +, Y, skipna=true)
    @test v.value ≈ mapreduce(f, +, B)
    @test !isnull(v)

    @test isequal(reduce(+, X), DataValue(reduce(+, X.values)))
    @test isequal(reduce(+, Y), DataValue{Float64}())
    v = reduce(+, Y, skipna=true)
    @test v.value ≈ reduce(+, B)
    @test !isnull(v)

    for method in (
        sum,
        prod,
        minimum,
        maximum,
    )
        @test method(X) == DataValue(method(A))
        @test method(f, X) == DataValue(method(f, A))
        @test method(Y) == DataValue{Float64}()
        v = method(Y, skipna=true)
        @test v.value ≈ method(B)
        @test !isnull(v)
        @test method(f, Y) == DataValue{Float64}()
        v = method(f, Y, skipna=true)
        @test v.value ≈ method(f, B)
        @test !isnull(v)
    end

    @test isequal(extrema(X), (DataValue(minimum(A)), DataValue(maximum(A))))
    @test isequal(extrema(Y), (DataValue{Float64}(), DataValue{Float64}()))
    v1 = extrema(Y, skipna=true)
    v2 = extrema(B)
    @test v1[1].value == v2[1]
    @test !isnull(v1[1])
    @test v1[2].value == v2[2]
    @test !isnull(v1[2])

    H = rand(Bool, N)
    G = H[find(x->!x, M)]
    U = DataValueArray(H)
    V = DataValueArray(H, M)

    for op in (
        &,
        |,
    )
        @test isequal(reduce(op, U),
                        DataValue(reduce(op, H)))
        @test isequal(reduce(op, U, skipna=true),
                        DataValue(reduce(op, H)))
        @test isequal(reduce(op, V, skipna=true),
                        DataValue(reduce(op, G)))
    end
end

end
