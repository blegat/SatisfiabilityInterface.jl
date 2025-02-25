using SatisfiabilityInterface: subscript


@testset "Sudoku" begin


    function all_different(v)
        vv = vec(v)
        n = length(vv)

        return [vv[i] ≠ vv[j] for i in 1:n for j in i+1:n]
    end



    function make_matrix(name, T, m, n)
        return [T(Symbol(name, subscript(i), ",", subscript(j))) 
            for i in 1:m, j in 1:n]
    end

    n = 9
    M = make_matrix(:M, BoundedInteger{n}, n, n)

    m = Model()

    push!(m, vec(M)...)


    for i in 1:n
        append!(m.constraints, all_different(M[:, i]))  # columns
        append!(m.constraints, all_different(M[i, :]))  # rows
    end

    # blocks:
    for i in 0:2, j in 0:2
        append!(m.constraints, all_different(M[3i+1:3i+3, 3j+1:3j+3]))
    end

    i, j = 0, 0
    all_different(M[3i+1:3i+3, 3j+1:3j+3])

    ## initial condition from https://www.juliaopt.org/notebooks/JuMP-Sudoku.html

    initial = [
    5 3 -1 -1 7 -1 -1 -1 -1
    6 -1 -1 1 9 5 -1 -1 -1
    -1 9 8 -1 -1 -1 -1 6 -1
    8 -1 -1 -1 6 -1 -1 -1 3
    4 -1 -1 8 -1 3 -1 -1 1
    7 -1 -1 -1 2 -1 -1 -1 6
    -1 6 -1 -1 -1 -1 2 8 -1
    -1 -1 -1 4 1 9 -1 -1 5
    -1 -1 -1 -1 8 -1 -1 7 9
    ]

    for i in 1:9, j in 1:9
        if initial[i, j] > 0 
            push!(m.constraints, M[i, j] ~ initial[i, j])
        end
    end

    @time status, results = solve(m);

    output = [results[M[i, j]] for i in 1:9, j in 1:9]

    @test output == [
        5  3  4  6  7  8  9  1  2
        6  7  2  1  9  5  3  4  8
        1  9  8  3  4  2  5  6  7
        8  5  9  7  6  1  4  2  3
        4  2  6  8  5  3  7  9  1
        7  1  3  9  2  4  8  5  6
        9  6  1  5  3  7  2  8  4
        2  8  7  4  1  9  6  3  5
        3  4  5  2  8  6  1  7  9
    ]

end