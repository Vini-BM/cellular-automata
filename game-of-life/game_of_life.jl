using Plots, Random

function setup(x,y)
    matrix = rand([0,1],(x,y))
    for i in [1,Int(x/2),Int(x/2+1),x]
        matrix[i,:] .= 1
    end
    for j in [1,Int(y/2),Int(y/2+1),y]
        matrix[:,j] .= 1
    end
    #matrix[1,:] .= 3
    #matrix[sqN,:] .= 3
    #matrix[:,1] .= 3
    #matrix[:,sqN] .= 3
    return matrix
end

function getNeighbors(i,j,matrix)
    n, m = size(matrix) # dimensions

    if i == 1 # upper row
        vertical = [n,1,2] # vertical neighbors

        if j == 1
            sides = [m,2] # side neighbors

        elseif j == m # upper left corner
            sides = [1,m-1]

        else # rest of the row
            sides = [j-1,j+1]
        end

    elseif i == n # lower row
        vertical = [n-1,n,1]

        if j == 1 # lower left corner
            sides = [m,2]

        elseif j == m # lower right corner
            sides = [1,m-1]

        else # rest of the row
            sides = [j-1,j+1]
        end

    else # middle of the matrix
        vertical = [i-1,i,i+1]

        if j == 1 # left column
            sides = [m,2]

        elseif j == m # right column
            sides = [1,m-1]

        else # rest of the row
            sides = [j-1,j+1]
        end
    end

    neighbors = vec([matrix[k,l] for k in vertical, l in sides])
    neighbors = vcat(neighbors,[matrix[k,j] for k in vertical])

    return neighbors
end

function condition(state,sum)
    if state == 1 && ((sum < 2) || (sum > 3))
        state = 0
    #end
    elseif state == 0 && sum == 3
        state = 1
    end

    return state
end

function evolve!(matrix,time)
    n, m = size(matrix) # dimensions
    #anim = @animate for t in 1:time
    #gif = @gif for t in 1:time
    for t in 1:time
        newmatrix = copy(matrix)
        for i in 1:n, j in 1:m # check neighbor sum
            site = newmatrix[i,j]
            neighbors = getNeighbors(i,j,matrix)
            n_sum = sum(neighbors)
            newmatrix[i,j] = condition(site,n_sum)
        end
        matrix = newmatrix
        heatmap!(matrix, legend=:none, framestyle=:none, background_color=:transparent, c=colors, display=true)
    end
    #file = "gameOfLife_t=$time.gif"
    #gif(anim,file,fps=30)
end

##### MAIN #####

# System
n = 64
m = 64
#system = rand([0,1],(n,m))
#system[1,:] .= 1
#system[n,:] .= 1
#system[:,1] .= 1
#system[:,m] .= 1
system = setup(n,m)
# Colors for heatmap
colors = cgrad([colorant"black",colorant"ivory"])
# Evolution
evolve!(system,50)
