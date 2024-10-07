using Plots, Random

# SYSTEM

"""
0 -> white
1 -> black
"""

# System structure
@kwdef struct System{T}
    grid::Matrix{T}  # Cellular automata's grid
    ant::Vector{Int}  # Ant's position and direction
    directions::Dict
end
# System constructor
function System{T}(x::Int, y::Int) where T
    ant = [rand(1:x), rand(1:y), rand(0:3)]  # Randomly initialize the ant's position and direction
    matrix = zeros(T, x, y)  # Initialize the grid
    dict = Dict(
        0 => (0,1), # up
        1 => (1,0), # right
        2 => (0,-1), # down
        3 => (-1,0) # left
        )
    System(grid=matrix, ant=ant, directions=dict)
end

# EVOLUTION

#function boundary!(system::System)

function step!(system::System)
    # Variables
    length, height = size(system.grid)
    x, y, dir = system.ant
    # Change direction
    if system.grid[x,y] == 0 # white -> clockwise
        dir = (dir + 1) % 4
    else # black -> counter-clockwise
        dir = (dir + 3) % 4 # adds 3 to avoid negative indices: (dir - 1 + 4) % 4
    end
    # Change tile
    system.grid[x,y] = abs(system.grid[x,y]-1) # 0->1, 1->0
    # Move
    dx, dy = system.directions[dir] # increment
    x += dx
    y += dy
    # Periodic boundary conditions:
    ## The modulus operator uses x-1 and y-1 to account for Julia's 1-indexing
    ## After taking the remainder, adds length or height to ensure the indices are positive
    ## Takes the remainder again, with positive indices
    ## Adds 1 to restore 1-indexing
    system.ant[1] = ((x-1) % length + length) % length + 1
    system.ant[2] = ((y-1) % height + height) % height + 1
    system.ant[3] = dir
end

function animate!(sys::System)
    color_map = cgrad([:white, :black, :red], [0, 1, 2])
    data = copy(sys.grid) # if copy not taken, the grid will receive wrong values
    data[sys.ant[1],sys.ant[2]] = 2 # paints red where ant is
    heatmap(transpose(data),color=color_map,colorbar=false,display=true)
end


##### MAIN #####

function main()
    n = 50
    m = 50
    sys = System{Int64}(n,m)
    for i in 1:500
        animate!(sys)
        step!(sys)
        sleep(.01)
    end
end

main()