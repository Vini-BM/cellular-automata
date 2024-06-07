using Plots, Random, LinearAlgebra


maxh = 8

function setup(sqN)
    matrix = rand(0:6,(sqN,sqN))
    #matrix = zeros(sqN,sqN)
    for i in [1,Int(sqN/2),Int(sqN/2+1),sqN]
        matrix[i,:] .= 7
        matrix[:,i] .= 7
    end
    #matrix[1,:] .= 3
    #matrix[sqN,:] .= 3
    #matrix[:,1] .= 3
    #matrix[:,sqN] .= 3
    return matrix
end

function neighborIndices(i,j,x)

    # Top rows
    if i == 1
        # Left column
        if j == 1
            ind = [(i,j+1),(i+1,j)]
        # Right column
        elseif j == x
            ind = [(i,j-1),(i+1,j)]
        # Middle column
        else
            ind = [(i,j+1),(i,j-1),(i+1,j)]
        end

    # Bottom row
    elseif i == x
        # Left column
        if j == 1
            ind = [(i,j+1),(i-1,j)]
        # Right column
        elseif j == x
            ind = [(i,j-1),(i-1,j)]
        # Middle column
        else
            ind = [(i,j+1),(i,j-1),(i-1,j)]
        end

    # Middle rows
    else
        # Left column
        if j == 1
            ind = [(i,j+1),(i+1,j),(i-1,j)]
        # Right column
        elseif j == x
            ind = [(i,j-1),(i+1,j),(i-1,j)]
        # Middle columns
        else
            ind = [(i+1,j+1),(i,j-1),(i,j+1),(i-1,j-1)]
        end
    end

    """

    if i == 1 # upper row
        vertical = [1,2] # vertical neighbors

        if j == 1
            sides = [2] # side neighbors
            #indices = [(1,2)]

        elseif j == sqN # upper left corner
            sides = [x-1]
            #indices = [(1,x)]

        else # rest of the row
            sides = [j-1,j+1]
        end

    elseif i == x # lower row
        vertical = [x-1,x]

        if j == 1 # lower left corner
            sides = [2]
            #indices = [(x,2)]

        elseif j == x # lower right corner
            sides = [x-1]

        else # rest of the row
            sides = [j-1,j+1]
        end

    else # middle of the matrix
        vertical = [i-1,i,i+1]

        if j == 1 # left column
            sides = [2]

        elseif j == x # right column
            sides = [x-1]

        else # rest of the row
            sides = [j-1,j+1]
        end
    end

    indices = vec([(k,l) for k in vertical, l in sides])
    indices = vcat(indices,(k,j) for k in vertical])
    """

    return ind
end

function toppling!(i,j,matrix)
    x, y = size(matrix) # dimension
    matrix[i,j] -= maxh # update site
    indices = neighborIndices(i,j,x)
    for pair in indices
        k, l = pair
        matrix[k,l] += Int(maxh/4)
    end
end

function evolve!(matrix,colors,time)
    x, y = size(matrix)
    N = Int(x^2)
    t = 0
    heatmap!(matrix, framestyle=:none, background_color=:transparent, display=true, c=colors)
    while t < time
    #while any(z -> z >= maxh, matrix)
        site_index = rand(1:N)
        matrix[site_index] += 1
        if any(x -> x>=maxh, matrix)
            for i in 1:x, j in 1:x
                if matrix[i,j] >= maxh
                    toppling!(i,j,matrix)
                    #heatmap!(matrix, framestyle=:none, background_color=:transparent, display=true, c=colors)
                end
            end
        end
        heatmap!(matrix, framestyle=:none, background_color=:transparent, display=true, c=colors)
        t += 1
    end
end


sqN = 30
matrix = setup(sqN)
#println(matrix)
colors = cgrad([colorant"blue1",colorant"skyblue1",colorant"goldenrod2",colorant"firebrick",colorant"red1"])

evolve!(matrix,colors,1000)